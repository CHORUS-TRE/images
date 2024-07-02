#!/bin/sh

HIP_USER=hip

# Starting a DBUS
dbus-uuidgen > /var/lib/dbus/machine-id
mkdir -p /var/run/dbus
DBUS_SESSION_BUS_ADDRESS="$(dbus-daemon --config-file=/usr/share/dbus-1/system.conf --print-address)"

APP_CMD_PREFIX="export DISPLAY=${DISPLAY}; ${APP_CMD_PREFIX}"
APP_CMD_PREFIX="export DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS}; ${APP_CMD_PREFIX}"
CMD="$APP_CMD_PREFIX; $APP_CMD"

useradd --create-home --shell /bin/bash $HIP_USER --uid 1000

exec runuser -l $HIP_USER -c "${CMD}"
