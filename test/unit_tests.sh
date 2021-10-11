#!/bin/sh

# $SHUNIT2 should be defined as an environment variable before running the tests
# shellcheck disable=SC2154
if [ -z "${SHUNIT2}" ]; then
    cat <<EOF
To be able to run the unit test you need a copy of shUnit2
You can download it from https://github.com/kward/shunit2

Once downloaded please set the SHUNIT2 variable with the location
of the 'shunit2' script
EOF
    exit 1
fi

if [ ! -x "${SHUNIT2}" ]; then
    echo "Error: the specified shUnit2 script (${SHUNIT2}) is not an executable file"
    exit 1
fi

SIGNALS="HUP INT QUIT TERM ABRT"
LC_ALL=C

SCRIPT=../check_ssl_cert
if [ ! -r "${SCRIPT}" ]; then
    echo "Error: the script to test (${SCRIPT}) is not a readable file"
fi

##############################################################################
# Utilities

create_temporary_test_file() {

    SUFFIX=$1

    if mktemp --help 2>&1 | grep -q 'TEMPLATE must end with XXXXXX'; then
        # no suffix possible
        SUFFIX=
    fi

    # create a temporary file
    TEMPFILE="$(mktemp "${TMPDIR}/XXXXXX${SUFFIX}" 2>/dev/null)"

    if [ -z "${TEMPFILE}" ] || [ ! -w "${TEMPFILE}" ]; then
        fail 'temporary file creation failure.'
    fi

    # add the file to the list of temporary files
    TEMPORARY_FILES="${TEMPORARY_FILES} ${TEMPFILE}"

}

remove_temporary_test_files() {
    # shellcheck disable=SC2086
    if [ -n "${TEMPORARY_FILES}" ]; then
        rm -f ${TEMPORARY_FILES}
    fi
}

cleanup_temporary_test_files() {
    SIGNALS=$1
    remove_temporary_test_files
    # shellcheck disable=SC2086
    trap - ${SIGNALS}
}

createSelfSignedCertificate() {

    DAYS=$1

    if [ -z "${DAYS}" ]; then
        DAYS=30 # default
    fi

    create_temporary_test_file
    CONFIGURATION=${TEMPFILE}
    create_temporary_test_file
    KEY=${TEMPFILE}
    create_temporary_test_file
    CERTIFICATE=${TEMPFILE}

    cat <<'EOT' >"${CONFIGURATION}"
[ req ]
default_bits = 2048

prompt = no
distinguished_name=req_distinguished_name
req_extensions = v3_req

[ req_distinguished_name ]
countryName=CH
stateOrProvinceName=ZH
localityName=Zurich
organizationName=Matteo Corti
organizationalUnitName=None
commonName=localhost
emailAddress=matteo@corti.li

[ alternate_names ]
DNS.1        = localhost

[ v3_req ]
keyUsage=digitalSignature
subjectKeyIdentifier = hash
subjectAltName = @alternate_names
EOT

    ${OPENSSL} genrsa -out "${KEY}" 2048 >/dev/null 2>&1

    ${OPENSSL} req -new -x509 -key "${KEY}" -out "${CERTIFICATE}" -days "${DAYS}" -config "${CONFIGURATION}"

    echo "${CERTIFICATE}"

}

##############################################################################
# Initial setup

oneTimeSetUp() {
    # constants

    NAGIOS_OK=0
    NAGIOS_WARNING=1
    NAGIOS_CRITICAL=2
    NAGIOS_UNKNOWN=3

    if [ -z "${TMPDIR}" ]; then
        TMPDIR=/tmp
    fi

    # Cleanup before program termination
    # Using named signals to be POSIX compliant
    # shellcheck disable=SC2086
    trap_with_arg cleanup ${SIGNALS}

    # we trigger a test by Qualy's SSL so that when the last test is run the result will be cached
    echo 'Starting SSL Lab test (to cache the result)'
    curl --silent 'https://www.ssllabs.com/ssltest/analyze.html?d=ethz.ch&latest' >/dev/null

    # check in OpenSSL supports dane checks
    if "${OPENSSL}" s_client -help 2>&1 | grep -q -- -dane_tlsa_rrdata || "${OPENSSL}" s_client not_a_real_option 2>&1 | grep -q -- -dane_tlsa_rrdata; then
        echo "dane checks supported"
        DANE=1
    fi

    # print the openssl version
    echo 'OpenSSL version'
    if [ -z "${OPENSSL}" ]; then
        OPENSSL=$(command -v openssl) # needed by openssl_version
    fi
    "${OPENSSL}" version

}

