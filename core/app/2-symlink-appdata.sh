#!/bin/bash

set -e
trap 'echo "4-symlink-appdata.sh : Error occurred on line $LINENO, exiting."; exit 1;' ERR

# Exit if APP_DATA_DIR_ARRAY is not set or empty
if [ -z "$APP_DATA_DIR_ARRAY" ]; then
  echo "APP_DATA_DIR_ARRAY is not set or empty. No app data to symlink. Exiting."
  exit 0
fi

# Ensure required variables are set
: "${CHORUS_USER:?CHORUS_USER is not set}"
: "${CHORUS_UID:?CHORUS_UID is not set}"
: "${CHORUS_GID:?CHORUS_GID is not set}"
: "${APP_NAME:?APP_NAME is not set}"

# Convert APP_DATA_DIR_ARRAY to array (space-separated)
IFS=' ' read -ra DIR_ARRAY <<< "$APP_DATA_DIR_ARRAY"

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

  # Remove existing local directory if it exists and is not a symlink
  if [ -d "$LOCAL_PATH" ] && [ ! -L "$LOCAL_PATH" ]; then
    echo "  Local directory exists and is not a symlink, removing..."
    rm -rf "$LOCAL_PATH"
    echo "  Removed successfully"
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

  # Ensure proper ownership on remote directory
  chown -R "$CHORUS_USER:$CHORUS_GID" "$REMOTE_PATH"

  echo "  Successfully configured: $DIR -> $STORAGE_TYPE storage"
done

echo "Config symlinking complete for user $CHORUS_UID. Using $STORAGE_TYPE storage at: $TARGET_BASE"
