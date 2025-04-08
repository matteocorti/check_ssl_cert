%global version          2.92.0
%global release          0
%global sourcename       check_ssl_cert
%global packagename      nagios-plugins-check_ssl_cert
%global nagiospluginsdir %{_libdir}/nagios/plugins

# No binaries in this package
%global debug_package %{nil}

%global completions_dir %( pkg-config --variable=completionsdir bash-completion )

Summary:   A Nagios plugin to check X.509 certificates
Name:      %{packagename}
Version:   %{version}
# any version
Obsoletes: check_ssl_cert <= 100
Release:   %{release}%{?dist}
License:   GPLv3+
Packager:  Matteo Corti <matteo@corti.li>
Group:     Applications/System
BuildRoot: %{_tmppath}/%{packagename}-%{version}-%{release}-root-%(%{__id_u} -n)
URL:       https://github.com/matteocorti/check_ssl_cert
Source:    https://github.com/matteocorti/check_ssl_cert/releases/download/v%{version}/check_ssl_cert-%{version}.tar.gz

Requires:  nagios-plugins expect perl(Date::Parse) bc curl openssl file

%description
A shell script (that can be used as a Nagios plugin) to check an SSL/TLS connection

%prep
%setup -q -n %{sourcename}-%{version}

%build


%install

%if "%{completions_dir}"
make DESTDIR=${RPM_BUILD_ROOT}%{nagiospluginsdir} MANDIR=${RPM_BUILD_ROOT}%{_mandir} COMPLETIONDIR=${RPM_BUILD_ROOT}%{completions_dir} install
%else
make DESTDIR=${RPM_BUILD_ROOT}%{nagiospluginsdir} MANDIR=${RPM_BUILD_ROOT}%{_mandir} install
%endif

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%doc AUTHORS.md ChangeLog NEWS.md README.md COPYING.md VERSION COPYRIGHT.md
%attr(0755, root, root) %{nagiospluginsdir}/check_ssl_cert
%{_mandir}/man1/%{sourcename}.1*
%if "%{completions_dir}"
%{completions_dir}
%endif

%changelog
* Tue Apr  8 2025 Matteo Corti <matteo@corti.li> - 2.92.0-0
- Updated to 2.92.0

* Fri Apr  4 2025 Matteo Corti <matteo@corti.li> - 2.91.0-0
- Updated to 2.91.0

* Fri Apr  4 2025 Matteo Corti <matteo@corti.li> - 2.90.0-0
- Updated to 2.90.0

* Wed Apr  2 2025 Matteo Corti <matteo@corti.li> - 2.89.0-0
- Updated to 2.89.0

* Wed Mar 12 2025 Matteo Corti <matteo@corti.li> - 2.88.0-0
- Updated to 2.88.0

* Fri Mar  7 2025 Matteo Corti <matteo@corti.li> - 2.87.1-0
- Updated to 2.87.1

* Thu Mar  6 2025 Matteo Corti <matteo@corti.li> - 2.87.0-0
- Updated to 2.87.0

* Mon Feb 24 2025 Matteo Corti <matteo@corti.li> - 2.86.1-0
- Updated to 2.86.1

* Mon Feb  3 2025 Matteo Corti <matteo@corti.li> - 2.86.0-0
- Updated to 2.86.0

* Tue Jan  7 2025 Matteo Corti <matteo@corti.li> - 2.85.1-0
- Updated to 2.85.1

* Wed Oct 15 2024 Matteo Corti <matteo@corti.li> - 2.85.0-0
- Updated to 2.85.0

* Sun Oct 13 2024 Matteo Corti <matteo@corti.li> - 2.84.5-0
- Updated to 2.84.5

* Wed Oct  2 2024 Matteo Corti <matteo@corti.li> - 2.84.4-0
- Updated to 2.84.4

* Fri Sep 27 2024 Matteo Corti <matteo@corti.li> - 2.84.3-0
- Updated to 2.84.3

* Fri Sep 27 2024 Matteo Corti <matteo@corti.li> - 2.84.2-0
- Updated to 2.84.2

* Thu Sep 26 2024 Matteo Corti <matteo@corti.li> - 2.84.1-0
- Updated to 2.84.1

