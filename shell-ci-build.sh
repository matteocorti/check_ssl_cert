#!/usr/bin/env bash
set -eo pipefail
source ./shell-ci-build/build.sh
check "./check_ssl_cert"
