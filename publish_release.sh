#!/bin/sh

VERSION=$( head -n 1 VERSION )

echo 'Did you update the RELEASE_NOTES.md? '
read -r ANSWER
if [ "x${ANSWER}" = "xy" ] ; then
    
    make
    gh release create "v${VERSION}" --title "check_ssl_cert-${VERSION}" --notes-file RELEASE_NOTES.md "check_ssl_cert-${VERSION}.tar.gz" "check_ssl_cert-${VERSION}.tar.bz2"

fi
