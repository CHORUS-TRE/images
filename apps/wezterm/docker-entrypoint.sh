#!/bin/sh
set -xeu

# Perform any command changes here (at your own risk)
CMD="$@"

exec tini -- runuser -l ${XPRA_USER} -c "$ENV $CMD"
