#!/bin/sh

# authors
authors=$(grep -c 'Many thanks' AUTHORS.md)

# versions
versions=$(grep -c Version NEWS.md)

version=$(head -n 1 VERSION)

PROG=$(command -v gh 2>/dev/null)

if [ -z "${PROG}" ]; then
    echo "cannot find gh" 1>&2
    exit 1
fi

echo
printf '\tcheck_ssl_cert version %s\n' "${version}"
echo

echo "------------------------------------------------------------------------------"
echo "-- Version History and Authors"
echo

printf "Authors:\\t\\t%'10d\\n" "${authors}"
printf "Versions:\\t\\t%'10d\\n" "${versions}"

releases=$(gh release list -L 1000 | wc -l)
printf "GH releases:\\t\\t%'10d\\n" "${releases}"

echo

echo "------------------------------------------------------------------------------"
echo "-- Code"
echo

make distclean > /dev/null
cloc --quiet . | grep -v AlDanial

echo

loc=$(grep -c '.' check_ssl_cert)

printf "Script LoC:\\t\\t%'10d\\n" "${loc}"
echo

echo "------------------------------------------------------------------------------"
echo "-- Repository"
echo

commits=$(git log --oneline | wc -l)

printf "Commits:\\t\\t%'10d\\n" "${commits}"
git log --numstat --format="" | awk '{files += 1}{ins += $1}{del += $2} END{printf "File changes:\t\t%10'"'"'d\nInsertions:\t\t%10'"'"'d\nDeletions:\t\t%10'"'"'d\n", files, ins, del}'

open_issues=$(gh issue list -L 1000 | wc -l)
closed_issues=$(gh issue list -s closed -L 1000 | wc -l)
open_bugs=$(gh issue list -L 1000 -l bug | grep -v -c 'No issue match')

echo
printf "Open issues:\\t\\t%'10d\\n" "${open_issues}"
printf "Open bugs:\\t\\t%'10d\\n" "${open_bugs}"
printf "Closed issues:\\t\\t%'10d\\n" "${closed_issues}"

open_prs=$(gh pr list -L 1000 | wc -l)
closed_prs=$(gh pr list -s all -L 1000 | wc -l)

echo
printf "Open pull requests:\\t%'10d\\n" "${open_prs}"
printf "Total pull requests:\\t%'10d\\n" "${closed_prs}"

echo

echo "------------------------------------------------------------------------------"
echo "-- Features"
echo

command_line_options=$(sed 's/;.*//' utils/help.txt | sort | uniq | wc -l)
printf "Command line options:\\t%'10d\\n" "${command_line_options}"

echo

echo "------------------------------------------------------------------------------"
echo "-- Tests"
echo

LIST_LIMIT=10000

# in_progewss
# success
# failure

tests=$(grep -c '^test' test/unit_tests.sh)
workflows=$(gh workflow list -L "${LIST_LIMIT}" | wc -l)

# cache the result

RUNS=$(gh run list -L "${LIST_LIMIT}")

runs=$(echo "${RUNS}" | wc -l)

runs_in_progress=$(echo "${RUNS}" | grep -c in_progress)
runs_success=$(echo "${RUNS}" | grep -c success)
runs_failure=$(echo "${RUNS}" | grep -c failure)
runs_cancelled=$(echo "${RUNS}" | grep -c cancelled)

printf "Tests:\\t\\t\\t%'10d\\n" "${tests}"
printf "GH workflows:\\t\\t%'10d\\n" "${workflows}"
printf "GH runs:\\t\\t%'10d\\n" "${runs}"
printf "  running:\\t\\t%'10d\\n" "${runs_in_progress}"
printf "  failed:\\t\\t%'10d\\n" "${runs_failure}"
printf "  ok:\\t\\t\\t%'10d\\n" "${runs_success}"
printf "  cancelled:\\t\\t%'10d\\n" "${runs_cancelled}"

echo
