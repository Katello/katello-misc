
Name:           katello-repos
Version:        2.2.0
Release:        2%{?dist}
Summary:        Definition of yum repositories for Katello

Group:          Applications/Internet
License:        GPLv2
URL:            http://www.katello.org
Source0:        https://fedorahosted.org/releases/k/a/katello/%{name}-%{version}.tar.gz

BuildArch:      noarch
Provides:       katello-repos-testing = 0.2.7
Obsoletes:      katello-repos-testing < 0.2.7

%description
Defines yum repositories for Katello and its sub projects, Candlepin and Pulp.

%prep
%setup -q

%build

%install
#prepare dir structure
install -d -m 0755 %{buildroot}%{_sysconfdir}/yum.repos.d
install -d -m 0755 %{buildroot}%{_sysconfdir}/pki/rpm-gpg/
# some sane default value
%define reposubdir      RHEL
# redefine on fedora
%{?fedora: %define reposubdir      Fedora}

for repofile in *.repo; do
    sed -i 's/@SUBDIR@/%{reposubdir}/' $repofile
done
 
install -m 644 katello.repo %{buildroot}%{_sysconfdir}/yum.repos.d/
install -m 644 RPM-GPG-KEY-katello-2012 %{buildroot}%{_sysconfdir}/pki/rpm-gpg/RPM-GPG-KEY-katello

%files
%{_sysconfdir}/yum.repos.d/*.repo
%{_sysconfdir}/pki/rpm-gpg/RPM-GPG-KEY-katello

%changelog
* Tue Feb 24 2015 Eric D. Helms <ericdhelms@gmail.com>
- Update repo name to nightly for Katello. (ericdhelms@gmail.com)
- fixing repo urls to match new format (jsherril@redhat.com)
- fixes #7959 - use https for yum repos and local gpg key (jsherril@redhat.com)
- fixes #7739 - combine three katello repo files into one (jsherril@redhat.com)

* Fri Dec 19 2014 David Davis <daviddavis@redhat.com> 2.2.0-1
- Merge pull request #39 from ehelms/fixes-7442 (eric.d.helms@gmail.com)
- Fixes #7442: Change repo structure to group by version and project.
  (ericdhelms@gmail.com)

* Fri Sep 12 2014 Justin Sherrill <jsherril@redhat.com> 2.1.0-1
- removing katello-foreman repo (mmccune@redhat.com)

* Fri Oct 11 2013 Partha Aji <paji@redhat.com> 1.5.1-1
- Bumping package versions for 1.5 (paji@redhat.com)

* Sat Apr 27 2013 Justin Sherrill <jsherril@redhat.com> 1.4.2-1
- Add 'repos/' from commit 'b3df18719d52a3a21ac88709d9d5a70e5f9be796'
  (jsherril@redhat.com)

* Fri Apr 12 2013 Justin Sherrill <jsherril@redhat.com> 1.4.1-1
- version bump to 1.4 (jsherril@redhat.com)

* Fri Apr 12 2013 Justin Sherrill <jsherril@redhat.com> 1.3.3-1
- remove old changelog entries (msuchy@redhat.com)

* Tue Dec 18 2012 Miroslav Suchý <msuchy@redhat.com> 1.3.2-1
- rebuild 

* Thu Dec 06 2012 Eric D Helms <ehelms@redhat.com> 1.3.1-1
- Bumping package versions for 1.3. (ehelms@redhat.com)

* Thu Dec 06 2012 Eric D Helms <ehelms@redhat.com> 1.2.2-1
- Do not skip our repo (msuchy@redhat.com)

* Mon Oct 15 2012 Lukas Zapletal <lzap+git@redhat.com> 1.2.1-1
- Bumping package versions for 1.1.

* Mon Aug 20 2012 Miroslav Suchý <msuchy@redhat.com> 1.1.2-1
- replace SUBDIR also in katello-foreman.repo (msuchy@redhat.com)
- add katello-foreman.repo (msuchy@redhat.com)

* Fri Aug 03 2012 Miroslav Suchý <msuchy@redhat.com> 1.1.1-1
- use Katello gpg key (msuchy@redhat.com)
- fedora-pulp.repo is not used any more (msuchy@redhat.com)
- Bumping package versions for 1.1. (msuchy@redhat.com)

* Tue Jul 31 2012 Miroslav Suchý <msuchy@redhat.com> 1.0.1-1
- bump up version to 1.0 (msuchy@redhat.com)

* Mon Jul 30 2012 Miroslav Suchý <msuchy@redhat.com> 0.2.10-1
- fix typo caused by copy'n'paste' (msuchy@redhat.com)

* Sun Jul 29 2012 Miroslav Suchý <msuchy@redhat.com> 0.2.9-1
- fixing urls so they don't throw a 404 (adprice@redhat.com)
- point Source0 to fedorahosted.org where tar.gz are stored (msuchy@redhat.com)

* Fri Jul 27 2012 Miroslav Suchý <msuchy@redhat.com> 0.2.8-1
- fix typo in repo files (msuchy@redhat.com)

* Thu Jul 26 2012 Miroslav Suchý <msuchy@redhat.com> 0.2.7-1
- refactor katello-repos (msuchy@redhat.com)

* Tue Jul 17 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.6-1
- temporarily disabling pulp testing repo
- %%defattr is not needed since rpm 4.4

* Mon Jul 16 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.5-1
- correcting pulp testing URL in the repofile

* Thu May 10 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.4-1
- putting releasever instead of 6Server

* Thu May 10 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.3-1
- repos - testing rpm now has katello testing repo file
- repos - fixing name of katello repos

* Fri Apr 27 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.2-1
- correcting pulp testing repofile url
