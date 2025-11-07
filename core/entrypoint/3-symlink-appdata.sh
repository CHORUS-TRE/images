#!/bin/bash

set -e
trap 'echo "3-symlink-appdata.sh : Error occurred on line $LINENO, exiting."; exit 1;' ERR

# Exit if APP_DATA_DIR_ARRAY is not set or empty
if [ -z "$APP_DATA_DIR_ARRAY" ]; then
  echo "APP_DATA_DIR_ARRAY is not set or empty. No app data to symlink. Exiting."
  exit 0
fi

# Ensure required variables are set
: "${CHORUS_USER:?CHORUS_USER is not set}"
: "${CHORUS_GID:?CHORUS_GID is not set}"
: "${APP_NAME:?APP_NAME is not set}"

# Convert APP_DATA_DIR_ARRAY to array (space-separated)
IFS=' ' read -ra DIR_ARRAY <<< "$APP_DATA_DIR_ARRAY"

# ============================================================================
# Create workspace-* symlinks in home directory pointing to data directories
# Users access data directly: ~/workspace-local/ shows data files immediately
# ============================================================================

echo "Creating workspace storage symlinks in home directory..."

# Check each storage type and create symlink to its data directory
if [ -d "/mnt/workspace-local/data" ]; then
  HOME_LINK="/home/$CHORUS_USER/workspace-local"
  DATA_PATH="/mnt/workspace-local/data"

  # Remove old mount point if it exists
  if [ -e "$HOME_LINK" ] && [ ! -L "$HOME_LINK" ]; then
    echo "  WARNING: $HOME_LINK exists but is not a symlink, removing..."
    rm -rf "$HOME_LINK"
  fi

  # Create symlink to data directory
  if [ ! -L "$HOME_LINK" ] || [ "$(readlink "$HOME_LINK")" != "$DATA_PATH" ]; then
    ln -sf "$DATA_PATH" "$HOME_LINK"
    chown -h "$CHORUS_USER:$CHORUS_GID" "$HOME_LINK"
    echo "  Created: workspace-local -> /mnt/workspace-local/data"
  else
    echo "  Symlink already exists: workspace-local"
  fi
fi

if [ -d "/mnt/workspace-archive/data" ]; then
  HOME_LINK="/home/$CHORUS_USER/workspace-archive"
  DATA_PATH="/mnt/workspace-archive/data"

  if [ -e "$HOME_LINK" ] && [ ! -L "$HOME_LINK" ]; then
    echo "  WARNING: $HOME_LINK exists but is not a symlink, removing..."
    rm -rf "$HOME_LINK"
  fi

  if [ ! -L "$HOME_LINK" ] || [ "$(readlink "$HOME_LINK")" != "$DATA_PATH" ]; then
    ln -sf "$DATA_PATH" "$HOME_LINK"
    chown -h "$CHORUS_USER:$CHORUS_GID" "$HOME_LINK"
    echo "  Created: workspace-archive -> /mnt/workspace-archive/data"
  else
    echo "  Symlink already exists: workspace-archive"
  fi
fi

if [ -d "/mnt/workspace-scratch" ]; then
  HOME_LINK="/home/$CHORUS_USER/workspace-scratch"
  SCRATCH_PATH="/mnt/workspace-scratch"

  if [ -e "$HOME_LINK" ] && [ ! -L "$HOME_LINK" ]; then
    echo "  WARNING: $HOME_LINK exists but is not a symlink, removing..."
    rm -rf "$HOME_LINK"
  fi

  # NFS doesn't have data/ subdirectory - point to root
  if [ ! -L "$HOME_LINK" ] || [ "$(readlink "$HOME_LINK")" != "$SCRATCH_PATH" ]; then
    ln -sf "$SCRATCH_PATH" "$HOME_LINK"
    chown -h "$CHORUS_USER:$CHORUS_GID" "$HOME_LINK"
    echo "  Created: workspace-scratch -> /mnt/workspace-scratch"
  else
    echo "  Symlink already exists: workspace-scratch"
  fi
fi

echo ""

# ============================================================================
# Detect available storage for app config persistence (priority: local > archive)
# ============================================================================

STORAGE_BASE=""
STORAGE_TYPE=""

if [ -d "/mnt/workspace-local" ]; then
  STORAGE_BASE="/mnt/workspace-local"
  STORAGE_TYPE="local"
  echo "Detected workspace-local storage for app data persistence"
elif [ -d "/mnt/workspace-archive" ]; then
  STORAGE_BASE="/mnt/workspace-archive"
  STORAGE_TYPE="archive"
  echo "Detected workspace-archive storage for app data persistence"
