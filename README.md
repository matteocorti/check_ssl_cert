
 (c) Matteo Corti, ETH Zurich, 2007-2012

 (c) Matteo Corti, 2007-2021
  see AUTHORS for the complete list of contributors

# check_ssl_cert

A shell script (that can be used as a Nagios plugin) to check an X.509 certificate:
 - checks if the server is running and delivers a valid certificate
 - checks if the CA matches a given pattern
 - checks the validity

## Usage

```

Usage: check_ssl_cert -H host [OPTIONS]

Arguments:
   -H,--host host                  server

Options:
   -A,--noauth                     ignore authority warnings (expiration only)
      --altnames                   matches the pattern specified in -n with
                                   alternate names too
      --check-ciphers grade        checks the offered ciphers
      --check-ciphers-warnings     critical if nmap reports a warning for an offered cipher
   -C,--clientcert path            use client certificate to authenticate
      --clientpass phrase          set passphrase for client certificate.
   -c,--critical days              minimum number of days a certificate has to
                                   be valid to issue a critical status. Default: 15
      --crl                        checks revokation via CRL (requires --rootcert-file)
      --curl-bin path              path of the curl binary to be used
      --curl-user-agent string     user agent that curl shall use to obtain the
                                   issuer cert
      --custom-http-header string  custom HTTP header sent when getting the cert
                                   example: 'X-Check-Ssl-Cert: Foobar=1'
      --dane                       verify that valid DANE records exist (since OpenSSL 1.1.0)
      --dane 211                   verify that a valid DANE-TA(2) SPKI(1) SHA2-256(1) TLSA record exists
      --dane 301                   verify that a valid DANE-EE(3) Cert(0) SHA2-256(1) TLSA record exists
      --dane 302                   verify that a valid DANE-EE(3) Cert(0) SHA2-512(2) TLSA record exists
      --dane 311                   verify that a valid DANE-EE(3) SPKI(1) SHA2-256(1) TLSA record exists
      --date path                  path of the date binary to be used
   -d,--debug                      produces debugging output
      --dig-bin path               path of the dig binary to be used
      --ecdsa                      signature algorithm selection: force ECDSA certificate
      --element number             checks N cert element from the begining of the chain
   -e,--email address              pattern to match the email address contained
                                   in the certificate
   -f,--file file                  local file path (works with -H localhost only)
                                   with -f you can not only pass a x509
                                   certificate file but also a certificate
                                   revocation list (CRL) to check the validity
                                   period
      --file-bin path              path of the file binary to be used
      --fingerprint SHA1           pattern to match the SHA1-Fingerprint
      --first-element-only         verify just the first cert element, not the whole chain
      --force-perl-date            force the usage of Perl for date computations
      --format FORMAT              format output template on success, for example
                                   "%SHORTNAME% OK %CN% from '%CA_ISSUER_MATCHED%'"
   -h,--help,-?                    this help message
      --http-use-get               use GET instead of HEAD (default) for the HTTP
                                   related checks
      --ignore-exp                 ignore expiration date
      --ignore-ocsp                do not check revocation with OCSP
      --ignore-ocsp-timeout        ignore OCSP result when timeout occurs while checking
      --ignore-sig-alg             do not check if the certificate was signed with SHA1
                                   or MD5
      --ignore-sct                 do not check for signed certificate timestamps (SCT)
      --ignore-ssl-labs-cache      Forces a new check by SSL Labs (see -L)
      --ignore-tls-renegotiation   Ignores the TLS renegotiation check
      --inetproto protocol         Force IP version 4 or 6
   -i,--issuer issuer              pattern to match the issuer of the certificate
      --issuer-cert-cache dir      directory where to store issuer certificates cache
   -K,--clientkey path             use client certificate key to authenticate
   -L,--check-ssl-labs grade       SSL Labs assessment
                                   (please check https://www.ssllabs.com/about/terms.html)
      --check-ssl-labs-warn grade  SSL-Labs grade on which to warn
      --long-output list           append the specified comma separated (no spaces) list
                                   of attributes to the plugin output on additional lines
                                   Valid attributes are:
                                     enddate, startdate, subject, issuer, modulus,
                                     serial, hash, email, ocsp_uri and fingerprint.
                                   'all' will include all the available attributes.
   -n,--cn name                    pattern to match the CN of the certificate (can be
                                   specified multiple times)
      --nmap-bin path              path of the nmap binary to be used
      --no_ssl2                    disable SSL version 2
      --no_ssl3                    disable SSL version 3
      --no_tls1                    disable TLS version 1
      --no_tls1_1                  disable TLS version 1.1
      --no_tls1_2                  disable TLS version 1.2
      --no_tls1_3                  disable TLS version 1.3
      --not-issued-by issuer       check that the issuer of the certificate does not match
                                   the given pattern
      --not-valid-longer-than days critical if the certificate validity is longer than
                                   the specified period
   -N,--host-cn                    match CN with the host name
      --ocsp-critical hours        minimum number of hours an OCSP response has to be valid to
                                   issue a critical status
      --ocsp-warning hours         minimum number of hours an OCSP response has to be valid to
                                   issue a warning status
   -o,--org org                    pattern to match the organization of the certificate
      --openssl path               path of the openssl binary to be used
      --password source            password source for a local certificate, see the PASS PHRASE ARGUMENTS section
                                   openssl(1)      
   -p,--port port                  TCP port
   -P,--protocol protocol          use the specific protocol
                                   {ftp|ftps|http|https|h2|imap|imaps|irc|ircs|ldap|ldaps|pop3|pop3s|
                                    postgres|sieve|smtp|smtps|xmpp|xmpp-server}
                                   https:                             default
                                   h2:                                forces HTTP/2
                                   ftp,imap,irc,ldap,pop3,postgres,sieve,smtp: switch to
                                   TLS using StartTLS
      --proxy proxy                sets http_proxy and the s_client -proxy option
      --require-no-ssl2            critical if SSL version 2 is offered
      --require-no-ssl3            critical if SSL version 3 is offered
      --require-no-tls1            critical if TLS 1 is offered
      --require-no-tls1_1          critical if TLS 1.1 is offered
   -s,--selfsigned                 allows self-signed certificates
      --serial serialnum           pattern to match the serial number
      --sni name                   sets the TLS SNI (Server Name Indication) extension
                                   in the ClientHello message to 'name'
      --ssl2                       forces SSL version 2
      --ssl3                       forces SSL version 3
      --require-ocsp-stapling      require OCSP stapling
      --require-san                require the presence of a Subject Alternative Name
                                   extension
   -r,--rootcert path              root certificate or directory to be used for
                                   certificate validation
      --rootcert-dir path          root directory to be used for certificate validation
      --rootcert-file path         root certificate to be used for certificate validation
      --rsa                        signature algorithm selection: force RSA certificate
      --temp dir                   directory where to store the temporary files
      --terse                      terse output
   -t,--timeout                    seconds timeout after the specified time
                                   (defaults to 120 seconds)
      --tls1                       force TLS version 1
      --tls1_1                     force TLS version 1.1
      --tls1_2                     force TLS version 1.2
      --tls1_3                     force TLS version 1.3
   -u,--url URL                    HTTP request URL
   -v,--verbose                    verbose output
   -V,--version                    version
   -w,--warning days               minimum number of days a certificate has to be valid
                                   to issue a warning status. Default: 20
      --xmpphost name              specifies the host for the 'to' attribute of the stream element
   -4                              force IPv4
   -6                              force IPv6

Deprecated options:
      --days days                  minimum number of days a certificate has to be valid
                                   (see --critical and --warning)
      --ocsp                       check revocation via OCSP
   -S,--ssl version                force SSL version (2,3)
                                   (see: --ssl2 or --ssl3)

Report bugs to https://github.com/matteocorti/check_ssl_cert/issues

```

## Expect & timeout

check_ssl_cert requires 'expect' or 'timeout' to enable timeouts. If 'expect' or 'timeout' is not
present on your system timeouts will be disabled.

See: http://en.wikipedia.org/wiki/Expect and https://man7.org/linux/man-pages/man1/timeout.1.html


## Virtual servers

check_ssl_cert supports the servername TLS extension in ClientHello
if the installed openssl version provides it. This is needed if you
are checking a machine with virtual hosts.

## SSL Labs

If `-L` or `--check-ssl-labs` are specified the plugin will check the
cached status using the SSL Labs Assessment API (see
https://www.ssllabs.com/about/terms.html).

The plugin will ask for a cached result (maximum age 1 day) to avoid
to many checks. The first time you issue the check you could therefore
get an outdated result.

## Notes

The root certificate corresponding to the checked certificate must be
available to openssl or specified with the `-r cabundle` or
`--rootcert cabundle` option, where cabundle is either a file for `-CAfile`
or a directory for `-CApath`.

On macOS the root certificates bundle is stored in the Keychain and
openssl will complain with:

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

## Bugs

The timeout is applied to each action involving a download.

Report bugs to https://github.com/matteocorti/check_ssl_cert/issues
