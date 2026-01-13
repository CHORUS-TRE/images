#!/bin/bash
# based on https://github.com/ffeldhaus/docker-xpra-html5-gpu-minimal/blob/master/docker-entrypoint.sh

XPRA_USER=xpra

# SCRIPT_PATH=./scripts

# $SCRIPT_PATH/check-dri.sh $CARD
# retVal=$?
# if [ $retVal -ne 0 ]; then
#   exit $retVal
# fi

# $SCRIPT_PATH/fix-video-groups.sh $CARD $XPRA_USER
# retVal=$?
# if [ $retVal -ne 0 ]; then
#   exit $retVal
# fi

# $SCRIPT_PATH/fix-audio-groups.sh $XPRA_USER
# retVal=$?
# if [ $retVal -ne 0 ]; then
#   exit $retVal
# fi

# make the socket accessible to socat
chmod -R 1777 /tmp/.X11-unix/

# remove a previous lock, if it exists
rm -rf /tmp/.X80-lock

# start xpra as $XPRA_USER
if [ "$XPRA_KEYCLOAK_AUTH" = "True" ]; then
  AUTH=",auth=keycloak"
fi

if [ -z "${INITIAL_RESOLUTION}" ]; then
  INITIAL_RESOLUTION="1920x1080"
fi

# Configure clipboard based on environment variable
# Default to disabled for security
if [ "$XPRA_CLIPBOARD_DIRECTION" != "disabled" ] && [ -n "$XPRA_CLIPBOARD_DIRECTION" ]; then
  # Enable clipboard in user xpra config
  sed -i 's/^clipboard=no/clipboard=yes/' /home/$XPRA_USER/.xpra/xpra.conf
  sed -i "s/^clipboard-direction=disabled/clipboard-direction=$XPRA_CLIPBOARD_DIRECTION/" /home/$XPRA_USER/.xpra/xpra.conf
  # Enable clipboard in HTML5 client
  sed -i 's/^clipboard = false/clipboard = true/' /etc/xpra/html5-client/default-settings.txt
fi

runuser -l $XPRA_USER -c "pulseaudio --start; pulseaudio --kill; XPRA_KEYCLOAK_SERVER_URL=$XPRA_KEYCLOAK_SERVER_URL XPRA_KEYCLOAK_REALM_NAME=$XPRA_KEYCLOAK_REALM_NAME XPRA_KEYCLOAK_CLIENT_ID=$XPRA_KEYCLOAK_CLIENT_ID XPRA_KEYCLOAK_CLIENT_SECRET_KEY=$XPRA_KEYCLOAK_CLIENT_SECRET_KEY XPRA_KEYCLOAK_REDIRECT_URI=$XPRA_KEYCLOAK_REDIRECT_URI XPRA_KEYCLOAK_SCOPE=$XPRA_KEYCLOAK_SCOPE XPRA_KEYCLOAK_CLAIM_FIELD=$XPRA_KEYCLOAK_CLAIM_FIELD XPRA_KEYCLOAK_AUTH_GROUPS=$XPRA_KEYCLOAK_AUTH_GROUPS XPRA_KEYCLOAK_AUTH_CONDITION=$XPRA_KEYCLOAK_AUTH_CONDITION XPRA_KEYCLOAK_GRANT_TYPE=$XPRA_KEYCLOAK_GRANT_TYPE xpra start :80 --bind-tcp=0.0.0.0:8080$AUTH --no-daemon -d auth --resize-display=$INITIAL_RESOLUTION"
