#!/bin/sh

if [ $# -ne 1 ]; then
    echo "Usage: $0 <vgl_version>"
    exit 1
fi

VGL_VERSION=$1

echo "========================================================================"
echo "===> Installing VirtualGL driver : version $VGL_VERSION"
echo "========================================================================"
echo ""

set -e

curl -fsSL https://packagecloud.io/dcommander/virtualgl/gpgkey | gpg --yes --dearmor -o /usr/share/keyrings/virtualgl.gpg
echo 'deb [signed-by=/usr/share/keyrings/virtualgl.gpg] https://packagecloud.io/dcommander/virtualgl/any/ any main' | \
tee /etc/apt/sources.list.d/virtualgl.list

apt-get -qq update && \
apt-get install -qq --no-install-recommends -y libglu1-mesa libegl1-mesa-dev libxv1 libxtst6 libegl-mesa0 primus virtualgl=${VGL_VERSION} && \
apt-get -qq autoremove -y --purge

echo "    VirtualGL driver version $VGL_VERSION installed"
echo ""
