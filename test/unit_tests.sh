#!/bin/sh

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
    ${SCRIPT} -H www.ethz.ch --cn www.ethz.ch --rootcert cabundle.crt
    EXIT_CODE=$?
    assertEquals "wrong exit code" ${NAGIOS_OK} "${EXIT_CODE}"
}

testGoDaddy() {
    ${SCRIPT} -H www.godaddy.com --cn www.godaddy.com --rootcert cabundle.crt
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
    
testValidityWithPerl() {
    ${SCRIPT} --rootcert cabundle.crt -H www.ethz.ch -w 1000 --force-perl-date
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

#Check for wildcard support in Alternative Names
testWildcardAltNames2() {
    ${SCRIPT} -H sherlock.sp.ethz.ch \
        --cn somehost.spapps.ethz.ch \
        --cn otherhost.sPaPPs.ethz.ch \
        --cn spapps.ethz.ch \
        --rootcert cabundle.crt --altnames
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

testXMPP() {
    if [ -z "${TRAVIS+x}" ] ; then
	${SCRIPT} -H nerv.tech --protocol xmpp
	EXIT_CODE=$?
	assertEquals "wrong exit code" ${NAGIOS_OK} "${EXIT_CODE}"
    else
	echo "Skipping XMPP tests on Travis CI"
    fi	
}

testXMPPHost() {
    if [ -z "${TRAVIS+x}" ] ; then
	out=$(${SCRIPT} -H prosody.xmpp.is --port 5222 --protocol xmpp --xmpphost xmpp.is)
	echo "${out}"
	EXIT_CODE=$?
	if echo ${out} | grep -q "s_client' does not support '-xmpphost'" ; then
	    assertEquals "wrong exit code" ${NAGIOS_OK} "${EXIT_CODE}"
	else
	    assertEquals "wrong exit code" ${NAGIOS_UNKNOWN} "${EXIT_CODE}"
	fi
    else
	echo "Skipping XMPP tests on Travis CI"
    fi	
}

# SSL Labs
    
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
    if [ -z "${TRAVIS+x}" ] ; then
	${SCRIPT} --rootcert cabundle.crt -H corti.li --port 993
	EXIT_CODE=$?
	assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    else
	echo "Skipping IMAP tests on Travis CI"
    fi	
}

testSMTP() {
    if [ -z "${TRAVIS+x}" ] ; then
	${SCRIPT} --rootcert cabundle.crt -H corti.li --protocol smtp --port 25 --timeout 60
	EXIT_CODE=$?
	assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    else
	echo "Skipping SMTP tests on Travis CI"
    fi	
}

################################################################################
# From https://badssl.com

testBadSSLExpired() {
    ${SCRIPT} -H expired.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLWrongHost() {
    ${SCRIPT} -H wrong.host.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLSelfSigned() {
    ${SCRIPT} -H self-signed.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLUntrustedRoot() {
    ${SCRIPT} -H untrusted-root.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLRevoked() {
    ${SCRIPT} -H revoked.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testGRCRevoked() {
    ${SCRIPT} -H revoked.grc.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLIncompleteChain() {
    ${SCRIPT} -H incomplete-chain.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLSHA256() {
    if [ -z "${TRAVIS+x}" ] ; then
	${SCRIPT} -H sha256.badssl.com --host-cn
	EXIT_CODE=$?
	assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    else
	echo "Skipping SHA 256 with badssl.com on Travis CI"
    fi	
}

testBadSSL1000SANs() {
    if [ -z "${TRAVIS+x}" ] ; then
	${SCRIPT} -H 1000-sans.badssl.com --host-cn
	EXIT_CODE=$?
	assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    else
	echo "Skipping 1000 subject alternative names with badssl.com on Travis CI"
    fi		
}

# Disabled as OpenSSL does not seem to handle it
#testBadSSL10000SANs() {
#    ${SCRIPT} -H 10000-sans.badssl.com --host-cn
#    EXIT_CODE=$?
#    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
#}

testBadSSLEcc256() {
    if [ -z "${TRAVIS+x}" ] ; then
	${SCRIPT} -H ecc256.badssl.com --host-cn
	EXIT_CODE=$?
	assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    else
	echo "Skipping ECC 256 with badssl.com on Travis CI"
    fi	
}

testBadSSLEcc384() {
    if [ -z "${TRAVIS+x}" ] ; then
	${SCRIPT} -H ecc384.badssl.com --host-cn
	EXIT_CODE=$?
	assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    else
	echo "Skipping ECC 384 with badssl.com on Travis CI"
    fi	
}

testBadSSLRSA8192() {
    if [ -z "${TRAVIS+x}" ] ; then
	${SCRIPT} -H rsa8192.badssl.com --host-cn
	EXIT_CODE=$?
	assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    else
	echo "Skipping RSA8192 with badssl.com on Travis CI"
    fi	
}

testBadSSLLongSubdomainWithDashes() {
    if [ -z "${TRAVIS+x}" ] ; then
	${SCRIPT} -H long-extended-subdomain-name-containing-many-letters-and-dashes.badssl.com --host-cn
	EXIT_CODE=$?
	assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    else
	echo "Skipping long subdomain with dashes with badssl.com on Travis CI"
    fi	
}

testBadSSLLongSubdomain() {
    if [ -z "${TRAVIS+x}" ] ; then
	${SCRIPT} -H longextendedsubdomainnamewithoutdashesinordertotestwordwrapping.badssl.com --host-cn
	EXIT_CODE=$?
	assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
    else
	echo "Skipping long subdomain with badssl.com on Travis CI"
    fi	
}

testBadSSLSHA12016() {
    ${SCRIPT} -H sha1-2016.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

testBadSSLSHA12017() {
    ${SCRIPT} -H sha1-2017.badssl.com --host-cn
    EXIT_CODE=$?
    assertEquals "wrong exit code" "${NAGIOS_CRITICAL}" "${EXIT_CODE}"
}

#testIPv4() {
#    ${SCRIPT} -H 129.132.19.216 --sni www.ethz.ch
#    EXIT_CODE=$?
#    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
#}

#testIPv6() {
#    ${SCRIPT} -H 2001:67c:10ec:4380::216 --sni www.ethz.ch
#    EXIT_CODE=$?
#    assertEquals "wrong exit code" "${NAGIOS_OK}" "${EXIT_CODE}"
#}

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
if ! . "${SHUNIT2}" | tee /dev/tty | grep -q 'tests\ passed:\ *[0-9]*\ 100%' ; then
    # at least one of the tests failed    
    exit 1
fi