* Tue Sep 24 2024 Matteo Corti <matteo@corti.li> - 2.84.0-0
- Updated to 2.84.0

* Mon Sep 16 2024 Matteo Corti <matteo@corti.li> - 2.83.1-1
- Corrected the dates im Changelog

* Tue Sep 10 2024 Matteo Corti <matteo@corti.li> - 2.83.1-0
- Updated to 2.83.1

* Wed Aug 28 2024 Matteo Corti <matteo@corti.li> - 2.83.0-0
- Updated to 2.83.0

* Thu Jul  11 2024 Matteo Corti <matteo@corti.li> - 2.82.0-0
- Updated to 2.82.0

* Tue May  28 2024 Matteo Corti <matteo@corti.li> - 2.81.1-0
- Updated to 2.81.1

* Sun Mar 17 2024 Matteo Corti <matteo@corti.li> - 2.81.0-0
- Updated to 2.81.0

* Wed Feb 28 2024 Matteo Corti <matteo@corti.li> - 2.80.0-0
- Updated to 2.80.0

* Sun Jan 14 2024 Matteo Corti <matteo@corti.li> - 2.79.0-0
- Updated to 2.79.0

* Thu Nov  30 2023 Matteo Corti <matteo@corti.li> - 2.78.0-0
- Updated to 2.78.0

* Thu Nov  23 2023 Matteo Corti <matteo@corti.li> - 2.77.0-0
- Updated to 2.77.0

* Mon Oct  30 2023 Matteo Corti <matteo@corti.li> - 2.76.0-0
- Updated to 2.76.0

* Wed Sep  27 2023 Matteo Corti <matteo@corti.li> - 2.75.0-0
- Updated to 2.75.0

* Wed Sep  13 2023 Matteo Corti <matteo@corti.li> - 2.74.0-0
- Updated to 2.74.0

* Sat Aug  26 2023 Matteo Corti <matteo@corti.li> - 2.73.0-0
- Updated to 2.73.0

* Thu Aug  10 2023 Matteo Corti <matteo@corti.li> - 2.72.0-0
- Updated to 2.72.0

* Fri Jul  28 2023 Matteo Corti <matteo@corti.li> - 2.71.0-0
- Updated to 2.71.0

* Tue May  30 2023 Matteo Corti <matteo@corti.li> - 2.70.0-0
- Updated to 2.70.0

* Fri May  12 2023 Matteo Corti <matteo@corti.li> - 2.69.0-0
- Updated to 2.69.0

* Fri Apr  28 2023 Matteo Corti <matteo@corti.li> - 2.68.0-0
- Updated to 2.68.0

* Mon Apr  24 2023 Matteo Corti <matteo@corti.li> - 2.67.0-0
- Updated to 2.67.0

* Fri Apr  21 2023 Matteo Corti <matteo@corti.li> - 2.66.0-0
- Updated to 2.66.0

* Fri Apr  21 2023 Matteo Corti <matteo@corti.li> - 2.65.0-0
- Updated to 2.65.0

* Fri Apr   7 2023 Matteo Corti <matteo@corti.li> - 2.64.0-0
- Updated to 2.64.0

* Wed Apr   5 2023 Matteo Corti <matteo@corti.li> - 2.63.0-0
- Updated to 2.63.0

* Thu Mar  16 2023 Matteo Corti <matteo@corti.li> - 2.62.0-0
- Updated to 2.62.0

* Thu Mar   9 2023 Matteo Corti <matteo@corti.li> - 2.61.0-0
- Updated to 2.61.0

* Wed Feb  15 2023 Matteo Corti <matteo@corti.li> - 2.60.0-0
- Updated to 2.60.0

* Wed Feb  15 2023 Matteo Corti <matteo@corti.li> - 2.59.0-0
- Updated to 2.59.0

* Mon Jan  16 2023 Matteo Corti <matteo@corti.li> - 2.58.0-0
- Updated to 2.58.0

* Sun Dec   4 2022 Matteo Corti <matteo@corti.li> - 2.57.0-0
- Updated to 2.57.0

* Wed Nov  30 2022 Matteo Corti <matteo@corti.li> - 2.56.0-0
- Updated to 2.56.0

