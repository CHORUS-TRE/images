#!/bin/bash

set -e

export GOOGLE_API_KEY="no"
export GOOGLE_DEFAULT_CLIENT_ID="no"
export GOOGLE_DEFAULT_CLIENT_SECRET="no"

PROFILE_DIR="$HOME/.chrome-data"
mkdir -p "$PROFILE_DIR"

# Headless warmup to fix cookies on first launch
/usr/local/bin/chrome-linux/chrome \
  --user-data-dir="$PROFILE_DIR" \
  --headless=new \
  --disable-gpu \
  "${KIOSK_URL}" > /dev/null 2>&1 &

WARMUP_PID=$!
sleep 2
kill $WARMUP_PID
wait $WARMUP_PID 2>/dev/null || true

# Main Chromium app launch
/usr/local/bin/chrome-linux/chrome \
  --noerrdialogs \
  --disable-infobars \
  --disable-session-crashed-bubble \
  --enable-features=NetworkService,NetworkServiceInProcess \
  --app="${KIOSK_URL}" \
  --window-size=1200,700 \
  --user-data-dir="$PROFILE_DIR" &

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
