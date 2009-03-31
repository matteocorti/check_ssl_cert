%define version 1.3.0
%define release 0
%define name    check_ssl_cert
%define _prefix /usr/lib/nagios/plugins/contrib

Summary:   A Nagios plugin to check X.509 certificates
Name:      %{name}
Version:   %{version}
Release:   %{release}
License:   GPL
Packager:  Matteo Corti <matteo.corti@id.ethz.ch>
Group:     Applications/System
BuildRoot: %{_tmppath}/%{name}-%{version}-root
Source:    http://www.id.ethz.ch/people/allid_list/corti/%{name}-%{version}.tar.gz
BuildArch: noarch

Requires: hddtemp
Requires: perl

%description
Checks an X.509 certificate:
 - checks if the server is running and delivers a valid certificate
 - checks if the CA matches a given pattern
 - checks the validity

%prep
%setup -q

%build

%install
make DESTDIR=$RPM_BUILD_ROOT%{_prefix} install

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-, root, root, 0644)
%doc AUTHORS ChangeLog NEWS README INSTALL TODO COPYING VERSION
%attr(0755, root, root) %{_prefix}/check_ssl_cert

%changelog
* Mon Mar 30 2009 Matteo Corti <matteo.corti@id.ethz.ch> - 1.3.0-0
- Tuomas Haarala patch: -P option

* Tue May 13 2008 Matteo Corti <matteo.corti@id.ethz.ch> - 1.2.2-0
- Dan Wallis patch to include the CN in the messages

* Mon Feb 25 2008 Matteo Corti <matteo.corti@id.ethz.ch> - 1.2.1-0
- Dan Wallis patches (error checking, see ChangeLog)

* Mon Feb 25 2008 Matteo Corti <matteo.corti@id.ethz.ch> - 1.2.0-0
- Dan Wallis patches (see the ChangeLog)

* Mon Sep 24 2007 Matteo Corti <matteo.corti@id.ethz.ch> - 1.1.0-0
- first rpm package

