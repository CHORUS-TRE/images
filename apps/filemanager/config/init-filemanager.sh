#!/bin/bash
# Filemanager initialization script
# Runs during entrypoint to set up configuration for CHORUS_USER

SETTINGS_PATH=~"${CHORUS_USER}"/.config/pcmanfm-qt/default
SETTINGS_FILE=settings.conf
SETTINGS=$SETTINGS_PATH/$SETTINGS_FILE

if [ ! -d "$SETTINGS_PATH" ]; then
  echo "Filemanager: SETTINGS_PATH does not exist, creating it"
  mkdir -p "$SETTINGS_PATH"
  echo "Created $SETTINGS_PATH"
fi

if [ ! -f "$SETTINGS" ]; then
  echo "Filemanager: SETTINGS does not exist, creating it"
  cat /apps/filemanager/config/$SETTINGS_FILE > "$SETTINGS"
  echo "Created $SETTINGS"
fi

if ! grep -q ^HiddenPlaces "$SETTINGS"; then
  sed -i "/^\[Places\].*/a HiddenPlaces=computer:///, ~${CHORUS_USER}/Desktop, network:///, menu://applications/" "$SETTINGS"
fi

# Fix ownership
chown -R "${CHORUS_USER}:${CHORUS_GROUP}" ~"${CHORUS_USER}"/.config/pcmanfm-qt

echo "Filemanager configuration initialized for ${CHORUS_USER}"
