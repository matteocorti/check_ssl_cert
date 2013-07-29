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
    assertEquals "wrong exit code" ${NAGIOS_UNKNOWN} "$?"
}    

# source the script.
. ${SCRIPT}  --source-only

# run shUnit: it will execute all the tests in this file
# (e.g., functions beginning with 'test'
. ${SHUNIT2}
