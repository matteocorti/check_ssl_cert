
 (c) Matteo Corti, ETH Zurich, 2007-2012

 (c) Matteo Corti, 2007-2018

  see AUTHORS for the complete list of contributors

# check_ssl_cert

A Nagios plugin to check an X.509 certificate:
 - checks if the server is running and delivers a valid certificate
 - checks if the CA matches a given pattern
 - checks the validity

## Usage

```
check_ssl_cert -H host [OPTIONS]

Arguments:
   -H,--host host             server

Options:
   -A,--noauth                ignore authority warnings (expiration only)
      --altnames              matches the pattern specified in -n with alternate
                              names too
   -C,--clientcert path       use client certificate to authenticate
      --clientpass phrase     set passphrase for client certificate.
   -c,--critical days         minimum number of days a certificate has to be valid
                              to issue a critical status
      --curl-bin path         path of the curl binary to be used
   -d,--debug                 produces debugging output
   -e,--email address         pattern to match the email address contained in the
                              certificate
       --ecdsa                cipher selection: force ECDSA authentication
   -f,--file file             local file path (works with -H localhost only)
                              with -f you can not only pass a x509 certificate file
                              but also a certificate revocation list (CRL) to check
                              the validity period
      --file-bin path         path of the file binary to be used
      --fingerprint SHA1      pattern to match the SHA1-Fingerprint
      --force-perl-date       force the usage of Perl for date computations
   -h,--help,-?               this help message
      --ignore-exp            ignore expiration date
      --ignore-sig-alg        do not check if the certificate was signed with SHA1
                              or MD5
      --ignore-ocsp           do not check revocation with OCSP
   -i,--issuer issuer         pattern to match the issuer of the certificate
      --issuer-cert-cache dir directory where to store issuer certificates cache
   -L,--check-ssl-labs grade  SSL Labs assestment
                              (please check https://www.ssllabs.com/about/terms.html)
      --ignore-ssl-labs-cache Forces a new check by SSL Labs (see -L)
      --long-output list      append the specified comma separated (no spaces) list
                              of attributes to the plugin output on additional lines
                              Valid attributes are:
                                enddate, startdate, subject, issuer, modulus,
                                serial, hash, email, ocsp_uri and fingerprint.
                              'all' will include all the available attributes.
   -n,--cn name               pattern to match the CN of the certificate (can be
                              specified multiple times)
      --no_ssl2               disable SSL version 2
      --no_ssl3               disable SSL version 3
      --no_tls1               disable TLS version 1
      --no_tls1_1             disable TLS version 1.1
      --no_tls1_2             disable TLS version 1.2
   -N,--host-cn               match CN with the host name
   -o,--org org               pattern to match the organization of the certificate
      --openssl path          path of the openssl binary to be used
   -p,--port port             TCP port
   -P,--protocol protocol     use the specific protocol {http|smtp|pop3|imap|ftp|xmpp|irc|ldap}
                              http:                    default
                              smtp,pop3,imap,ftp,ldap: switch to TLS
   -s,--selfsigned            allows self-signed certificates
      --serial serialnum      pattern to match the serial number
      --ssl2                  force SSL version 2
      --ssl3                  force SSL version 3
      --require-san           require the presence of a Subject Alternative Name extension
   -r,--rootcert path         root certificate or directory to be used for
                              certificate validation
      --rsa                   cipher selection: force RSA authentication
      --terse                 terse output
   -t,--timeout               seconds timeout after the specified time
                              (defaults to 15 seconds)
      --temp dir              directory where to store the temporary files
      --tls1                  force TLS version 1
      --tls1_1                force TLS version 1.1
      --tls1_2                force TLS version 1.2
   -v,--verbose               verbose output
   -V,--version               version
   -w,--warning days          minimum number of days a certificate has to be valid
                              to issue a warning status

Deprecated options:
   -d,--days days             minimum number of days a certificate has to be valid
                              (see --critical and --warning)
      --ocsp                  check revocation via OCSP
   -S,--ssl version           force SSL version (2,3)
                              (see: --ssl2 or --ssl3)

```

## Expect

check_ssl_cert requires 'expect' to enable timeouts. If expect is not
present on your system timeouts will be disabled.

See: http://en.wikipedia.org/wiki/Expect

## Virtual servers

check_ssl_client supports the servername TLS extension in ClientHello
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
