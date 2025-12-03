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
    # Build find command dynamically, only pruning workspace paths that exist
    FIND_CMD="find \"/home/$CHORUS_USER\""
    [ -e "/home/$CHORUS_USER/workspace-scratch" ] && FIND_CMD="$FIND_CMD -path \"/home/$CHORUS_USER/workspace-scratch\" -prune -o"
    [ -e "/home/$CHORUS_USER/workspace-archive" ] && FIND_CMD="$FIND_CMD -path \"/home/$CHORUS_USER/workspace-archive\" -prune -o"
    [ -e "/home/$CHORUS_USER/workspace-local" ] && FIND_CMD="$FIND_CMD -path \"/home/$CHORUS_USER/workspace-local\" -prune -o"
    FIND_CMD="$FIND_CMD -exec chown \"$CHORUS_USER:$CHORUS_GID\" {} +"
    eval "$FIND_CMD"
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
# Create .bashrc for proper shell initialization
# This ensures NSS wrapper variables are set for all interactive shells
# (including kitty terminal and kubectl exec sessions)
# ============================================================================

echo -n "Creating .bashrc for user $CHORUS_USER... "
cat > "/home/$CHORUS_USER/.bashrc" << 'EOF'
# Chorus environment configuration for NSS wrapper

# Ensure NSS wrapper is loaded for user identity resolution
if [ -f /usr/lib/x86_64-linux-gnu/libnss_wrapper.so ]; then
    export LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libnss_wrapper.so"
elif [ -f /usr/lib/libnss_wrapper.so ]; then
    export LD_PRELOAD="/usr/lib/libnss_wrapper.so"
fi
export NSS_WRAPPER_PASSWD="/home/.chorus-auth/passwd"
export NSS_WRAPPER_GROUP="/home/.chorus-auth/group"

# Source system bashrc if it exists
if [ -f /etc/bash.bashrc ]; then
    . /etc/bash.bashrc
fi

# Fix for bash username caching issue with NSS wrapper
# Bash caches the username at startup before NSS wrapper is fully active,
# so \u in PS1 shows "I have no name!". We use PROMPT_COMMAND to fix PS1
# on every prompt display, in case profile scripts reset PS1.
_chorus_fix_prompt() {
    # Check if PS1 contains \u (backslash-u) and fix it
    # Match both literal \u and the expanded "I have no name!" text
    if [[ "$PS1" == *'\u'* ]] || [[ "$PS1" == *'I have no name'* ]]; then
        local user
        user=$(whoami 2>/dev/null) || user="$USER"
        # Replace \u with actual username
        PS1="${PS1//\\u/$user}"
        # Also replace "I have no name!" if present
        PS1="${PS1//I have no name!/$user}"
    fi
}

# Append to PROMPT_COMMAND - this will run on every prompt display
if [[ -z "$PROMPT_COMMAND" ]]; then
    PROMPT_COMMAND="_chorus_fix_prompt"
elif [[ "$PROMPT_COMMAND" != *"_chorus_fix_prompt"* ]]; then
    PROMPT_COMMAND="${PROMPT_COMMAND}; _chorus_fix_prompt"
fi
EOF

chown "$CHORUS_UID:$CHORUS_GID" "/home/$CHORUS_USER/.bashrc"
chmod 644 "/home/$CHORUS_USER/.bashrc"
echo "done."

# ============================================================================
# Export user/group information for libnss_wrapper in main container
# This allows the main container to have proper NSS entries without running as root
# ============================================================================

echo -n "Exporting user/group information for main container... "

# Create secure directory for auth files on shared /home volume
AUTH_DIR="/home/.chorus-auth"
mkdir -p "$AUTH_DIR"
chmod 500 "$AUTH_DIR"
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

# Set secure permissions (read-only for the user, preventing any modification)
chmod 400 "$PASSWD_FILE"
chmod 400 "$GROUP_FILE"
chown "$CHORUS_UID:$CHORUS_GID" "$PASSWD_FILE"
chown "$CHORUS_UID:$CHORUS_GID" "$GROUP_FILE"

echo "done."
echo "  Created: $PASSWD_FILE"
echo "  Created: $GROUP_FILE"
