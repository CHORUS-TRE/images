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
  --no-sandbox \
  "${KIOSK_URL}" > /dev/null 2>&1 &

WARMUP_PID=$!
sleep 2

# Kill warmup process if it's still running
if kill -0 $WARMUP_PID 2>/dev/null; then
    kill $WARMUP_PID 2>/dev/null || true
    wait $WARMUP_PID 2>/dev/null || true
fi

# Main Chromium app launch
# Note : --test-type suppresses Chrome's warning about unsupported command-line flags like--no-sandbox.
/usr/local/bin/chrome-linux/chrome \
  --no-sandbox \
  --test-type \
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
    WIN_ID=$(xdotool search --pid "$CHROMIUM_PID" --onlyvisible | head -n1 || true)
    sleep 1
done

echo "Updating window title..."
while xdotool getwindowpid "$WIN_ID" &>/dev/null; do
    wmctrl -i -r "$WIN_ID" -T "$APP_NAME" || echo "wmctrl failed"
    sleep 1
done

echo "Chromium window closed. Exiting."