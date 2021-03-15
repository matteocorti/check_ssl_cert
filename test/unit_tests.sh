#!/bin/sh

# $SHUNIT2 should be defined as an environment variable before running the tests
# shellcheck disable=SC2154
if [ -z "${SHUNIT2}" ] ; then
    cat <<EOF
To be able to run the unit test you need a copy of shUnit2
You can download it from https://github.com/kward/shunit2

Once downloaded please set the SHUNIT2 variable with the location
of the 'shunit2' script
EOF
    exit 1
fi

if [ ! -x "${SHUNIT2}" ] ; then
    echo "Error: the specified shUnit2 script (${SHUNIT2}) is not an executable file"
    exit 1
fi

SCRIPT=../check_ssl_cert
if [ ! -r "${SCRIPT}" ] ; then
    echo "Error: the script to test (${SCRIPT}) is not a readable file"
fi

oneTimeSetUp() {
    # constants

    NAGIOS_OK=0
    NAGIOS_WARNING=1
    NAGIOS_CRITICAL=2
    NAGIOS_UNKNOWN=3

    # we trigger a test by Qualy's SSL so that when the last test is run the result will be cached
    echo 'Starting SSL Lab test (to cache the result)'
    curl --silent 'https://www.ssllabs.com/ssltest/analyze.html?d=ethz.ch&latest' > /dev/null

    # check in OpenSSL supports dane checks
    if openssl s_client -help 2>&1 | grep -q -- -dane_tlsa_rrdata || openssl s_client not_a_real_option 2>&1 | grep -q -- -dane_tlsa_rrdata; then

    echo "dane checks supported"
    DANE=1
    fi

}

testHoursUntilNow() {
    # testing with perl
    export DATETYPE='PERL'
    hours_until "$( date )"
    assertEquals "error computing the missing hours until now" 0 "${HOURS_UNTIL}"
}

testHoursUntil5Hours() {
    # testing with perl
    export DATETYPE='PERL'
    hours_until "$( perl -e '$x=localtime(time+(5*3600));print $x' )"
    assertEquals "error computing the missing hours until now" 5 "${HOURS_UNTIL}"
}

testHoursUntil42Hours() {
    # testing with perl
    export DATETYPE='PERL'
    hours_until "$( perl -e '$x=localtime(time+(42*3600));print $x' )"
    assertEquals "error computing the missing hours until now" 42 "${HOURS_UNTIL}"
}

testOpenSSLVersion1() {
    export OPENSSL_VERSION='OpenSSL 1.1.1j  16 Feb 2021'
    export REQUIRED_VERSION='1.2.0a'
    OPENSSL=$( command -v openssl ) # needed by openssl_version
    openssl_version "${REQUIRED_VERSION}"
    RET=$?
    assertEquals "error comparing required version ${REQUIRED_VERSION} to current version ${OPENSSL_VERSION}" 1 "${RET}"
    export OPENSSL_VERSION=
}

testOpenSSLVersion2() {
    export OPENSSL_VERSION='OpenSSL 1.1.1j  16 Feb 2021'
    export REQUIRED_VERSION='1.1.1j'
    OPENSSL=$( command -v openssl ) # needed by openssl_version
    openssl_version "${REQUIRED_VERSION}"
    RET=$?
    assertEquals "error comparing required version ${REQUIRED_VERSION} to current version ${OPENSSL_VERSION}" 0 "${RET}"
    export OPENSSL_VERSION=
}

testOpenSSLVersion3() {
    export OPENSSL_VERSION='OpenSSL 1.1.1j  16 Feb 2021'
    export REQUIRED_VERSION='1.0.0b'
    OPENSSL=$( command -v openssl ) # needed by openssl_version
    openssl_version "${REQUIRED_VERSION}"
    RET=$?
    assertEquals "error comparing required version ${REQUIRED_VERSION} to current version ${OPENSSL_VERSION}" 0 "${RET}"
    export OPENSSL_VERSION=
}

testOpenSSLVersion4() {
    export OPENSSL_VERSION='OpenSSL 1.0.2k-fips 26 Jan 2017'
    export REQUIRED_VERSION='1.0.0b'
    OPENSSL=$( command -v openssl ) # needed by openssl_version
    openssl_version "${REQUIRED_VERSION}"
    RET=$?
    assertEquals "error comparing required version ${REQUIRED_VERSION} to current version ${OPENSSL_VERSION}" 0 "${RET}"
    export OPENSSL_VERSION=
}