* Fri Nov  25 2022 Matteo Corti <matteo@corti.li> - 2.55.0-0
- Updated to 2.55.0

* Thu Oct  20 2022 Matteo Corti <matteo@corti.li> - 2.54.0-0
- Updated to 2.54.0

* Wed Oct  19 2022 Matteo Corti <matteo@corti.li> - 2.53.0-0
- Updated to 2.53.0

* Thu Oct   6 2022 Matteo Corti <matteo@corti.li> - 2.52.0-0
- Updated to 2.52.0

* Thu Oct   6 2022 Matteo Corti <matteo@corti.li> - 2.51.0-0
- Updated to 2.51.0

* Thu Oct   6 2022 Matteo Corti <matteo@corti.li> - 2.50.0-0
- Updated to 2.50.0

* Tue Sep  27 2022 Matteo Corti <matteo@corti.li> - 2.49.0-0
- Updated to 2.49.0

* Sat Sep  24 2022 Matteo Corti <matteo@corti.li> - 2.48.0-0
- Updated to 2.48.0

* Fri Sep  23 2022 Matteo Corti <matteo@corti.li> - 2.47.0-0
- Updated to 2.47.0

* Tue Sep  20 2022 Matteo Corti <matteo@corti.li> - 2.46.0-0
- Updated to 2.46.0

* Mon Sep  19 2022 Matteo Corti <matteo@corti.li> - 2.45.0-0
- Updated to 2.45.0

* Tue Sep  13 2022 Matteo Corti <matteo@corti.li> - 2.44.0-0
- Updated to 2.44.0

* Fri Sep   9 2022 Matteo Corti <matteo@corti.li> - 2.43.0-0
- Updated to 2.43.0

* Tue Sep   6 2022 Matteo Corti <matteo@corti.li> - 2.42.0-0
- Updated to 2.42.0

* Thu Sep   1 2022 Matteo Corti <matteo@corti.li> - 2.41.0-0
- Updated to 2.41.0

* Wed Aug  24 2022 Matteo Corti <matteo@corti.li> - 2.40.0-0
- Updated to 2.40.0

* Wed Aug  24 2022 Matteo Corti <matteo@corti.li> - 2.39.0-0
- Updated to 2.39.0

* Tue Aug  23 2022 Matteo Corti <matteo@corti.li> - 2.38.0-0
- Updated to 2.38.0

* Wed Aug  17 2022 Matteo Corti <matteo@corti.li> - 2.37.0-0
- Updated to 2.37.0
- Added dependencies to curl, openssl and file

* Tue Jul  26 2022 Matteo Corti <matteo@corti.li> - 2.36.0-0
- Updated to 2.36.0

* Fri Jul  15 2022 Matteo Corti <matteo@corti.li> - 2.35.0-0
- Updated to 2.35.0

* Wed Jul   6 2022 Matteo Corti <matteo@corti.li> - 2.34.0-0
- Updated to 2.34.0

* Fri Jul   1 2022 Matteo Corti <matteo@corti.li> - 2.33.0-0
- Updated to 2.33.0

* Fri Jun  17 2022 Matteo Corti <matteo@corti.li> - 2.32.0-0
- Updated to 2.32.0

* Sat Jun  11 2022 Matteo Corti <matteo@corti.li> - 2.31.0-0
- Updated to 2.31.0

* Wed Jun   1 2022 Matteo Corti <matteo@corti.li> - 2.30.0-0
- Updated to 2.30.0

* Wed May  25 2022 Matteo Corti <matteo@corti.li> - 2.29.0-0
- Updated to 2.29.0

* Wed May   4 2022 Matteo Corti <matteo@corti.li> - 2.28.0-0
- Updated to 2.28.0

* Thu Apr  28 2022 Matteo Corti <matteo@corti.li> - 2.27.0-0
- Updated to 2.27.0

* Thu Apr  28 2022 Matteo Corti <matteo@corti.li> - 2.26.0-0
- Updated to 2.26.0

* Wed Apr  13 2022 Matteo Corti <matteo@corti.li> - 2.25.0-0
- Updated to 2.25.0

* Wed Apr   6 2022 Matteo Corti <matteo@corti.li> - 2.24.0-0
- Updated to 2.24.0

