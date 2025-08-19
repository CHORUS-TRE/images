#!/bin/bash

echo -n "Creating user $CHORUS_USER... "

if grep -E "^$CHORUS_USER" /etc/passwd >/dev/null; then
  echo "$CHORUS_USER already exists."
  exit 0
else
  if [ -d "/home/$CHORUS_USER" ]; then
    if useradd --no-create-home --shell /bin/bash "$CHORUS_USER" --uid 1001; then
      cp -r /etc/skel/. "/home/$CHORUS_USER/"
      find "/home/$CHORUS_USER" -not -path "/home/$CHORUS_USER/workspace-data/*" -exec chown $CHORUS_USER:$CHORUS_USER {} \;
      echo "done and updated permissions."
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