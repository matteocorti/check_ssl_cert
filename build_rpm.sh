#!/bin/sh

NAME=check_updates
VERSION=$( grep "our\ \$VERSION\ =\ " "${NAME}" | sed "s/^[^']*'\([0-9.]*\)';/\1/" )
TARBALL="${NAME}-${VERSION}.tar.gz"

# delete current distribution
rm -f "${TARBALL}"

# build a new tarball
make dist

rpmbuild -ta "${TARBALL}"
