#!/bin/sh

NAME=check_ssl_cert
VERSION=$( cat VERSION )
TARBALL="${NAME}-${VERSION}.tar.gz"

# delete current distribution
rm -f "${TARBALL}"

# build a new tarball
make dist

rpmbuild -ta "${TARBALL}"
