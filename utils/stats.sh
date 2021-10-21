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