oneTimeTearDown() {
    # Cleanup before program termination
    # Using named signals to be POSIX compliant
    # shellcheck disable=SC2086
    cleanup_temporary_test_files ${SIGNALS}
}

##############################################################################
# Tests

testHoursUntilNow() {
    # testing with perl
    export DATETYPE='PERL'
    hours_until "$(date)"
    assertEquals "error computing the missing hours until now" 0 "${HOURS_UNTIL}"
}

testHoursUntil5Hours() {
    # testing with perl
    export DATETYPE='PERL'
    hours_until "$(perl -e '$x=localtime(time+(5*3600));print $x')"
    assertEquals "error computing the missing hours until now" 5 "${HOURS_UNTIL}"
}

testHoursUntil42Hours() {
    # testing with perl
    export DATETYPE='PERL'
    hours_until "$(perl -e '$x=localtime(time+(42*3600));print $x')"
    assertEquals "error computing the missing hours until now" 42 "${HOURS_UNTIL}"
}

testOpenSSLVersion1() {
    export OPENSSL_VERSION='OpenSSL 1.1.1j  16 Feb 2021'
    export REQUIRED_VERSION='1.2.0a'
    if [ -z "${OPENSSL}" ]; then
        OPENSSL=$(command -v openssl) # needed by openssl_version
    fi
    openssl_version "${REQUIRED_VERSION}"
    RET=$?
    assertEquals "error comparing required version ${REQUIRED_VERSION} to current version ${OPENSSL_VERSION}" 1 "${RET}"
    export OPENSSL_VERSION=
}

testOpenSSLVersion2() {
    export OPENSSL_VERSION='OpenSSL 1.1.1j  16 Feb 2021'
    export REQUIRED_VERSION='1.1.1j'
    if [ -z "${OPENSSL}" ]; then
        OPENSSL=$(command -v openssl) # needed by openssl_version
    fi
    openssl_version "${REQUIRED_VERSION}"
    RET=$?
    assertEquals "error comparing required version ${REQUIRED_VERSION} to current version ${OPENSSL_VERSION}" 0 "${RET}"
    export OPENSSL_VERSION=
}

testOpenSSLVersion3() {
    export OPENSSL_VERSION='OpenSSL 1.1.1j  16 Feb 2021'
    export REQUIRED_VERSION='1.0.0b'
    if [ -z "${OPENSSL}" ]; then
        OPENSSL=$(command -v openssl) # needed by openssl_version
    fi
    openssl_version "${REQUIRED_VERSION}"
    RET=$?
    assertEquals "error comparing required version ${REQUIRED_VERSION} to current version ${OPENSSL_VERSION}" 0 "${RET}"
    export OPENSSL_VERSION=
}

testOpenSSLVersion4() {
    export OPENSSL_VERSION='OpenSSL 1.0.2k-fips 26 Jan 2017'
    export REQUIRED_VERSION='1.0.0b'
    if [ -z "${OPENSSL}" ]; then
        OPENSSL=$(command -v openssl) # needed by openssl_version
    fi
    openssl_version "${REQUIRED_VERSION}"
    RET=$?
    assertEquals "error comparing required version ${REQUIRED_VERSION} to current version ${OPENSSL_VERSION}" 0 "${RET}"
    export OPENSSL_VERSION=
}

testOpenSSLVersion5() {
    export OPENSSL_VERSION='OpenSSL 1.1.1h-freebsd 22 Sep 2020'
    export REQUIRED_VERSION='1.0.0b'
    if [ -z "${OPENSSL}" ]; then
        OPENSSL=$(command -v openssl) # needed by openssl_version
    fi
    openssl_version "${REQUIRED_VERSION}"
    RET=$?
    assertEquals "error comparing required version ${REQUIRED_VERSION} to current version ${OPENSSL_VERSION}" 0 "${RET}"
    export OPENSSL_VERSION=
}

testDependencies() {
    check_required_prog openssl
    # $PROG is defined in the script
    # shellcheck disable=SC2154
    assertNotNull 'openssl not found' "${PROG}"
}

testSCT() {
    if [ -z "${OPENSSL}" ]; then
        OPENSSL=$(command -v openssl) # needed by openssl_version
    fi
    ${OPENSSL} version
    if openssl_version '1.1.0'; then
        echo "OpenSSL >= 1.1.0: SCTs supported"
        ${SCRIPT} --rootcert-file cabundle.crt -H no-sct.badssl.com -c 1 -w 2 --ignore-exp
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
    else
        echo "OpenSSL < 1.1.0: SCTs not supported"
        ${SCRIPT} --rootcert-file cabundle.crt -H no-sct.badssl.com -c 1 -w 2 --ignore-exp
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    fi
}

