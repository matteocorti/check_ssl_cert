#!/bin/sh

# colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

FAILED=

check_required() {

    printf "Checking %35s:" "$1"

    PROG=$(command -v "$1" 2>/dev/null)

    if [ -z "${PROG}" ]; then
        ERROR="$1 not found"
        printf " [${RED}error${NC}: %-35s]\n" "${ERROR}"
        FAILED=1
    else
        printf " [${GREEN}OK${NC}:    %-35s]\n" "${PROG}"
    fi

}

check_optional() {

    printf "Checking %35s:" "$1"

    PROG=$(command -v "$1" 2>/dev/null)

    if [ -z "${PROG}" ]; then
        ERROR="$1 not found"
        printf " [${YELLOW}error${NC}: %-35s]\n" "${ERROR}"
    else
        printf " [${GREEN}OK${NC}:    %-35s]\n" "${PROG}"
    fi

}

printf "\nChecking required dependencies:\n\n"

check_required bc
check_required curl
check_required date
check_required file
check_required host
check_required nmap
check_required openssl

printf "\nChecking optional dependencies:\n\n"

check_optional bzip2
check_optional dig
check_optional expand
check_optional expect
check_optional gmake
check_optional ifconfig
check_optional ip
check_optional java
check_optional netcat
check_optional python3
check_optional tar

printf "\nChecking optional dependencies for development:\n\n"

check_optional dig
check_optional shellcheck
check_optional shfmt
check_optional shunit2
check_optional tinyproxy


if [ -n "${FAILED}" ] ; then
    exit 1
fi

exit 0
