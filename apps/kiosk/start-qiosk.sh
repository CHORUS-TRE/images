#!/bin/bash

set -e

# needed as long as we don't have a GPU
export QT_QUICK_BACKEND=software
export QTWEBENGINE_CHROMIUM_FLAGS="--disable-gpu"

qiosk -m maximized --display-scroll-bars --display-navbar --underlay-navbar --navbar-enable-buttons back,forward,reload,home $KIOSK_URL
QIOSK_PID=$!

wait $QIOSK_PID
