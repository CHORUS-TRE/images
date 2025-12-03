#!/bin/bash
# Main container entrypoint - runs as non-root user with zero capabilities
# User creation and setup completed by init container
# Relies on libnss_wrapper for user context

set -e
trap 'echo "docker-entrypoint.sh : Error occurred on line $LINENO, exiting."; exit 1;' ERR

# This entrypoint runs as non-root user (setup completed by init container)
# No user creation or privileged operations needed
# The /home directory is shared with init container

# Security: Set umask for file creation
umask 007  # Files: 660 (rw-rw----) - Use for full read/write collaboration

# Ensure APP_CMD is set
: "${APP_CMD:?Environment variable APP_CMD is required but not set}"

# ============================================================================
# Configure libnss_wrapper for proper NSS user/group resolution
# The init container created passwd/group files on the shared /home volume
# This allows proper user context without requiring root privileges
# ============================================================================

echo "Configuring libnss_wrapper for user context..."

# Locate libnss_wrapper library - must be installed in app image for libc compatibility
NSS_WRAPPER_LIB=""
if [ -f "/usr/lib/x86_64-linux-gnu/libnss_wrapper.so" ]; then
    NSS_WRAPPER_LIB="/usr/lib/x86_64-linux-gnu/libnss_wrapper.so"
    echo "  Using libnss_wrapper from app image"
elif [ -f "/usr/lib/libnss_wrapper.so" ]; then
    NSS_WRAPPER_LIB="/usr/lib/libnss_wrapper.so"
    echo "  Using libnss_wrapper from app image"
else
    echo "ERROR: libnss_wrapper.so not found!"
    echo "  Please install libnss-wrapper package in your app Dockerfile"
    echo "  Example: RUN apt-get install -y libnss-wrapper"
    echo "  Or use chorus-utils.sh which installs it automatically"
    exit 1
fi

# Configure NSS wrapper to use the passwd/group files created by init container
export LD_PRELOAD="${NSS_WRAPPER_LIB}"
export NSS_WRAPPER_PASSWD="/home/.chorus-auth/passwd"
export NSS_WRAPPER_GROUP="/home/.chorus-auth/group"

# Verify the auth files exist
if [ ! -f "$NSS_WRAPPER_PASSWD" ]; then
    echo "ERROR: NSS passwd file not found at $NSS_WRAPPER_PASSWD"
    echo "Init container may have failed to create user context files"
    exit 1
fi

if [ ! -f "$NSS_WRAPPER_GROUP" ]; then
    echo "ERROR: NSS group file not found at $NSS_WRAPPER_GROUP"
    echo "Init container may have failed to create user context files"
    exit 1
fi

echo "  LD_PRELOAD: $LD_PRELOAD"
echo "  NSS_WRAPPER_PASSWD: $NSS_WRAPPER_PASSWD"
echo "  NSS_WRAPPER_GROUP: $NSS_WRAPPER_GROUP"

# Verify user identity is properly resolved through NSS
echo "Verifying user identity..."
if ! id -u "$CHORUS_USER" >/dev/null 2>&1; then
    echo "ERROR: User $CHORUS_USER not found in NSS database"
    exit 1
fi

# Set environment variables for proper user context
# NSS provides the passwd database, but we still need to set environment variables
export HOME="/home/${CHORUS_USER}"
export USER="${CHORUS_USER}"
export LOGNAME="${CHORUS_USER}"
export XDG_RUNTIME_DIR="/tmp/runtime-${CHORUS_USER}"

echo "  User: $(whoami)"
echo "  UID: $(id -u)"
echo "  GID: $(id -g)"
echo "  Groups: $(id -G)"
echo "  Home: $HOME"

# Create XDG_RUNTIME_DIR for applications that need it
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR" 2>/dev/null || true

# ============================================================================
# Execute scripts from /docker-entrypoint.d/
# This allows apps to run custom setup scripts before the main application starts
# ============================================================================

# Source any envsh, run any sh scripts in /docker-entrypoint.d/
if /usr/bin/find "/docker-entrypoint.d/" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
    echo "$0: /docker-entrypoint.d/ is not empty, will attempt to perform configuration"

    echo "$0: Looking for shell scripts in /docker-entrypoint.d/"
    find "/docker-entrypoint.d/" -follow -type f -print | sort -V | while read -r f; do
        case "$f" in
            *.envsh)
                if [ -x "$f" ]; then
                    echo "$0: Sourcing $f";
                    . "$f"
                else
                    # warn on shell scripts without exec bit
                    echo "$0: Ignoring $f, not executable";
                fi
                ;;
            *.sh)
                if [ -x "$f" ]; then
                    echo "$0: Launching $f";
                    "$f"
                else
                    # warn on shell scripts without exec bit
                    echo "$0: Ignoring $f, not executable";
                fi
                ;;
            *) echo "$0: Ignoring $f";;
        esac
    done

    echo "$0: Configuration complete; ready for start up"
else
    echo "$0: No files found in /docker-entrypoint.d/, skipping configuration"
fi

# Default CARD to none if not set
if [ -z "$CARD" ]; then
    CARD="none"
fi

# Build the command
case "$CARD" in
  "none")
    echo "Running $APP_NAME on CPU..."
    CMD="$APP_CMD"
    ;;
  *)
    echo "Running $APP_NAME on GPU..."
    CMD="vglrun -d /dev/dri/$CARD $APP_CMD"
    ;;
esac

# Add any prefix commands
if [ -n "$APP_CMD_PREFIX" ]; then
    CMD="$APP_CMD_PREFIX; $CMD"
fi

# Change to home directory and execute the command
cd "$HOME"

# Execute the command with appropriate shell based on user context
if [ "$(id -u)" = "0" ]; then
    # Running as root (debug mode) - use runuser to switch to user
    # -l: login shell (sources ~/.bash_profile)
    # -w: preserve environment variables needed for X11 and NSS wrapper
    exec runuser -l "$CHORUS_USER" -w DISPLAY,LD_PRELOAD,NSS_WRAPPER_PASSWD,NSS_WRAPPER_GROUP -c "$CMD"
else
    # Running as non-root user - use login shell directly
    # --login sources ~/.bash_profile for app-specific environment setup
    exec /bin/bash --login -c "$CMD"
fi
