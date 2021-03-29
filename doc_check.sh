#!/bin/sh

# list all the command line options
OPTIONS=$( grep -- '^\ *-[-A-Za-z0-9|]*)' check_ssl_cert | sed 's/^\ *\(.*\))/\1/' | sed 's/.*|//'  | grep -v -- '^--$' | sort | uniq )

FAILED=0
for option in ${OPTIONS} ; do

    if ! grep -- "${option}" check_ssl_cert | grep -q echo ; then
        echo "${option} is not documented in check_ssl_cert"
        FAILED=1
    fi

    if ! grep -q -- "${option}" README.md ; then
        echo "${option} is not documented in README.md"
        FAILED=1
    fi

    if ! grep -q -- "${option}" check_ssl_cert.1 ; then
        echo "${option} is not documented in check_ssl_cert.1"
        FAILED=1
    fi

    if [ -r ../check_ssl_cert.homepage/index.html ] && ! grep -q -- "${option}" ../check_ssl_cert.homepage/index.html ; then
        echo "${option} is not documented in ../check_ssl_cert.homepage/index.html"
        FAILED=1
    fi

done

exit "${FAILED}"
