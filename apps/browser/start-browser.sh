#!/bin/bash

set -e

export GOOGLE_API_KEY="no"
export GOOGLE_DEFAULT_CLIENT_ID="no"
export GOOGLE_DEFAULT_CLIENT_SECRET="no"

PROFILE_DIR="$HOME/.chrome-data"
mkdir -p "$PROFILE_DIR"

# JWT token exchange if IDP_SL_TOKEN and IDP_JWT_URL are defined
if [ -n "$IDP_SL_TOKEN" ] && [ -n "$IDP_JWT_URL" ] ; then
    echo "Exchanging JWT token for session cookie..."

    # Launch headless Chrome to perform token exchange without leaving history
    /usr/local/bin/chrome-linux/chrome \
      --user-data-dir="$PROFILE_DIR" \
      --headless=new \
      --disable-gpu \
      --no-sandbox \
      --dump-dom \
      "${IDP_JWT_URL}#jwt=${IDP_SL_TOKEN}" &

    EXCHANGE_PID=$!

    echo "Waiting for token exchange to complete..."
    sleep 10

    kill $EXCHANGE_PID 2>/dev/null || true
    wait $EXCHANGE_PID 2>/dev/null || true

    echo "Token exchange complete. Cookies should now be set."
fi

# Main Chromium launch — full browser UI (address bar visible), no --app=.
# --test-type suppresses Chrome's warning about unsupported command-line flags like --no-sandbox.
exec /usr/local/bin/chrome-linux/chrome \
  --no-sandbox \
  --test-type \
  --noerrdialogs \
  --disable-infobars \
  --disable-session-crashed-bubble \
  --enable-features=NetworkService,NetworkServiceInProcess \
  --window-size=1200,700 \
  --user-data-dir="$PROFILE_DIR" \
  "${BROWSER_URL:-about:blank}"
