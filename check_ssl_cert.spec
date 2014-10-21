################################################################################
# File version information:
# $Id: check_updates.spec 1126 2010-02-16 20:06:11Z corti $
# $Revision: 1126 $
# $HeadURL: https://svn.id.ethz.ch/nagios_plugins/check_updates/check_updates.spec $
# $Date: 2010-02-16 21:06:11 +0100 (Tue, 16 Feb 2010) $
################################################################################

%define version          1.17.0
%define release          0
%define sourcename       check_ssl_cert
%define packagename      nagios-plugins-check_ssl_cert
%define nagiospluginsdir %{_libdir}/nagios/plugins

# No binaries in this package
%define debug_package %{nil}

Summary:   A Nagios plugin to check X.509 certificates
Name:      %{packagename}
Version:   %{version}
Obsoletes: check_ssl_cert
Release:   %{release}%{?dist}
License:   GPLv3+
Packager:  Matteo Corti <matteo.corti@id.ethz.ch>
Group:     Applications/System
BuildRoot: %{_tmppath}/%{packagename}-%{version}-%{release}-root-%(%{__id_u} -n)
URL:       https://trac.id.ethz.ch/projects/nagios_plugins/wiki/check_ssl_cert
Source:    https://trac.id.ethz.ch/projects/nagios_plugins/downloads/%{sourcename}-%{version}.tar.gz

Requires:  nagios-plugins expect perl(Date::Parse)

%description
Checks an X.509 certificate:
 - checks if the server is running and delivers a valid certificate
 - checks if the CA matches a given pattern
 - checks the validity

%prep
%setup -q -n %{sourcename}-%{version}

%build

%install
make DESTDIR=${RPM_BUILD_ROOT}%{nagiospluginsdir} MANDIR=${RPM_BUILD_ROOT}%{_mandir} install

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%doc AUTHORS ChangeLog NEWS README INSTALL TODO COPYING VERSION COPYRIGHT
%attr(0755, root, root) %{nagiospluginsdir}/check_ssl_cert
%{_mandir}/man1/%{sourcename}.1*

%changelog
* Tue Oct 21 2014 Matteo Corti <matteo@corti.li> - 1.17.0-0
- Updated to 1.17.0

* Fri Jun  6 2014 Matteo Corti <matteo.corti@id.ethz.ch> - 1.16.2-0
- updated to 1.16.2

* Thu May 22 2014 Andreas Dijkman <andreas.dijkman@cygnis.nl> - 1.16.1-1
- Added noarch as buildarch
- Added expect and perl(Date::Parse) dependency

* Fri Feb 28 2014 Matteo Corti <matteo.corti@id.ethz.ch> - 1.16.1-0
- Updated to 1.16.1 (rpm make target)

* Mon Dec 23 2013 Matteo Corti <matteo.corti@id.ethz.ch> - 1.16.0-0
- Udated to 1.16.0 (force TLS)

* Mon Jul 29 2013 Matteo Corti <matteo.corti@id.ethz.ch> - 1.15.0-0
- Updated to 1.15.0 (force SSL version)

* Sun May 12 2013 Matteo Corti <matteo.corti@id.ethz.ch> - 1.14.6-0
- Updated to 1.16.6 (timeout and XMPP support)

* Sat Mar  2 2013 Matteo Corti <matteo.corti@id.ethz.ch> - 1.14.5-0
- Updated to 1.14.5 (TLS and multiple names fix)

* Fri Dec  7 2012 Matteo Corti <matteo.corti@id.ethz.ch> - 1.14.4-0
- Updated to 1.14.4 (bug fix release)

* Wed Sep 19 2012 Matteo Corti <matteo.corti@id.ethz.ch> - 1.14.3-0
- Updated to 1.14.3

* Fri Jul 13 2012 Matteo Corti <matteo.corti@id.ethz.ch> - 1.14.2-0
- Updated to 1.14.2

* Wed Jul 11 2012 Matteo Corti <matteo.corti@id.ethz.ch> - 1.14.1-0
- Updated to 1.14.1

* Fri Jul  6 2012 Matteo Corti <matteo.corti@id.ethz.ch> - 1.14.0-0
- updated to 1.14.0

* Thu Apr  5 2012 Matteo Corti <matteo.corti@id.ethz.ch> - 1.13.0-0
- updated to 1.13.0

* Wed Apr  4 2012 Matteo Corti <matteo.corti@id.ethz.ch> - 1.12.0-0
- updated to 1.12.0 (bug fix release)

* Sat Oct 22 2011 Matteo Corti <matteo.corti@id.ethz.ch> - 1.11.0-0
- ipdated to 1.10.1 (--altnames option)

* Thu Sep  1 2011 Matteo Corti <matteo.corti@id.ethz.ch> - 1.10.0-0
- apllied patch from Sven Nierlein for client certificate authentication

* Thu Mar 10 2011 Matteo Corti <matteo.corti@id.ethz.ch> - 1.9.1-0
- updated to 1.9.1: allows http as protocol and fixes -N with wildcards

* Mon Jan 24 2011 Matteo Corti <matteo.corti@id.ethz.ch> - 1.9.0-0
- updated to 1.9.0: --openssl option

* Thu Dec 16 2010 Dan Wallis - 1.8.1-0
- Fixed bugs with environment bleeding & shell globbing

* Thu Dec  9 2010 Matteo Corti <matteo.corti@id.ethz.ch> - 1.8.0-0
- added support for TLS servername extension

* Thu Oct 28 2010 Matteo Corti <matteo.corti@id.ethz.ch> - 1.7.7-0
- Fixed a bug in the signal specification

* Thu Oct 28 2010 Matteo Corti <matteo.corti@id.ethz.ch> - 1.7.6-0
- better temporary file clean up

* Thu Oct 14 2010 Matteo Corti <matteo.corti@id.ethz.ch> - 1.7.5-0
- updated to 1.7.5 (fixed the check order)

* Fri Oct  1 2010 Matteo Corti <matteo.corti@id.ethz.ch> - 1.7.4-0
- added -A command line option

* Wed Sep 15 2010 Matteo Corti <matteo.corti@id.ethz.ch> - 1.7.3-0
- Fixed a bug in the command line options processing

* Thu Aug 26 2010 Dan Wallis - 1.7.2-0
- updated to 1.7.2 (cat and expect fixes)

* Thu Aug 26 2010 Dan Wallis - 1.7.1-0
- updated to 1.7.1 ("-verify 6" revert)

* Thu Aug 26 2010 Dan Wallis - 1.7.0-0

* Wed Jul 21 2010 Matteo Corti <matteo.corti@id.ethz.ch> - 1.6.1-0
- updated to 1.6.0 (--temp option)

* Fri Jul  9 2010 Matteo Corti <matteo.corti@id.ethz.ch> - 1.6.0-0
- updated to version 1.6.0 (long options, --critical and --warning, man page)

* Wed Jul  7 2010 Matteo Corti <matteo.corti@id.ethz.ch> - 1.5.2-0
- updated to version 1.5.2 (Wolfgang Schricker patch, see ChangeLog)

* Thu Jul  1 2010 Matteo Corti <matteo.corti@id.ethz.ch> - 1.5.1-0
- updated to version 1.5.1 (Yannick Gravel patch, see ChangeLog)

* Tue Jun  8 2010 Matteo Corti <matteo.corti@id.ethz.ch> - 1.5.0-0
- updated to version 1.5.0 (-s option to allow self signed certificates)

* Thu Mar 11 2010 Matteo Corti <matteo.corti@id.ethz.ch> - 1.4.4-0
- updated to 1.4.4 (bug fix release)

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
- first RPM package