* Fri Mar  25 2022 Matteo Corti <matteo@corti.li> - 2.23.0-0
- Updated to 2.23.0

* Fri Mar  11 2022 Matteo Corti <matteo@corti.li> - 2.22.0-0
- Updated to 2.22.0

* Sun Feb  20 2022 Matteo Corti <matteo@corti.li> - 2.21.0-0
- Updated to 2.21.0

* Thu Feb   3 2022 Matteo Corti <matteo@corti.li> - 2.20.0-1
- Packaged the bash completion script

* Thu Feb   3 2022 Matteo Corti <matteo@corti.li> - 2.20.0-0
- Updated to 2.20.0

* Thu Jan  13 2022 Matteo Corti <matteo@corti.li> - 2.19.0-0
- Updated to 2.19.0

* Wed Jan  12 2022 Matteo Corti <matteo@corti.li> - 2.18.0-0
- Updated to 2.18.0

* Tue Dec  21 2021 Matteo Corti <matteo@corti.li> - 2.17.0-0
- Updated to 2.17.0

* Mon Dec  20 2021 Matteo Corti <matteo@corti.li> - 2.16.0-0
- Updated to 2.16.0

* Wed Dec  15 2021 Matteo Corti <matteo@corti.li> - 2.15.0-0
- Updated to 2.15.0

* Fri Dec  10 2021 Matteo Corti <matteo@corti.li> - 2.14.0-0
- Updated to 2.14.0

* Wed Nov  24 2021 Matteo Corti <matteo@corti.li> - 2.13.0-0
- Updated to 2.13.0

* Tue Nov  16 2021 Matteo Corti <matteo@corti.li> - 2.12.0-0
- Updated to 2.12.0

* Thu Nov  11 2021 Matteo Corti <matteo@corti.li> - 2.11.0-0
- Updated to 2.11.0

* Fri Oct  22 2021 Matteo Corti <matteo@corti.li> - 2.10.4-0
- Updated to 2.10.4

* Thu Oct  21 2021 Matteo Corti <matteo@corti.li> - 2.10.3-0
- Updated to 2.10.3

* Thu Oct  14 2021 Matteo Corti <matteo@corti.li> - 2.10.2-0
- Updated to 2.10.2

* Tue Oct  12 2021 Matteo Corti <matteo@corti.li> - 2.10.1-0
- Updated to 2.10.1

* Mon Oct  11 2021 Matteo Corti <matteo@corti.li> - 2.10.0-0
- Updated to 2.10.0

* Wed Oct   6 2021 Matteo Corti <matteo@corti.li> - 2.9.1-0
- Updated to 2.9.1

* Fri Oct   1 2021 Matteo Corti <matteo@corti.li> - 2.9.0-0
- Updated to 2.9.0

* Wed Sep  29 2021 Matteo Corti <matteo@corti.li> - 2.8.0-0
- Updated to 2.8.0

* Fri Sep  24 2021 Matteo Corti <matteo@corti.li> - 2.7.0-0
- Updated to 2.7.0

* Tue Sep  21 2021 Matteo Corti <matteo@corti.li> - 2.6.1-0
- Updated to 2.6.1

* Fri Sep  17 2021 Matteo Corti <matteo@corti.li> - 2.6.0-0
- Updated to 2.6.0

* Thu Sep  16 2021 Matteo Corti <matteo@corti.li> - 2.5.2-0
- Updated to 2.5.2

* Wed Sep  15 2021 Matteo Corti <matteo@corti.li> - 2.5.1-0
- Updated to 2.5.1

* Wed Sep  15 2021 Matteo Corti <matteo@corti.li> - 2.5.0-0
- Updated to 2.5.0

* Wed Sep   1 2021 Matteo Corti <matteo@corti.li> - 2.4.3-0
- Updated to 2.4.3

* Fri Aug  27 2021 Matteo Corti <matteo@corti.li> - 2.4.2-0
- Updated to 2.4.2

* Thu Aug  19 2021 Matteo Corti <matteo@corti.li> - 2.4.1-0
- Updated to 2.4.1

* Mon Aug  16 2021 Matteo Corti <matteo@corti.li> - 2.4.0-0
- Updated to 2.4.0

