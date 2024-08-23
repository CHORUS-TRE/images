#!/bin/bash

set -e
trap 'echo "docker-entrypoint.sh : Error occurred on line $LINENO, exiting."; exit 1;' ERR

# Set default CHORUS_USER if not provided
if [ -z "$CHORUS_USER" ]; then
    echo "CHORUS_USER is not set. Defaulting to 'chorus'"
    export CHORUS_USER="chorus"
fi

# Check if /docker-entrypoint.d/ contains any files
if /usr/bin/find "/docker-entrypoint.d/" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read -r _; then
    echo "$0: /docker-entrypoint.d/ is not empty, will attempt to perform configuration"

    echo "$0: Looking for shell scripts in /docker-entrypoint.d/"
    find "/docker-entrypoint.d/" -follow -type f -print | sort -V | while IFS= read -r f; do
        case "$f" in
            *.envsh|*.sh)
                if [ -x "$f" ]; then
                    echo "$0: Executing $f";
                    "$f"
                else
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

# Add DISPLAY to APP_CMD_PREFIX
if [ -n "$APP_CMD_PREFIX" ]; then
    APP_CMD_PREFIX="export DISPLAY=$DISPLAY;$APP_CMD_PREFIX"
else
    APP_CMD_PREFIX="export DISPLAY=$DISPLAY"
fi

# Ensure CARD and APP_CMD are set
: "${CARD:?Environment variable CARD is required but not set}"
: "${APP_CMD:?Environment variable APP_CMD is required but not set}"

# Run $APP_NAME as $CHORUS_USER
echo -n "Running $APP_NAME as $CHORUS_USER "
case "$CARD" in
  "none")
    echo "on CPU... "
    #CMD="$APP_CMD_PREFIX; QT_DEBUG_PLUGINS=1 $APP_CMD"
    CMD="$APP_CMD_PREFIX; $APP_CMD"
    ;;
  *)
    echo "on GPU... "
    #CMD="$APP_CMD_PREFIX; vglrun -d /dev/dri/$CARD /opt/VirtualGL/bin/glxspheres64"
    #CMD="$APP_CMD_PREFIX; QT_DEBUG_PLUGINS=1 vglrun -d /dev/dri/$CARD $APP_CMD"
    CMD="$APP_CMD_PREFIX; vglrun -d /dev/dri/$CARD $APP_CMD"
    ;;
esac

runuser -l "$CHORUS_USER" -c "$CMD"
retVal=$?
exit $retVal
