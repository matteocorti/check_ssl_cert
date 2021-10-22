#!/bin/sh

# authors
authors=$( grep -c 'Many thanks' AUTHORS )

# versions
versions=$( grep -c Version NEWS )

version=$( head -n 1 VERSION )

echo "check_ssl_cert version ${version}"
echo

printf "Authors:\\t%s\\n" "${authors}"
printf "Versions:\\t%s\\n" "${versions}"

echo

tests=$( grep -c '^test' test/unit_tests.sh )
loc=$( grep -c '.' check_ssl_cert )

printf "LoC:\\t\\t%s\\n" "${loc}"
printf "Tests:\\t\\t%s\\n" "${tests}"

echo
