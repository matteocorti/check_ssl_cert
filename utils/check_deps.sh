#!/bin/sh

# colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

FAILED=

check_perl_module() {

    printf "Checking %35s:" "$1"

    if perl -M"$1" -e1 2>/dev/null ; then
        printf " [${GREEN}OK${NC}:    %-35s]\n" "$1"
    else
        ERROR="$1 not found"
        printf " [${RED}error${NC}: %-35s]\n" "${ERROR}"
    fi
}

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

check_shunit2() {

    printf "Checking %35s:" shunit2

    PROG=$(command -v shunit2 2> /dev/null)
    if [ -z "${PROG}" ] ; then
        if [ -x /usr/share/shunit2/shunit2 ] ; then
            PROG=/usr/share/shuni2/shunit2
        fi
    fi
    if [ -z "${PROG}" ]; then
        ERROR="shunit2 not found"
        printf " [${YELLOW}error${NC}: %-35s]\n" "${ERROR}"
    else
        printf " [${GREEN}OK${NC}:    %-35s]\n" "${PROG}"
    fi
}

printf "\nChecking required dependencies:\n"
printf "===============================\n\n"

check_required bc
check_required curl
check_required date
check_required file
check_required host
check_required nmap
check_required openssl

printf "\nChecking optional dependencies:\n"
printf "===============================\n\n"

check_optional bzip2
check_optional dig
check_optional expand
check_optional expect
check_optional gmake
check_optional ifconfig
check_optional java
check_optional python3
check_optional tar
check_optional timeout

# linux tools
os=$(uname -s)
if [ "${os}" = "Linux" ]; then
    check_optional ip
fi

printf "\nChecking optional dependencies for development:\n"
printf "===============================================\n\n"

check_optional dig
check_optional shellcheck
check_optional shfmt
check_shunit2
check_optional tinyproxy
check_perl_module Date::Parse

echo

if [ -n "${FAILED}" ] ; then
    exit 1
fi

exit 0
