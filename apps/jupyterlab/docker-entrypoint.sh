#!/bin/sh

HIP_USER=hip

APP_CMD_PREFIX="export DISPLAY=${DISPLAY}; ${APP_CMD_PREFIX}"
APP_CMD_PREFIX="export DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS}; ${APP_CMD_PREFIX}"
CMD="$APP_CMD_PREFIX; $APP_CMD"

useradd --create-home --shell /bin/bash $HIP_USER --uid 1000

exec runuser -l $HIP_USER -c "${CMD}"
