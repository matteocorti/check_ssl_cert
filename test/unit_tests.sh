#!/bin/sh

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

    # create a temporary file
    TEMPFILE="$(mktemp "${TMPDIR}/XXXXXX" 2>/dev/null)"

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
    echo 'Starting SSL Lab test (to cache the result)'
    curl --silent 'https://www.ssllabs.com/ssltest/analyze.html?d=ethz.ch&latest' >/dev/null

    # print the openssl version
    echo 'OpenSSL version'
    if [ -z "${OPENSSL}" ]; then
        OPENSSL=$(command -v openssl) # needed by openssl_version
    fi
    "${OPENSSL}" version

    KEYTOOL=$(command -v keytool) # Java?
    PYTHON3=$(command -v python3) # web server for the issuer certificate test

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

    if [ -n "${http_proxy}" ]; then
        # print the test number
        # shellcheck disable=SC2154
        echo "Running test ${COUNTER} (proxy=${http_proxy}) of ${__shunit_testsTotal} (${PERCENT}%), ${REMAINING} remaining (${__shunit_testsFailed} failed)"
    else
        # print the test number
        # shellcheck disable=SC2154
        echo "Running test ${COUNTER} of ${__shunit_testsTotal} (${PERCENT}%), ${REMAINING} remaining (${__shunit_testsFailed} failed)"
    fi
    COUNTER=$((COUNTER + 1))
}

##############################################################################
# Tests

testNumericCheck() {

    export UNIT_TEST=1

    for argument in 0 1 01 10 100 0.1 1.1 11.1 0% 10% 100% 0.1% 3.3% 100.0%; do
        echo "Checking numeric argument: ${argument}"
        check_numeric_argument "${argument}"
        assertEquals " check_numeric_argument ${argument}" 1 $?
    done

    for argument in a % %1 1.1.1 1%1 120% 100.1% 10%% -1%; do
        echo "Checking numeric argument: ${argument}"
        check_numeric_argument "${argument}"
        assertEquals " check_numeric_argument ${argument}" 0 $?
    done

}

testHoursUntilNow() {
    # testing with perl
    if perl -e 'use Date::Parse;' >/dev/null 2>&1; then
        export DATETYPE='PERL'
        DATE_TMP="$(date)"
        hours_until "${DATE_TMP}"
        assertEquals "error computing the missing hours until now" 0 "${HOURS_UNTIL}"
    else
        echo "Date::Parse not installed: skipping Perl date computation tests"
    fi
}

testHoursUntil5Hours() {

    # testing with perl
    if perl -e 'use Date::Parse;' >/dev/null 2>&1; then
        export DATETYPE='PERL'
        DATE_TMP="$(perl -e '$x=localtime(time+(5*3600));print $x')"
        hours_until "${DATE_TMP}"
        assertEquals "error computing the missing hours until now" 5 "${HOURS_UNTIL}"
    else
        echo "Date::Parse not installed: skipping Perl date computation tests"
    fi
}

testHoursUntil42Hours() {
    # testing with perl
    if perl -e 'use Date::Parse;' >/dev/null 2>&1; then
        export DATETYPE='PERL'
        DATE_TMP="$(perl -e '$x=localtime(time+(42*3600));print $x')"
        hours_until "${DATE_TMP}"
        assertEquals "error computing the missing hours until now" 42 "${HOURS_UNTIL}"
    else
        echo "Date::Parse not installed: skipping Perl date computation tests"
    fi
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

testUsage() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} >/dev/null 2>&1
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
}

testMissingArgument() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.google.com --critical >/dev/null 2>&1
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
}

testMissingArgument2() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.google.com --critical --warning 10 >/dev/null 2>&1
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
}

testGroupedVariables() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.google.com -vvv --ignore-exp
    # >/dev/null 2>&1
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testGroupedVariablesError() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.google.com -vvxv >/dev/null 2>&1
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
}

testTimeOut() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H gmail.com --protocol imap --port 993 --timeout 1 --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testRequiredProgramFile() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.google.com --file-bin /doesnotexist --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
}

