#!/bin/sh
set -e

echo "========================================================================"
echo "                  Installing Chorus utilities                           "
echo "========================================================================"
echo ""

apt-get -qq update && \
apt-get -qq upgrade -y && \
apt-get install -qq --no-install-recommends -y curl ca-certificates gnupg && \

./install-vgl.sh "3.1.1-20240228"
./install-utility-tools.sh "$@"
echo "===> Creating directory /docker-entrypoint.d"
mkdir /docker-entrypoint.d

apt-get -qq autoremove -y --purge