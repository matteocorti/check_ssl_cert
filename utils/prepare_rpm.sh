#!/bin/sh

echo "Building the RPMs"
OUT=$(make rpm 2>&1 | grep ^Wrote)

echo "${OUT}"

RPM=$(echo "${OUT}" | grep /RPMS | grep -v debug | sed 's/.* //')
SRPM=$(echo "${OUT}" | grep SRPMS | sed 's/.* //')

echo "RPM:  ${RPM}"
echo "SRPM: ${SRPM}"

ARCH=$(echo "${RPM}" | sed 's/\.rpm$//' | sed 's/.*\.//')
DIST=$(echo "${SRPM}" | sed 's/\.src\.rpm$//' | sed 's/.*\.//')

echo "arch: ${ARCH}"
echo "dist: ${DIST}"

WEBROOT=/var/www/rpm
case ${DIST} in
    fc[0-9]*)
        # strip the 'fc' prefix
        RELEASE=$( echo "${DIST}" | sed 's/^fc//' )
        DIST=fedora
        RPMDIR="${WEBROOT}/${DIST}/${RELEASE}/${ARCH}"
        SRPMDIR="${WEBROOT}/${DIST}/${RELEASE}/SRPMS"
        ;;
    el7)
        RPMDIR="${WEBROOT}/epel/7/${ARCH}"
        SRPMDIR="${WEBROOT}/epel/7/SRPMS"
        DIST='epel'
        RELEASE='7'
        ;;
    el8)
        RPMDIR="${WEBROOT}/epel/8/${ARCH}"
        SRPMDIR="${WEBROOT}/epel/8/SRPMS"
        DIST='epel'
        RELEASE='8'
        ;;
    *)
        echo "Unknown distribution ${DIST}" 1>&2
        exit 1
        ;;
esac

echo "RPMDIR:  ${RPMDIR}"
echo "SRPMDIR: ${SRPMDIR}"
echo "RPM:     ${RPM}"
echo "SRPM:    ${SRPM}"
echo "DIST:    ${DIST}"
echo "RELEASE: ${RELEASE}"

export RPMDIR
export SRPMDIR
export RPM
export SRPM
export DIST
export RELEASE
