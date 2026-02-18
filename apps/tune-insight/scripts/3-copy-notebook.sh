#!/bin/bash
set -e

if [ -z "$NOTEBOOK_ARRAY" ]; then
  echo "NOTEBOOK_ARRAY is not set. Exiting."
  exit 0
fi

# Convert CONFIG_ARRAY string to an array
NOTEBOOK_ARRAY=( "$NOTEBOOK_ARRAY" )

# Copy all notebooks in $NOTEBOOK_ARRAY in $CHORUS_USER workspace-archive
# if it does not already exist
for NOTEBOOK in ${NOTEBOOK_ARRAY}; do
  echo -n "Copying ${NOTEBOOK} to ${CHORUS_USER} ${PERSISTED_FOLDER}... "
  eval cp -r --update=none /apps/"${APP_NAME}"/notebook/"${NOTEBOOK}" ~"${CHORUS_USER}"/"${PERSISTED_FOLDER}"
  eval chown -R "${CHORUS_USER}": ~"${CHORUS_USER}"/"${PERSISTED_FOLDER}"/"${NOTEBOOK}"
  echo "Notebook copied for ${CHORUS_USER}"
done
