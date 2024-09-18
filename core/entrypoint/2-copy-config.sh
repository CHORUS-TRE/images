#!/bin/bash
set -e

if [ -z "$CONFIG_ARRAY" ]; then
  echo "CONFIG_ARRAY is not set. Exiting."
  exit 0
fi

# Convert CONFIG_ARRAY string to an array
CONFIG_ARRAY=( "$CONFIG_ARRAY" )

#copy all configuration files in $CONFIG_ARRAY in $CHORUS_USER homedir
for CONFIG in ${CONFIG_ARRAY}; do
  echo -n "Copying ${CONFIG} to ${CHORUS_USER} homedir... "
  eval cp -r /apps/"${APP_NAME}"/config/"${CONFIG}" ~"${CHORUS_USER}"
  eval chown -R "${CHORUS_USER}": ~"${CHORUS_USER}"/"${CONFIG}"
  echo "Configuration copied for ${CHORUS_USER}"
done
