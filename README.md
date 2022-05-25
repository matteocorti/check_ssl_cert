
 &copy; Matteo Corti, ETH Zurich, 2007-2012

 &copy; Matteo Corti, 2007-2022
  see AUTHORS.md for the complete list of contributors

# check\_ssl\_cert

A shell script (that can be used as a Nagios/Icinga plugin) to check an SSL/TLS connection

## Usage

```

Usage: check_ssl_cert -H host [OPTIONS]
       check_ssl_cert -f file [OPTIONS]

Arguments:
   -f,--file file                  Local file path or URI.
                                   With -f you can not only pass a x509
                                   certificate file but also a certificate
                                   revocation list (CRL) to check the
                                   validity period
   -H,--host host                  Server

Options:
   -A,--noauth                     Ignore authority warnings (expiration
                                   only)
      --all                        Enable all the possible optional checks
                                   at the maximum level
      --all-local                  Enable all the possible optional checks
                                   at the maximum level (without SSL-Labs)
      --allow-empty-san            Allow certificates without Subject
                                   Alternative Names (SANs)
   -C,--clientcert path            Use client certificate to authenticate
   -c,--critical days              Minimum number of days a certificate has
                                   to be valid to issue a critical status.
                                   Can be a floating point number, e.g., 0.5
                                   Default: 15
      --check-ciphers grade        Check the offered ciphers
      --check-ciphers-warnings     Critical if nmap reports a warning for an
                                   offered cipher
      --check-ssl-labs-warn grade  SSL Labs grade on which to warn
      --clientpass phrase          Set passphrase for client certificate.
      --crl                        Check revocation via CRL (requires
                                   --rootcert-file)
      --curl-bin path              Path of the curl binary to be used
      --curl-user-agent string     User agent that curl shall use to obtain
                                   the issuer cert
      --custom-http-header string  Custom HTTP header sent when getting the
                                   cert example: 'X-Check-Ssl-Cert: Foobar=1'
   -d,--debug                      Produce debugging output (can be
                                   specified more than once)
      --dane                       Verify that valid DANE records exist
                                   (since OpenSSL 1.1.0)
      --dane 211                   Verify that a valid DANE-TA(2) SPKI(1)
                                   SHA2-256(1) TLSA record exists
      --dane 301                   Verify that a valid DANE-EE(3) Cert(0)
                                   SHA2-256(1) TLSA record exists
      --dane 302                   Verify that a valid DANE-EE(3) Cert(0)
                                   SHA2-512(2) TLSA record exists
      --dane 311                   Verify that a valid DANE-EE(3) SPKI(1)
                                   SHA2-256(1) TLSA record exists
      --dane 312                   Verify that a valid DANE-EE(3)
                                   SPKI(1) SHA2-512(1) TLSA record exists
      --date path                  Path of the date binary to be used
      --debug-cert                 Store the retrieved certificates in the
                                   current directory
      --debug-file file            Write the debug messages to file
      --debug-time                 Write timing information in the
                                   debugging output
      --dtls                       Use the DTLS protocol
      --dtls1                      Use the DTLS protocol 1.0
      --dtls1_2                    Use the DTLS protocol 1.2
      --dig-bin path               Path of the dig binary to be used
   -e,--email address              Pattern to match the email address
                                   contained in the certificate
      --ecdsa                      Signature algorithm selection: force ECDSA
                                   certificate
      --element number             Check up to the N cert element from the
                                   beginning of the chain
      --file-bin path              Path of the file binary to be used
      --fingerprint SHA1           Pattern to match the SHA1-Fingerprint
      --first-element-only         Verify just the first cert element, not
                                   the whole chain
      --force-dconv-date           Force the usage of dconv for date
                                   computations
      --force-perl-date            Force the usage of Perl for date
                                   computations
      --format FORMAT              Format output template on success, for
                                   example: '%SHORTNAME% OK %CN% from
                                   %CA_ISSUER_MATCHED%'
                                   list of possible variables:
                                   - %HOST%
                                   - %PORT%
                                   - %CA_ISSUER_MATCHED%
                                   - %CHECKEDNAMES%
                                   - %CN%
                                   - %DATE%
                                   - %DAYS_VALID%
                                   - %DYSPLAY_CN%
                                   - %OPENSSL_COMMAND%
                                   - %SELFSIGNEDCERT%
                                   - %SHORTNAME%
                                   - %OCSP_EXPIRES_IN_HOURS%
                                   - %SSL_LABS_HOST_GRADE%
   -h,--help,-?                    This help message
      --http-use-get               Use GET instead of HEAD (default) for the
                                   HTTP related checks
   -i,--issuer issuer              Pattern to match the issuer of the
                                   certificate
      --ignore-altnames            Ignore alternative names when matching
                                   pattern specified in -n (or the host name)
      --ignore-connection-problems [state] In case of connection problems
                                   returns OK or the optional state
      --ignore-exp                 Ignore expiration date
      --ignore-host-cn             Do not complain if the CN does not match
                                   the host name
      --ignore-incomplete-chain    Do not check chain integrity
      --ignore-ocsp                Do not check revocation with OCSP
      --ignore-ocsp-errors         Continue if the OCSP status cannot be
                                   checked
      --ignore-ocsp-timeout        Ignore OCSP result when timeout occurs
                                   while checking
      --ignore-sct                 Do not check for signed certificate
                                   timestamps (SCT)
      --ignore-sig-alg             Do not check if the certificate was signed
                                   with SHA1 or MD5
      --ignore-ssl-labs-cache      Force a new check by SSL Labs (see -L)
      --ignore-tls-renegotiation   Ignore the TLS renegotiation check
      --inetproto protocol         Force IP version 4 or 6
      --info                       Print certificate information
      --init-host-cache            Initialize the host cache
      --issuer-cert-cache dir      Directory where to store issuer
                                   certificates cache
   -K,--clientkey path             Use client certificate key to authenticate
   -L,--check-ssl-labs grade       SSL Labs assessment (please check
                                   https://www.ssllabs.com/about/terms.html)
      --long-output list           Append the specified comma separated (no
                                   spaces) list of attributes to the plugin
                                   output on additional lines
                                   Valid attributes are:
                                     enddate, startdate, subject, issuer,
                                     modulus, serial, hash, email, ocsp_uri
                                     and fingerprint.
                                   'all' will include all the available
                                   attributes.
   -m,--match.                     Pattern to match the CN or AltName
                                   (can be specified multiple times)
      --nmap-bin path              Path of the nmap binary to be used
      --no-perf                    Do not show performance data
      --no-proxy                   Ignore the http_proxy and https_proxy
                                   environment variables
      --no-proxy-curl              Ignore the http_proxy and https_proxy
                                   environment variables for curl
      --no-proxy-s_client          Ignore the http_proxy and https_proxy
                                   environment variables for openssl s_client
      --no-ssl2                    Disable SSL version 2
      --no-ssl3                    Disable SSL version 3
      --no-tls1                    Disable TLS version 1
      --no-tls1_1                  Disable TLS version 1.1
      --no-tls1_2                  Disable TLS version 1.2
      --no-tls1_3                  Disable TLS version 1.3
      --not-issued-by issuer       Check that the issuer of the certificate
                                   does not match the given pattern
      --not-valid-longer-than days Critical if the certificate validity is
                                   longer than the specified period
   -o,--org org                    Pattern to match the organization of the
                                   certificate
      --ocsp-critical hours        Minimum number of hours an OCSP response
                                   has to be valid to issue a critical status
      --ocsp-warning hours         Minimum number of hours an OCSP response
                                   has to be valid to issue a warning status
      --openssl path               Path of the openssl binary to be used
   -p,--port port                  TCP port
      --precision digits           Number of decimal places for durations:
                                   defaults to 0 if critical or warning are
                                   integers, 2 otherwise
   -P,--protocol protocol          Use the specific protocol:
                                   ftp, ftps, http, https (default),
                                   h2 (HTTP/2), imap, imaps, irc, ircs, ldap,
                                   ldaps, mysql, pop3, pop3s, postgres,
                                   sieve, smtp, smtps, xmpp, xmpp-server.
                                   ftp, imap, irc, ldap, pop3, postgres,
                                   sieve, smtp: switch to TLS using StartTLS
      --password source            Password source for a local certificate,
                                   see the PASS PHRASE ARGUMENTS section
                                   openssl(1)
      --prometheus                 Generate Prometheus/OpenMetrics output
      --proxy proxy                Set http_proxy and the s_client -proxy
                                   option
   -q,--quiet                      Do not produce any output
   -r,--rootcert path              Root certificate or directory to be used
                                   for certificate validation
      --require-client-cert [list] The server must accept a client
                                   certificate. 'list' is an optional comma
                                   separated list of expected client
                                   certificate CAs
      --require-no-ssl2            Critical if SSL version 2 is offered
      --require-no-ssl3            Critical if SSL version 3 is offered
      --require-no-tls1            Critical if TLS 1 is offered
      --require-no-tls1_1          Critical if TLS 1.1 is offered
      --require-ocsp-stapling      Require OCSP stapling
      --resolve ip                 Provide a custom IP address for the
                                   specified host
      --rootcert-dir path          Root directory to be used for certificate
                                   validation
      --rootcert-file path         Root certificate to be used for
                                   certificate validation
      --rsa                        Signature algorithm selection: force RSA
                                   certificate
   -s,--selfsigned                 Allow self-signed certificates
      --serial serialnum           Pattern to match the serial number
      --skip-element number        Skip checks on the Nth cert element (can
                                   be specified multiple times)
      --sni name                   Set the TLS SNI (Server Name Indication)
                                   extension in the ClientHello message to
                                   'name'
      --ssl2                       Force SSL version 2
      --ssl3                       Force SSL version 3
   -t,--timeout seconds            Timeout after the specified time
                                   (defaults to 120 seconds)
      --temp dir                   Directory where to store the temporary
                                   files
      --terse                      Terse output
      --tls1                       Force TLS version 1
      --tls1_1                     Force TLS version 1.1
      --tls1_2                     Force TLS version 1.2
      --tls1_3                     Force TLS version 1.3
   -u,--url URL                    HTTP request URL
   -v,--verbose                    Verbose output (can be specified more than
                                   once)
   -V,--version                    Version
   -w,--warning days               Minimum number of days a certificate has
                                   to be valid to issue a warning status.
                                   Can be a floating point number, e.g., 0.5
                                   Default: 20
      --xmpphost name              Specify the host for the 'to' attribute
                                   of the stream element
   -4                              Force IPv4
   -6                              Force IPv6

Deprecated options:
      --altnames                   Match the pattern specified in -n with
                                   alternate names too (enabled by default)
      --days days                  Minimum number of days a certificate has
                                   to be valid
                                   (see --critical and --warning)
   -n,--cn name                    Pattern to match the CN or AltName
                                   (can be specified multiple times)
   -N,--host-cn                    Match CN with the host name
                                   (enabled by default)
      --no_ssl2                    Disable SSLv2 (deprecated use --no-ssl2)
      --no_ssl3                    Disable SSLv3 (deprecated use --no-ssl3)
      --no_tls1                    Disable TLSv1 (deprecated use --no-tls1)
      --no_tls1_1                  Disable TLSv1.1 (deprecated use
                                   --no-tls1_1)
      --no_tls1_2                  Disable TLSv1.1 (deprecated use
                                   --no-tls1_2)
      --no_tls1_3                  Disable TLSv1.1 (deprecated use
                                   --no-tls1_3)
      --ocsp                       Check revocation via OCSP (enabled by
                                   default)
      --require-san                Require the presence of a Subject
                                   Alternative Name
                                   extension
   -S,--ssl version                Force SSL version (2,3)
                                   (see: --ssl2 or --ssl3)

Report bugs to https://github.com/matteocorti/check_ssl_cert/issues
```