* Fri Aug  13 2021 Matteo Corti <matteo@corti.li> - 2.3.8-0
- Updated to 2.3.8

* Fri Jul   9 2021 Matteo Corti <matteo@corti.li> - 2.3.7-0
- Updated to 2.3.7

* Wed Jun  23 2021 Matteo Corti <matteo@corti.li> - 2.3.6-0
- Updated to 2.3.6

* Tue Jun  22 2021 Matteo Corti <matteo@corti.li> - 2.3.5-0
- Updated to 2.3.5

* Fri Jun  18 2021 Matteo Corti <matteo@corti.li> - 2.3.4-0
- Updated to 2.3.4

* Wed Jun  16 2021 Matteo Corti <matteo@corti.li> - 2.3.3-0
- Updated to 2.3.3

* Thu Jun   3 2021 Matteo Corti <matteo@corti.li> - 2.3.2-0
- Updated to 2.3.2

* Fri May  28 2021 Matteo Corti <matteo@corti.li> - 2.3.1-0
- Updated to 2.3.1

* Fri May  21 2021 Matteo Corti <matteo@corti.li> - 2.3.0-0
- Updated to 2.3.0

* Fri May   7 2021 Matteo Corti <matteo@corti.li> - 2.2.0-0
- Updated to 2.2.0

* Thu May   6 2021 Matteo Corti <matteo@corti.li> - 2.1.4-0
- Updated to 2.1.4

* Wed May   5 2021 Matteo Corti <matteo@corti.li> - 2.1.3-0
- Updated to 2.1.3

* Fri Apr  30 2021 Matteo Corti <matteo@corti.li> - 2.1.2-0
- Updated to 2.1.2

* Thu Apr  29 2021 Matteo Corti <matteo@corti.li> - 2.1.1-0
- Updated to 2.1.1

* Wed Apr  28 2021 Matteo Corti <matteo@corti.li> - 2.1.0-0
- Updated to 2.1.0

* Wed Apr   7 2021 Matteo Corti <matteo@corti.li> - 2.0.1-0
- Updated to 2.0.1

* Thu Apr   1 2021 Matteo Corti <matteo@corti.li> - 2.0.0-0
- Updated to 2.0.0

* Mon Mar  29 2021 Matteo Corti <matteo@corti.li> - 1.147.0-0
- Updated to 1.147.0

* Thu Mar  25 2021 Matteo Corti <matteo@corti.li> - 1.146.0-0
- Updated to 1.146.0

* Mon Mar  15 2021 Matteo Corti <matteo@corti.li> - 1.145.0-0
- Updated to 1.145.0

* Sun Mar  14 2021 Matteo Corti <matteo@corti.li> - 1.144.0-0
- Updated to 1.144.0

* Fri Mar  12 2021 Matteo Corti <matteo@corti.li> - 1.143.0-0
- Updated to 1.143.0

* Wed Mar  10 2021 Matteo Corti <matteo@corti.li> - 1.142.0-0
- Updated to 1.142.0

* Tue Mar   9 2021 Matteo Corti <matteo@corti.li> - 1.141.0-0
- Updated to 1.141.0

* Thu Feb  25 2021 Matteo Corti <matteo@corti.li> - 1.140.0-0
- Updated to 1.140.0

* Wed Feb  24 2021 Matteo Corti <matteo@corti.li> - 1.139.0-0
- Updated to 1.139.0

* Wed Feb  24 2021 Matteo Corti <matteo@corti.li> - 1.138.0-0
- Updated to 1.138.0

* Thu Feb  18 2021 Matteo Corti <matteo@corti.li> - 1.137.0-0
- Updated to 1.137.0

* Tue Feb  16 2021 Matteo Corti <matteo@corti.li> - 1.136.0-0
- Updated to 1.136.0

* Thu Jan  28 2021 Matteo Corti <matteo@corti.li> - 1.135.0-0
- Updated to 1.135.0

* Wed Jan  27 2021 Matteo Corti <matteo@corti.li> - 1.134.0-0
- Updated to 1.134.0

* Tue Jan  26 2021 Matteo Corti <matteo@corti.li> - 1.133.0-0
- Updated to 1.133.0

