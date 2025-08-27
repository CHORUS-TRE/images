#!/bin/bash

echo -n "Creating group $CHORUS_GROUP with GID $CHORUS_GID... "
if ! groupadd -g $CHORUS_GID $CHORUS_GROUP; then
  echo "failed: group $CHORUS_GROUP or GID $CHORUS_GID already exists"
  exit 1
fi

echo -n "Creating user $CHORUS_USER with UID $CHORUS_UID... "
if getent passwd "$CHORUS_USER" >/dev/null; then
  echo "failed: $CHORUS_USER already exists."
  exit 1
fi

if [ -d "/home/$CHORUS_USER" ]; then
  if useradd --no-create-home --shell /bin/bash "$CHORUS_USER" --uid "$CHORUS_UID" --gid "$CHORUS_GID"; then
   cp -a /etc/skel/. "/home/$CHORUS_USER/"
    find "/home/$CHORUS_USER" -path "/home/$CHORUS_USER/workspace-data" -prune -o -exec chown "$CHORUS_USER:$CHORUS_GID" {} +
    chown "$CHORUS_USER:$CHORUS_GID" "/home/$CHORUS_USER/workspace-data"
    echo "done and updated permissions."
  else
    echo "failed: could not add user (without homedir)."
    exit 1
  fi
else
  if useradd --create-home --shell /bin/bash "$CHORUS_USER" --uid "$CHORUS_UID" --gid "$CHORUS_GID"; then
    echo "done."
  else
    echo "failed: could not add user (with homedir)."
    exit 1
  fi
fi
