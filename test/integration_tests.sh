#!/bin/sh

# SSL_LABS_HOST=ethz.ch

# $SHUNIT2 should be defined as an environment variable before running the tests
# shellcheck disable=SC2154
if [ -z "${SHUNIT2}" ]; then

    SHUNIT2=$(command -v shunit2)

    if [ -z "${SHUNIT2}" ]; then

        cat <<EOF
To be able to run the unit test you need a copy of shUnit2
You can download it from https://github.com/kward/shunit2

Once downloaded please set the SHUNIT2 variable with the location
of the 'shunit2' script
EOF
        exit 1

    else
        echo "shunit2 detected: ${SHUNIT2}"
    fi

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

oneTimeSetUp() {
    # constants

    NAGIOS_OK=0
    NAGIOS_WARNING=1
    NAGIOS_CRITICAL=2
    NAGIOS_UNKNOWN=3

    OK=0
    NOT_OK=1

    COUNTER=1
    START_TIME=$(date +%s)

    if [ -z "${TMPDIR}" ]; then
        TMPDIR=/tmp
    fi

    # Cleanup before program termination
    # Using named signals to be POSIX compliant
    # shellcheck disable=SC2086
    trap_with_arg cleanup ${SIGNALS}

    # we trigger a test by Qualy's SSL so that when the last test is run the result will be cached
    # echo 'Starting SSL Lab test (to cache the result)'
    # curl --silent "https://www.ssllabs.com/ssltest/analyze.html?d=${SSL_LABS_HOST}&latest" >/dev/null

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

    if [ -z "${GREP_BIN}" ]; then
        GREP_BIN=$(command -v grep) # needed by openssl_version
    fi
    if ! "${GREP_BIN}" -V >/dev/null 2>&1; then
        echo "Cannot determine grep version (Busybox?)"
    else
        "${GREP_BIN}" -V
    fi

}

seconds2String() {
    seconds=$1
    if [ "${seconds}" -gt 60 ]; then
        minutes=$((seconds / 60))
        seconds=$((seconds % 60))
        if [ "${minutes}" -gt 1 ]; then
            MINUTE_S="minutes"
        else
            MINUTE_S="minute"
        fi
        if [ "${seconds}" -eq 1 ]; then
            SECOND_S=" and ${seconds} second"
        elif [ "${seconds}" -eq 0 ]; then
            SECOND_S=
        else
            SECOND_S=" and ${seconds} seconds"
        fi
        string="${minutes} ${MINUTE_S}${SECOND_S}"
    else
        if [ "${seconds}" -eq 1 ]; then
            SECOND_S="second"
        else
            SECOND_S="seconds"
        fi
        string="${seconds} ${SECOND_S}"
    fi
    echo "${string}"

}

oneTimeTearDown() {
    # Cleanup before program termination
    # Using named signals to be POSIX compliant
    # shellcheck disable=SC2086
    cleanup_temporary_test_files ${SIGNALS}

    NOW=$(date +%s)
    ELAPSED=$((NOW - START_TIME))
    # shellcheck disable=SC2154
    ELAPSED_STRING=$(seconds2String "${ELAPSED}")
    echo
    echo "Total time: ${ELAPSED_STRING}"
}

setUp() {
    echo

    # shellcheck disable=SC2154
    PERCENT=$(echo "scale=2; ${COUNTER} / ${__shunit_testsTotal} * 100" | bc | sed 's/[.].*//')

    NOW=$(date +%s)
    ELAPSED=$((NOW - START_TIME))
    # shellcheck disable=SC2154
    REMAINING_S=$(echo "scale=2; ${__shunit_testsTotal} * ( ${ELAPSED} ) / ${COUNTER} - ${ELAPSED}" | bc | sed 's/[.].*//')
    if [ -z "${REMAINING_S}" ]; then
        REMAINING_S=0
    fi
    REMAINING=$(seconds2String "${REMAINING_S}")

    # print the test number
    # shellcheck disable=SC2154
    echo "Running test ${COUNTER} of ${__shunit_testsTotal} (${PERCENT}%), ${REMAINING} remaining (${__shunit_testsFailed} failed)"
    COUNTER=$((COUNTER + 1))
}

##############################################################################
# Tests