testOpenSSLVersion5() {
    export OPENSSL_VERSION='OpenSSL 1.1.1h-freebsd 22 Sep 2020'
    export REQUIRED_VERSION='1.0.0b'
    OPENSSL=$( command -v openssl ) # needed by openssl_version
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
    OPENSSL=$( command -v openssl ) # needed by openssl_version
    ${OPENSSL} version
    if openssl_version '1.1.0' ; then
	echo "OpenSSL >= 1.1.0: SCTs supported"
        ${SCRIPT} --rootcert-file cabundle.crt -H no-sct.badssl.com
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
    else
	echo "OpenSSL < 1.1.0: SCTs not supported"
        ${SCRIPT} --rootcert-file cabundle.crt -H no-sct.badssl.com
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    fi
}

testUsage() {
    ${SCRIPT} > /dev/null 2>&1
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
}

testMissingArgument() {
    ${SCRIPT} --rootcert-file cabundle.crt -H www.google.com --critical > /dev/null 2>&1
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
}

testMissingArgument2() {
    ${SCRIPT} --rootcert-file cabundle.crt -H www.google.com --critical --warning 10 > /dev/null 2>&1
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
}

testETHZ() {
    ${SCRIPT} --rootcert-file cabundle.crt -H ethz.ch --cn ethz.ch
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testLetsEncrypt() {
    ${SCRIPT} --rootcert-file cabundle.crt -H helloworld.letsencrypt.org
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testGoDaddy() {
    ${SCRIPT} --rootcert-file cabundle.crt -H www.godaddy.com --cn www.godaddy.com
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testETHZCaseInsensitive() {
    # debugging: to be removed
    ${SCRIPT} --rootcert-file cabundle.crt -H ethz.ch --cn ETHZ.CH
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testETHZWildCard() {
    ${SCRIPT} --rootcert-file cabundle.crt -H sherlock.sp.ethz.ch --cn sp.ethz.ch
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testETHZWildCardCaseInsensitive() {
    ${SCRIPT} --rootcert-file cabundle.crt -H sherlock.sp.ethz.ch --cn SP.ETHZ.CH
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testETHZWildCardSub() {
    ${SCRIPT} --rootcert-file cabundle.crt -H sherlock.sp.ethz.ch --cn sub.sp.ethz.ch
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testETHZWildCardSubCaseInsensitive() {
    ${SCRIPT} --rootcert-file cabundle.crt -H sherlock.sp.ethz.ch --cn SUB.SP.ETHZ.CH
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testRootIssuer() {
    ${SCRIPT} --rootcert-file cabundle.crt -H google.com --issuer 'GlobalSign'
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
    ${SCRIPT} --rootcert-file cabundle.crt -H www.inf.ethz.ch --cn www.inf.ethz.ch --altnames
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

#Do not require to match Alternative Name if CN already matched
testWildcardAltNames1() {
    ${SCRIPT} --rootcert-file cabundle.crt -H sherlock.sp.ethz.ch --altnames --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

#Check for wildcard support in Alternative Names
testWildcardAltNames2() {
    ${SCRIPT} --rootcert-file cabundle.crt -H sherlock.sp.ethz.ch \
        --cn somehost.spapps.ethz.ch \
        --cn otherhost.sPaPPs.ethz.ch \
        --cn spapps.ethz.ch \
        --altnames \

    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testAltNamesCaseInsensitve() {
    ${SCRIPT} --rootcert-file cabundle.crt -H www.inf.ethz.ch --cn WWW.INF.ETHZ.CH --altnames
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testMultipleAltNamesFailOne() {
    # Test with wiltiple CN's but last one is wrong
    ${SCRIPT} --rootcert-file cabundle.crt -H inf.ethz.ch -n www.ethz.ch -n wrong.ch --altnames
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testMultipleAltNamesFailTwo() {
    # Test with multiple CN's but first one is wrong
    ${SCRIPT} --rootcert-file cabundle.crt -H inf.ethz.ch -n wrong.ch -n www.ethz.ch --altnames
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testXMPPHost() {
    out=$(${SCRIPT} --rootcert-file cabundle.crt -H prosody.xmpp.is --port 5222 --protocol xmpp --xmpphost xmpp.is )
    EXIT_CODE=$?
    if echo "${out}" | grep -q "s_client' does not support '-xmpphost'" ; then
        assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
    else
        assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    fi
}

testTimeOut() {
    ${SCRIPT} --rootcert-file cabundle.crt -H gmail.com --protocol imap --port 993 --timeout  1
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
    ${SCRIPT} --rootcert-file cabundle.crt -H imap.gmail.com --port 993 --timeout 30 --protocol imaps
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testPOP3S() {
    ${SCRIPT} --rootcert-file cabundle.crt -H pop.gmail.com --port 995 --timeout 30 --protocol pop3s
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}


testSMTP() {
    ${SCRIPT} --rootcert-file cabundle.crt -H smtp.gmail.com --protocol smtp --port 25 --timeout 60
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testSMTPSubmbission() {
    ${SCRIPT} --rootcert-file cabundle.crt -H smtp.gmail.com --protocol smtp --port 587 --timeout 60
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testSMTPS() {
    ${SCRIPT} --rootcert-file cabundle.crt -H smtp.gmail.com --protocol smtps --port 465 --timeout 60
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
    ${SCRIPT} --rootcert-file cabundle.crt -H expired.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLExpiredAndWarnThreshold() {
    ${SCRIPT} --rootcert-file cabundle.crt -H expired.badssl.com --host-cn --warning 3000
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLWrongHost() {
    ${SCRIPT} --rootcert-file cabundle.crt -H wrong.host.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLSelfSigned() {
    ${SCRIPT} --rootcert-file cabundle.crt -H self-signed.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLUntrustedRoot() {
    ${SCRIPT} --rootcert-file cabundle.crt -H untrusted-root.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLRevoked() {
    ${SCRIPT} --rootcert-file cabundle.crt -H revoked.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLRevokedCRL() {
    ${SCRIPT} --rootcert-file cabundle.crt -H revoked.badssl.com --host-cn --crl --ignore-ocsp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testGRCRevoked() {
    ${SCRIPT} --rootcert-file cabundle.crt -H revoked.grc.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLIncompleteChain() {
    ${SCRIPT} --rootcert-file cabundle.crt -H incomplete-chain.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLDH480(){
    ${SCRIPT} --rootcert-file cabundle.crt -H dh480.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLDH512(){
    ${SCRIPT} --rootcert-file cabundle.crt -H dh512.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLRC4MD5(){
    ${SCRIPT} --rootcert-file cabundle.crt -H rc4-md5.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLRC4(){
    ${SCRIPT} --rootcert-file cabundle.crt -H rc4.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSL3DES(){
    ${SCRIPT} --rootcert-file cabundle.crt -H 3des.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLNULL(){
    ${SCRIPT} --rootcert-file cabundle.crt -H null.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLSHA256() {
    ${SCRIPT} --rootcert-file cabundle.crt -H sha256.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testBadSSLEcc256() {
    ${SCRIPT} --rootcert-file cabundle.crt -H ecc256.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testBadSSLEcc384() {
    ${SCRIPT} --rootcert-file cabundle.crt -H ecc384.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testBadSSLRSA8192() {
    ${SCRIPT} --rootcert-file cabundle.crt -H rsa8192.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testBadSSLLongSubdomainWithDashes() {
    ${SCRIPT} --rootcert-file cabundle.crt -H long-extended-subdomain-name-containing-many-letters-and-dashes.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testBadSSLLongSubdomain() {
    ${SCRIPT} --rootcert-file cabundle.crt -H longextendedsubdomainnamewithoutdashesinordertotestwordwrapping.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testBadSSLSHA12016() {
    ${SCRIPT} --rootcert-file cabundle.crt -H sha1-2016.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLSHA12017() {
    ${SCRIPT} --rootcert-file cabundle.crt -H sha1-2017.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testMultipleOCSPHosts() {
    ${SCRIPT} --rootcert-file cabundle.crt -H netlock.hu
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testRequireOCSP() {
    ${SCRIPT} --rootcert-file cabundle.crt -H videolan.org --require-ocsp-stapling --critical 1 --warning 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

# tests for -4 and -6
testIPv4() {
    if openssl s_client -help 2>&1 | grep -q -- -4 ; then
        ${SCRIPT} --rootcert-file cabundle.crt -H www.google.com -4
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    else
        echo "Skipping forcing IPv4: no OpenSSL support"
    fi
}

testIPv6() {
    if openssl s_client -help 2>&1 | grep -q -- -6 ; then

	IPV6=
	if command -v ifconfig > /dev/null && ifconfig -a | grep -q -F inet6 ; then
	    IPV6=1
	elif command -v ip > /dev/null && ip addr | grep -q -F inet6 ; then
	    IPV6=1
	fi
	    
        if [ -n "${IPV6}" ] ; then

	    echo "IPv6 is configured"

            if ping -6 www.google.com > /dev/null 2>&1  ; then

                ${SCRIPT} --rootcert-file cabundle.crt -H www.google.com -6
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
    OUTPUT=$( ${SCRIPT} --rootcert-file cabundle.crt -H ethz.ch --cn ethz.ch --format "%SHORTNAME% OK %CN% from '%CA_ISSUER_MATCHED%'" | cut '-d|' -f 1 )
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    assertEquals "wrong output" "SSL_CERT OK ethz.ch from 'QuoVadis Global SSL ICA G2'" "${OUTPUT}"
}

testMoreErrors() {
    OUTPUT=$( ${SCRIPT} --rootcert-file cabundle.crt -H www.ethz.ch --email doesnotexist --critical 1000 --warning 1001 --verbose | wc -l | sed 's/\ //g' )
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    # we should get three lines: the plugin output and three errors
    assertEquals "wrong number of errors" 5 "${OUTPUT}"
}

testMoreErrors2() {
    OUTPUT=$( ${SCRIPT} --rootcert-file cabundle.crt -H www.ethz.ch --email doesnotexist --warning 1000 --warning 1001 --verbose | wc -l | sed 's/\ //g' )
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    # we should get three lines: the plugin output and three errors
    assertEquals "wrong number of errors" 5 "${OUTPUT}"
}

# dane

testDANE211() {
    ${SCRIPT} --rootcert-file cabundle.crt --dane 211  --port 25 -P smtp -H hummus.csx.cam.ac.uk
    EXIT_CODE=$?
    if [ -n "${DANE}" ] ; then
        assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    else
        assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
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

testDANE301ECDSA() {
    ${SCRIPT} --rootcert-file cabundle.crt --dane 301 --ecdsa -H mail.aegee.org
    EXIT_CODE=$?
    if [ -n "${DANE}" ] ; then
        assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    else
        assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
    fi
}

testRequiredProgramFile() {
    ${SCRIPT} --rootcert-file cabundle.crt -H www.google.com --file-bin /doesnotexist
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
}

testRequiredProgramPermissions() {
    ${SCRIPT} --rootcert-file cabundle.crt -H www.google.com --file-bin /etc/hosts
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
}

testSieveRSA() {
    if ! { openssl s_client -starttls sieve 2>&1 | grep -F -q 'Value must be one of:' || openssl s_client -starttls sieve 2>&1 | grep -F -q 'usage:' ; } ; then
        ${SCRIPT} --rootcert-file cabundle.crt -P sieve -p 4190 -H mail.aegee.org --rsa
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    else
        echo "Skipping sieve tests (not supported)"
    fi
}

testSieveECDSA() {
    if ! { openssl s_client -starttls sieve 2>&1 | grep -F -q 'Value must be one of:' || openssl s_client -starttls sieve 2>&1 | grep -F -q 'usage:' ; } ; then
        ${SCRIPT} --rootcert-file cabundle.crt -P sieve -p 4190 -H mail.aegee.org --ecdsa
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
    if openssl s_client -help 2>&1 | grep -q -F alpn ; then
        ${SCRIPT} --rootcert-file cabundle.crt -H www.ethz.ch --protocol h2
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    else
        echo "Skupping forced HTTP2 test as -alpn is not supported"
    fi
}

testNotLongerValidThan() {
    ${SCRIPT} --rootcert-file cabundle.crt -H www.ethz.ch --not-valid-longer-than 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testDERCert() {
    ${SCRIPT} --rootcert-file cabundle.crt -H localhost -f ./der.cer --ignore-sct
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testPKCS12Cert() {
    export PASS=
    ${SCRIPT} --rootcert-file cabundle.crt -H localhost -f ./client.p12 --ignore-sct --password env:PASS
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testCertificsteWithoutCN() {
    ${SCRIPT} --rootcert-file cabundle.crt -H localhost -n www.uue.org -f ./cert_with_subject_without_cn.crt --force-perl-date --ignore-sig-alg --ignore-sct
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testCertificsteWithEmptySubject() {
    ${SCRIPT} --rootcert-file cabundle.crt -H localhost -n www.uue.org -f ./cert_with_empty_subject.crt --force-perl-date --ignore-sig-alg --ignore-sct
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testCiphersOK() {
    if command -v nmap > /dev/null ; then
        if ! nmap --script ssl-enum-ciphers 2>&1 | grep -q -F 'NSE: failed to initialize the script engine' ; then
            ${SCRIPT} --rootcert-file cabundle.crt -H www.wikipedia.org --check-ciphers A --check-ciphers-warnings
            EXIT_CODE=$?
            assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
        else
            echo "no ssl-enum-ciphers nmap script found: skipping ciphers test"
        fi
    else
        echo "no nmap found: skipping ciphers test"
    fi
}

testCiphersError() {
    if command -v nmap > /dev/null ; then
        if ! nmap --script ssl-enum-ciphers 2>&1 | grep -q -F 'NSE: failed to initialize the script engine' ; then
            ${SCRIPT} --rootcert-file cabundle.crt -H ethz.ch --check-ciphers A --check-ciphers-warnings
            EXIT_CODE=$?
            assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
        else
            echo "no ssl-enum-ciphers nmap script found: skipping ciphers test"
        fi
    else
        echo "no nmap found: skipping ciphers test"
    fi
}

# SSL Labs (last one as it usually takes a lot of time

testETHZWithSSLLabs() {
    # we assume www.ethz.ch gets at least a B
    ${SCRIPT} --rootcert-file cabundle.crt -H ethz.ch --cn ethz.ch --check-ssl-labs B
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
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
