#!/bin/sh

error() {

    message=$1

    echo "Error: ${message}" 1>&2
    exit 1

}

################################################################################
# Checks if a given program is available and executable
# Params
#   $1 program name
# Returns 1 if the program exists and is executable
check_required_prog() {

    PROG=$(command -v "$1" 2>/dev/null)

    if [ -z "${PROG}" ]; then
        error "cannot find program: $1"
    fi

    if [ ! -x "${PROG}" ]; then
        error "${PROG} is not executable"
    fi

}

check_required_prog tinyproxy

conf=$1

if [ -z "${conf}" ]; then
    error "No configuration file specified"
fi
if ! [ -f "${conf}" ]; then
    error "Configuration file ${conf} is not readable"
fi

tinyproxy -c "${conf}" > /dev/null 2>&1
