#!/bin/sh

echo "Building the RPMs"
OUT=$( make rpm 2>&1 | grep ^Wrote )

echo "${OUT}"

RPM=$( echo "${OUT}" | grep /RPMS | grep -v debug | sed 's/.*\ //' )
SRPM=$( echo "${OUT}" | grep SRPMS | sed 's/.*\ //' )

echo "RPM:  ${RPM}"
echo "SRPM: ${SRPM}"

ARCH=$( echo "${RPM}" | sed 's/\.rpm$//' | sed 's/.*\.//' )
DIST=$( echo "${SRPM}" | sed 's/\.src\.rpm$//' | sed 's/.*\.//' )

echo "arch: ${ARCH}"
echo "dist: ${DIST}"

WEBROOT=/var/www/rpm
case ${DIST} in
    fc30)
        RPMDIR="${WEBROOT}/fedora/30/${ARCH}"
        SRPMDIR="${WEBROOT}/fedora/30/SRPMS"
        ;;
    fc31)
        RPMDIR="${WEBROOT}/fedora/31/${ARCH}"
        SRPMDIR="${WEBROOT}/fedora/31/SRPMS"
        ;;
    fc32)
        RPMDIR="${WEBROOT}/fedora/32/${ARCH}"
        SRPMDIR="${WEBROOT}/fedora/32/SRPMS"
        ;;
    fc33)
        RPMDIR="${WEBROOT}/fedora/33/${ARCH}"
        SRPMDIR="${WEBROOT}/fedora/33/SRPMS"
        ;;
    fc34)
        RPMDIR="${WEBROOT}/fedora/34/${ARCH}"
        SRPMDIR="${WEBROOT}/fedora/34/SRPMS"
        ;;
    fc35)
        RPMDIR="${WEBROOT}/fedora/35/${ARCH}"
        SRPMDIR="${WEBROOT}/fedora/35/SRPMS"
        ;;
    el7)
        RPMDIR="${WEBROOT}/epel/7/${ARCH}"
        SRPMDIR="${WEBROOT}/epel/7/SRPMS"
        ;;
    el8)
        RPMDIR="${WEBROOT}/epel/8/${ARCH}"
        SRPMDIR="${WEBROOT}/epel/8/SRPMS"
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

export RPMDIR
export SRPMDIR
export RPM
export SRPM
