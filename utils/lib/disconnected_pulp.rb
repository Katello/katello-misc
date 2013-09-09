#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
# Manifest representation in Ruby
#

require 'runcible'
require 'uri'

# This class provides business logic for katello-disconnected CLI tool.
# Individual methods represent cli actions (verbs). This class communicates
# with Pulp using Runcible rubygem, therefore Runcible must be configured.
#
class DisconnectedPulp
  attr_accessor :active_manifest, :manifest

  def initialize(active_manifest, options, log, runcible)
    @active_manifest = active_manifest
    @manifest = active_manifest.manifest
    @options = options
    @log = log
    @runcible = runcible
  end

  def LOG; @log; end

  def dry_run(&block)
    block.call unless @options[:dry_run]
  end

  def list(disabled = false)
    if disabled
      puts manifest.repositories.values.collect {|r| r.repoid }.sort
    else
      puts manifest.enabled_repositories
    end
  end

  def clean
    @runcible.resources.repository.retrieve_all.each do |repo|
      LOG.verbose _("Removing repo %s") % repo['id']
      dry_run do
        @runcible.resources.repository.delete repo['id']
      end
    end
  end

  def enable(value, repoids = nil, all = nil)
    if repoids
      repoids = repoids.split(/,\s*/).collect(&:strip)
    else
      if all
        repoids = manifest.repositories.keys
      else
        LOG.error _('You need to provide some repoids')
        return
      end
    end
    repoids.each do |repoid|
      LOG.verbose _("Setting enabled flag to %{value} for %{repoid}") % {:value => value, :repoid => repoid}
      manifest.enable_repository repoid, value
    end
    active_manifest.save_repo_conf
  end
  
  def puppet_queries(repoid, queries)
    LOG.debug ("updating repo: #{repoid} with queries: #{queries}")
    repo = @runcible.extensions.repository.retrieve_with_details(repoid)
    config = {"importer_config" => {"queries" => [queries]}}
    @runcible.resources.repository.update_importer repoid, "puppet_importer", config
    LOG.debug _("repo updated")
  end

  def configure(remove_disabled = false, puppet = false, puppet_forge_url, puppet_forge_id)
    active_repos = manifest.repositories
    mfrepos = manifest.enabled_repositories
    purepos = @runcible.resources.repository.retrieve_all.collect { |m| m['id'] }
    repos_to_be_added = mfrepos - purepos
    repos_to_be_removed = purepos - mfrepos
    LOG.debug _("Enabled repos: %s") % mfrepos.inspect
    LOG.debug _("Pulp repos: %s") % purepos.inspect
    LOG.debug _("To be added: %s") % repos_to_be_added.inspect
    # remove extra repos
    if remove_disabled and repos_to_be_removed.size > 0
      LOG.debug _("To be removed: %s") % repos_to_be_removed.inspect
      repos_to_be_removed.each do |repoid|
        LOG.verbose _("Removing repo %s") % repoid
        dry_run do
          @runcible.resources.repository.delete repoid
        end
      end
    end
    # add new repos
    repos_to_be_added.each do |repoid|
      LOG.verbose _("Creating repo %s") % repoid
      dry_run do
        repo = active_repos[repoid]
        relative_url = URI.split(repo.url)[5]

        # Yum, ISO and Export
        distributors = [Runcible::Models::YumDistributor.new(relative_url, true, false, {:id => 'yum_distributor'}),
            Runcible::Models::ExportDistributor.new(true, false)]
  
        yum_importer = Runcible::Models::YumImporter.new
        yum_importer.feed = repo.url
        yum_importer.ssl_ca_cert = manifest.read_cdn_ca
        yum_importer.ssl_client_cert = repo.cert
        yum_importer.ssl_client_key = repo.key
        @runcible.extensions.repository.create_with_importer_and_distributors(repoid, yum_importer, distributors)
      end
    end
    
    # enable or disable the puppet forge repo
    if puppet and not purepos.include?(puppet_forge_id)
      LOG.debug _("Adding Puppet Forge repo")
      puppet_importer = Runcible::Models::PuppetImporter.new({"feed" => "http://forge.puppetlabs.com"})
      puppet_distributors = [Runcible::Models::PuppetDistributor.new('/', true, false, :id => "puppet_distirubtor"), 
                             Runcible::Models::ExportDistributor.new(true, false)]
      @runcible.extensions.repository.create_with_importer_and_distributors(puppet_forge_id, puppet_importer, puppet_distributors)
      LOG.debug _("Done adding Puppet Forge repo")
    elsif not puppet
       LOG.debug _("Deleting Puppet Forge repo")
       @runcible.resources.repository.delete puppet_forge_id rescue RestClient::ResourceNotFound
       LOG.debug _("Deleted Puppet Forge repo")
    end

  end

  def synchronize(repoids = nil)
    if repoids
      repoids = repoids.split(/,\s*/).collect(&:strip)
    else
      repoids = @runcible.resources.repository.retrieve_all.collect{|r| r['id']}
    end
    repoids.each do |repoid|
      begin
        LOG.verbose _("Synchronizing repo %s") % repoid
        dry_run do
          @runcible.resources.repository.sync repoid
        end
      rescue RestClient::ResourceNotFound => e
        LOG.error _("Repo %s not found, skipping") % repoid
      end
    end
  end

  def watch(delay_time = nil, repoids = nil, once = nil, watch_type = :sync_status)
    if delay_time.nil?
      delay_time = 10
    else
      delay_time = delay_time.to_i rescue 1
      delay_time = 1 if delay_time < 1
    end
    if repoids
      repoids = repoids.split(/,\s*/).collect(&:strip)
    else
      repoids = @runcible.resources.repository.retrieve_all.collect{|r| r['id']}
    end
    puts _('Watching sync... (this may be safely interrupted with Ctrl+C)')
    finished_repoids = {}
    running = true
    while running
      statuses = {}
      begin
        repoids.each do |repoid|
          begin
            # skip if this repo was already finished
            next if finished_repoids[repoid]
            if watch_type == :sync_status
              status = @runcible.extensions.repository.sync_status repoid
            elsif watch_type == :publish_status
              status = @runcible.extensions.repository.publish_status repoid
            else
              LOG.fatal _("Unknown watch_type: %s") % watch_type
              raise _("Unknown watch_type: %s") % watch_type
            end
            state = status[0]['state'] || 'unknown' rescue 'unknown'
            items_left = status[0]['progress']['yum_importer']['content']['items_left'] rescue 'unknown'
            exception = status[0]['exception'] || '' rescue ''
            statuses[state] = [] if statuses[state].nil?
            statuses[state] << [repoid, exception, items_left] if not repoid.nil?
            # remove finished repos
            finished_repoids[repoid] = true if state == 'finished' or state == 'unknown'
          rescue RestClient::ResourceNotFound => e
            LOG.fatal _("Repo %s not found") % repoid
          rescue SignalException => e
            raise e
          rescue Exception => e
            LOG.error _("Error while getting status for %{repoid}: %{msg}") % {:repoid => repoid, :msg => e.message}
          end
        end
        statuses.keys.sort.each do |state|
          puts "State: #{state}:"
          statuses[state].each do |pair|
            puts "  repo: [#{pair[0]}] packages remaining: [#{pair[2]}]"
            puts "    error: #{pair[1]}" unless pair[1].empty?
          end
        end
        puts "\n"
        running = false if once or statuses.count == 0
        sleep delay_time
      rescue SignalException => e
        puts "\n" + _('Watching stopped, the following repos have finished:')
        finished_repoids.keys.sort.each { |repoid| puts repoid }
        running = false
      end
    end
    puts _('Watching finished')
  end

  def export(target_basedir = nil, repoids = nil, overwrite = false, onlycreate = false, 
             onlyexport = false, start_date=nil, end_date=nil)
    LOG.fatal _('Please provide target directory, see --help') if target_basedir.nil?
    overwrite = false if overwrite.nil?
    onlycreate = false if onlycreate.nil?

    # active_repos = manifest.repositories
    all_repos = @runcible.resources.repository.retrieve_all(:optional => {:details => true})
    active_repos = {}
    all_repos.each do |r| 
      active_repos[r[:id]] = @runcible.extensions.repository.retrieve_with_details(r[:id])
    end
    if repoids
      repoids = repoids.split(/,\s*/).collect(&:strip)
    else
      repoids = all_repos.collect{|r| r[:id]}
    end
    
    # create directory structure
    repoids.each do |repoid|
      repo = active_repos[repoid]
      relative_url = get_relative_url(repo)
      target_dir = File.join(target_basedir, relative_url)
      if not onlyexport
        LOG.verbose "Creating #{target_dir}"
        FileUtils.mkdir_p target_dir
      end
    end
    # create listing files
    Find.find(target_basedir) do |path|
      if FileTest.directory? path
        File.open(File.join(path, 'listing'), 'w') do |file|
          Dir[File.join(path, '*/')].each do |dir|
            file.write(File.basename(dir) + "\n")
          end
        end
      end
    end
    # change owner to apache
    begin
      FileUtils.chown_R 'apache', 'apache', target_basedir
    rescue Errno::EPERM => e
      LOG.error _("Cannot chown to 'apache' - %s") % e.message
    end

    # check if we are using start/end dates
    start_end_options = {}
    unless start_date.nil? and end_date.nil?
      start_end_options = {:start_date => start.date, :end_date => end_date}
    end
    
    # initiate export
    repoids.each do |repoid|
      # repo = active_repos[repoid]
      repo = active_repos[repoid]
      relative_url = get_relative_url(repo)
      target_dir = File.join(target_basedir, relative_url)
      begin
        if not onlycreate
          LOG.verbose _("Exporting repo %s") % repoid
          dry_run do
            distributors = repo['distributors']
            distributors.each do |d|
              pulp_task = @runcible.resources.repository.publish repoid, d['id'], start_end_options
            end
            # 
          end
        end
      rescue RestClient::ResourceNotFound => e
        LOG.error _("Repo %s not found, skipping") % repoid
      end
    end

    # wait for repos to finish publishing
    puts _("Waiting for repos to finish publishing")
    self.watch(10, repoids.join(','), false, watch_type = :publish_status)
    puts _("Done watching ...")

    # combine pulp exported repos and the listing files into one tree
    puts _(" Copying content to #{target_basedir}")
    cmd = "rsync -aL /var/lib/pulp/published/http/repos/ #{target_basedir}"
    cmd = "rsync -aL /var/www/pulp_puppet/http/repos #{target_basedir}"
    exitcode = system(cmd)
    # split the export into DVD sized chunks
    puts _(" Archiving contents of #{target_basedir} into 4600M tar archives.")
    puts _(" NOTE: This may take a while.")
    cmd = "tar czpf - #{target_basedir} | split -d -b 4600M - #{target_basedir}/content-export-"
    exitcode = system(cmd)
    # Write out simple script to expand split up archives
    unsplit_script = "#!/bin/bash\n\n"\
                     "cat content-export-* | tar xzpf -\n\n"\
                     "echo \"*** Done expanding archives. ***\"\n"
    # puts unsplit_script
    f = File.open("#{target_basedir}/expand_export.sh", 'w') 
    f.write(unsplit_script)
    f.chmod(0755)
    # Clean up dir trees
    FileUtils.rm_rf("#{target_basedir}/content")
    FileUtils.rm("#{target_basedir}/listing")
    puts ""
    puts _("Done exporting content, please copy #{target_basedir}/* to your disconnected host")
    puts ""
  end
  
private
  
  def get_relative_url(repo)
    # Find the yum_distributor so we can get the basedir
    repo_path = nil
    repo['distributors'].each do |d|
      repo_path = d['config']['relative_url'] if d['id'] == 'yum_distributor'
    end
    # if not found default to / 
    repo_path = '/' unless not repo_path.nil?
    repo_path
  end
  
end
