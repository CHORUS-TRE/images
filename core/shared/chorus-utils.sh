#!/bin/sh
set -e

echo "========================================================================"
echo "                  Installing Chorus utilities                           "
echo "========================================================================"
echo ""

apt-get -qq update && \
apt-get install -qq --no-install-recommends -y curl ca-certificates gnupg libnss-wrapper && \

script_dir=$(dirname "$0")
"$script_dir"/install-vgl.sh "3.1.1-20240228"
"$script_dir"/install-utility-tools.sh "$@"
echo "===> Creating directory /docker-entrypoint.d"
mkdir /docker-entrypoint.d

# libnss_wrapper is installed from the app's Ubuntu version
# This ensures binary compatibility with the app's libc version
echo "===> Verifying libnss_wrapper installation"
if [ -f "/usr/lib/x86_64-linux-gnu/libnss_wrapper.so" ]; then
    echo "     libnss_wrapper.so found at /usr/lib/x86_64-linux-gnu/libnss_wrapper.so"
elif [ -f "/usr/lib/libnss_wrapper.so" ]; then
    echo "     libnss_wrapper.so found at /usr/lib/libnss_wrapper.so"
else
    echo "     WARNING: libnss_wrapper.so not found in expected locations"
    find /usr -name "libnss_wrapper.so" 2>/dev/null || true
fi

apt-get -qq autoremove -y --purge
rm -rf /var/lib/apt/lists/*
