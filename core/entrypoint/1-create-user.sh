#!/bin/bash

echo -n "Creating user $CHORUS_USER... "

if grep -E "^$CHORUS_USER" /etc/passwd >/dev/null; then
  echo "$CHORUS_USER already exists."
  exit 0
else
  if useradd --create-home --shell /bin/bash "$CHORUS_USER" --uid 1001; then
    echo "done."
  else
    echo "failed."
    exit 1
  fi
fi