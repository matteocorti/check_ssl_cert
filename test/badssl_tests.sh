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

startLocalProxy() {
    tinyproxy -c tinyproxy.conf -d  > /dev/null 2>&1
    TINYPROXY=$!
}

stopLocalProxy() {
    if [ -n "${TINYPROXY}" ] ; then
        kill "${TINYPROXY}"
    fi
}

oneTimeSetUp() {
    # constants

    NAGIOS_OK=0
    NAGIOS_CRITICAL=2

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

    true # if the last variable is empty the setup will fail

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

    if [ -n "${http_proxy}" ]; then
        # print the test number
        # shellcheck disable=SC2154
        echo "Running test ${COUNTER} (proxy=${http_proxy}) of ${__shunit_testsTotal} (${PERCENT}%), ${REMAINING} remaining (${__shunit_testsFailed} failed, ${__shunit_assertsSkipped} skipped)"
    else
        # print the test number
        # shellcheck disable=SC2154
        echo "Running test ${COUNTER} of ${__shunit_testsTotal} (${PERCENT}%), ${REMAINING} remaining (${__shunit_testsFailed} failed, ${__shunit_assertsSkipped} skipped)"
     fi
    COUNTER=$((COUNTER + 1))
}

##############################################################################
# Tests

testSignatureAlgorithms() {

    echo "  testing sha256WithRSAEncryption (2048 bit)"
    # shellcheck disable=SC2086
    ALGORITHM=$(${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt --info --ignore-exp --host rsa2048.badssl.com |
                    grep '^Signature algorithm' |
                    sed 's/^Signature algorithm *//')
    assertEquals "wrong signature algorithm" 'sha256WithRSAEncryption (2048 bit)' "${ALGORITHM}"

    echo "  testing sha256WithRSAEncryption (4096 bit)"
    # shellcheck disable=SC2086
    ALGORITHM=$(${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt --info --ignore-exp --host rsa4096.badssl.com |
                    grep '^Signature algorithm' |
                    sed 's/^Signature algorithm *//')
    assertEquals "wrong signature algorithm" 'sha256WithRSAEncryption (4096 bit)' "${ALGORITHM}"

    echo "  testing sha256WithRSAEncryption (8192 bit)"
    # shellcheck disable=SC2086
    ALGORITHM=$(${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt --info --ignore-exp --host rsa8192.badssl.com |
                    grep '^Signature algorithm' |
                    sed 's/^Signature algorithm *//')
    assertEquals "wrong signature algorithm" 'sha256WithRSAEncryption (8192 bit)' "${ALGORITHM}"

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

testBadSSLExpired() {
    host=expired.badssl.com
    if ! nmap --unprivileged -Pn -p 443 "${host}" | grep -q '^443.*open' ; then
        startSkipping
        echo "Skipping test: cannot connect to ${host}:443"
    fi
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H "${host}"
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLExpiredAndWarnThreshold() {
    host=expired.badssl.com
    if ! nmap --unprivileged -Pn -p 443 "${host}" | grep -q '^443.*open' ; then
        startSkipping
        echo "Skipping test: cannot connect to ${host}:443"
    fi
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H "${host}" --warning 3000
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLWrongHost() {
    host=wrong.host.badssl.com
    if ! nmap --unprivileged -Pn -p 443 "${host}" | grep -q '^443.*open' ; then
        startSkipping
        echo "Skipping test: cannot connect to ${host}:443"
    fi
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H "${host}"  --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLSelfSigned() {
    host=self-signed.badssl.com
    if ! nmap --unprivileged -Pn -p 443 "${host}" | grep -q '^443.*open' ; then
        startSkipping
        echo "Skipping test: cannot connect to ${host}:443"
    fi
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H "${host}" --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLUntrustedRoot() {
    host=untrusted-root.badssl.com
    if ! nmap --unprivileged -Pn -p 443 "${host}" | grep -q '^443.*open' ; then
        startSkipping
        echo "Skipping test: cannot connect to ${host}:443"
    fi
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H "${host}"  --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLRevoked() {
    host=revoked.badssl.com
    if ! nmap --unprivileged -Pn -p 443 "${host}" | grep -q '^443.*open' ; then
        startSkipping
        echo "Skipping test: cannot connect to ${host}:443"
    fi
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H "${host}"
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testGRCRevoked() {
    host=revoked.grc.com
    if ! nmap --unprivileged -Pn -p 443 "${host}" | grep -q '^443.*open' ; then
        startSkipping
        echo "Skipping test: cannot connect to ${host}:443"
    fi
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H "${host}"
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLIncompleteChain() {
    host=incomplete-chain.badssl.com
    if ! nmap --unprivileged -Pn -p 443 "${host}" | grep -q '^443.*open' ; then
        startSkipping
        echo "Skipping test: cannot connect to ${host}:443"
    fi
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H "${host}"
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLDH480() {
    host=dh480.badssl.com
    if ! nmap --unprivileged -Pn -p 443 "${host}" | grep -q '^443.*open' ; then
        startSkipping
        echo "Skipping test: cannot connect to ${host}:443"
    fi
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H "${host}"  --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLDH512() {
    host=dh512.badssl.com
    if ! nmap --unprivileged -Pn -p 443 "${host}" | grep -q '^443.*open' ; then
        startSkipping
        echo "Skipping test: cannot connect to ${host}:443"
    fi
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H "${host}" --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLRC4MD5() {
    host=rc4-md5.badssl.com
    if ! nmap --unprivileged -Pn -p 443 "${host}" | grep -q '^443.*open' ; then
        startSkipping
        echo "Skipping test: cannot connect to ${host}:443"
    fi
    # older versions of OpenSSL validate RC4-MD5
    if "${OPENSSL}" ciphers RC4-MD5 >/dev/null 2>&1; then
        startSkipping
        echo "Skipping test: OpenSSL too old to test RC4-MD5 ciphers"
    fi
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H "${host}" --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}


testBadSSLRC4() {
    host=rc4.badssl.com
    if ! nmap --unprivileged -Pn -p 443 "${host}" | grep -q '^443.*open' ; then
        startSkipping
        echo "Skipping test: cannot connect to ${host}:443"
    fi
    # older versions of OpenSSL validate RC4
    if "${OPENSSL}" ciphers RC4 >/dev/null 2>&1; then
        startSkipping
    fi
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H "${host}" --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSL3DES() {
    host=3des.badssl.com
    if ! nmap --unprivileged -Pn -p 443 "${host}" | grep -q '^443.*open' ; then
        startSkipping
        echo "Skipping test: cannot connect to ${host}:443"
    fi
    # older versions of OpenSSL validate RC4
    if "${OPENSSL}" ciphers 3DES >/dev/null 2>&1; then
        startSkipping
        echo "Skipping test: OpenSSL too old to test 3DES ciphers"
    fi
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H "${host}" --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLNULL() {
    host=null.badssl.com
    if ! nmap --unprivileged -Pn -p 443 "${host}" | grep -q '^443.*open' ; then
        startSkipping
        echo "Skipping test: cannot connect to ${host}:443"
    fi
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H "${host}" --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLSHA256() {
    host=sha256.badssl.com
    if ! nmap --unprivileged -Pn -p 443 "${host}" | grep -q '^443.*open' ; then
        startSkipping
        echo "Skipping test: cannot connect to ${host}:443"
    fi
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H "${host}" --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testBadSSLEcc256() {
    host=ecc256.badssl.com
    if ! nmap --unprivileged -Pn -p 443 "${host}" | grep -q '^443.*open' ; then
        startSkipping
        echo "Skipping test: cannot connect to ${host}:443"
    fi
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H "${host}" --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testBadSSLEcc384() {
    host=ecc384.badssl.com
    if ! nmap --unprivileged -Pn -p 443 "${host}" | grep -q '^443.*open' ; then
        startSkipping
        echo "Skipping test: cannot connect to ${host}:443"
    fi
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H "${host}" --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testBadSSLRSA8192() {
    host=rsa8192.badssl.com
    if ! nmap --unprivileged -Pn -p 443 "${host}" | grep -q '^443.*open' ; then
        startSkipping
        echo "Skipping test: cannot connect to ${host}:443"
    fi
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H "${host}" --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testBadSSLLongSubdomainWithDashes() {
    host=long-extended-subdomain-name-containing-many-letters-and-dashes.badssl.com
    if ! nmap --unprivileged -Pn -p 443 "${host}" | grep -q '^443.*open' ; then
        startSkipping
        echo "Skipping test: cannot connect to ${host}:443"
    fi
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H "${host}" --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testBadSSLLongSubdomain() {
    host=longextendedsubdomainnamewithoutdashesinordertotestwordwrapping.badssl.com
    if ! nmap --unprivileged -Pn -p 443 "${host}" | grep -q '^443.*open' ; then
        startSkipping
        echo "Skipping test: cannot connect to ${host}:443"
    fi
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H "${host}" --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testBadSSLSHA12016() {
    host=sha1-2016.badssl.com
    if ! nmap --unprivileged -Pn -p 443 "${host}" | grep -q '^443.*open' ; then
        startSkipping
        echo "Skipping test: cannot connect to ${host}:443"
    fi
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H "${host}" --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLSHA12017() {
    host=sha1-2017.badssl.com
    if ! nmap --unprivileged -Pn -p 443 "${host}" | grep -q '^443.*open' ; then
        startSkipping
        echo "Skipping test: cannot connect to ${host}:443"
    fi
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H "${host}" --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testXFrameOptionsFailed() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H badssl.com --ignore-exp --require-http-header X-Frame-Options
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testHTTPHeadersFailed() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H badssl.com --ignore-exp --require-security-headers
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testHTTPHeaderFailed() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H badssl.com --ignore-exp --require-http-header X-Frame-Options --require-http-header x-xss-protection
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
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
