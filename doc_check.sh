#!/bin/sh

# list all the command line options
OPTIONS=$( grep -- '^\ *-[-A-Za-z0-9|]*)' check_ssl_cert | sed 's/^\ *\(.*\))/\1/' | sed 's/.*|//'  | grep -v -- '^--$' | sort | uniq )

FAILED=0
for option in ${OPTIONS} ; do

    LINE=$( ./check_ssl_cert --help | grep -- "${option}" | grep '^\ *--' )

    # Debugging
    #    echo $option
    #    ./check_ssl_cert --help | grep -- "${option}"
    #    echo $LINE
    
    echo ==============================================================================

    # check the script

    if ! grep -- "${option}" check_ssl_cert | grep -q echo ; then
        echo "${option} is not documented in check_ssl_cert"
        FAILED=1
    fi

    # check README.md

    if ! grep -q -- "${option}" README.md ; then
        echo "${option} is not documented in README.md"
        FAILED=1
    fi

    if ! grep -q -- "${LINE}" README.md ; then
        echo "The description of ${option} is different in README.md"
        FAILED=1
    fi

    # man page

    if ! grep -q -- "${option}" check_ssl_cert.1 ; then
        echo "${option} is not documented in check_ssl_cert.1"
        FAILED=1
    fi

    # web page

    if [ -r ../check_ssl_cert.homepage/index.html ] && ! grep -q -- "${option}" ../check_ssl_cert.homepage/index.html ; then
        echo "${option} is not documented in ../check_ssl_cert.homepage/index.html"
        FAILED=1
    fi

done

exit "${FAILED}"
