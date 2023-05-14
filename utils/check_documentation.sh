#!/bin/sh

ERROR=0

# get the help
HELP=$(./check_ssl_cert --help)

# check for lines that are too long (78 chars)
LONG_LINES=$(echo "${HELP}" | perl -ne 'length ($_) > 78 && print')

if [ -n "${LONG_LINES}" ]; then
    echo "Help lines are too long (>78 chars)"
    echo "${LONG_LINES}"
    ERROR=1
fi

ALL_OPTIONS=$( cat utils/help.txt utils/deprecated.txt )

# list all the command line options

# shellcheck disable=SC2013
for option in $(grep '^[ ]*-.*)$' check_ssl_cert | sed -e 's/^[ ]*//' -e 's/)//'); do

    case "${option}" in
        '|' | '--' | '-*')
            continue
            ;;
        *)

            # check if the option is documented in the help.txt file
            if ! echo "${ALL_OPTIONS}" | grep -q -- "${option}"; then
                echo "Error: ${option} is not documented in help.txt or deprecated.txt"
                ERROR=1
            fi

            # check if the option is documented in check_ssl_cert
            if ! echo "${HELP}" | grep -q -- "${option}"; then
                echo "Error: ${option} is not documented in the help (--help)"
                ERROR=1
            fi

            # check if the option is documented in README.md
            if ! grep -q -- "${option}" README.md; then
                echo "Error: ${option} is not documented in README.md"
                ERROR=1
            fi

            # check if the option is documented in the man page
            if ! grep -q -- "${option}" check_ssl_cert.1; then
                echo "Error: ${option} is not documented in check_ssl_cert.1"
                ERROR=1
            fi

            ;;

    esac

done

# che the Icigna conf file (only long options not deprecated)

# shellcheck disable=SC2013
for option in $(sed -e 's/;.*//' -e 's/.*,//' -e 's/[ ].*//' utils/help.txt  | sort -u ); do

    case "${option}" in
        '|' | '--' | '-*' | '--version' | '-?')
            continue
            ;;
        *)

            # check if the option is documented in the check_ssl_cert_icinga2.conf file
            if ! grep -q -- "${option}" check_ssl_cert_icinga2.conf; then
                echo "Error: ${option} is not documented in check_ssl_cert_icinga2.conf"
                ERROR=1
            fi
            ;;

    esac

done

# check if the option descriptions are present in all the files

while read -r line; do

    option=$(echo "${line}" | sed 's/;.*//')
    description=$(echo "${line}" | sed 's/[^;]*;//')

    if ! grep -q -- "${description}" check_ssl_cert; then
        echo "Error: the description of option '${option}' '${description}' is not present in check_ssl_cert"
        ERROR=1
    fi

    if ! grep -q -- "${description}" check_ssl_cert.1; then
        # check for automatically generated options
        # shellcheck disable=SC2016
        if ! echo "${description}" | grep -q '${'; then
            echo "Error: the description of option '${option}' '${description}' is not present in check_ssl_cert.1"
            ERROR=1
        fi
    fi

    if ! grep -q -- "${description}" README.md; then
        # check for automatically generated options
        # shellcheck disable=SC2016
        if ! echo "${description}" | grep -q '${'; then
            echo "Error: the description of option '${option}' '${description}' is not present in README.md"
            ERROR=1
        fi
    fi

done < utils/help.txt

exit "${ERROR}"
