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
NAGIOS_WARNING=1
NAGIOS_CRITICAL=2
NAGIOS_UNKNOWN=3

testDependencies() {
    check_required_prog openssl
    assertNotNull 'openssl not found' "${PROG}"
}

testUsage() {
    ${SCRIPT} > /dev/null 2>&1
    EXIT_CODE=$?
    assertEquals "wrong exit code" ${NAGIOS_UNKNOWN} "${EXIT_CODE}"
}    

testETHZ() {
    # debugging: to be removed
    ${SCRIPT} -H www.ethz.ch --cn www.ethz.ch --rootcert cabundle.crt
    EXIT_CODE=$?
    assertEquals "wrong exit code" ${NAGIOS_OK} "${EXIT_CODE}"
}

testETHZCaseInsensitive() {
    # debugging: to be removed
    ${SCRIPT} -H www.ethz.ch --cn WWW.ETHZ.CH --rootcert cabundle.crt
    EXIT_CODE=$?
    assertEquals "wrong exit code" ${NAGIOS_OK} "${EXIT_CODE}"
}

testETHZWildCard() {
    ${SCRIPT} -H sherlock.sp.ethz.ch --cn sp.ethz.ch --rootcert cabundle.crt
    EXIT_CODE=$?
    assertEquals "wrong exit code" ${NAGIOS_OK} "${EXIT_CODE}"
}

testETHZWildCardCaseInsensitive() {
    ${SCRIPT} -H sherlock.sp.ethz.ch --cn SP.ETHZ.CH --rootcert cabundle.crt
    EXIT_CODE=$?
    assertEquals "wrong exit code" ${NAGIOS_OK} "${EXIT_CODE}"
}

testETHZWildCardSub() {
    ${SCRIPT} -H sherlock.sp.ethz.ch --cn sub.sp.ethz.ch --rootcert cabundle.crt
    EXIT_CODE=$?
    assertEquals "wrong exit code" ${NAGIOS_OK} "${EXIT_CODE}"
}

testETHZWildCardSubCaseInsensitive() {
    ${SCRIPT} -H sherlock.sp.ethz.ch --cn SUB.SP.ETHZ.CH --rootcert cabundle.crt
    EXIT_CODE=$?
    assertEquals "wrong exit code" ${NAGIOS_OK} "${EXIT_CODE}"
}

testValidity() {
    # Tests bug #8
    ${SCRIPT} --rootcert cabundle.crt -H www.ethz.ch -w 1000
    EXIT_CODE=$?
    assertEquals "wrong exit code" ${NAGIOS_WARNING} "${EXIT_CODE}"
}
    

testAltNames() {
    ${SCRIPT} -H www.inf.ethz.ch --cn www.inf.ethz.ch --rootcert cabundle.crt --altnames
    EXIT_CODE=$?
    assertEquals "wrong exit code" ${NAGIOS_OK} "${EXIT_CODE}"
}

#Do not require to match Alternative Name if CN already matched
testWildcardAltNames1() {
    ${SCRIPT} -H sherlock.sp.ethz.ch --rootcert cabundle.crt --altnames --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" ${NAGIOS_OK} "${EXIT_CODE}"
}

testAltNamesCaseInsensitve() {
    ${SCRIPT} -H www.inf.ethz.ch --cn WWW.INF.ETHZ.CH --rootcert cabundle.crt --altnames
    EXIT_CODE=$?
    assertEquals "wrong exit code" ${NAGIOS_OK} "${EXIT_CODE}"
}

testAltNames2() {
    # should fail: inf.ethz.ch has the same ip as www.inf.ethz.ch but inf.ethz.ch is not in the certificate
    ${SCRIPT} -H inf.ethz.ch --cn inf.ethz.ch --rootcert cabundle.crt --altnames
    EXIT_CODE=$?
    assertEquals "wrong exit code" ${NAGIOS_CRITICAL} "${EXIT_CODE}"
}

testMultipleAltNamesOK() {
    # Test with multiple CN's
    ${SCRIPT} -H inf.ethz.ch -n www.ethz.ch -n ethz.ch --rootcert cabundle.crt --altnames
    EXIT_CODE=$?
    assertEquals "wrong exit code" ${NAGIOS_OK} "${EXIT_CODE}"
}

testMultipleAltNamesFailOne() {
    # Test with wiltiple CN's but last one is wrong
    ${SCRIPT} -H inf.ethz.ch -n www.ethz.ch -n wrong.ch --rootcert cabundle.crt --altnames
    EXIT_CODE=$?
    assertEquals "wrong exit code" ${NAGIOS_CRITICAL} "${EXIT_CODE}"
}

testMultipleAltNamesFailTwo() {
    # Test with multiple CN's but first one is wrong
    ${SCRIPT} -H inf.ethz.ch -n wrong.ch -n www.ethz.ch --rootcert cabundle.crt --altnames
    EXIT_CODE=$?
    assertEquals "wrong exit code" ${NAGIOS_CRITICAL} "${EXIT_CODE}"
}

testAltNames2CaseInsensitive() {
    # should fail: inf.ethz.ch has the same ip as www.inf.ethz.ch but inf.ethz.ch is not in the certificate
    ${SCRIPT} -H inf.ethz.ch --cn INF.ETHZ.CH --rootcert cabundle.crt --altnames
    EXIT_CODE=$?
    assertEquals "wrong exit code" ${NAGIOS_CRITICAL} "${EXIT_CODE}"
}

testETHZWithSSLLabs() {
    # we assume www.ethz.ch gets at least a C
    ${SCRIPT} -H www.ethz.ch --cn www.ethz.ch --check-ssl-labs C --rootcert cabundle.crt
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testTimeOut() {
    ${SCRIPT} --rootcert cabundle.crt -H corti.li --protocol imap --port 993 --timeout  1
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testIMAP() {
    ${SCRIPT} --rootcert cabundle.crt -H corti.li --port 993
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
}

testSMTP() {

    # Travis CI blocks port 25
    if [ -z "${TRAVIS+x}" ] ; then

	${SCRIPT} --rootcert cabundle.crt -H corti.li --protocol smtp --port 25 --timeout 60
	EXIT_CODE=$?
	assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"

    else

	echo "Skipping SMTP tests on Travis CI"

    fi	
	
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
if ! . "${SHUNIT2}" | tee /dev/tty | grep -q 'tests\ total:\ *[0-9]*\ 100%' ; then
    # at least one of the tests failed
    exit 1
fi
