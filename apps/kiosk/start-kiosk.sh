#!/bin/bash

set -e

export GOOGLE_API_KEY="no"
export GOOGLE_DEFAULT_CLIENT_ID="no"
export GOOGLE_DEFAULT_CLIENT_SECRET="no"

PROFILE_DIR="$HOME/.chrome-data"
mkdir -p "$PROFILE_DIR"

# JWT token exchange if KIOSK_JWT_TOKEN and KIOSK_JWT_URL is defined
if [ -n "$KIOSK_JWT_TOKEN" ] && [ -n "$KIOSK_JWT_URL" ] ; then
    echo "Exchanging JWT token for session cookie..."
    
    # Launch headless Chrome to perform token exchange without leaving history
    /usr/local/bin/chrome-linux/chrome \
      --user-data-dir="$PROFILE_DIR" \
      --headless=new \
      --disable-gpu \
      --virtual-time-budget=10000 \
      "${KIOSK_JWT_URL}#jwt=${KIOSK_JWT_TOKEN}" > /dev/null 2>&1 &
    
    EXCHANGE_PID=$!
    
    # Wait for token exchange to complete (adjust timeout as needed)
    echo "Waiting for token exchange to complete..."
    sleep 2
    
    # Kill the headless instance
    kill $EXCHANGE_PID 2>/dev/null || true
    wait $EXCHANGE_PID 2>/dev/null || true
    
    echo "Token exchange complete. Cookies should now be set."
else
    # Standard headless warmup to fix cookies on first launch
    /usr/local/bin/chrome-linux/chrome \
      --user-data-dir="$PROFILE_DIR" \
      --headless=new \
      --disable-gpu \
      "${KIOSK_URL}" > /dev/null 2>&1 &

    WARMUP_PID=$!
    sleep 2
    kill $WARMUP_PID
    wait $WARMUP_PID 2>/dev/null || true
fi

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
    WIN_ID=$(xdotool search --pid "$CHROMIUM_PID" --onlyvisible | head -n1 || true)
    sleep 1
done

echo "Updating window title..."
while xdotool getwindowpid "$WIN_ID" &>/dev/null; do
    wmctrl -i -r "$WIN_ID" -T "$APP_NAME" || echo "wmctrl failed"
    sleep 1
done

echo "Chromium window closed. Exiting."