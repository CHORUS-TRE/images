#!/bin/bash

set -e
trap 'echo "2-symlink-workspace.sh : Error occurred on line $LINENO, exiting."; exit 1;' ERR

# Ensure required variables are set
: "${CHORUS_USER:?CHORUS_USER is not set}"
: "${CHORUS_GID:?CHORUS_GID is not set}"

# ============================================================================
# Create base data directories for user files
# Must be created BEFORE symlinks so symlink targets exist
# ============================================================================

echo "Creating base data directories for user files..."

if [ -d "/mnt/workspace-local" ]; then
  DATA_DIR="/mnt/workspace-local/data"
  if [ ! -d "$DATA_DIR" ]; then
    mkdir -p "$DATA_DIR"
    chown root:$CHORUS_GID "$DATA_DIR"
    chmod 2770 "$DATA_DIR"  # drwxrws--- - group can write, setgid
    echo "  Created: /mnt/workspace-local/data (2770, root:chorus)"
  else
    echo "  Already exists: /mnt/workspace-local/data"
  fi
fi

if [ -d "/mnt/workspace-archive" ]; then
  DATA_DIR="/mnt/workspace-archive/data"
  if [ ! -d "$DATA_DIR" ]; then
    mkdir -p "$DATA_DIR"
    chown root:$CHORUS_GID "$DATA_DIR"
    chmod 2770 "$DATA_DIR"  # drwxrws--- - group can write, setgid
    echo "  Created: /mnt/workspace-archive/data (2770, root:chorus)"
  else
    echo "  Already exists: /mnt/workspace-archive/data"
  fi
fi

echo ""

# ============================================================================
# Create base config directories for app data persistence
# Apps will create their own config/{UID}/ subdirectories
# ============================================================================

echo "Creating base config directories for app data persistence..."

if [ -d "/mnt/workspace-local" ]; then
  CONFIG_DIR="/mnt/workspace-local/config"
  if [ ! -d "$CONFIG_DIR" ]; then
    mkdir -p "$CONFIG_DIR"
    chown root:$CHORUS_GID "$CONFIG_DIR"
    chmod 775 "$CONFIG_DIR"  # drwxrwxr-x - group can write
    echo "  Created: /mnt/workspace-local/config (775, root:chorus)"
  else
    echo "  Already exists: /mnt/workspace-local/config"
  fi
fi

if [ -d "/mnt/workspace-archive" ]; then
  CONFIG_DIR="/mnt/workspace-archive/config"
  if [ ! -d "$CONFIG_DIR" ]; then
    mkdir -p "$CONFIG_DIR"
    chown root:$CHORUS_GID "$CONFIG_DIR"
    chmod 775 "$CONFIG_DIR"  # drwxrwxr-x - group can write
    echo "  Created: /mnt/workspace-archive/config (775, root:chorus)"
  else
    echo "  Already exists: /mnt/workspace-archive/config"
  fi
fi

echo ""

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