* Mon Jan  18 2021 Matteo Corti <matteo@corti.li> - 1.132.0-0
- Updated to 1.132.0

* Fri Jan  15 2021 Matteo Corti <matteo@corti.li> - 1.131.0-0
- Updated to 1.131.0

* Thu Jan  14 2021 Matteo Corti <matteo@corti.li> - 1.130.0-0
- Updated to 1.130.0

* Thu Dec  24 2020 Matteo Corti <matteo@corti.li> - 1.129.0-0
- Updated to 1.129.0

* Tue Dec  22 2020 Matteo Corti <matteo@corti.li> - 1.128.0-0
- Updated to 1.128.0

* Mon Dec  21 2020 Matteo Corti <matteo@corti.li> - 1.127.0-0
- Updated to 1.127.0

* Wed Dec  16 2020 Matteo Corti <matteo@corti.li> - 1.126.0-0
- Updated to 1.126.0

* Fri Dec  11 2020 Matteo Corti <matteo@corti.li> - 1.125.0-0
- Updated to 1.125.0

* Tue Dec   1 2020 Matteo Corti <matteo@corti.li> - 1.124.0-0
- Updated to 1.124.0

* Mon Nov  30 2020 Matteo Corti <matteo@corti.li> - 1.123.0-0
- Updated to 1.123.0

* Fri Aug   7 2020 Matteo Corti <matteo@corti.li> - 1.122.0-0
- Updated to 1.122.0

* Fri Jul  24 2020 Matteo Corti <matteo@corti.li> - 1.121.0-0
- Updated to 1.121.0

* Thu Jul   2 2020 Matteo Corti <matteo@corti.li> - 1.120.0-0
- Updated to 1.120.0

* Wed Jul   1 2020 Matteo Corti <matteo@corti.li> - 1.119.0-0
- Updated to 1.119.0

* Fri Jun  12 2020 Matteo Corti <matteo@corti.li> - 1.118.0-0
- Updated to 1.118.0

* Sat Jun   6 2020 Matteo Corti <matteo@corti.li> - 1.117.0-0
- Updated to 1.117.0

* Thu Jun   4 2020 Matteo Corti <matteo@corti.li> - 1.115.0-0
- Updated to 1.115.0

* Wed May  27 2020 Matteo Corti <matteo@corti.li> - 1.114.0-0
- Updated to 1.114.0

* Tue May  19 2020 Matteo Corti <matteo@corti.li> - 1.113.0-0
- Updated to 1.113.0

* Tue Apr   7 2020 Matteo Corti <matteo@corti.li> - 1.112.0-0
- Updated to 1.112.0

* Mon Mar   9 2020 Matteo Corti <matteo@corti.li> - 1.111.0-0
- Updated to 1.111.0

* Mon Feb  17 2020 Matteo Corti <matteo@corti.li> - 1.110.0-0
- Updated to 1.110.0

* Tue Jan  7 2020 Matteo Corti <matteo@corti.li> - 1.109.0-0
- Updated to 1.109.0

* Mon Dec 23 2019 Matteo Corti <matteo@corti.li> - 1.108.0-0
- Updated to 1.108.0

* Fri Dec 20 2019 Matteo Corti <matteo@corti.li> - 1.107.0-0
- Updated to 1.107.0

* Thu Nov 21 2019 Matteo Corti <matteo@corti.li> - 1.106.0-0
- Updated to 1.106.0

* Mon Nov  4 2019 Matteo Corti <matteo@corti.li> - 1.105.0-0
- Updated to 1.105.0

* Mon Nov  4 2019 Matteo Corti <matteo@corti.li> - 1.104.0-0
- Updated to 1.104.0

* Thu Oct 31 2019 Matteo Corti <matteo@corti.li> - 1.103.0-0
- Updated to 1.103.0

* Fri Oct 25 2019 Matteo Corti <matteo@corti.li> - 1.102.0-0
- Updated to 1.102.0

* Tue Oct 22 2019 Matteo Corti <matteo@corti.li> - 1.101.0-0
- Updated to 1.101.0

* Fri Oct 18 2019 Matteo Corti <matteo@corti.li> - 1.100.0-0
- Updated to 1.100.0

