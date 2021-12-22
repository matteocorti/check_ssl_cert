#!/bin/sh

VERSION=$(head -n 1 VERSION)

echo "Publishing release ${VERSION}"

echo

echo 'Checking release date'

MONTH_YEAR=$( date +"%B, %Y" )
YEAR=$( date +"%Y" )

if ! grep -q "${MONTH_YEAR}" check_ssl_cert.1 ; then
    echo "Please update the date in check_ssl_cert.1"
    exit 1
fi
if ! grep -q "&copy; Matteo Corti, 2007-${YEAR}" README.md ; then
    echo "Please update the copyright year in README.md"
    exit 1
fi
if ! grep -q "Copyright (c) 2007-${YEAR} Matteo Corti" COPYRIGHT ; then
    echo "Please update the copyright year in COPYRIGHT"
    exit 1
fi
if ! grep -q "Copyright (c) 2007-${YEAR} Matteo Corti <matteo@corti.li>" check_ssl_cert ; then
    echo "Please update the copyright year in check_ssl_cert"
    exit 1
fi
echo "Copyright year check: OK"

echo
echo 'RELEASE_NOTES.md:'
echo '------------------------------------------------------------------------------'

cat RELEASE_NOTES.md

echo '------------------------------------------------------------------------------'

echo 'Did you update the RELEASE_NOTES.md file? '
read -r ANSWER
if [ "${ANSWER}" = "y" ]; then
    make
    gh release create "v${VERSION}" --title "check_ssl_cert-${VERSION}" --notes-file RELEASE_NOTES.md "check_ssl_cert-${VERSION}.tar.gz" "check_ssl_cert-${VERSION}.tar.bz2"

fi

# get the new tag
git pull