testRequiredProgramPermissions() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.google.com --file-bin /etc/hosts --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"
}

testNotLongerValidThan() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -H www.github.com --not-valid-longer-than 2
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testDERCert() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -f ./der.cer --ignore-sct --ignore-exp --allow-empty-san -s
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testDERCertURI() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -f "file://${PWD}/der.cer" --ignore-sct --ignore-exp --allow-empty-san -s
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testDERCertSymbolicLink() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --rootcert-file cabundle.crt -f ./derlink.cer --ignore-sct --ignore-exp --allow-empty-san -s
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testIssuerP7B() {
    # the CA Issuers URI points to a PEM encoded PKCS #7 bundle (#574)
    if [ -n "${PYTHON3}" ]; then

        create_temporary_test_file
        CA_KEY=${TEMPFILE}
        create_temporary_test_file
        CA_CERT=${TEMPFILE}
        create_temporary_test_file
        CONFIGURATION=${TEMPFILE}
        create_temporary_test_file
        KEY=${TEMPFILE}
        create_temporary_test_file
        CSR=${TEMPFILE}
        create_temporary_test_file
        CERTIFICATE=${TEMPFILE}
        create_temporary_test_file
        INDEX=${TEMPFILE}
        WWW=$(mktemp -d "${TMPDIR}/XXXXXX")

        cat <<'EOT' >"${CONFIGURATION}"
[ req ]
prompt = no
distinguished_name=req_distinguished_name

[ req_distinguished_name ]
commonName=localhost

[ v3_req ]
subjectAltName = DNS:localhost
authorityInfoAccess = caIssuers;URI:http://127.0.0.1:18080/issuer.p7b,OCSP;URI:http://127.0.0.1:18081
EOT

        ${OPENSSL} req -new -x509 -newkey rsa:2048 -nodes -subj '/CN=p7b test CA' -keyout "${CA_KEY}" -out "${CA_CERT}" -days 30 >/dev/null 2>&1
        ${OPENSSL} req -new -newkey rsa:2048 -nodes -keyout "${KEY}" -out "${CSR}" -config "${CONFIGURATION}" >/dev/null 2>&1
        ${OPENSSL} x509 -req -in "${CSR}" -CA "${CA_CERT}" -CAkey "${CA_KEY}" -set_serial 1 -days 30 -extfile "${CONFIGURATION}" -extensions v3_req -out "${CERTIFICATE}" >/dev/null 2>&1
        ${OPENSSL} crl2pkcs7 -nocrl -certfile "${CA_CERT}" -out "${WWW}/issuer.p7b"
        printf 'V\t351231235959Z\t\t01\tunknown\t/CN=localhost\n' >"${INDEX}"

        "${PYTHON3}" -m http.server --bind 127.0.0.1 --directory "${WWW}" 18080 >/dev/null 2>&1 &
        WWW_PID=$!
        ${OPENSSL} ocsp -index "${INDEX}" -CA "${CA_CERT}" -rsigner "${CA_CERT}" -rkey "${CA_KEY}" -port 18081 -nrequest 1 >/dev/null 2>&1 &
        OCSP_PID=$!
        sleep 1

        # shellcheck disable=SC2086
        ${SCRIPT} ${TEST_DEBUG} --file "${CERTIFICATE}" --rootcert-file "${CA_CERT}" --ignore-sct --ignore-maximum-validity
        EXIT_CODE=$?

        kill "${WWW_PID}" "${OCSP_PID}" 2>/dev/null
        rm -rf "${WWW}"

        assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"

    else
        echo "Python 3 not installed: skipping PKCS #7 issuer test"
    fi
}