* Wed Oct 16 2019 Matteo Corti <matteo@corti.li> - 1.99.0-0
- Updated to 1.99.0
w
* Thu Oct 10 2019 Matteo Corti <matteo@corti.li> - 1.98.0-0
- Updated to 1.98.0

* Wed Oct  9 2019 Matteo Corti <matteo@corti.li> - 1.97.0-0
- Updated to 1.97.0

* Wed Sep 25 2019 Matteo Corti <matteo@corti.li> - 1.96.0-0
- Updated to 1.96.0

* Tue Sep 24 2019 Matteo Corti <matteo@corti.li> - 1.95.0-0
- Updated to 1.95.0

* Tue Sep 24 2019 Matteo Corti <matteo@corti.li> - 1.94.0-0
- Updated to 1.94.0

* Tue Sep 24 2019 Matteo Corti <matteo@corti.li> - 1.93.0-0
- Updated to 1.93.0

* Tue Sep 24 2019 Matteo Corti <matteo@corti.li> - 1.92.0-0
- Updated to 1.92.0

* Tue Sep 24 2019 Matteo Corti <matteo@corti.li> - 1.91.0-0
- Updated to 1.91.0

* Thu Sep 19 2019 Matteo Corti <matteo@corti.li> - 1.90.0-0
- Updated to 1.90.0

* Thu Aug 22 2019 Matteo Corti <matteo@corti.li> - 1.89.0-0
- Updated to 1.89.0

* Fri Aug  9 2019 Matteo Corti <matteo@corti.li> - 1.88.0-0
- Updated to 1.88.0

* Thu Aug  8 2019 Matteo Corti <matteo@corti.li> - 1.87.0-0
- Updated to 1.87.0

* Sun Jul 21 2019 Matteo Corti <matteo@corti.li> - 1.86.0-0
- Updated to 1.86.0

* Sun Jun  2 2019 Matteo Corti <matteo@corti.li> - 1.85.0-0
- Updated to 1.85.0

* Thu Mar 28 2019 Matteo Corti <matteo@corti.li> - 1.84.0-0
- Updated to 1.84.0

* Fri Mar  1 2019 Matteo Corti <matteo@corti.li> - 1.83.0-0
- Updated to 1.83.0

* Fri Feb  8 2019 Matteo Corti <matteo@corti.li> - 1.82.0-0
- Updated to 1.82.0

* Sat Feb  2 2019 Matteo Corti <matteo@corti.li> - 1.81.0-0
- Updated to 1.81.0

* Wed Jan 16 2019 Matteo Corti <matteo@corti.li> - 1.80.1-0
- Updated to 1.80.1

* Mon Dec 24 2018 Matteo Corti <matteo@corti.li> - 1.80.0-0
- Updated to 1.80.0

* Tue Dec 11 2018 Matteo Corti <matteo@corti.li> - 1.79.0-0
- Updated to 1.79.0

* Wed Nov  7 2018 Matteo Corti <matteo@corti.li> - 1.78.0-0
- Updated to 1.78.0

* Mon Nov  5 2018 Matteo Corti <matteo@corti.li> - 1.77.0-0
- Updated to 1.77.0

* Fri Oct 19 2018 Matteo Corti <matteo@corti.li> - 1.76.0-0
- Updated to 1.76.0

* Thu Oct 18 2018 Matteo Corti <matteo@corti.li> - 1.75.0-0
- Updated to 1.75.0

* Mon Oct 15 2018 Matteo Corti <matteo@corti.li> - 1.74.0-0
- Updated to 1.74.0

* Mon Sep 10 2018 Matteo Corti <matteo@corti.li> - 1.73.0-0
- Updated to 1.73.0

* Mon Jul 30 2018 Matteo Corti <matteo@corti.li> - 1.72.0-0
- Updated to 1.72.0

* Mon Jul 30 2018 Matteo Corti <matteo@corti.li> - 1.71.0-0
- Updated to 1.71.0

* Thu Jun 28 2018 Matteo Corti <matteo@corti.li> - 1.70.0-0
- Updated to 1.70.0

* Mon Jun 25 2018 Matteo Corti <matteo@corti.li> - 1.69.0-0
- Updated to 1.69.0