testUsage() {
    ${SCRIPT} >/dev/null 2>&1
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
}

testMissingArgument() {
    ${SCRIPT} --rootcert-file cabundle.crt -H www.google.com --critical >/dev/null 2>&1
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
}

testMissingArgument2() {
    ${SCRIPT} --rootcert-file cabundle.crt -H www.google.com --critical --warning 10 >/dev/null 2>&1
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
}

testGroupedVariables() {
    ${SCRIPT} --rootcert-file cabundle.crt -H www.google.com -vvv >/dev/null 2>&1
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testGroupedVariablesError() {
    ${SCRIPT} --rootcert-file cabundle.crt -H www.google.com -vvxv >/dev/null 2>&1
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
}

testPrometheus() {
    OUTPUT=$(${SCRIPT} --rootcert-file cabundle.crt -H ethz.ch --prometheus --critical 1000 --warning 1100)
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
    assertContains "wrong output" "${OUTPUT}" '# HELP cert_valid '
    assertContains "wrong output" "${OUTPUT}" 'cert_valid_chain_elem{cn="ethz.ch", element=1} 2'
    assertContains "wrong output" "${OUTPUT}" 'cert_days_chain_elem{cn="ethz.ch", element=1}'
}

testETHZ() {
    ${SCRIPT} --rootcert-file cabundle.crt -H ethz.ch --cn ethz.ch --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testLetsEncrypt() {
    ${SCRIPT} --rootcert-file cabundle.crt -H helloworld.letsencrypt.org --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testGoDaddy() {
    ${SCRIPT} --rootcert-file cabundle.crt -H www.godaddy.com --cn www.godaddy.com --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testETHZCaseInsensitive() {
    ${SCRIPT} --rootcert-file cabundle.crt -H ethz.ch --cn ETHZ.CH --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testIPOK() {
    ${SCRIPT} --rootcert-file cabundle.crt -H 138.201.94.172 --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testIPOKAltName() {
    ${SCRIPT} --rootcert-file cabundle.crt -H 138.201.94.172 --cn pasi.corti.li --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testIPFailAltName() {
    ${SCRIPT} --rootcert-file cabundle.crt -H 138.201.94.172 --cn bogus.corti.li --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testETHZWildCard() {
    # * should not match, see https://serverfault.com/questions/310530/should-a-wildcard-ssl-certificate-secure-both-the-root-domain-as-well-as-the-sub
    # we ignore the altnames as sp.ethz.ch is listed
    ${SCRIPT} --rootcert-file cabundle.crt -H sherlock.sp.ethz.ch --cn sp.ethz.ch --ignore-altnames --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testETHZWildCardCaseInsensitive() {
    # * should not match, see https://serverfault.com/questions/310530/should-a-wildcard-ssl-certificate-secure-both-the-root-domain-as-well-as-the-sub
    # we ignore the altnames as sp.ethz.ch is listed
    ${SCRIPT} --rootcert-file cabundle.crt -H sherlock.sp.ethz.ch --cn SP.ETHZ.CH --ignore-altnames --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testETHZWildCardSub() {
    ${SCRIPT} --rootcert-file cabundle.crt -H sherlock.sp.ethz.ch --cn sub.sp.ethz.ch --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testETHZWildCardSubCaseInsensitive() {
    ${SCRIPT} --rootcert-file cabundle.crt -H sherlock.sp.ethz.ch --cn SUB.SP.ETHZ.CH --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testRootIssuer() {
    ${SCRIPT} --rootcert-file cabundle.crt -H ethz.ch --issuer 'QuoVadis Limited' --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testValidity() {
    # Tests bug #8
    ${SCRIPT} --rootcert-file cabundle.crt -H www.ethz.ch -w 1000
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_WARNING}" "${EXIT_CODE}"
}

testValidityWithPerl() {
    ${SCRIPT} --rootcert-file cabundle.crt -H www.ethz.ch -w 1000 --force-perl-date
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_WARNING}" "${EXIT_CODE}"
}

testAltNames() {
    ${SCRIPT} --rootcert-file cabundle.crt -H www.inf.ethz.ch --cn www.inf.ethz.ch --altnames --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

#Do not require to match Alternative Name if CN already matched
testWildcardAltNames1() {
    ${SCRIPT} --rootcert-file cabundle.crt -H sherlock.sp.ethz.ch --altnames --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

#Check for wildcard support in Alternative Names
testWildcardAltNames2() {
    ${SCRIPT} --rootcert-file cabundle.crt -H sherlock.sp.ethz.ch \
        --cn somehost.spapps.ethz.ch \
        --cn otherhost.sPaPPs.ethz.ch \
        --cn spapps.ethz.ch \
        --critical 1 --warning 2 \
        --altnames

    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testAltNamesCaseInsensitve() {
    ${SCRIPT} --rootcert-file cabundle.crt -H www.inf.ethz.ch --cn WWW.INF.ETHZ.CH --altnames --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testMultipleAltNamesOK() {
    # Test with multiple CN's
    ${SCRIPT} --rootcert-file cabundle.crt -H corti.li -n www.corti.li -n rpm.corti.li --altnames --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testMultipleAltNamesFailOne() {
    # Test with wiltiple CN's but last one is wrong
    ${SCRIPT} --rootcert-file cabundle.crt -H inf.ethz.ch -n www.ethz.ch -n wrong.ch --altnames --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testMultipleAltNamesFailTwo() {
    # Test with multiple CN's but first one is wrong
    ${SCRIPT} --rootcert-file cabundle.crt -H inf.ethz.ch -n wrong.ch -n www.ethz.ch --altnames --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testXMPPHost() {
    out=$(${SCRIPT} --rootcert-file cabundle.crt -H prosody.xmpp.is --port 5222 --protocol xmpp --xmpphost xmpp.is --critical 1 --warning 2)
    EXIT_CODE=$?
    if echo "${out}" | grep -q "s_client' does not support '-xmpphost'"; then
        assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
    else
        assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    fi
}

testTimeOut() {
    ${SCRIPT} --rootcert-file cabundle.crt -H gmail.com --protocol imap --port 993 --timeout 1 --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testIMAP() {
    # minimal critical and warning as they renew pretty late
    ${SCRIPT} --rootcert-file cabundle.crt -H imap.gmx.com --port 143 --timeout 30 --protocol imap --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testIMAPS() {
    ${SCRIPT} --rootcert-file cabundle.crt -H imap.gmail.com --port 993 --timeout 30 --protocol imaps --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testPOP3S() {
    ${SCRIPT} --rootcert-file cabundle.crt -H pop.gmail.com --port 995 --timeout 30 --protocol pop3s --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testSMTP() {
    ${SCRIPT} --rootcert-file cabundle.crt -H smtp.gmail.com --protocol smtp --port 25 --timeout 60 --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testSMTPSubmbission() {
    ${SCRIPT} --rootcert-file cabundle.crt -H smtp.gmail.com --protocol smtp --port 587 --timeout 60 --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testSMTPS() {
    ${SCRIPT} --rootcert-file cabundle.crt -H smtp.gmail.com --protocol smtps --port 465 --timeout 60 --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

# Disabled as test.rebex.net is currently not workin. Should find another public FTP server with TLS
#testFTP() {
#    ${SCRIPT} --rootcert-file cabundle.crt -H test.rebex.net --protocol ftp --port 21 --timeout 60
#    EXIT_CODE=$?
#    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
#}
#
#testFTPS() {
#    ${SCRIPT} --rootcert-file cabundle.crt -H test.rebex.net --protocol ftps --port 990 --timeout 60
#    EXIT_CODE=$?
#    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
#}

################################################################################
# From https://badssl.com

testBadSSLExpired() {
    ${SCRIPT} --rootcert-file cabundle.crt -H expired.badssl.com --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLExpiredAndWarnThreshold() {
    ${SCRIPT} --rootcert-file cabundle.crt -H expired.badssl.com --warning 3000
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLWrongHost() {
    ${SCRIPT} --rootcert-file cabundle.crt -H wrong.host.badssl.com --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLSelfSigned() {
    ${SCRIPT} --rootcert-file cabundle.crt -H self-signed.badssl.com --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLUntrustedRoot() {
    ${SCRIPT} --rootcert-file cabundle.crt -H untrusted-root.badssl.com --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLRevoked() {
    ${SCRIPT} --rootcert-file cabundle.crt -H revoked.badssl.com --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLRevokedCRL() {
    ${SCRIPT} --rootcert-file cabundle.crt -H revoked.badssl.com --crl --ignore-ocsp --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testGRCRevoked() {
    ${SCRIPT} --rootcert-file cabundle.crt -H revoked.grc.com --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLIncompleteChain() {
    ${SCRIPT} --rootcert-file cabundle.crt -H incomplete-chain.badssl.com --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLDH480() {
    ${SCRIPT} --rootcert-file cabundle.crt -H dh480.badssl.com --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLDH512() {
    ${SCRIPT} --rootcert-file cabundle.crt -H dh512.badssl.com --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLRC4MD5() {
    # older versions of OpenSSL validate RC4-MD5
    if ! "${OPENSSL}" ciphers RC4-MD5 >/dev/null 2>&1; then
        ${SCRIPT} --rootcert-file cabundle.crt -H rc4-md5.badssl.com --critical 1 --warning 2
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
    else
        echo "OpenSSL too old to test RC4-MD5 ciphers"
    fi
}

testBadSSLRC4() {
    # older versions of OpenSSL validate RC4
    if ! "${OPENSSL}" ciphers RC4 >/dev/null 2>&1; then
        ${SCRIPT} --rootcert-file cabundle.crt -H rc4.badssl.com --critical 1 --warning 2
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
    else
        echo "OpenSSL too old to test RC4-MD5 ciphers"
    fi
}

testBadSSL3DES() {
    # older versions of OpenSSL validate RC4
    if ! "${OPENSSL}" ciphers 3DES >/dev/null 2>&1; then
        ${SCRIPT} --rootcert-file cabundle.crt -H 3des.badssl.com --critical 1 --warning 2
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
    else
        echo "OpenSSL too old to test 3DES ciphers"
    fi
}

testBadSSLNULL() {
    ${SCRIPT} --rootcert-file cabundle.crt -H null.badssl.com --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLSHA256() {
    ${SCRIPT} --rootcert-file cabundle.crt -H sha256.badssl.com --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testBadSSLEcc256() {
    ${SCRIPT} --rootcert-file cabundle.crt -H ecc256.badssl.com --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testBadSSLEcc384() {
    ${SCRIPT} --rootcert-file cabundle.crt -H ecc384.badssl.com --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testBadSSLRSA8192() {
    ${SCRIPT} --rootcert-file cabundle.crt -H rsa8192.badssl.com --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testBadSSLLongSubdomainWithDashes() {
    ${SCRIPT} --rootcert-file cabundle.crt -H long-extended-subdomain-name-containing-many-letters-and-dashes.badssl.com --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testBadSSLLongSubdomain() {
    ${SCRIPT} --rootcert-file cabundle.crt -H longextendedsubdomainnamewithoutdashesinordertotestwordwrapping.badssl.com --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testBadSSLSHA12016() {
    ${SCRIPT} --rootcert-file cabundle.crt -H sha1-2016.badssl.com --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLSHA12017() {
    ${SCRIPT} --rootcert-file cabundle.crt -H sha1-2017.badssl.com --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testRequireOCSP() {
    ${SCRIPT} --rootcert-file cabundle.crt -H videolan.org --require-ocsp-stapling --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

# tests for -4 and -6
testIPv4() {
    if "${OPENSSL}" s_client -help 2>&1 | grep -q -- -4; then
        ${SCRIPT} --rootcert-file cabundle.crt -H www.google.com -4 --critical 1 --warning 2
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    else
        echo "Skipping forcing IPv4: no OpenSSL support"
    fi
}

testIPv6() {
    if "${OPENSSL}" s_client -help 2>&1 | grep -q -- -6; then

        IPV6=
        if command -v ifconfig >/dev/null && ifconfig -a | grep -q -F inet6; then
            IPV6=1
        elif command -v ip >/dev/null && ip addr | grep -q -F inet6; then
            IPV6=1
        fi

        if [ -n "${IPV6}" ]; then

            echo "IPv6 is configured"

            if ping -c 3 -6 www.google.com >/dev/null 2>&1; then

                ${SCRIPT} --rootcert-file cabundle.crt -H www.google.com -6 --critical 1 --warning 2
                EXIT_CODE=$?
                assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"

            else
                echo "IPv6 is configured but not working: skipping test"
            fi

        else
            echo "Skipping forcing IPv6: not IPv6 configured locally"
        fi

    else
        echo "Skipping forcing IPv6: no OpenSSL support"
    fi
}

testFormatShort() {
    OUTPUT=$(${SCRIPT} --rootcert-file cabundle.crt -H ethz.ch --cn ethz.ch --critical 1 --warning 2 --format "%SHORTNAME% OK %CN% from '%CA_ISSUER_MATCHED%'" | cut '-d|' -f 1)
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    assertEquals "wrong output" "SSL_CERT OK ethz.ch from 'QuoVadis Europe SSL CA G2'" "${OUTPUT}"
}

testMoreErrors() {
    OUTPUT=$(${SCRIPT} --rootcert-file cabundle.crt -H www.ethz.ch -v --email doesnotexist --critical 1000 --warning 1001 | wc -l | sed 's/\ //g')
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    # we should get three lines: the plugin output and three errors
    assertEquals "wrong number of errors" 4 "${OUTPUT}"
}

testMoreErrors2() {
    OUTPUT=$(${SCRIPT} --rootcert-file cabundle.crt -H www.ethz.ch -v --email doesnotexist --warning 1000 --warning 1001 --verbose | wc -l | sed 's/\ //g')
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    # we should get three lines: the plugin output and three errors
    assertEquals "wrong number of errors" 4 "${OUTPUT}"
}

# dane

testDANE211() {
    # dig is needed for DANE
    if command -v dig >/dev/null; then

        # on github actions the dig command produces no output
        if dig +short TLSA _25._tcp.hummus.csx.cam.ac.uk | grep -q -f 'hummus'; then

            # check if a connection is possible
            if printf 'QUIT\\n' | "${OPENSSL}" s_client -connect hummus.csx.cam.ac.uk:25 -starttls smtp >/dev/null 2>&1; then
                ${SCRIPT} --rootcert-file cabundle.crt --dane 211 --port 25 -P smtp -H hummus.csx.cam.ac.uk --critical 1 --warning 2
                EXIT_CODE=$?
                if [ -n "${DANE}" ]; then
                    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
                else
                    assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
                fi
            else
                echo "connection to hummus.csx.cam.ac.uk:25 not possible: skipping test"
            fi
        else
            echo "no TLSA entries in DNS: skipping DANE test"
        fi
    else
        echo "dig not available: skipping DANE test"
    fi
}

# does not work anymore
#testDANE311SMTP() {
#    ${SCRIPT} --rootcert-file cabundle.crt --dane 311 --port 25 -P smtp -H mail.ietf.org
#    EXIT_CODE=$?
#    if [ -n "${DANE}" ] ; then
#        assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
#    else
#        assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
#    fi
#}
#
#testDANE311() {
#    ${SCRIPT} --rootcert-file cabundle.crt --dane 311 -H www.ietf.org
#    EXIT_CODE=$?
#    if [ -n "${DANE}" ] ; then
#        assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
#    else
#        assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
#    fi
#}
#
#testDANE301ECDSA() {
#    if command -v dig > /dev/null ; then
#        ${SCRIPT} --rootcert-file cabundle.crt --dane 301 --ecdsa -H mail.aegee.org --critical 1 --warning 2
#        EXIT_CODE=$?
#        if [ -n "${DANE}" ] ; then
#            assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
#        else
#            assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
#        fi
#    else
#        echo "dig not available: skipping DANE test"
#    fi
#}

testRequiredProgramFile() {
    ${SCRIPT} --rootcert-file cabundle.crt -H www.google.com --file-bin /doesnotexist --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
}

testRequiredProgramPermissions() {
    ${SCRIPT} --rootcert-file cabundle.crt -H www.google.com --file-bin /etc/hosts --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
}

testSieveECDSA() {
    if ! { "${OPENSSL}" s_client -starttls sieve 2>&1 | grep -F -q 'Value must be one of:' || "${OPENSSL}" s_client -starttls sieve 2>&1 | grep -F -q 'usage:'; }; then
        ${SCRIPT} --rootcert-file cabundle.crt -P sieve -p 4190 -H mail.aegee.org --ecdsa --critical 1 --warning 2
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    else
        echo "Skipping sieve tests (not supported)"
    fi
}

testHTTP2() {
    ${SCRIPT} --rootcert-file cabundle.crt -H rwserve.readwritetools.com --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testForceHTTP2() {
    if "${OPENSSL}" s_client -help 2>&1 | grep -q -F alpn; then
        ${SCRIPT} --rootcert-file cabundle.crt -H www.ethz.ch --protocol h2 --critical 1 --warning 2
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    else
        echo "Skupping forced HTTP2 test as -alpn is not supported"
    fi
}

testNotLongerValidThan() {
    ${SCRIPT} --rootcert-file cabundle.crt -H www.ethz.ch --not-valid-longer-than 2 --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testDERCert() {
    ${SCRIPT} --rootcert-file cabundle.crt -H localhost -f ./der.cer --ignore-sct --critical 1 --warning 2 --allow-empty-san
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testDERCertSymbolicLink() {
    ${SCRIPT} --rootcert-file cabundle.crt -H localhost -f ./derlink.cer --ignore-sct --critical 1 --warning 2 --allow-empty-san
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testPKCS12Cert() {
    export PASS=
    ${SCRIPT} --rootcert-file cabundle.crt -H localhost -f ./client.p12 --ignore-sct --password env:PASS --critical 1 --warning 2 --allow-empty-san
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testCertificsteWithoutCN() {
    ${SCRIPT} --rootcert-file cabundle.crt -H localhost -n www.uue.org -f ./cert_with_subject_without_cn.crt --force-perl-date --ignore-sig-alg --ignore-sct --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testCertificsteWithEmptySubject() {
    ${SCRIPT} --rootcert-file cabundle.crt -H localhost -n www.uue.org -f ./cert_with_empty_subject.crt --force-perl-date --ignore-sig-alg --ignore-sct --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testResolveSameName() {
    ${SCRIPT} --rootcert-file cabundle.crt -H www.ethz.ch --resolve www.ethz.ch --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testResolveDifferentName() {
    ${SCRIPT} --rootcert-file cabundle.crt -H corti.li --resolve www.google.com --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

#testNewQuoVadis() {
#    ${SCRIPT} --rootcert-file cabundle.crt -H matteo.ethz.ch
#    EXIT_CODE=$?
#    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
#}

testResolveCorrectIP() {
    # dig is needed to resolve the IP address
    if command -v dig >/dev/null; then
        ${SCRIPT} --rootcert-file cabundle.crt -H ethz.ch --resolve "$(dig +short ethz.ch)" --critical 1 --warning 2
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    else
        echo 'dig missing: skipping test'
    fi
}

testResolveWrongIP() {
    # dig is needed to resolve the IP address
    if command -v dig >/dev/null; then
        ${SCRIPT} --rootcert-file cabundle.crt -H corti.li --resolve "$(dig +short www.google.com)" --critical 1 --warning 2
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
    else
        echo 'dig missing: skipping test'
    fi
}

testCiphersOK() {

    # nmap ssl-enum-ciphers dumps core on CentOS 7 and RHEL 7
    if [ -f /etc/redhat-release ] && grep -q '.*Linux.*release\ 7\.' /etc/redhat-release; then
        echo 'Skipping tests on CentOS and RedHat 7 since nmap is crashing (core dump)'
    else

        # check if nmap is installed
        if command -v nmap >/dev/null; then

            # check if ssl-enum-ciphers is present
            if ! nmap --script ssl-enum-ciphers 2>&1 | grep -q -F 'NSE: failed to initialize the script engine'; then

                ${SCRIPT} --rootcert-file cabundle.crt -H cloudflare.com --check-ciphers C --critical 1 --warning 2
                EXIT_CODE=$?
                assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"

            else
                echo "no ssl-enum-ciphers nmap script found: skipping ciphers test"
            fi

        else
            echo "no nmap found: skipping ciphers test"
        fi

    fi

}

testCiphersError() {

    # nmap ssl-enum-ciphers dumps core on CentOS 7 and RHEL 7
    if [ -f /etc/redhat-release ] && grep -q '.*Linux.*release\ 7\.' /etc/redhat-release; then
        echo 'Skipping tests on CentOS and RedHat 7 since nmap is crashing (core dump)'
    else

        # check if nmap is installed
        if command -v nmap >/dev/null; then

            # check if ssl-enum-ciphers is present
            if ! nmap --script ssl-enum-ciphers 2>&1 | grep -q -F 'NSE: failed to initialize the script engine'; then
                ${SCRIPT} --rootcert-file cabundle.crt -H www.google.com --check-ciphers A --check-ciphers-warnings --critical 1 --warning 2
                EXIT_CODE=$?
                assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"

            else
                echo "no ssl-enum-ciphers nmap script found: skipping ciphers test"
            fi

        else
            echo "no nmap found: skipping ciphers test"
        fi

    fi

}

# SSL Labs (last one as it usually takes a lot of time

testETHZWithSSLLabs() {
    # we assume www.ethz.ch gets at least a B
    ${SCRIPT} --rootcert-file cabundle.crt -H ethz.ch --cn ethz.ch --check-ssl-labs B --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testGithubComCRL() {

    # get current certificate of github.com, download the CRL named in that certificate
    # and use it for local CRL check

    create_temporary_test_file
    TEMPFILE_GITHUB_CERT=${TEMPFILE}

    echo Q | "${OPENSSL}" s_client -connect github.com:443 2>/dev/null | sed -n '/-----BEGIN/,/-----END/p' >"${TEMPFILE_GITHUB_CERT}"

    GITHUB_CRL_URI=$(${OPENSSL} x509 -in "${TEMPFILE_GITHUB_CERT}" -noout -text | grep -A 6 "X509v3 CRL Distribution Points" | grep "http://" | head -1 | sed -e "s/.*URI://")

    create_temporary_test_file '.crl'
    TEMPFILE_CRL=${TEMPFILE}

    curl --silent "${GITHUB_CRL_URI}" >"${TEMPFILE_CRL}"

    ${SCRIPT} --file "${TEMPFILE_CRL}" --warning 2 --critical 1
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"

}

testFloatingPointThresholds() {

    ${SCRIPT} -H github.com --warning 2.5 --critical 1.5
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"

}

testFloatingPointThresholdsWrongUsage() {

    ${SCRIPT} -H github.com --warning 1.5 --critical 2.5
    EXIT_CODE=$?
    assertEquals "expecting error message about --warning is less or equal --critical, but got wrong exit code, " "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"

}

testCertExpiringInLessThanOneDay() {

    CERT=$(createSelfSignedCertificate 1)

    ${SCRIPT} -f "${CERT}" --warning 1.5 --critical 0.5 --selfsigned --allow-empty-san
    EXIT_CODE=$?

    assertEquals "wrong exit code" "${NAGIOS_WARNING}" "${EXIT_CODE}"

}

testAcceptableClientCertCAMissing() {

    ${SCRIPT} -H www.ethz.ch --require-client-cert
    EXIT_CODE=$?

    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"

}

# not responding: should find something new

# testAcceptableClientCertCAGeneric() {
#
#     ${SCRIPT} -H klik.nlb.si --require-client-cert
#     EXIT_CODE=$?
#
#     assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
#
# }

# testAcceptableClientCertCAList() {
#
#     ${SCRIPT} -H klik.nlb.si --require-client-cert ACNLB,NLB
#     EXIT_CODE=$?
#
#     assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
#
# }

testAcceptableClientCertCAListWrong() {

    ${SCRIPT} -H klik.nlb.si --require-client-cert ACNLB,NLB,fake
    EXIT_CODE=$?

    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"

}

testMaxDateOn32BitSystems() {

    # generate a cert expiring after 2038-01-19
    CERT=$(createSelfSignedCertificate 7000)

    ${SCRIPT} -f "${CERT}" --warning 2 --critical 1 --selfsigned --allow-empty-san
    EXIT_CODE=$?

    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"

    ${SCRIPT} -f "${CERT}" --warning 2 --critical 1 --selfsigned --allow-empty-san 2>&1 | grep -q 'invalid\ date'
    EXIT_CODE=$?

    assertEquals "Invalid date" 1 "${EXIT_CODE}"

}

testIgnoreConnectionStateOK() {
    ${SCRIPT} -H www.google.com --port 444 --timeout 1 --ignore-connection-problems "${NAGIOS_OK}"
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testIgnoreConnectionStateWARNING() {
    ${SCRIPT} -H www.google.com --port 444 --timeout 1 --ignore-connection-problems "${NAGIOS_WARNING}"
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_WARNING}" "${EXIT_CODE}"
}

testIgnoreConnectionStateCRITICAL() {
    ${SCRIPT} -H www.google.com --port 444 --timeout 1 --ignore-connection-problems "${NAGIOS_CRITICAL}"
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testIgnoreConnectionStateWARNING() {
    ${SCRIPT} -H www.google.com --port 444 --timeout 1 --ignore-connection-problems "${NAGIOS_WARNING}"
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_WARNING}" "${EXIT_CODE}"
}

testIgnoreConnectionStateError() {
    ${SCRIPT} -H www.google.com --port 444 --timeout 1 --ignore-connection-state 4
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
}

testSubdomainWithUnderscore() {
    TEST_HOST=_test.github.com
    OUTPUT=$(echo Q | "${OPENSSL}" s_client -connect "${TEST_HOST}":443 2>&1)
    if [ $? -eq 1 ]; then
        # there was an error: check if it's due to the _
        if echo "${OUTPUT}" | grep -q -F 'gethostbyname failure' ||
            echo "${OUTPUT}" | grep -q -F 'ame or service not known'; then
            # older versions of OpenSSL are not able to connect
            echo "OpenSSL does not support underscores in the host name: disabling test"
        else
            fail "error connecting to ${TEST_HOST}"
        fi
    else
        ${SCRIPT} -H "${TEST_HOST}"
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    fi
}

testChainOK() {
    ${SCRIPT} -f ./fullchain.pem
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testChainFail() {
    ${SCRIPT} -f ./incomplete_chain.pem
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

# the script will exit without executing main
export SOURCE_ONLY='test'

# source the script.
# Do not follow
# shellcheck disable=SC1090
. "${SCRIPT}"

unset SOURCE_ONLY

# run shUnit: it will execute all the tests in this file
# (e.g., functions beginning with 'test'
#
# We clone to output to pass it to grep as shunit does always return 0
# We parse the output to check if a test failed
#

# Do not follow
# shellcheck disable=SC1090
. "${SHUNIT2}"