testIntegerOK() {
    # shellcheck disable=SC2086,SC2154
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.github.com --precision 2 --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testIntegerNotOK() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.github.com --precision 2.2 --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.github.com --precision 2.a --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
}

testFloatOK() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.github.com --critical 2.2 --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testFloatNotOK() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.github.com --critical 2.2a --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.github.com --critical .2 --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
}

testPrecision() {
    # if nothing is specified integers should be used
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.github.com --ignore-exp | grep -q -E 'in [0-9]*[.]'
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NOT_OK}" "${EXIT_CODE}"
}

testPrecisionCW() {
    # if critical or warning is not an integer we should switch to floating point
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.github.com --critical 1.5 | grep -q -E 'in [0-9]*[.][0-9]{2}'
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${OK}" "${EXIT_CODE}"
}

testPrecision4() {
    # we force a precision of 4
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.github.com --precision 4 --critical 1 | grep -q -E 'in [0-9]*[.][0-9]{4}'
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${OK}" "${EXIT_CODE}"
}

testPrecision0() {
    # we force integers even if critical is a floating point
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.github.com --critical 1.5 --precision 0 | grep -q -E 'in [0-9]*[.]'
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NOT_OK}" "${EXIT_CODE}"
}

testInfo() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.github.com --info --ignore-exp
}

