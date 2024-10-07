#!/bin/sh
set -e

echo "========================================================================"
echo "                  Installing Chorus utilities                           "
echo "========================================================================"
echo ""

apt-get -qq update && \
apt-get install -qq --no-install-recommends -y curl ca-certificates gnupg && \

script_dir=$(dirname "$0")
"$script_dir"/install-vgl.sh "3.1.1-20240228"
"$script_dir"/install-utility-tools.sh "$@"
echo "===> Creating directory /docker-entrypoint.d"
mkdir /docker-entrypoint.d

apt-get -qq autoremove -y --purge