testCertificateWithEmptySAN() {
    CERT=$(createSelfSignedCertificate 30)

    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -f "${CERT}" --selfsigned --allow-empty-san --ignore-sig-alg --ignore-exp -m localhost
    EXIT_CODE=$?

    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testCertificateWithEmptySANFail() {
    # Test with wrong CN's
    CERT=$(createSelfSignedCertificate 30)

    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -f "${CERT}" --selfsigned --allow-empty-san --ignore-sig-alg --ignore-exp -m wrong.com
    EXIT_CODE=$?

    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testFloatingPointThresholds() {

    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H google.com --warning 2.5 --critical 1.5
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"

}

testFloatingPointThresholdsExpired() {

    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H expired.badssl.com --warning 2.5 --critical 1.5
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"

}

testFloatingPointThresholdsRecentlyExpired() {

    create_temporary_test_file
    FAKE_DATE=${TEMPFILE}

    cat <<'EOT' >"${FAKE_DATE}"
#!/bin/sh

case "$1" in
    --version)
        echo 'date (GNU coreutils) 9.0'
        ;;
    +%s)
        echo 1748312553
        ;;
    -d)
        echo 1748308953
        ;;
    *)
        exit 1
        ;;
esac
EOT
    chmod +x "${FAKE_DATE}"

    create_temporary_test_file
    EXPIRED_CERT=${TEMPFILE}
    # Keep only the leaf so --ignore-incomplete-chain reaches the expiry check.
    "${OPENSSL}" x509 -in ./corti.li.pem -out "${EXPIRED_CERT}"

    # The fake date reports one hour after corti.li.pem's expiry.
    # Use the local fixture so connection failures cannot hide the expiry message.
    # shellcheck disable=SC2086
    OUTPUT=$(${SCRIPT} ${TEST_DEBUG} -f "${EXPIRED_CERT}" --ignore-incomplete-chain --ignore-ocsp --ignore-crl --ignore-sct --warning 1.0 --critical 0 --date "${FAKE_DATE}" --first-element-only 2>&1)
    EXIT_CODE=$?
    echo "${OUTPUT}"

    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"

    echo "${OUTPUT}" | grep -q 'less than a day ago'
    assertEquals "wrong expiry description" 0 $?

}

testFloatingPointThresholdsWrongUsage() {

    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -H github.com --warning 1.5 --critical 2.5
    EXIT_CODE=$?
    assertEquals "expecting error message about --warning is less or equal --critical, but got wrong exit code, " "${NAGIOS_UNKNOWN}" "${EXIT_CODE}"

}

testCertExpiringInLessThanOneDay() {

    CERT=$(createSelfSignedCertificate 1)

    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -f "${CERT}" --warning 1.5 --critical 0.5 --selfsigned --allow-empty-san --ignore-sig-alg
    EXIT_CODE=$?

    assertEquals "wrong exit code" "${NAGIOS_WARNING}" "${EXIT_CODE}"

}

testMaxDateOn32BitSystems() {

    # generate a cert expiring after 2038-01-19
    CERT=$(createSelfSignedCertificate 7000)

    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -f "${CERT}" --warning 2 --critical 1 --selfsigned --allow-empty-san --ignore-sig-alg --ignore-maximum-validity
    EXIT_CODE=$?

    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"

    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -f "${CERT}" --warning 2 --critical 1 --selfsigned --allow-empty-san --ignore-sig-alg --ignore-maximum-validity 2>&1 | grep -q 'invalid date'
    EXIT_CODE=$?

    assertEquals "Invalid date" 1 "${EXIT_CODE}"

}

testNoCRLDistributionPoint() {

    CERT=$(createSelfSignedCertificate)

    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -f "${CERT}" --selfsigned --allow-empty-san --ignore-sig-alg 2>&1 | grep -q 'No extensions in certificate'
    EXIT_CODE=$?

    assertEquals "OpenSSL message in the output" 1 "${EXIT_CODE}"

}

