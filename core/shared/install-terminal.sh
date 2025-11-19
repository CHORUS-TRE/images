#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <terminal_version>"
    exit 1
fi

TERMINAL_VERSION=$1

echo "========================================================================"
echo "===> Installing Kitty terminal : version $TERMINAL_VERSION"
echo "========================================================================"
echo ""

set -e
#installs wezterm for ubuntu 22.04 -> vulkan issues
#apt-get -qq update && \
#apt-get install -qq --no-install-recommends -y ca-certificates curl gpg lsb-release && \
#curl -fsSL https://apt.fury.io/wez/gpg.key | gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg && \
#echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | tee /etc/apt/sources.list.d/wezterm.list && \
#apt-get -qq update && \
#apt-get install -qq --no-install-recommends -y libegl-dev wezterm xdg-desktop-portal

#installs wezterm for ubuntu 24.04 -> shm issues
#apt-get -qq update && \
#apt-get install -qq --no-install-recommends -y curl libfontconfig1 libwayland-egl1 libxcb-image0 libxcb-util1 libxkbcommon-x11-0 libxkbcommon0 x11-utils && \
#pushd /tmp && \
#pwd && \
#echo $PWD && \
#curl -LO https://github.com/wezterm/wezterm/releases/download/nightly/wezterm-nightly.Ubuntu24.04.deb && \
#dpkg -i wezterm-nightly.Ubuntu24.04.deb && \
#rm wezterm-nightly.Ubuntu24.04.deb
#popd

#installs kitty
apt-get -qq update && \
apt-get install -qq --no-install-recommends -y curl xz-utils libfontconfig1 libxcursor1 libxcb-xkb1 && \
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin \
    dest=/usr/bin/kitty installer=version-$TERMINAL_VERSION launch=n

#echo "    Wezterm terminal installed, executable file at /usr/bin/wezterm"
echo "    Kitty terminal version $TERMINAL_VERSION installed, executable file at /usr/bin/kitty/kitty.app/bin/kitty"
echo ""