* Sun Apr 29 2018 Matteo Corti <matteo@corti.li> - 1.68.0-0
- Updated to 1.68.0

* Tue Apr 17 2018 Matteo Corti <matteo@corti.li> - 1.67.0-0
- Updated to 1.67.0

* Fri Apr  6 2018 Matteo Corti <matteo@corti.li> - 1.66.0-0
- Updated to 1.66.0

* Thu Mar 29 2018 Matteo Corti <matteo@corti.li> - 1.65.0-0
- Updated to 1.65.0

* Wed Mar 28 2018 Matteo Corti <matteo@corti.li> - 1.64.0-0
- Updated to 1.64.0

* Sat Mar 17 2018 Matteo Corti <matteo@corti.li> - 1.63.0-0
- Updated to 1.63.0

* Tue Mar  6 2018 Matteo Corti <matteo@corti.li> - 1.62.0-0
- Updated to 1.62.0

* Fri Jan 19 2018 Matteo Corti <matteo@corti.li> - 1.61.0-0
- Updated to 1.61.0

* Fri Dec 15 2017 Matteo Corti <matteo@corti.li> - 1.60.0-0
- Updated to 1.60.0

* Thu Dec 14 2017 Matteo Corti <matteo@corti.li> - 1.59.0-0
- Updated to 1.59.0

* Wed Nov 29 2017 Matteo Corti <matteo@corti.li> - 1.58.0-0
- Updated to 1.58.0

* Tue Nov 28 2017 Matteo Corti <matteo@corti.li> - 1.57.0-0
- Updated to 1.57.0

* Fri Nov 17 2017 Matteo Corti <matteo@corti.li> - 1.56.0-0
- Updated to 1.56.0

* Thu Nov 16 2017 Matteo Corti <matteo@corti.li> - 1.55.0-0
- Updated to 1.55.0

* Tue Sep 19 2017 Matteo Corti <matteo@corti.li> - 1.54.0-0
- Updated to 1.54.0

* Sun Sep 10 2017 Matteo Corti <matteo@corti.li> - 1.53.0-0
- Updated to 1.53.0

* Sat Sep  9 2017 Matteo Corti <matteo@corti.li> - 1.52.0-0
- Updated to 1.52.0

* Fri Jul 28 2017 Matteo Corti <matteo@corti.li> - 1.51.0-0
- Updated to 1.51.0

* Mon Jul 24 2017 Matteo Corti <matteo@corti.li> - 1.50.0-0
- Updated to 1.50.0

* Mon Jul 17 2017 Matteo Corti <matteo@corti.li> - 1.49.0-0
- Updated to 1.49.0

* Fri Jun 23 2017 Matteo Corti <matteo@corti.li> - 1.48.0-0
- Updated to 1.48.0

* Thu Jun 15 2017 Matteo Corti <matteo@corti.li> - 1.47.0-0
- Updated to 1.47.0

* Mon May 15 2017 Matteo Corti <matteo@corti.li> - 1.46.0-0
- Updated to 1.46.0

* Tue May  2 2017 Matteo Corti <matteo@corti.li> - 1.45.0-0
- Updated to 1.45.0

* Fri Apr 28 2017 Matteo Corti <matteo@corti.li> - 1.44.0-0
- Updated to 1.44.0

* Tue Mar  7 2017 Matteo Corti <matteo@corti.li> - 1.43.0-0
- Updated to 1.43.0

* Thu Feb 16 2017 Matteo Corti <matteo@corti.li> - 1.42.0-0
- Updated to 1.42.0

* Fri Feb 10 2017 Matteo Corti <matteo@corti.li> - 1.41.0-0
- Updated to 1.41.0

* Wed Feb  8 2017 Matteo Corti <matteo@corti.li> - 1.40.0-0
- Updated to 1.40.0

* Thu Feb  2 2017 Matteo Corti <matteo@corti.li> - 1.39.0-0
- Updated to 1.39.0

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
- Updated to 1.16.0 (force TLS)

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
- updated to 1.10.1 (--altnames option)

* Thu Sep  1 2011 Matteo Corti <matteo.corti@id.ethz.ch> - 1.10.0-0
- applied patch from Sven Nierlein for client certificate authentication

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