testMaximumValidityFailed() {
    # generate a cert expiring in 400 days
    CERT=$(createSelfSignedCertificate 400)
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -f "${CERT}" --selfsigned --allow-empty-san --ignore-sig-alg
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testMaximumValidityShort() {
    # generate a cert expiring in 400 days
    CERT=$(createSelfSignedCertificate 400)
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -f "${CERT}" --selfsigned --allow-empty-san --ignore-sig-alg --maximum-validity 20
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testMaximumValidityLong() {
    # generate a cert expiring in 400 days
    CERT=$(createSelfSignedCertificate 400)
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -f "${CERT}" --selfsigned --allow-empty-san --ignore-sig-alg --maximum-validity 500
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testMaximumValidityIgnored() {
    # generate a cert expiring in 400 days
    CERT=$(createSelfSignedCertificate 400)
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -f "${CERT}" --selfsigned --allow-empty-san --ignore-sig-alg --ignore-maximum-validity
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testChainOK() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -f ./fullchain.pem --allow-empty-san --ignore-sct --ignore-exp --ignore-maximum-validity
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testChainFail() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -f ./incomplete_chain.pem --allow-empty-san --ignore-sct --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testChainFailIgnored() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} -f ./incomplete_chain.pem --ignore-incomplete-chain --allow-empty-san --ignore-sct --ignore-exp
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testJavaKeyStore1() {
    if [ -n "${KEYTOOL}" ]; then
        # shellcheck disable=SC2086
        ${SCRIPT} ${TEST_DEBUG} --file ./keystore.jks --password changeit --jks-alias google-com --ignore-incomplete-chain --ignore-exp
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    else
        echo "Java not installed: skipping key store tests"
    fi
}

testJavaKeyStore2() {
    if [ -n "${KEYTOOL}" ]; then
        # shellcheck disable=SC2086
        ${SCRIPT} ${TEST_DEBUG} --file ./cacerts.jks --password changeit --jks-alias "verisignuniversalrootca [jdk]" --allow-empty-san --ignore-maximum-validity --selfsigned
        EXIT_CODE=$?
        assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    else
        echo "Java not installed: skipping key store tests"
    fi
}

testDirectoryAsAFile() {
    # shellcheck disable=SC2086
    ${SCRIPT} ${TEST_DEBUG} --file somedir
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

# Keep the clock deterministic while exercising the real threshold checks.
# Subshells isolate the clock and OpenSSL stubs from other tests.
# Variables and function stubs are consumed by the sourced plugin.
# shellcheck disable=SC2034,SC2329,SC2030,SC2317
testPercentageThresholds() (
    BCBIN=$(command -v bc)
    GREP_BIN=$(command -v grep)
    SCALE=0
    VERBOSE=0
    DEBUG=0

    extract_cert_attribute() {
        case "$1" in
        cn) echo 'test certificate' ;;
        enddate) echo "$((remaining_days * 86400))" ;;
        startdate) echo "$(((remaining_days - lifetime_days) * 86400))" ;;
        *) return 1 ;;
        esac
    }
    hours_until() {
        DATE_SECONDS=$1
        HOURS_UNTIL=$((DATE_SECONDS / 3600))
    }
    checkend() {
        [ "$((remaining_days * 86400))" -gt "$2" ]
    }
    unknown() {
        echo "$1"
        exit 3
    }

    for OPENSSL_COMMAND in x509 crl; do
        # lifetime, remaining, warning, critical, expected status, resolved days
        # Consecutive elements exercise percentage preservation across a chain.
        for scenario in \
            '100 15 20% 10% 1 20 10' \
            '200 15 20% 10% 2 40 20' \
            '100 30 20% 10% 0 20 10' \
            '100 15 20 10% 1 20 10' \
            '100 15 20% 10 1 20 10' \
            '100 15 20.5% 10.5% 1 20.5 10.5' \
            '100 15 100% 0% 1 100 0' \
            '100 15 0% 0% 0 0 0' \
            '100 -1 0% 0% 2 0 0' \
            '100 15 20 10 1 20 10'; do
            # shellcheck disable=SC2086
            set -- ${scenario}
            lifetime_days=$1
            remaining_days=$2
            WARNING_DAYS=$3
            CRITICAL_DAYS=$4
            WARNING_SECONDS=$(days_to_seconds "${WARNING_DAYS}")
            CRITICAL_SECONDS=$(days_to_seconds "${CRITICAL_DAYS}")
            PERFORMANCE_DATA=''
            check_cert_end_date 'test certificate' 1
            status=$?
            assertEquals "${OPENSSL_COMMAND}: ${scenario}" "$5" "${status}" || exit 1
            compare "${ELEM_WARNING_DAYS}" '==' "$6"
            assertEquals "resolved warning: ${scenario}" 0 $? || exit 1
            compare "${ELEM_CRITICAL_DAYS}" '==' "$7"
            assertEquals "resolved critical: ${scenario}" 0 $? || exit 1
            echo "${PERFORMANCE_DATA}" | grep -q '%'
            assertEquals 'performance thresholds must be numeric days' 1 $? || exit 1
        done
    done

    for scenario in '100 10% 20' '200 20 15%'; do
        # shellcheck disable=SC2086
        set -- ${scenario}
        lifetime_days=$1
        remaining_days=15
        WARNING_DAYS=$2
        CRITICAL_DAYS=$3
        WARNING_SECONDS=$(days_to_seconds "${WARNING_DAYS}")
        CRITICAL_SECONDS=$(days_to_seconds "${CRITICAL_DAYS}")
        (check_cert_end_date 'test certificate' 1)
        assertEquals "inverted mixed thresholds: ${scenario}" 3 $? || exit 1
    done
)