## Expect & timeout

check\_ssl\_cert requires [```expect```](http://en.wikipedia.org/wiki/Expect) or [```timeout```](https://man7.org/linux/man-pages/man1/timeout.1.html) to enable timeouts. If ```expect``` or ```timeout``` are not present on your system timeouts will be disabled.

## Virtual servers

check\_ssl\_cert supports the servername TLS extension in ClientHello
if the installed OpenSSL version provides it. This is needed if you
are checking a server with virtual hosts.

## SSL Labs

If `-L` or `--check-ssl-labs` are specified the plugin will check the
cached status using the [SSL Labs Assessment API](https://www.ssllabs.com/about/terms.html).

The plugin will ask for a cached result (maximum age 1 day) to avoid
too many checks. The first time you issue the check you could therefore
get an outdated result.

## Root Certificate

The root certificate corresponding to the checked certificate must be
available to OpenSSL or specified with the `-r cabundle` or
`--rootcert cabundle` option, where ```cabundle``` is either a file for `-CAfile`
or a directory for `-CApath`.

On macOS the root certificates bundle is stored in the Keychain and
OpenSSL will complain with:

```
verification error: unable to get local issuer certificate
```

The bundle can be extracted with:

```
$ sudo security find-certificate -a \
  -p /System/Library/Keychains/SystemRootCertificates.keychain > cabundle.crt
```

and then submitted to `check_ssl_cert` with the `-r,--rootcert path` option

```
 ./check_ssl_cert -H www.google.com -r ./cabundle.crt
```

## Quoting in Nagios

An asterisk ```*``` is automatically escaped by nagios. If you need to specify an option (e.g., ```--cn```) with an argument containing an asterisk you need to enclose it in double quotes (e.g., ```''*.github.com''```)

## bash completion and caching

Once the host name cache (```${HOME}/.check_ssl_cert-cache```) is initialized (with the ```--init-host-cache``` option), every specified host is cached.

The host name cache is a plain text file which contains an host name per line. Each time a new host is specified, it is automatically added to the cache. The file can be edited with a text editor (to delete or edit entries).

When using bash completion with the ```--host``` command line option the cache is then read and used as a suggestion.

## Development

### Testing

To run the test suite you will need [shUnit2](https://github.com/kward/shunit2)

 * Manual install: [github](https://github.com/kward/shunit2)
 * macOS with [Homebrew](https://brew.sh): ```brew install shunit2```
 * Debian, Ubuntu: ```apt-get install shunit2```
 * Fedora: ```dnf install shunit2```

Run ```make test``` to execute the whole test suite.

With ```make disttest``` you can check the formatting of the files (e.g. tabs and blanks at the end of the lines) and run ShellCheck to lint the scripts.

To run a single test:

 * set the ```SHUNIT2``` environment variable with the location of the shUnit2 binary
 * change the directory to the test suite: ```cd test```
 * execute the test suite with the tests to be run as argument after ```--```. For example ```./unit_tests.sh -- testName```

## Bugs

Report bugs to [https://github.com/matteocorti/check_ssl_cert/issues](https://github.com/matteocorti/check_ssl_cert/issues)