else
  echo "WARNING: No persistent storage found (workspace-local or workspace-archive)"
  echo "App data directories will not persist between runs: ${DIR_ARRAY[*]}"
  exit 0
fi

# Create base config directory on persistent storage (per-user)
# This mirrors the home directory structure at config/{uid}/
TARGET_BASE="$STORAGE_BASE/config/$CHORUS_UID"
if [ ! -d "$TARGET_BASE" ]; then
  echo "Creating user config base directory on $STORAGE_TYPE storage: $TARGET_BASE"
  mkdir -p -m 700 "$TARGET_BASE"  # SECURITY: Create with 700 (owner-only access)
  chown "$CHORUS_USER:$CHORUS_GID" "$TARGET_BASE"
  echo "  Set permissions: 700 (owner-only access)"
fi

# Process each directory in the array
for DIR in "${DIR_ARRAY[@]}"; do
  # Skip empty entries
  [ -z "$DIR" ] && continue

  # Determine if this is an absolute path or relative path
  if [[ "$DIR" = /* ]]; then
    # Absolute path - use as-is for LOCAL_PATH
    LOCAL_PATH="$DIR"
    # Use basename for remote storage to keep it organized
    DIR_NAME=$(basename "$DIR")
    REMOTE_PATH="$TARGET_BASE/$DIR_NAME"
    echo "Processing config directory (absolute): $DIR -> storage:$REMOTE_PATH"
  else
    # Relative path - relative to user's home directory
    # This preserves the directory structure (e.g., .config/Code -> config/{uid}/.config/Code)
    LOCAL_PATH="/home/$CHORUS_USER/$DIR"
    REMOTE_PATH="$TARGET_BASE/$DIR"
    DIR_NAME=$(basename "$DIR")
    echo "Processing config directory (relative): $DIR -> storage:config/$CHORUS_UID/$DIR"
  fi

  # Create remote directory if it doesn't exist
  if [ ! -d "$REMOTE_PATH" ]; then
    echo "  Creating directory on $STORAGE_TYPE storage: $REMOTE_PATH"
    mkdir -p -m 700 "$REMOTE_PATH"  # SECURITY: Create with 700 (owner-only access)
    chown -R "$CHORUS_USER:$CHORUS_GID" "$REMOTE_PATH"
    echo "    Set permissions: 700 (owner-only access)"
  fi

  # Handle existing local directory
  restore=1
  if [ -d "$LOCAL_PATH" ] && [ ! -L "$LOCAL_PATH" ]; then
    echo "  Local directory already exists and is not a symlink, backing up..."
    mv "$LOCAL_PATH" /tmp/
    retVal=$?
    if [ $retVal -ne 0 ]; then
      echo "  ERROR: Failed to backup $LOCAL_PATH"
      exit $retVal
    fi
    restore=0
    echo "  Backup successful"
  fi

  # Create parent directory if needed (for nested paths like .config/Code)
  PARENT_PATH=$(dirname "$LOCAL_PATH")
  if [ "$PARENT_PATH" != "/home/$CHORUS_USER" ] && [ ! -d "$PARENT_PATH" ]; then
    echo "  Creating parent directory: $PARENT_PATH"
    mkdir -p "$PARENT_PATH"
    chown -R "$CHORUS_USER:$CHORUS_GID" "$PARENT_PATH"
  fi

  # Create symlink if it doesn't exist
  if [ ! -L "$LOCAL_PATH" ]; then
    echo "  Creating symlink: $LOCAL_PATH -> $REMOTE_PATH"
    ln -sf "$REMOTE_PATH" "$LOCAL_PATH"
    retVal=$?
    if [ $retVal -ne 0 ]; then
      echo "  ERROR: Failed to create symlink"
      exit $retVal
    fi
  else
    echo "  Symlink already exists"
  fi

  # Fix ownership of the symlink itself
  chown -h "$CHORUS_USER:$CHORUS_GID" "$LOCAL_PATH"

  # Restore backed up content if needed
  if [ $restore -eq 0 ]; then
    echo "  Restoring backed up content from /tmp/$DIR_NAME to $REMOTE_PATH"
    (shopt -s dotglob; mv /tmp/"$DIR_NAME"/* "$REMOTE_PATH"/ 2>/dev/null || true)
    rm -rf /tmp/"$DIR_NAME"
    echo "  Restore complete"
  fi

  # Ensure proper ownership on remote directory
  chown -R "$CHORUS_USER:$CHORUS_GID" "$REMOTE_PATH"

  echo "  Successfully configured: $DIR -> $STORAGE_TYPE storage"
done

echo "Config symlinking complete for user $CHORUS_UID. Using $STORAGE_TYPE storage at: $TARGET_BASE"
