# check\_ssl\_cert list of authors

Maintainer: [Matteo Corti](https://github.com/matteocorti) <[matteo@corti.li](mailto:matteo@.corti.li)>

* Many thanks to Kenny McCormack for his help on comp.unix.shell on how to implement a timeout
* Many thanks to Dan Wallis for several patches and fixes (see the [Changelog](Changelog))
* Many thanks to Tuomas Haarala for the ```-P``` option patch to check TLS certs using other protocols
* Many thanks to Marcus Rejås for the ```-N``` and ```-n``` patches
* Many thanks to Marc Fournier for
  * the ```==``` bashism fix and
  * the ```mktemp``` error handling patch
* Many thanks to Wolfgang Schricker for
  * the selfsigned bug report and cleanup fixes and
  * the patch adding the possibility to check local files (```-``` option)
* Many thanks to Yannick Gravel for the patch fixing the plugin output and the fix on the test order
* Many thanks to Scott Worthington for the ```--critical``` and ```--warning``` hints
* Many thanks to Lawren Quigley-Jones for
  * the ```-A,--noauth``` patch and
  * the trap fix
* Many thanks to Matthias Fuhrmeister for the ```-servername``` patch
* Many thanks to Raphael Thoma for
  * the patch allowing HTTP to be specified as protocol and
  * the fix on ```-N``` with wildcards
* Many thanks to Sven Nierlein for the client certificate authentication patch
* Many thanks to Rob Yamry for the help in debugging a problem with certain versions of [OpenSSL](https://www.openssl.org) and TLS extensions
* Many thanks to Jim Hopp for the "No certificate returned" enhancement patch
* Many thanks to Javier Gonel for the TLS servername patch
* Many thanks to Christian Ruppert for the XMPP patch
* Many thanks to Robin H. Johnson for the ```timeout``` patch
* Many thanks to Max Winterstein for the SSL version patch
* Many thanks to Colin Smith for the RPM build Makefile patch
* Many thanks to Andreas Dijkman for the RPM dependencies patch
* Many thanks to Lawren Quigley-Jones for the common name patch
* Many thanks to Ryan Nowakowski for the OCSP patch
* Many thanks to Jérémy Lecour for the review and corrections
* Many thanks to Mark Ruys for the OCSP patch
* Many thanks to Milan Koudelka for the serial number patch
* Many thanks to Konstantin Shalygin for the UTF-8 patch
* Many thanks to Sam Richards for the SNI patch
* Many thanks to [Sergei Shmanko](https://github.com/sshmanko) for the wildcard certificate patch
* Many thanks to [juckerf](https://github.com/juckerf) for patch to increase control over which SSL/TLS versions to use
* Many thanks to Rolf Eike Beer for the IRC and SMTP check patch
* Many thanks to Viktor Szépe for the formatting and style patches
* Many thanks to Philippe Kueck for the CN patch
* Many thanks to [Ricardo](https://github.com/bb-Ricardo) for the date timestamp patch
* Many thanks to [xert](https://github.com/xert) for the date timestamp patch
* Many thanks to [xert](https://github.com/xert) for the [Qualys, SSL Labs](https://www.ssllabs.com/ssltest/) patch
* Many thanks to [Leynos](https://github.com/leynos) for the OCSP proxy patch
* Many thanks to Philippe Kueck for the selection of the cipher authentication
* Many thanks to [Jalonet](https://github.com/jalonet) for the file/PEM patch
* Many thanks to [Sander Cornelissen](https://github.com/scornelissen85)for the multiple CNs patch
* Many thanks to [Pavel Rochnyak](https://github.com/rpv-tomsk) for the issuer certificate cache patch and the wildcard support in alternative names
* Many thanks to [Vamp898](https://github.com/Vamp898) for the LDAP patch
* Many thanks to Emilian Ertel for the [curl](https://curl.se) and ```date``` patches
* Many thanks to Kosta Velikov for the ```grep``` patch
* Many thanks to Vojtech Horky for the [OpenSSL](https://www.openssl.org) 1.1 patch
* Many thanks to [Nicolas Lafont](https://github.com/ManicoW) for the Common Name fix
* Many thanks to [d7415](https://github.com/d7415) for the ```-help``` patch
* Many thanks to [Łukasz Wąsikowski](https://github.com/IdahoPL) for the [curl](https://curl.se) and date display patches
* Many thanks to [booboo-at-gluga-de](https://github.com/booboo-at-gluga-de) for the CRL patch
* Many thanks to [Georg](https://github.com/gbotti) for the fingerprint patch
* Many thanks to [Wim van Ravesteijn](https://github.com/wimvr) for the DER encoded CRL files patch and the OCSP expiring date patch
* Many thanks to [yasirathackersdotmu](https://github.com/yasirathackersdotmu)
* Many thanks to [Christoph Moench-Tegeder](https://github.com/moench-tegeder) for the [curl](https://curl.se) patch
* Many thanks to Dan Pritts for the ```--terse``` patch
* Many thanks to [eeertel](https://github.com/eeertel) for the SNI warning patch
* Many thanks to [Vojtech Horky](https://github.com/vhotspur) for the ```--format``` patch
* Many thanks to [Markus Frosch](https://github.com/lazyfrosch) for the cleanup patch
* Many thanks to [Ricardo Bartels](https://github.com/bb-Ricardo) for
  * the patch fixing unit tests,
  * the patch forlong output on Linux and
  * extending the issuer checks to the whole chain
* Many thanks to [eimamagi](https://github.com/eimamagi) for the client key patch and for the CA file and directory support
* Many thanks to Stefan Schlesinger for the ```HTTP_REQUEST``` patch
* Many thanks to [sokol-44](https://github.com/sokol-44) for the HTTP request fix
* Many thanks to [Jonas Meurer](https://github.com/mejo-) for the IMAP / IMAPS fix
* Many thanks to [Mathieu Simon](https://github.com/matsimon) for the IMAPS, POP3S and LDAP patches
* Many thanks to [Nico](https://github.com/nicox) for the [Qualys, SSL Labs](https://www.ssllabs.com/ssltest/) patch
* Many thanks to [barakAtSoluto](https://github.com/barakAtSoluto) for the [Qualys, SSL Labs](https://www.ssllabs.com/ssltest/) warning patch
* Many thanks to [Valentin Heidelberger](https://github.com/va1entin) for the [curl](https://curl.se) user agent patch
* Many thanks to [Tone](https://github.com/anthonyhaussman) for the warning message improvement patch
* Many thanks to [Michael Niewiara](https://github.com/mobitux)for the HTTPS/```echo``` fix
* Many thanks to [Zadkiel](https://github.com/aslafy-z) for the extended regex patch and for the n-elementh check
* Many thanks to [Dick Visser](https://github.com/dnmvisser) for the ```--inetproto``` patch
* Many thanks to [jmuecke](https://github.com/jmuecke) for the multiple errors patch
* Many thanks to [iasdeoupxe](https://github.com/iasdeoupxe) for various fixes
* Many thanks to [Andre Klärner](https://github.com/klaernie) for the typos corrections
* Many thanks to [Дилян Палаузов](https://github.com/dilyanpalauzov) for the DANE checks
* Many thanks to [dupondje](https://github.com/dupondje) for the ```check_prog``` fix
* Many thanks to [Jörg Thalheim](https://github.com/Mic92) for the ```xmpp-server``` patch
* Many thanks to [Arkadiusz Miśkiewicz](https://github.com/arekm) for the OCSP timeout patch
* Many thanks to [Thomas Weißschuh](https://github.com/t-8ch) for the [PostgreSQL](https://www.postgresql.org) patch
* Many thanks to [Jonathan Besanceney](https://github.com/jonathan-besanceney) for the proxy patch
* Many thanks to [grizzlydev-sarl](https://github.com/grizzlydev-sarl) for
  * the processing of all the certificate in the chain,
  * the verbose patch and
  * the output cleanup patch
* Many thanks to [Claudio Kuenzler](https://github.com/Napsty) for the chain expiration output fix
* Many thanks to [jf-vf](https://github.com/jf-vf) for the [MySQL](https://www.mysql.com) support patch
* Many thanks to [skanx](https://github.com/skanx) for the ```--not-issued-by``` output patch
* Many thanks to [Zadkiel](https://github.com/aslafy-z) for
  * the ```--version``` patch and
  * the ```--skip-element``` patch
* Many thanks to [Marcel Burkhalter](https://github.com/explorer69) for the custom HTTP header patch.
* Many thanks to [Peter Newman](https://github.com/peternewman) for
  * the timeout documentation patch and
  * the issuers patch
  * the PCKS12 extension patch
  * the spelling fixes and checks
  * and several other fixes
* Many thanks to [cbiedl](https://github.com/cbiedl) for the proxy patch
* Many thanks to [Robin Schneider](https://github.com/ypid-geberit) for the ```--long-output``` patch
* Many thanks to [Robin Pronk](https://github.com/rfpronk) for the ```-u``` patch
* Many thanks to [tunnelpr0](https://github.com/tunnelpr0) for the ```--inetproto``` patch
* Many thanks to [Christoph Moench-Tegeder](https://github.com/moench-tegeder) for the [OpenSSL](https://www.openssl.org) version patch
* Many thanks to [waja](https://github.com/waja) for
  * the [GitHub](https://www.github.com) workflows and
  * the chain checks with STARTTLS and
  * the trailing backslash patch
* Many thanks to [Tobias Grünewald](https://github.com/tobias-gruenewald) for the client certificate patch
* Many thanks to [chornberger-c2c](https://github.com/chornberger-c2c) for the critical and warning output fix
* Many thanks to [Claus-Theodor Riegg](https://github.com/ctriegg-mak) for
  * the domain with underscores fix and
  * the certificate chain fix
* Many thanks to [Ed Sabol](https://github.com/esabol) for the FQDN patch
* Many thanks to [Igor Mironov](https://github.com/mcs6502) for the [LibreSSL](https://www.libressl.org) patch
* Many thanks to [jalbstmeijer](https://github.com/jalbstmeijer) for
  * the [OpenSSL](https://www.openssl.org) patch and
  * the ```INETPROTO``` patch
* Many thanks to [Pim Rupert](https://github.com/prupert) for the ```file(1)``` patches
* Many thanks to [Alexander Aleksandrovič Klimov](https://github.com/Al2Klimov) for the DANE 312 patch
* Many thanks to [Jaime Hablutzel](https://github.com/hablutzel1) for the ```--element``` fix
* Many thanks to [Bernd Strößenreuther](https://github.com/booboo-at-gluga-de) for
  * the CRL fix,
  * the IPv6 fix and
  * for the floating point patch and
  * for the ```--help``` patch
* Many thanks to [Kim Jahn](https://github.com/mookie-) for
  * the conversion typo and
  * the underscore fixes
* Many thanks to [Naveen](https://github.com/naveensrinivasan) for the GitHub actions permissions fix
* Many thanks to [Varac](https://github.com/varac) for the Prometheus fix
* Many thanks to [PSSGCSim](https://github.com/PSSGCSim) for the Prometheus fix
* Many thanks to [Dick Visser](https://github.com/dnmvisser) for the user agent fix
* Many thanks to [claudioth](https://github.com/claudioth) for the Perl date computation fix
* Many thanks to [Lukas Tribus](https://github.com/lukastribus) for the Python 3 patch
* Many thanks to [Peter](https://github.com/Peter2121) for the FreeBSD jail patch
* Many thanks to [Marcel Burkhalter](https://github.com/marcel-burkhalter) for the path check
* Many thanks to [Slavko](https://github.com/slavkoja) for the RSA algorithms patch
* Many thanks to [Ben Byrne](https://github.com/benbyr) for the CRL output format patch
* Many thanks to [Tom Geißler](https://github.com/d7031) for the Icinga configuration
* Many thanks to [Florian Apolloner](https://github.com/apollo13) for the configuration patch
* Many thanks to [vanElden](https://github.com/vanElden) for the support to ignore unclean TLS shutdowns
* Many thanks to [agibson2](https://github.com/agibson2) for the fingerprint patch
* Many thanks to [Adam Cécile](https://github.com/eLvErDe) for the nmap SNI patch
