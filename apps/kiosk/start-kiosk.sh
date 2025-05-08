#!/bin/bash

set -xe

export GOOGLE_API_KEY="no"
export GOOGLE_DEFAULT_CLIENT_ID="no"
export GOOGLE_DEFAULT_CLIENT_SECRET="no"

/usr/local/bin/chrome-linux/chrome --noerrdialogs --disable-infobars --app=${KIOSK_URL} --window-size=1200,800 &

CHROMIUM_PID=$!

sleep 2

WIN_ID=$(wmctrl -l | grep "$WEB_UI" | awk '{print $1}')
wmctrl -i -r $WIN_ID -T "$APP_NAME"

wait $CHROMIUM_PID
