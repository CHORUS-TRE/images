#!/bin/bash

set -e
trap 'echo "2-symlink-workspace.sh : Error occurred on line $LINENO, exiting."; exit 1;' ERR

# Ensure required variables are set
: "${CHORUS_USER:?CHORUS_USER is not set}"
: "${CHORUS_UID:?CHORUS_UID is not set}"
: "${CHORUS_GID:?CHORUS_GID is not set}"

# ============================================================================
# Prepare app_data mount point with proper ownership
# The operator mounts /mnt/app_data with per-user subpath, but the directory
# may not exist yet or may have wrong ownership. Init container runs as root
# and can fix this before the app container starts.
# ============================================================================

if [ -d "/mnt/app_data" ]; then
  echo "Preparing app_data mount point..."
  chown "$CHORUS_UID:$CHORUS_GID" "/mnt/app_data"
  chmod 700 "/mnt/app_data"
  echo "  Set ownership: $CHORUS_UID:$CHORUS_GID, permissions: 700"
fi

# ============================================================================
# Create workspace-* symlinks in home directory pointing to mount points
# The operator mounts with SubPath workspaces/{namespace}/data so the mount
# point IS the data directory - no need to create subdirectories
# Users access data directly: ~/workspace-local/ shows data files immediately
# ============================================================================

echo "Creating workspace storage symlinks in home directory..."

# Check each storage type and create symlink directly to mount point
if [ -d "/mnt/workspace-local" ]; then
  HOME_LINK="/home/$CHORUS_USER/workspace-local"
  DATA_PATH="/mnt/workspace-local"

  # Remove old mount point if it exists
  if [ -e "$HOME_LINK" ] && [ ! -L "$HOME_LINK" ]; then
    echo "  WARNING: $HOME_LINK exists but is not a symlink, removing..."
    rm -rf "$HOME_LINK"
  fi

  # Create symlink to mount point (which IS the data directory via SubPath)
  if [ ! -L "$HOME_LINK" ] || [ "$(readlink "$HOME_LINK")" != "$DATA_PATH" ]; then
    ln -sf "$DATA_PATH" "$HOME_LINK"
    chown -h "$CHORUS_USER:$CHORUS_GID" "$HOME_LINK"
    echo "  Created: workspace-local -> /mnt/workspace-local"
  else
    echo "  Symlink already exists: workspace-local"
  fi
fi

if [ -d "/mnt/workspace-archive" ]; then
  HOME_LINK="/home/$CHORUS_USER/workspace-archive"
  DATA_PATH="/mnt/workspace-archive"

  if [ -e "$HOME_LINK" ] && [ ! -L "$HOME_LINK" ]; then
    echo "  WARNING: $HOME_LINK exists but is not a symlink, removing..."
    rm -rf "$HOME_LINK"
  fi

  if [ ! -L "$HOME_LINK" ] || [ "$(readlink "$HOME_LINK")" != "$DATA_PATH" ]; then
    ln -sf "$DATA_PATH" "$HOME_LINK"
    chown -h "$CHORUS_USER:$CHORUS_GID" "$HOME_LINK"
    echo "  Created: workspace-archive -> /mnt/workspace-archive"
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

  # NFS scratch storage - point directly to mount
  if [ ! -L "$HOME_LINK" ] || [ "$(readlink "$HOME_LINK")" != "$SCRATCH_PATH" ]; then
    ln -sf "$SCRATCH_PATH" "$HOME_LINK"
    chown -h "$CHORUS_USER:$CHORUS_GID" "$HOME_LINK"
    echo "  Created: workspace-scratch -> /mnt/workspace-scratch"
  else
    echo "  Symlink already exists: workspace-scratch"
  fi
fi

echo ""
