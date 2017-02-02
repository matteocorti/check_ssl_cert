%define version          1.38.2
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
Packager:  Matteo Corti <matteo@corti.li>
Group:     Applications/System
BuildRoot: %{_tmppath}/%{packagename}-%{version}-%{release}-root-%(%{__id_u} -n)
URL:       https://github.com/matteocorti/check_ssl_cert
Source:    https://github.com/matteocorti/check_ssl_cert/releases/download/v%{version}/check_ssl_cert-%{version}.tar.gz

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
%doc AUTHORS ChangeLog NEWS README.md TODO COPYING VERSION COPYRIGHT
%attr(0755, root, root) %{nagiospluginsdir}/check_ssl_cert
%{_mandir}/man1/%{sourcename}.1*

%changelog
* Thu Feb  2 2017 Matteo Corti <matteo@corti.li> - 1.38.2-0
- Updated to 1.38.2

* Sun Jan 29 2017 Matteo Corti <matteo@corti.li> - 1.38.1-0
- Updated to 1.38.1

* Sat Jan 28 2017 Matteo Corti <matteo@corti.li> - 1.38.0-0
- Updated to 1.38.0

* Fri Dec 23 2016 Matteo Corti <matteo@corti.li> - 1.37.0-0
- Updated to 1.37.0

* Tue Dec 13 2016 Matteo Corti <matteo@corti.li> - 1.36.2-0
- Updated to 1.36.2

* Tue Dec 06 2016 Matteo Corti <matteo@corti.li> - 1.36.1-0
- Updated to 1.36.1

* Sun Dec 04 2016 Matteo Corti <matteo@corti.li> - 1.36.0-0
- Updated to 1.36.0

* Tue Oct 18 2016 Matteo Corti <matteo@corti.li> - 1.35.0-0
- Updated to 1.35.0

* Mon Sep 19 2016 Matteo Corti <matteo@corti.li> - 1.34.0-0
- Updated to 1.34.0

* Thu Aug  4 2016 Matteo Corti <matteo@corti.li> - 1.33.0-0
- Updated to 1.33.0

* Fri Jul 29 2016 Matteo Corti <matteo@corti.li> - 1.32.0-0
- Updated to 1.32.0

* Tue Jul 12 2016 Matteo Corti <matteo@corti.li> - 1.31.0-0
- Updated to 1.31.0

* Thu Jun 30 2016 Matteo Corti <matteo@corti.li> - 1.30.0-0
- Updated to 1.30.0

* Wed Jun 15 2016 Matteo Corti <matteo@corti.li> - 1.29.0-0
- Updated to 1.29.0

* Wed Jun 01 2016 Matteo Corti <matteo@corti.li> - 1.28.0-0
- Updated to 1.28.0

* Wed Apr 27 2016 Matteo Corti <matteo@corti.li> - 1.27.0-0
- Updated to 1.27.0

* Tue Mar 29 2016 Matteo Corti <matteo@corti.li> - 1.26.0-0
- Updated to 1.26.0

* Mon Mar 21 2016 Matteo Corti <matteo@corti.li> - 1.25.0-0
- Updated to 1.25.0

* Wed Mar  9 2016 Matteo Corti <matteo@corti.li> - 1.24.0-0
- Updated to 1.24.0

* Mon Mar  7 2016 Matteo Corti <matteo@corti.li> - 1.23.0-0
- Updated to 1.23.0

* Thu Mar  3 2016 Matteo Corti <matteo@corti.li> - 1.22.0-0
- Updated to 1.22.0

* Tue Mar  1 2016 Matteo Corti <matteo@corti.li> - 1.21.0-0
- Updated to 1.21.0

* Fri Feb 26 2016 Matteo Corti <matteo@corti.li> - 1.20.0-0
- Updated to 1.20.0

* Thu Feb 25 2016 Matteo Corti <matteo@corti.li> - 1.19.0-0
- Updated to 1.19.0

* Sat Oct 31 2015 Matteo Corti <matteo@corti.li> - 1.18.0-0
- Updated to 1.18.0

* Tue Oct 20 2015 Matteo Corti <matteo@corti.li> - 1.17.2-0
- Updated to 1.17.2

* Tue Apr  7 2015 Matteo Corti <matteo@corti.li> - 1.17.1-0
- Updated to 1.17.1

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