testPercentageThresholdsFromFile() {
    createSelfSignedCertificate 90 >/dev/null
    CERT=${CERTIFICATE}
    # A 100% threshold must be checked after the certificate's issue time.
    sleep 1

    for thresholds in '20% 10% 0' '100% 10% 1' '100% 100% 2' '20 10% 0' '20% 10 0'; do
        # shellcheck disable=SC2086
        set -- ${thresholds}
        # shellcheck disable=SC2086
        OUTPUT=$(${SCRIPT} ${TEST_DEBUG} -f "${CERT}" --warning "$1" --critical "$2" --selfsigned --allow-empty-san --ignore-sig-alg)
        EXIT_CODE=$?
        echo "${OUTPUT}"
        assertEquals "file thresholds: ${thresholds}" "$3" "${EXIT_CODE}"
        if [ "$1:$2" = '20%:10%' ]; then
            echo "${OUTPUT}" | grep -q ';18[.]00000000;9[.]00000000;;'
            assertEquals 'percentage thresholds use the full 90-day lifetime' 0 $?
        fi
    done
}

testPercentageThresholdsFromCRL() {
    createSelfSignedCertificate 90 >/dev/null
    create_temporary_test_file
    CRL_DATABASE=${TEMPFILE}
    create_temporary_test_file
    CRL_CONFIG=${TEMPFILE}
    create_temporary_test_file
    CRL_FILE=${TEMPFILE}
    cat >"${CRL_CONFIG}" <<EOF
[ ca ]
default_ca = test
[ test ]
database = ${CRL_DATABASE}
certificate = ${CERTIFICATE}
private_key = ${KEY}
default_md = sha256
default_crl_days = 90
EOF
    "${OPENSSL}" ca -gencrl -config "${CRL_CONFIG}" -out "${CRL_FILE}" 2>/dev/null
    assertEquals 'generate test CRL' 0 $?
    # A 100% threshold must be checked after the CRL's issue time.
    sleep 1
    for thresholds in '20% 10% 0' '100% 100% 2'; do
        # shellcheck disable=SC2086
        set -- ${thresholds}
        ${SCRIPT} -f "${CRL_FILE}" --warning "$1" --critical "$2" --ignore-maximum-validity
        assertEquals "CRL thresholds: ${thresholds}" "$3" $?
    done
}

testPercentageThresholdsInvalidInput() (
    unset UNIT_TEST
    for threshold in '100.1%' '101%' '-1%' '10%%' '%' 'ten%'; do
        for option in --warning --critical; do
            ${SCRIPT} -H localhost "${option}" "${threshold}"
            assertEquals "invalid threshold: ${option} ${threshold}" 3 $? || exit 1
        done
    done
)

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
