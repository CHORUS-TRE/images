#!/bin/bash

echo -n "Creating user $CHORUS_USER... "

egrep "^$CHORUS_USER" /etc/passwd >/dev/null
if [ $? -eq 0 ]; then
  echo "$CHORUS_USER already exists."
  exit 0
else
  useradd --create-home --shell /bin/bash $CHORUS_USER --uid 1001
  if [ $? -eq 0 ]; then
    echo "done."
  else
    echo "failed."
    exit 1
  fi
fi