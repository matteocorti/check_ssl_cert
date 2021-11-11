#!/bin/sh

# authors
authors=$( grep -c 'Many thanks' AUTHORS )

# versions
versions=$( grep -c Version NEWS )

version=$( head -n 1 VERSION )

echo "check_ssl_cert version ${version}"
echo

printf "Authors:\\t%10s\\n" "${authors}"
printf "Versions:\\t%10s\\n" "${versions}"

echo

tests=$( grep -c '^test' test/unit_tests.sh )
loc=$( grep -c '.' check_ssl_cert )

printf "LoC:\\t\\t%10s\\n" "${loc}"
printf "Tests:\\t\\t%10s\\n" "${tests}"

echo

commits=$( git log --oneline | wc -l )

printf "Commits:\\t%10s\\n" "${commits}"
git log --numstat --format="" | awk '{files += 1}{ins += $1}{del += $2} END{printf "File changes\t%10s\nInsertions\t%10s\nDeletions\t%10s\n", files, ins, del}'
