#!/bin/sh

ERROR=0

# get the help
HELP=$( ./check_ssl_cert --help )

# list all the command line options

for option in $( grep '^[ ]*-.*)$' check_ssl_cert | sed -e 's/^[ ]*//' -e 's/)//' ) ; do

    case "${option}" in
        '|'|'--'|'-*')
            continue
            ;;
        *)

            # 1) check if the option is documented in check_ssl_cert

            if ! echo "${HELP}" | grep -q -- "${option}" ; then
                echo "Error ${option} is not documented in the help (--help_)"
                ERROR=1
            fi

            # 2) check if the option is documented in README.md

            if ! grep -q -- "${option}" README.md ; then
                echo "Error ${option} is not documented in README.md"
                ERROR=1
            fi

            # 3) check if the option is documented in the man page

            if ! grep -q -- "${option}" check_ssl_cert.1 ; then
                echo "Error ${option} is not documented in check_ssl_cert.1"
                ERROR=1
            fi

            ;;

    esac

done

exit "${ERROR}"
