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
    # Set ownership on home directory contents, but skip workspace symlinks (they're created later)
    # The actual storage mounts are at /mnt/workspace-* and don't need chown
    find "/home/$CHORUS_USER" -path "/home/$CHORUS_USER/workspace-scratch" -prune -o -path "/home/$CHORUS_USER/workspace-archive" -prune -o -path "/home/$CHORUS_USER/workspace-local" -prune -o -exec chown "$CHORUS_USER:$CHORUS_GID" {} +
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

# ============================================================================
# Export user/group information for libnss_wrapper in main container
# This allows the main container to have proper NSS entries without running as root
# ============================================================================

echo -n "Exporting user/group information for main container... "

# Create secure directory for auth files on shared /home volume
AUTH_DIR="/home/.chorus-auth"
mkdir -p "$AUTH_DIR"
chmod 700 "$AUTH_DIR"
chown "$CHORUS_UID:$CHORUS_GID" "$AUTH_DIR"

# Create passwd file with base system entries + dynamic user
# Include essential system users for proper application functionality
PASSWD_FILE="$AUTH_DIR/passwd"
cat > "$PASSWD_FILE" << EOF
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
$CHORUS_USER:x:$CHORUS_UID:$CHORUS_GID:$CHORUS_USER:/home/$CHORUS_USER:/bin/bash
EOF

# Create group file with base system groups + dynamic group
GROUP_FILE="$AUTH_DIR/group"
cat > "$GROUP_FILE" << EOF
root:x:0:
daemon:x:1:
bin:x:2:
sys:x:3:
adm:x:4:
tty:x:5:
disk:x:6:
dialout:x:20:
nogroup:x:65534:
$CHORUS_GROUP:x:$CHORUS_GID:$CHORUS_USER
EOF

# Set secure permissions (readable only by the user who will use them)
chmod 600 "$PASSWD_FILE"
chmod 600 "$GROUP_FILE"
chown "$CHORUS_UID:$CHORUS_GID" "$PASSWD_FILE"
chown "$CHORUS_UID:$CHORUS_GID" "$GROUP_FILE"

echo "done."
echo "  Created: $PASSWD_FILE"
echo "  Created: $GROUP_FILE"
