################################################################################
# File version information:
# $Id: check_updates.spec 1126 2010-02-16 20:06:11Z corti $
# $Revision: 1126 $
# $HeadURL: https://svn.id.ethz.ch/nagios_plugins/check_updates/check_updates.spec $
# $Date: 2010-02-16 21:06:11 +0100 (Tue, 16 Feb 2010) $
################################################################################

%define version 1.4.3
%define release 0
%define name    check_ssl_cert
%define nagiospluginsdir %{_libdir}/nagios/plugins

# No binaries in this package
%define debug_package %{nil}

Summary:   A Nagios plugin to check X.509 certificates
Name:      %{name}
Version:   %{version}
Release:   %{release}%{?dist}
License:   GPLv3+
Packager:  Matteo Corti <matteo.corti@id.ethz.ch>
Group:     Applications/System
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
URL:       https://trac.id.ethz.ch/projects/nagios_plugins/wiki/check_ssl_cert
Source:    https://trac.id.ethz.ch/projects/nagios_plugins/downloads/%{name}-%{version}.tar.gz

Requires:  nagios-plugins

%description
Checks an X.509 certificate:
 - checks if the server is running and delivers a valid certificate
 - checks if the CA matches a given pattern
 - checks the validity

%prep
%setup -q

%build

%install
make DESTDIR=$RPM_BUILD_ROOT%{nagiospluginsdir} install

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-, root, root, 0644)
%doc AUTHORS ChangeLog NEWS README INSTALL TODO COPYING VERSION
%attr(0755, root, root) %{nagiospluginsdir}/check_ssl_cert

%changelog
* Tue Mar  9 2010 Matteo Corti <matteo.corti@id.ethz.ch> - 1.4.3-0
- updated to 1.4.3 (-n and -N options)

* Wed Dec  2 2009 Matteo Corti <matteo.corti@id.ethz.ch> - 1.4.2-0
- updated to 1.4.2

* Mon Nov 30 2009 Matteo Corti <matteo.corti@id.ethz.ch> - 1.4.1-0
- updated to 1.4.1 (-r option)

* Mon Nov 30 2009 Matteo Corti <matteo.corti@id.ethz.ch> - 1.4.0-0
- Updated to 1.4.0: verify the certificate chain

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