testSignatureAlgorithms() {

    # shellcheck disable=SC2086
    ALGORITHM=$(${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt --info --ignore-exp --host rsa2048.badssl.com |
        grep '^Signature algorithm' |
        sed 's/^Signature algorithm *//')
    assertEquals "wrong signature algorithm" 'sha256WithRSAEncryption (2048 bit)' "${ALGORITHM}"

    # shellcheck disable=SC2086
    ALGORITHM=$(${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt --info --ignore-exp --host rsa4096.badssl.com |
        grep '^Signature algorithm' |
        sed 's/^Signature algorithm *//')
    assertEquals "wrong signature algorithm" 'sha256WithRSAEncryption (4096 bit)' "${ALGORITHM}"

    # shellcheck disable=SC2086
    ALGORITHM=$(${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt --info --ignore-exp --host rsa8192.badssl.com |
        grep '^Signature algorithm' |
        sed 's/^Signature algorithm *//')
    assertEquals "wrong signature algorithm" 'sha256WithRSAEncryption (8192 bit)' "${ALGORITHM}"

    # shellcheck disable=SC2086
    ALGORITHM=$(${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt --info --ignore-exp --host ecc256.badssl.com |
        grep '^Signature algorithm' |
        sed 's/^Signature algorithm *//')
    assertEquals "wrong signature algorithm" 'sha256WithRSAEncryption (256 bit)' "${ALGORITHM}"

    # shellcheck disable=SC2086
    ALGORITHM=$(${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt --info --ignore-exp --host ecc384.badssl.com |
        grep '^Signature algorithm' |
        sed 's/^Signature algorithm *//')
    assertEquals "wrong signature algorithm" 'sha256WithRSAEncryption (384 bit)' "${ALGORITHM}"

}

testFQDN() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.github.com. --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testSCT() {
    if [ -z "${OPENSSL}" ]; then
        OPENSSL=$(command -v openssl) # needed by openssl_version
    fi
    ${OPENSSL} version
    if openssl_version '1.1.0'; then
        echo "OpenSSL >= 1.1.0: SCTs supported"
        # shellcheck disable=SC2086
        ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H no-sct.badssl.com --ignore-exp
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
    else
        echo "OpenSSL < 1.1.0: SCTs not supported"
        # shellcheck disable=SC2086
        ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H no-sct.badssl.com --ignore-exp
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    fi
}

testPrometheus() {
    # shellcheck disable=SC2086
    OUTPUT=$(${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H github.com --prometheus --critical 1000 --warning 1100)
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"

    echo "${OUTPUT}" | grep -q '# HELP cert_valid'
    EXIT_CODE=$?
    assertEquals "output does not contain '# HELP cert_valid'" "${OK}" "${EXIT_CODE}"

    echo "${OUTPUT}" | grep -q 'cert_valid_chain_elem{cn="github.com", element="1"} 2'
    EXIT_CODE=$?
    assertEquals "output does not contain 'cert_valid_chain_elem{cn=\"github.com\", element=\"1\"} 2'" "${OK}" "${EXIT_CODE}"

    echo "${OUTPUT}" | grep -q 'cert_days_chain_elem{cn="github.com", element="1"}'
    EXIT_CODE=$?
    assertEquals "output does not contain 'cert_days_chain_elem{cn=\"github.com\", element=\"1\"}'" "${OK}" "${EXIT_CODE}"

}

testGitHub() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H github.com --match github.com --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testLetsEncrypt() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H helloworld.letsencrypt.org --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testGITHUBCaseInsensitive() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H github.com --match GITHUB.COM --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testIPOK() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H 138.201.94.172 --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testIPOKAltName() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H 138.201.94.172 --match pasi.corti.li --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testIPFailAltName() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H 138.201.94.172 --match bogus.corti.li --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testIPCN() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt --host github.com --match 1.1.1.1 --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testETHZWildCard() {
    # * should not match, see https://serverfault.com/questions/310530/should-a-wildcard-ssl-certificate-secure-both-the-root-domain-as-well-as-the-sub
    # we ignore the altnames as sp.ethz.ch is listed
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H sherlock.sp.ethz.ch --match sp.ethz.ch --ignore-altnames --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testETHZWildCardCaseInsensitive() {
    # * should not match, see https://serverfault.com/questions/310530/should-a-wildcard-ssl-certificate-secure-both-the-root-domain-as-well-as-the-sub
    # we ignore the altnames as sp.ethz.ch is listed
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H sherlock.sp.ethz.ch --match SP.ETHZ.CH --ignore-altnames --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testETHZWildCardSub() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H sherlock.sp.ethz.ch --match sub.sp.ethz.ch --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testETHZWildCardSubCaseInsensitive() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H sherlock.sp.ethz.ch --match SUB.SP.ETHZ.CH --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testRootIssuer() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H github.com --issuer 'DigiCert Inc' --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testValidity() {
    # Tests bug #8
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.github.com -w 1000 --critical 1
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_WARNING}" "${EXIT_CODE}"
}

testValidityWithPerl() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.github.com -w 1000 --critical 1 --force-perl-date
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_WARNING}" "${EXIT_CODE}"
}

testAltNames() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.github.com --match www.github.com --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

#Do not require to match Alternative Name if CN already matched
testWildcardAltNames1() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H sherlock.sp.ethz.ch --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

#Check for wildcard support in Alternative Names
testWildcardAltNames2() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H sherlock.sp.ethz.ch \
        --match somehost.spapps.ethz.ch \
        --match otherhost.sPaPPs.ethz.ch \
        --match spapps.ethz.ch \
        --ignore-exp

    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testAltNamesCaseInsensitive() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.github.com --match WWW.GITHUB.COM --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testAltNamesCaseMixed() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.github.com --match WwW.gItHuB.cOm --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testMultipleAltNamesOK() {
    # Test with multiple CN's
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H corti.li -m www.corti.li -m rpm.corti.li --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testMultipleAltNamesFailOne() {
    # Test with multiple CN's but last one is wrong
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H github.com -m www.github.com -m wrong.com --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testMultipleAltNamesFailTwo() {
    # Test with multiple CN's but first one is wrong
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H github.com -m wrong.ch -m www.github.com --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testMultipleAltNamesFailIPOne() {
    # Test with multiple CN's but last one is an incorrect IP
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H github.com -m www.github.com -m 192.168.0.1 --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testMultipleAltNamesFailIPTwo() {
    # Test with multiple CN's but first one is an incorrect IP
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H github.com -m 192.168.0.1 -m www.github.com --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testIMAP() {
    # minimal critical and warning as they renew pretty late
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H imap.gmx.com --port 143 --timeout 30 --protocol imap --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testIMAPS() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H imap.gmail.com --port 993 --timeout 30 --protocol imaps --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testPOP3S() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H pop.gmail.com --port 995 --timeout 30 --protocol pop3s --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testSMTP() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H smtp.gmail.com --protocol smtp --port 25 --timeout 60 --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testSMTPSubmbission() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H smtp.gmail.com --protocol smtp --port 587 --timeout 60 --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testSMTPS() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H smtp.gmail.com --protocol smtps --port 465 --timeout 60 --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

################################################################################
# From https://badssl.com

testBadSSLExpired() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H expired.badssl.com
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLExpiredAndWarnThreshold() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H expired.badssl.com --warning 3000
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLWrongHost() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H wrong.host.badssl.com --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLSelfSigned() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H self-signed.badssl.com --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLUntrustedRoot() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H untrusted-root.badssl.com --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLRevoked() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H revoked.badssl.com
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLRevokedCRL() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H revoked.badssl.com --crl --ignore-ocsp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testGRCRevoked() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H revoked.grc.com
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLIncompleteChain() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H incomplete-chain.badssl.com
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLDH480() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H dh480.badssl.com --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLDH512() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H dh512.badssl.com --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLRC4MD5() {
    # older versions of OpenSSL validate RC4-MD5
    if ! "${OPENSSL}" ciphers RC4-MD5 >/dev/null 2>&1; then
        # shellcheck disable=SC2086
        ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H rc4-md5.badssl.com --ignore-exp
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
    else
        echo "OpenSSL too old to test RC4-MD5 ciphers"
    fi
}

testBadSSLRC4() {
    # older versions of OpenSSL validate RC4
    if ! "${OPENSSL}" ciphers RC4 >/dev/null 2>&1; then
        # shellcheck disable=SC2086
        ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H rc4.badssl.com --ignore-exp
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
    else
        echo "OpenSSL too old to test RC4-MD5 ciphers"
    fi
}

testBadSSL3DES() {
    # older versions of OpenSSL validate RC4
    if ! "${OPENSSL}" ciphers 3DES >/dev/null 2>&1; then
        # shellcheck disable=SC2086
        ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H 3des.badssl.com --ignore-exp
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
    else
        echo "OpenSSL too old to test 3DES ciphers"
    fi
}

testBadSSLNULL() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H null.badssl.com --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLSHA256() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H sha256.badssl.com --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testBadSSLEcc256() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H ecc256.badssl.com --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testBadSSLEcc384() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H ecc384.badssl.com --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testBadSSLRSA8192() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H rsa8192.badssl.com --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testBadSSLLongSubdomainWithDashes() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H long-extended-subdomain-name-containing-many-letters-and-dashes.badssl.com --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testBadSSLLongSubdomain() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H longextendedsubdomainnamewithoutdashesinordertotestwordwrapping.badssl.com --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testBadSSLSHA12016() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H sha1-2016.badssl.com --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLSHA12017() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H sha1-2017.badssl.com --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testRequireOCSP() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H wikipedia.org --require-ocsp-stapling --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

# tests for -4 and -6
testIPv4() {
    if "${OPENSSL}" s_client -help 2>&1 | grep -q -- -4; then
        # shellcheck disable=SC2086
        ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.google.com -4 --ignore-exp
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

            if ping6 -c 3 www.google.com >/dev/null 2>&1; then

                echo "IPv6 is working"

                # shellcheck disable=SC2086
                ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.google.com -6 --ignore-exp
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

testIPv6Only() {
    if "${OPENSSL}" s_client -help 2>&1 | grep -q -- -6; then

        IPV6=
        if command -v ifconfig >/dev/null && ifconfig -a | grep -q -F inet6; then
            IPV6=1
        elif command -v ip >/dev/null && ip addr | grep -q -F inet6; then
            IPV6=1
        fi

        if [ -n "${IPV6}" ]; then

            echo "IPv6 is configured"

            if ping6 -c 3 ipv6.corti.li >/dev/null 2>&1; then

                echo "IPv6 is working"

                # shellcheck disable=SC2086
                ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H ipv6.corti.li --ignore-host-cn --ignore-exp
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

testIPv6Numeric() {
    if "${OPENSSL}" s_client -help 2>&1 | grep -q -- -6; then

        IPV6=
        if command -v ifconfig >/dev/null && ifconfig -a | grep -q -F inet6; then
            IPV6=1
        elif command -v ip >/dev/null && ip addr | grep -q -F inet6; then
            IPV6=1
        fi

        if [ -n "${IPV6}" ]; then

            echo "IPv6 is configured"

            if ping6 -c 3 ipv6.google.com >/dev/null 2>&1; then

                echo "IPv6 is working"

                # shellcheck disable=SC2086
                ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H 2a00:1450:4001:803::200e --ignore-exp
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
    # shellcheck disable=SC2086
    OUTPUT=$(${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H github.com --match github.com --ignore-exp --format "%SHORTNAME% OK %CN% from '%CA_ISSUER_MATCHED%'" | cut '-d|' -f 1)
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    assertEquals "wrong output" "SSL_CERT OK github.com from 'DigiCert Inc'" "${OUTPUT}"
}

testMoreErrors() {
    # shellcheck disable=SC2086,SC2126
    OUTPUT=$(${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.github.com -v --email doesnotexist --critical 1000 --warning 1001 | grep -A 100 '^SSL_CERT CRITICAL' | wc -l | sed 's/ //g')
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    # we should get three lines: the plugin output and three errors
    assertEquals "wrong number of errors" 4 "${OUTPUT}"
}

testMoreErrors2() {
    # shellcheck disable=SC2086,SC2126
    OUTPUT=$(${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.github.com -v --email doesnotexist --warning 1000 --warning 1001 --match DOES_NOT_EXIST | grep -A 100 '^SSL_CERT CRITICAL' | wc -l | sed 's/ //g')
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    # we should get three lines: the plugin output and three errors
    assertEquals "wrong number of errors" 5 "${OUTPUT}"
}

# dane

testDANE211() {
    # dig is needed for DANE
    if command -v dig >/dev/null; then

        # on github actions the dig command produces no output
        if dig +short TLSA _25._tcp.hummus.csx.cam.ac.uk | grep -q -f 'hummus'; then

            # check if a connection is possible
            if printf 'QUIT\\n' | "${OPENSSL}" s_client -connect hummus.csx.cam.ac.uk:25 -starttls smtp >/dev/null 2>&1; then
                # shellcheck disable=SC2086
                ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt --dane 211 --port 25 -P smtp -H hummus.csx.cam.ac.uk --ignore-exp
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

testHTTP2() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H rwserve.readwritetools.com --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testForceHTTP2() {
    if "${OPENSSL}" s_client -help 2>&1 | grep -q -F alpn; then
        # shellcheck disable=SC2086
        ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.github.com --protocol h2 --ignore-exp
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    else
        echo "Skipping forced HTTP2 test as -alpn is not supported"
    fi
}

testCertificateWithoutCN() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -m www.uue.org -f ./cert_with_subject_without_cn.crt --force-perl-date --ignore-sig-alg --ignore-sct --ignore-exp --ignore-incomplete-chain --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testCertificateWithEmptySubject() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -m www.uue.org -f ./cert_with_empty_subject.crt --force-perl-date --ignore-sig-alg --ignore-sct --ignore-exp --ignore-incomplete-chain --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

# see #449
testNotExistingHosts() {

    # shellcheck disable=SC2086
    OUTPUT=$( ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt --host li )
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
    assertContains "wrong error message" "${OUTPUT}" "Cannot resolve"

    # shellcheck disable=SC2086
    OUTPUT=$( ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt --host li --do-not-resolve )
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
    assertContains "wrong error message" "${OUTPUT}" "Cannot connect"

    # shellcheck disable=SC2086
    OUTPUT=$( ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt --host nxdomain.corti.li )
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
    assertContains "wrong error message" "${OUTPUT}" "Cannot resolve"

    # shellcheck disable=SC2086
    OUTPUT=$( ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt --host nxdomain.corti.li --do-not-resolve )
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
    assertContains "wrong error message" "${OUTPUT}" "Cannot connect"

}

testResolveOverHTTP() {

    # shellcheck disable=SC2086
    OUTPUT=$( ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt --resolve-over-http --host github.com )
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"

    # shellcheck disable=SC2086
    OUTPUT=$( ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt --resolve-over-http 8.8.8.8 --host github.com )
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"

    # shellcheck disable=SC2086
    OUTPUT=$( ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt --resolve-over-http 8.8.8.8 --host github.comm )
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"

    # shellcheck disable=SC2086
    OUTPUT=$( ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt --resolve-over-http 8.8.8.9 --host github.com --timeout 2 )
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"

}


testResolveSameName() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.github.com --resolve www.github.com --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testResolveDifferentName() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H corti.li --resolve www.google.com --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testResolveCorrectIP() {
    # dig is needed to resolve the IP address
    if command -v dig >/dev/null; then
        RESOLVED_IP="$(dig +short github.com)"
        # shellcheck disable=SC2086
        ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H github.com --resolve "${RESOLVED_IP}" --ignore-exp
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    else
        echo 'dig missing: skipping test'
    fi
}

testResolveWrongIP() {
    # dig is needed to resolve the IP address
    if command -v dig >/dev/null; then
        RESOLVED_IP="$(dig +short www.google.com)"
        # shellcheck disable=SC2086
        ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H corti.li --resolve "${RESOLVED_IP}"--ignore-exp
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
    else
        echo 'dig missing: skipping test'
    fi
}

testResolveIPv6() {
    if "${OPENSSL}" s_client -help 2>&1 | grep -q -- -6; then
        IPV6=
        if command -v ifconfig >/dev/null && ifconfig -a | grep -q -F inet6; then
            IPV6=1
        elif command -v ip >/dev/null && ip addr | grep -q -F inet6; then
            IPV6=1
        fi
        if [ -n "${IPV6}" ]; then
            echo "IPv6 is configured"
            if ping6 -c 3 www.google.com >/dev/null 2>&1; then
                echo "IPv6 is working"
                RESOLVED=$(host www.google.com | grep IPv6 | sed 's/.* //')
                # shellcheck disable=SC2086
                ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.google.com --resolve "${RESOLVED}" --ignore-exp
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

testCiphersOK() {

    # nmap ssl-enum-ciphers dumps core on CentOS 7 and RHEL 7
    if [ -f /etc/redhat-release ] && grep -q '.*Linux.*release 7\.' /etc/redhat-release; then
        echo 'Skipping tests on CentOS and RedHat 7 since nmap is crashing (core dump)'
    elif [ -f /etc/redhat-release ] && grep -q '.*Linux.*release 6\.' /etc/redhat-release; then
        echo 'Skipping tests on CentOS and RedHat 6 since nmap is not delivering cipher strengths'
    else

        # check if nmap is installed
        if command -v nmap >/dev/null; then

            # check if ssl-enum-ciphers is present
            if ! nmap --script ssl-enum-ciphers 2>&1 | grep -q -F 'NSE: failed to initialize the script engine'; then

                # shellcheck disable=SC2086
                ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H cloudflare.com --check-ciphers C --ignore-exp
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

testCiphersNonStandardPort() {

    # nmap ssl-enum-ciphers dumps core on CentOS 7 and RHEL 7
    #    if [ -f /etc/redhat-release ] && grep -q '.*Linux.*release 7\.' /etc/redhat-release; then
    #        echo 'Skipping tests on CentOS and RedHat 7 since nmap is crashing (core dump)'
    #    el
    if [ -f /etc/redhat-release ] && grep -q '.*Linux.*release 6\.' /etc/redhat-release; then
        echo 'Skipping tests on CentOS and RedHat 6 since nmap is not delivering cipher strengths'
    else

        # check if nmap is installed
        if command -v nmap >/dev/null; then

            # check if ssl-enum-ciphers is present
            if ! nmap --script ssl-enum-ciphers 2>&1 | grep -q -F 'NSE: failed to initialize the script engine'; then

                # shellcheck disable=SC2086
                ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt --host corti.li --port 8443 --check-ciphers C --ignore-exp
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

    # nmap ssl-enum-ciphers dumps core on CentOS 7 and RHEL 7w
    if [ -f /etc/redhat-release ] && grep -q '.*Linux.*release 7\.' /etc/redhat-release; then
        echo 'Skipping tests on CentOS and RedHat 7 since nmap is crashing (core dump)'
    elif [ -f /etc/redhat-release ] && grep -q '.*Linux.*release 6\.' /etc/redhat-release; then
        echo 'Skipping tests on CentOS and RedHat 6 since nmap is not delivering cipher strengths'
    else

        # check if nmap is installed
        if command -v nmap >/dev/null; then

            # check if ssl-enum-ciphers is present
            if ! nmap --script ssl-enum-ciphers 2>&1 | grep -q -F 'NSE: failed to initialize the script engine'; then
                # shellcheck disable=SC2086
                ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.google.com --check-ciphers A --check-ciphers-warnings --ignore-exp
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

# SSL Labs (last one as it usually takes a lot of time)
# disabled as it often gives a timeout

# testSSLLabs() {
#     # we assume www.github.com gets at least a B
#     # shellcheck disable=SC2086
#     ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt --host "${SSL_LABS_HOST}" --match "${SSL_LABS_HOST}" --check-ssl-labs A --ignore-exp
#     EXIT_CODE=$?
#     assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
# }

testGithubComCRL() {

    # get current certificate of github.com, download the CRL named in that certificate
    # and use it for local CRL check

    create_temporary_test_file
    TEMPFILE_GITHUB_CERT=${TEMPFILE}

    echo Q | "${OPENSSL}" s_client -connect github.com:443 2>/dev/null | sed -n '/-----BEGIN/,/-----END/p' >"${TEMPFILE_GITHUB_CERT}"

    GITHUB_CRL_URI=$(${OPENSSL} x509 -in "${TEMPFILE_GITHUB_CERT}" -noout -text | grep -A 6 "X509v3 CRL Distribution Points" | grep "http://" | head -1 | sed -e "s/.*URI://")

    create_temporary_test_file '.crl'
    TEMPFILE_CRL=${TEMPFILE}

    echo "${GITHUB_CRL_URI}"
    curl --silent "${GITHUB_CRL_URI}" >"${TEMPFILE_CRL}"

    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --file "${TEMPFILE_CRL}" --ignore-exp --ignore-maximum-validity
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"

}

testAcceptableClientCertCAMissing() {

    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H www.github.com --require-client-cert --ignore-exp
    EXIT_CODE=$?

    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"

}

testIgnoreConnectionStateOK() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H www.google.com --port 444 --timeout 1 --ignore-connection-problems "${NAGIOS_OK}"
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testIgnoreConnectionStateCRITICAL() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H www.google.com --port 444 --timeout 1 --ignore-connection-problems "${NAGIOS_CRITICAL}"
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testIgnoreConnectionStateWARNING() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H www.google.com --port 444 --timeout 1 --ignore-connection-problems "${NAGIOS_WARNING}"
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_WARNING}" "${EXIT_CODE}"
}

testIgnoreConnectionStateError() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H www.google.com --port 444 --timeout 1 --ignore-connection-problems 4
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
}

testIgnoreConnectionStateHTTP() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H www.github.com --port 443 --ignore-connection-problems 0
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
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
        # shellcheck disable=SC2086
        ${SCRIPT} ${TEST_DEBUG} -H "${TEST_HOST}" --ignore-exp
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    fi
}

testRSA() {
    if "${OPENSSL}" s_client -help 2>&1 | grep -q -- -sigalgs; then
        # shellcheck disable=SC2086
        ${SCRIPT} ${TEST_DEBUG} -H github.com --rsa --tls1_2 --ignore-exp
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    else
        echo "Skipping forcing RSA: no OpenSSL support"
    fi
}

testOrganizationFail() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H github.com -o 'SomeOrg' --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testOrganizationOK() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H github.com -o 'GitHub, Inc.' --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testOrganizationOKUmlaut() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H ethz.ch -o 'ETH Zürich' --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testHSTSOK() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG}--require-http-header strict-transport-security --host github.com --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testHSTSFail() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG}--require-http-header strict-transport-security --host google.com --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testHostCache() {

    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --init-host-cache

    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H github.com --ignore-exp

    grep -q '^github.com$' ~/.check_ssl_cert-cache
    EXIT_CODE=$?
    assertEquals "wrong exit code (host not cached)" "${NAGIOS_OK}" "${EXIT_CODE}"

    # test the caching of IPv6 addresses (if IPv6 is available)
    IPV6=
    if command -v ifconfig >/dev/null && ifconfig -a | grep -q -F inet6; then
        IPV6=1
    elif command -v ip >/dev/null && ip addr | grep -q -F inet6; then
        IPV6=1
    fi

    if [ -n "${IPV6}" ]; then

        echo "IPv6 is configured"

        if ping6 -c 3 www.google.com >/dev/null 2>&1; then

            echo "IPv6 is working"

            # shellcheck disable=SC2086
            ${SCRIPT} ${TEST_DEBUG} -H github.com --ignore-exp

            grep -c '^github.com$' ~/.check_ssl_cert-cache | grep -q '^1$'
            EXIT_CODE=$?
            assertEquals "wrong exit code (host cached more than once)" "${NAGIOS_OK}" "${EXIT_CODE}"

            # take the first IPv6 address
            TEST_IPV6=$(dig -t AAAA google.com +short | head -n 1)
            PARAMETER="[${TEST_IPV6}]"

            # shellcheck disable=SC2086
            ${SCRIPT} ${TEST_DEBUG} -H "${PARAMETER}" --ignore-exp

            # shellcheck disable=SC2086
            ${SCRIPT} ${TEST_DEBUG} -H "${PARAMETER}" --ignore-exp

            grep -c "${TEST_IPV6}" ~/.check_ssl_cert-cache | grep -q '^1$'
            EXIT_CODE=$?
            assertEquals "wrong exit code (IPv6 cached more than once)" "${NAGIOS_OK}" "${EXIT_CODE}"

        else
            echo "IPv6 is configured but not working: skipping test"
        fi

    else
        echo "Skipping forcing IPv6: not IPv6 configured locally"
    fi

}

testPurposeCriticalFail() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H github.com --ignore-exp --require-purpose-critical
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testPurposeFail() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H github.com --ignore-exp --require-purpose NOT\ EXISTING
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testPurpose() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H github.com --ignore-exp --require-purpose Digital\ Signature
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testDNSSECOk() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H switch.ch --ignore-exp --require-dnssec
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testDNSSECError() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H corti.li --ignore-exp --require-dnssec
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testXFrameOptionsOK() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H github.com --ignore-exp --require-http-header X-Frame-Options
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testXFrameOptionsFailed() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H badssl.com --ignore-exp --require-http-header X-Frame-Options
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testHTTPHeadersOK() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H securityheaders.com --ignore-exp --require-security-headers
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testHTTPHeadersFailed() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H badssl.com --ignore-exp --require-security-headers
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testHTTPHeaderOK() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H github.com --ignore-exp --require-http-header X-Frame-Options --require-http-header x-xss-protection
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testHTTPHeaderFailed() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H badssl.com --ignore-exp --require-http-header X-Frame-Options --require-http-header x-xss-protection
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testHTTPNoHeaderOK() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H github.com --ignore-exp --require-no-http-header Some-Header --require-http-header x-xss-protection
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testHTTPNoHeaderFailed() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H github.com --ignore-exp --require-no-http-header X-Frame-Options
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testHTTPHeaders() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H matteo.ethz.ch --check-http-headers
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testConfigurationOK() {
    create_temporary_test_file
    CONFIGURATION=${TEMPFILE}
    echo "--verbose" >>"${CONFIGURATION}"
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H matteo.ethz.ch --configuration "${CONFIGURATION}" | grep -q 'The certificate for this site contains'
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${OK}" "${EXIT_CODE}"
}

testConfigurationMissingFile() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H matteo.ethz.ch --configuration MISSING_FILE
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
}

testConfigurationWrongOption() {
    create_temporary_test_file
    CONFIGURATION=${TEMPFILE}
    echo "--invalid-option" >>"${CONFIGURATION}"
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H matteo.ethz.ch --configuration "${CONFIGURATION}"
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
}

testRootCertInChainEnforceOK() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --host www.github.com --check-chain
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testRootCertNotInChainGitHub() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H github.com --verbose | grep -q 'The root certificate is unnecessarily present in the delivered certificate chain'
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NOT_OK}" "${EXIT_CODE}"
}

testRootCertNotInChainGoogle() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H google.com --verbose | grep -q 'The root certificate is unnecessarily present in the delivered certificate chain'
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NOT_OK}" "${EXIT_CODE}"
}

testWrongHost() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --host wrong.host.badssl.com --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testWrongHostIgnore() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --host wrong.host.badssl.com --ignore-host-cn --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testDNS() {

    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --host 1.1.1.1 --protocol dns --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"

    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --host 8.8.8.8 --protocol dns --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"

    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --host 129.132.98.12 --protocol dns --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"

    # test the caching of IPv6 addresses (if IPv6 is available)
    IPV6=
    if command -v ifconfig >/dev/null && ifconfig -a | grep -q -F inet6; then
        IPV6=1
    elif command -v ip >/dev/null && ip addr | grep -q -F inet6; then
        IPV6=1
    fi
    if [ -n "${IPV6}" ]; then
        echo "IPv6 is configured"
        if ping6 -c 3 www.google.com >/dev/null 2>&1; then
            echo "IPv6 is working"

            # shellcheck disable=SC2086
            ${SCRIPT} ${TEST_DEBUG} --host 2001:4860:4860::8888 --protocol dns --ignore-exp
            EXIT_CODE=$?
            assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
        fi
    fi

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
