#!/bin/sh

if [ -z "${SHUNIT2}" ] ; then
    cat <<EOF
To be able to run the unit test you need a copy of shUnit2
You can download it from http://shunit2.googlecode.com/

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

# constants

NAGIOS_OK=0
NAGIOS_CRITICAL=1
NAGIOS_WARNING=2
NAGIOS_UNKNOWN=3

testDependencies() {
    check_required_prog openssl
    assertNotNull 'openssl not found' "${PROG}"
}

# FIXME use a series of certificates to test valid/invalid data
testCertificate() {
    ${SCRIPT} --host localhost --file cacert.crt > /dev/null
    assertEquals "wrong exit code" ${NAGIOS_OK} "$?"
}

testUsage() {
    ${SCRIPT} > /dev/null 2>&1
    EXIT_CODE=$?
    assertEquals "wrong exit code" ${NAGIOS_UNKNOWN} "${EXIT_CODE}"
}    

testGoogle() {
    ${SCRIPT} -H www.google.com --cn www.google.com
    EXIT_CODE=$?
    assertEquals "wrong exit code" ${NAGIOS_OK} "${EXIT_CODE}"
}

testGoogleWildCard() {
    ${SCRIPT} -H translate.google.com --cn google.com
    EXIT_CODE=$?
    assertEquals "wrong exit code" ${NAGIOS_OK} "${EXIT_CODE}"
}

testGoogleWithSSLLabs() {
    # we assume Google gets at least a C
    ${SCRIPT} -H www.google.com --cn www.google.com --check-ssl-labs C
    EXIT_CODE=$?
    assertEquals "wrong exit code" ${NAGIOS_OK} "${EXIT_CODE}"
}

# the script will exit without executing main
export SOURCE_ONLY='test'

# source the script.
. ${SCRIPT} 

unset SOURCE_ONLY

# run shUnit: it will execute all the tests in this file
# (e.g., functions beginning with 'test'
#
# We clone to output to pass it to grep as shunit does always return 0
# We parse the output to check if a test failed
#
if ! . "${SHUNIT2}" | tee /dev/tty | grep -q 'success rate: 100%' ; then
    # at least one of the tests failed
    exit 1
fi
