#!/bin/sh
set -xeu

# Fix permissions on the volume
chmod -R 1777 /tmp/.X11-unix

# Pass some environment variables down.
ENV="XPRA_PASSWORD=${XPRA_PASSWORD}"

# Perform any command changes here (at your own risk)
CMD="$@"

exec tini -- runuser -l ${XPRA_USER} -c "$ENV $CMD"
