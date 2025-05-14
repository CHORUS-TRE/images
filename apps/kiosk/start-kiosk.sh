#!/bin/bash

set -e

export GOOGLE_API_KEY="no"
export GOOGLE_DEFAULT_CLIENT_ID="no"
export GOOGLE_DEFAULT_CLIENT_SECRET="no"

/usr/local/bin/chrome-linux/chrome --noerrdialogs --disable-infobars --disable-session-crashed-bubble --app=${KIOSK_URL} --window-size=1200,700 &

CHROMIUM_PID=$!

echo "Waiting for ${KIOSK_URL} Chromium window to appear..."
WIN_ID=""

while [ -z "$WIN_ID" ]; do
    WIN_ID=$(wmctrl -l | grep "$APP_NAME" | awk '{print $1}' | head -n1)
    sleep 1
done

echo "Updating window title..."
while kill -0 $CHROMIUM_PID 2>/dev/null; do
    wmctrl -i -r $WIN_ID -T "$APP_NAME"
    sleep 1
done

wait $CHROMIUM_PID
