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
fc30)
    RPMDIR="${WEBROOT}/fedora/30/${ARCH}"
    SRPMDIR="${WEBROOT}/fedora/30/SRPMS"
    DIST='fedora'
    RELEASE='30'
    ;;
fc31)
    RPMDIR="${WEBROOT}/fedora/31/${ARCH}"
    SRPMDIR="${WEBROOT}/fedora/31/SRPMS"
    DIST='fedora'
    RELEASE='31'
    ;;
fc32)
    RPMDIR="${WEBROOT}/fedora/32/${ARCH}"
    SRPMDIR="${WEBROOT}/fedora/32/SRPMS"
    DIST='fedora'
    RELEASE='32'
    ;;
fc33)
    RPMDIR="${WEBROOT}/fedora/33/${ARCH}"
    SRPMDIR="${WEBROOT}/fedora/33/SRPMS"
    DIST='fedora'
    RELEASE='33'
    ;;
fc34)
    RPMDIR="${WEBROOT}/fedora/34/${ARCH}"
    SRPMDIR="${WEBROOT}/fedora/34/SRPMS"
    DIST='fedora'
    RELEASE='34'
    ;;
fc35)
    RPMDIR="${WEBROOT}/fedora/35/${ARCH}"
    SRPMDIR="${WEBROOT}/fedora/35/SRPMS"
    DIST='fedora'
    RELEASE='35'
    ;;
fc36)
    RPMDIR="${WEBROOT}/fedora/36/${ARCH}"
    SRPMDIR="${WEBROOT}/fedora/36/SRPMS"
    DIST='fedora'
    RELEASE='36'
    ;;
fc37)
    RPMDIR="${WEBROOT}/fedora/37/${ARCH}"
    SRPMDIR="${WEBROOT}/fedora/37/SRPMS"
    DIST='fedora'
    RELEASE='37'
    ;;
fc38)
    RPMDIR="${WEBROOT}/fedora/38/${ARCH}"
    SRPMDIR="${WEBROOT}/fedora/38/SRPMS"
    DIST='fedora'
    RELEASE='38'
    ;;
fc39)
    RPMDIR="${WEBROOT}/fedora/39/${ARCH}"
    SRPMDIR="${WEBROOT}/fedora/39/SRPMS"
    DIST='fedora'
    RELEASE='39'
    ;;
fc40)
    RPMDIR="${WEBROOT}/fedora/40/${ARCH}"
    SRPMDIR="${WEBROOT}/fedora/40/SRPMS"
    DIST='fedora'
    RELEASE='40'
    ;;
fc41)
    RPMDIR="${WEBROOT}/fedora/41/${ARCH}"
    SRPMDIR="${WEBROOT}/fedora/41/SRPMS"
    DIST='fedora'
    RELEASE='41'
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
