#!/bin/sh
set -e
echo "===> Installing Wine environment"

script_dir=$(dirname "$0")

dpkg --add-architecture i386
apt-get update -qy
apt-get install -qy \
    wine \
    fonts-wine fontconfig fonts-liberation fonts-dejavu \
    libfreetype6 libfreetype6:i386 \
    gcc-multilib libc6-dev-i386 \
    libx11-dev libx11-dev:i386 libxext-dev libxext-dev:i386

echo "===> Building MIT-SHM disable wrapper (32-bit + 64-bit)"
gcc -shared -fPIC -o /usr/lib/x86_64-linux-gnu/noshm.so "$script_dir/noshm.c" -lX11 -lXext
gcc -m32 -shared -fPIC -o /usr/lib/i386-linux-gnu/noshm.so "$script_dir/noshm.c" -lX11 -lXext

echo "===> Installing wine-wrapper.sh"
cp "$script_dir/wine-wrapper.sh" /usr/local/bin/wine-wrapper.sh
chmod +x /usr/local/bin/wine-wrapper.sh

echo "===> Cleaning up build dependencies"
apt-get remove -y --purge gcc-multilib libc6-dev-i386 \
    libx11-dev libx11-dev:i386 libxext-dev libxext-dev:i386
apt-get autoremove -y --purge
