#!/bin/sh

# authors
authors=$( grep -c 'Many thanks' AUTHORS.md )

# versions
versions=$( grep -c Version NEWS.md )

version=$( head -n 1 VERSION )

echo
printf "\tcheck_ssl_cert version %s\n" "${version}"
echo

echo "------------------------------------------------------------------------------"
echo "-- Version History and Authors"
echo

printf "Authors:\\t\\t%'10d\\n" "${authors}"
printf "Versions:\\t\\t%'10d\\n" "${versions}"

releases=$( gh release list -L 1000 | wc -l )
printf "GH releases:\\t\\t%'10d\\n" "${releases}"

echo

echo "------------------------------------------------------------------------------"
echo "-- Code"
echo

loc=$( grep -c '.' check_ssl_cert )

printf "LoC:\\t\\t\\t%'10d\\n" "${loc}"
echo

echo "------------------------------------------------------------------------------"
echo "-- Repository"
echo

commits=$( git log --oneline | wc -l )

printf "Commits:\\t\\t%'10d\\n" "${commits}"
git log --numstat --format="" | awk '{files += 1}{ins += $1}{del += $2} END{printf "File changes:\t\t%10'"'"'d\nInsertions:\t\t%10'"'"'d\nDeletions:\t\t%10'"'"'d\n", files, ins, del}'

open_issues=$( gh issue list -L 1000 | wc -l )
closed_issues=$( gh issue list -s closed -L 1000 | wc -l )
open_bugs=$( gh issue list -L 1000 -l bug | grep -v -c 'No issue match' )

echo
printf "Open issues:\\t\\t%'10d\\n" "${open_issues}"
printf "Open bugs:\\t\\t%'10d\\n" "${open_bugs}"
printf "Closed issues:\\t\\t%'10d\\n" "${closed_issues}"

open_prs=$( gh pr list -L 1000 | wc -l )
closed_prs=$( gh pr list -s all -L 1000 | wc -l )

echo
printf "Open pull requests:\\t%'10d\\n" "${open_prs}"
printf "Total pull requests:\\t%'10d\\n" "${closed_prs}"

echo

echo "------------------------------------------------------------------------------"
echo "-- Features"
echo

command_line_options=$( sed 's/;.*//' help.txt  | sort  | uniq | wc -l )
printf "Command line options:\\t%'10d\\n" "${command_line_options}"

echo

echo "------------------------------------------------------------------------------"
echo "-- Tests"
echo

tests=$( grep -c '^test' test/unit_tests.sh )
workflows=$( gh workflow list -L 1000 | wc -l)
runs=$( gh run list -L 10000 | wc -l )

printf "Tests:\\t\\t\\t%'10d\\n" "${tests}"
printf "GH workflows:\\t\\t%'10d\\n" "${workflows}"
printf "GH runs:\\t\\t%'10d\\n" "${runs}"

echo
