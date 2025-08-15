#!/bin/bash

echo -n "Creating user $CHORUS_USER... "

if grep -E "^$CHORUS_USER" /etc/passwd >/dev/null; then
  echo "$CHORUS_USER already exists."
  exit 0
else
  if [ -d "/home/$CHORUS_USER" ]; then
    echo "home directory already exists, updating permissions"
    chown 1001:1001 /home/$CHORUS_USER
    if useradd --no-create-home --shell /bin/bash "$CHORUS_USER" --uid 1001; then
      echo "copying skeleton files..."
      cp -r /etc/skel/. "/home/$CHORUS_USER/"
      echo "done."
    else
      echo "failed."
      exit 1
    fi
  else
    if useradd --create-home --shell /bin/bash "$CHORUS_USER" --uid 1001; then
      echo "done."
    else
      echo "failed."
      exit 1
    fi
  fi
fi