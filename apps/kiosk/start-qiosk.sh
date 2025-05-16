#!/bin/bash

set -e

# env vars below needed as long as we don't have a GPU

# using this makes it prettier
# export QT_QUICK_BACKEND=software

# using this makes it slower
# export QT_OPENGL=software

# using this gives info
export QSG_INFO=1

# unsure this makes a difference
export QTWEBENGINE_CHROMIUM_FLAGS="--disable-gpu --enable-software-rasterizer --disable-features=Vulkan"

# unsure these two make a difference
export QT_FONT_DPI=96
export QT_SCALE_FACTOR=1

qiosk -m automaticvisibility --display-scroll-bars $KIOSK_URL
QIOSK_PID=$!

wait $QIOSK_PID
