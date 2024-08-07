#!/bin/sh

echo "===> Installing Wezterm terminal                                        "
echo ""

set -e

apt-get -qq update && \
apt-get install -qq --no-install-recommends -y ca-certificates curl gpg lsb-release && \
curl -fsSL https://apt.fury.io/wez/gpg.key | gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg && \
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | tee /etc/apt/sources.list.d/wezterm.list && \
apt-get -qq update && \
apt-get install -qq --no-install-recommends -y libegl-dev wezterm xdg-desktop-portal

echo "    Wezterm terminal installed, executable file at /usr/bin/wezterm"
echo ""
