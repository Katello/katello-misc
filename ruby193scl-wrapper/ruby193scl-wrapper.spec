%{!?scl:%global pkg_name %{name}}
%{?scl:%scl_package wrapper}

Name:		ruby193scl-wrapper
Version:	1.2
Release:	1%{?dist}
Summary:	Wrapper for ruby193 Software Collection

Group:		Applications/System
License:	GPLv2
URL:		https://fedorahosted.org/katello
Source0:	https://fedorahosted.org/releases/k/a/katello/%{name}-%{version}.tar.gz
BuildArch:  noarch

Requires:	%{name}-ruby %{name}-rake
BuildRequires: asciidoc
BuildRequires: libxslt
BuildRequires: util-linux

%description
Contains wrappers for ruby193 Software Collection, which e.g. allows you write
ruby193-ruby foo
instead of
scl enable ruby193 "ruby foo"


%package ruby
BuildArch:	noarch
Summary:	Ruby wrapper for ruby193 Software Collection
Requires:	scl-utils
Requires:	ruby193-ruby

%description ruby
Contains ruby wrapper for ruby193 Software Collection, which allows you write
ruby193-ruby foo
instead of
scl enable ruby193 "ruby foo"

%package rake
BuildArch:	noarch
Summary:	Rake wrapper for ruby193 Software Collection
Requires:	scl-utils
Requires:	ruby193-rubygem-rake

%description rake
Contains rake wrapper for ruby193 Software Collection, which allows you write
ruby193-rake foo
instead of
scl enable ruby193 "rake foo"

%prep
%setup -q


%build
# convert manages
a2x -d manpage -f manpage ruby193-rake.1.asciidoc
a2x -d manpage -f manpage ruby193-ruby.1.asciidoc

%install
install -d %{buildroot}%{_root_mandir}/man1
install -d -m0755 %{buildroot}%{_root_bindir}
install -m 755 ruby193-rake ruby193-ruby %{buildroot}%{_root_bindir}
install -m 644 ruby193-ruby.1 ruby193-rake.1 %{buildroot}/%{_root_mandir}/man1/

%files
%doc LICENSE

%files ruby
%{_root_bindir}/ruby193-ruby
%doc %{_root_mandir}/man1/ruby193-ruby.1*

%files rake
%{_root_bindir}/ruby193-rake
%doc %{_root_mandir}/man1/ruby193-rake.1*


%changelog
* Tue May 28 2013 Miroslav Suchý <msuchy@redhat.com> 1.2-1
- add util-linux as buildrequires (msuchy@redhat.com)
- create new package ruby193scl-wrapper (msuchy@redhat.com)

* Fri May 24 2013 Miroslav Suchý <msuchy@redhat.com> 1.1-1
- new package built with tito


