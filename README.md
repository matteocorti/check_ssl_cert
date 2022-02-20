
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
   -f,--file file                  local file path or URI.
                                   With -f you can not only pass a x509
                                   certificate file but also a certificate
                                   revocation list (CRL) to check the
                                   validity period
   -H,--host host                  server

Options:
   -A,--noauth                     ignore authority warnings (expiration
                                   only)
      --all                        enables all the possible optional checks
                                   at the maximum level
      --all-local                  enables all the possible optional checks
                                   at the maximum level (without SSL-Labs)
      --allow-empty-san            allow certificates without Subject
                                   Alternative Names (SANs)
   -C,--clientcert path            use client certificate to authenticate
   -c,--critical days              minimum number of days a certificate has
                                   to be valid to issue a critical status.
                                   Can be a floating point number, e.g., 0.5
                                   Default: 15
      --check-ciphers grade        checks the offered ciphers
      --check-ciphers-warnings     critical if nmap reports a warning for an
                                   offered cipher
      --check-ssl-labs-warn grade  SSL Labs grade on which to warn
      --clientpass phrase          set passphrase for client certificate.
      --crl                        checks revocation via CRL (requires
                                   --rootcert-file)
      --curl-bin path              path of the curl binary to be used
      --curl-user-agent string     user agent that curl shall use to obtain
                                   the issuer cert
      --custom-http-header string  custom HTTP header sent when getting the
                                   cert example: 'X-Check-Ssl-Cert: Foobar=1'
   -d,--debug                      produces debugging output (can be
                                   specified more than once)
      --dane                       verify that valid DANE records exist
                                   (since OpenSSL 1.1.0)
      --dane 211                   verify that a valid DANE-TA(2) SPKI(1)
                                   SHA2-256(1) TLSA record exists
      --dane 301                   verify that a valid DANE-EE(3) Cert(0)
                                   SHA2-256(1) TLSA record exists
      --dane 302                   verify that a valid DANE-EE(3) Cert(0)
                                   SHA2-512(2) TLSA record exists
      --dane 311                   verify that a valid DANE-EE(3) SPKI(1)
                                   SHA2-256(1) TLSA record exists
      --dane 312                   verify that a valid DANE-EE(3)
                                   SPKI(1) SHA2-512(1) TLSA record exists
      --date path                  path of the date binary to be used
      --debug-cert                 stores the retrieved certificates in the
                                   current directory
      --debug-file file            writes the debug messages to file
      --debug-time                 writes timing information in the
                                   debugging output
      --dig-bin path               path of the dig binary to be used
   -e,--email address              pattern to match the email address
                                   contained in the certificate
      --ecdsa                      signature algorithm selection: force ECDSA
                                   certificate
      --element number             checks up to the N cert element from the
                                   beginning of the chain
      --file-bin path              path of the file binary to be used
      --fingerprint SHA1           pattern to match the SHA1-Fingerprint
      --first-element-only         verify just the first cert element, not
                                   the whole chain
      --force-dconv-date           force the usage of dconv for date
                                   computations
      --force-perl-date            force the usage of Perl for date
                                   computations
      --format FORMAT              format output template on success, for
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
   -h,--help,-?                    this help message
      --http-use-get               use GET instead of HEAD (default) for the
                                   HTTP related checks
   -i,--issuer issuer              pattern to match the issuer of the
                                   certificate
      --ignore-altnames            ignores alternative names when matching
                                   pattern specified in -n (or the host name)
      --ignore-connection-problems [state] in case of connection problems
                                   returns OK or the optional state
      --ignore-exp                 ignore expiration date
      --ignore-host-cn             do not complain if the CN does not match
                                   the host name
      --ignore-incomplete-chain    does not check chain integrity
      --ignore-ocsp                do not check revocation with OCSP
      --ignore-ocsp-errors         continue if the OCSP status cannot be
                                   checked
      --ignore-ocsp-timeout        ignore OCSP result when timeout occurs
                                   while checking
      --ignore-sct                 do not check for signed certificate
                                   timestamps (SCT)
      --ignore-sig-alg             do not check if the certificate was signed
                                   with SHA1 or MD5
      --ignore-ssl-labs-cache      Forces a new check by SSL Labs (see -L)
      --ignore-tls-renegotiation   Ignores the TLS renegotiation check
      --inetproto protocol         Force IP version 4 or 6
      --info                       Prints certificate information
      --issuer-cert-cache dir      directory where to store issuer
                                   certificates cache
   -K,--clientkey path             use client certificate key to authenticate
   -L,--check-ssl-labs grade       SSL Labs assessment (please check
                                   https://www.ssllabs.com/about/terms.html)
      --long-output list           append the specified comma separated (no
                                   spaces) list of attributes to the plugin
                                   output on additional lines
                                   Valid attributes are:
                                     enddate, startdate, subject, issuer,
                                     modulus, serial, hash, email, ocsp_uri
                                     and fingerprint.
                                   'all' will include all the available
                                   attributes.
   -n,--cn name                    pattern to match the CN of the certificate
                                   (can be specified multiple times)
      --nmap-bin path              path of the nmap binary to be used
      --no-perf                    do not show performance data
      --no-proxy                   ignores the http_proxy and https_proxy
                                   environment variables
      --no-proxy-curl              ignores the http_proxy and https_proxy
                                   environment variables for curl
      --no-proxy-s_client          ignores the http_proxy and https_proxy
                                   environment variables for openssl s_client
      --no-ssl2                    disable SSL version 2
      --no-ssl3                    disable SSL version 3
      --no-tls1                    disable TLS version 1
      --no-tls1_1                  disable TLS version 1.1
      --no-tls1_2                  disable TLS version 1.2
      --no-tls1_3                  disable TLS version 1.3
      --not-issued-by issuer       check that the issuer of the certificate
                                   does not match the given pattern
      --not-valid-longer-than days critical if the certificate validity is
                                   longer than the specified period
   -o,--org org                    pattern to match the organization of the
                                   certificate
      --ocsp-critical hours        minimum number of hours an OCSP response
                                   has to be valid to issue a critical status
      --ocsp-warning hours         minimum number of hours an OCSP response
                                   has to be valid to issue a warning status
      --openssl path               path of the openssl binary to be used
   -p,--port port                  TCP port
      --precision digits           number of decimal places for durations:
                                   defaults to 0 if critical or warning are
                                   integers, 2 otherwise
   -P,--protocol protocol          use the specific protocol:
                                   ftp, ftps, http, https (default),
                                   h2 (HTTP/2), imap, imaps, irc, ircs, ldap,
                                   ldaps, mysql, pop3, pop3s, postgres,
                                   sieve, smtp, smtps, xmpp, xmpp-server.
                                   ftp, imap, irc, ldap, pop3, postgres,
                                   sieve, smtp: switch to TLS using StartTLS
      --password source            password source for a local certificate,
                                   see the PASS PHRASE ARGUMENTS section
                                   openssl(1)
      --prometheus                 generates Prometheus/OpenMetrics output
      --proxy                      sets http_proxy and the s_client -proxy
   -q,--quiet                      do not produce any output
   -r,--rootcert path              root certificate or directory to be used
                                   for certificate validation
      --require-client-cert [list] the server must accept a client
                                   certificate. 'list' is an optional comma
                                   separated list of expected client
                                   certificate CAs
      --require-no-ssl2            critical if SSL version 2 is offered
      --require-no-ssl3            critical if SSL version 3 is offered
      --require-no-tls1            critical if TLS 1 is offered
      --require-no-tls1_1          critical if TLS 1.1 is offered
      --require-ocsp-stapling      require OCSP stapling
      --resolve ip                 provides a custom IP address for the
                                   specified host
      --rootcert-dir path          root directory to be used for certificate
                                   validation
      --rootcert-file path         root certificate to be used for
                                   certificate validation
      --rsa                        signature algorithm selection: force RSA
                                   certificate
   -s,--selfsigned                 allows self-signed certificates
      --serial serialnum           pattern to match the serial number
      --skip-element number        skips checks on the Nth cert element (can
                                   be specified multiple times)
      --sni name                   sets the TLS SNI (Server Name Indication)
                                   extension in the ClientHello message to
                                   'name'
      --ssl2                       force SSL version 2
      --ssl3                       force SSL version 3
   -t,--timeout                    seconds timeout after the specified time
                                   (defaults to 120 seconds)
      --temp dir                   directory where to store the temporary
                                   files
      --terse                      terse output
      --tls1                       force TLS version 1
      --tls1_1                     force TLS version 1.1
      --tls1_2                     force TLS version 1.2
      --tls1_3                     force TLS version 1.3
   -u,--url URL                    HTTP request URL
   -v,--verbose                    verbose output (can be specified more than
                                   once)
   -V,--version                    version
   -w,--warning days               minimum number of days a certificate has
                                   to be valid to issue a warning status.
                                   Can be a floating point number, e.g., 0.5
                                   Default: 20
      --xmpphost name              specifies the host for the 'to' attribute
                                   of the stream element
   -4                              force IPv4
   -6                              force IPv6

Deprecated options:
      --altnames                   matches the pattern specified in -n with
                                   alternate names too (enabled by default)
      --days days                  minimum number of days a certificate has
                                   to be valid
                                   (see --critical and --warning)
   -N,--host-cn                    match CN with the host name
                                   (enabled by default)
      --no_ssl2                    disable SSLv2 (deprecated use --no-ssl2)
      --no_ssl3                    disable SSLv3 (deprecated use --no-ssl3)
      --no_tls1                    disable TLSv1 (deprecated use --no-tls1)
      --no_tls1_1                  disable TLSv1.1 (deprecated use
                                   --no-tls1_1)
      --no_tls1_2                  disable TLSv1.1 (deprecated use
                                   --no-tls1_2)
      --no_tls1_3                  disable TLSv1.1 (deprecated use
                                   --no-tls1_3)
      --ocsp                       check revocation via OCSP (enabled by
                                   default)
      --require-san                require the presence of a Subject
                                   Alternative Name
                                   extension
   -S,--ssl version                force SSL version (2,3)
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
