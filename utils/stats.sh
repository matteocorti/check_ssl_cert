#!/bin/sh

# authors
authors=$( grep -c 'Many thanks' AUTHORS.md )

# versions
versions=$( grep -c Version NEWS.md )

version=$( head -n 1 VERSION )

echo
printf "\tcheck_ssl_cert version ${version}\n"
echo

echo "------------------------------------------------------------------------------"
echo "-- Version History and Authors"
echo

printf "Authors:\\t\\t%'10d\\n" "${authors}"
printf "Versions:\\t\\t%'10d\\n" "${versions}"
echo

echo "------------------------------------------------------------------------------"
echo "-- Code"
echo

tests=$( grep -c '^test' test/unit_tests.sh )
loc=$( grep -c '.' check_ssl_cert )

printf "LoC:\\t\\t\\t%'10d\\n" "${loc}"
printf "Tests:\\t\\t\\t%'10d\\n" "${tests}"
echo

echo "------------------------------------------------------------------------------"
echo "-- Repository"
echo

commits=$( git log --oneline | wc -l )

printf "Commits:\\t\\t%'10d\\n" "${commits}"
git log --numstat --format="" | awk '{files += 1}{ins += $1}{del += $2} END{printf "File changes:\t\t%10'"'"'d\nInsertions:\t\t%10'"'"'d\nDeletions:\t\t%10'"'"'d\n", files, ins, del}'

echo

echo "------------------------------------------------------------------------------"
echo "-- Features"
echo

command_line_options=$( sed 's/;.*//' help.txt  | sort  | uniq | wc -l )
printf "Command line options:\\t%'10d\\n" "${command_line_options}"

echo
