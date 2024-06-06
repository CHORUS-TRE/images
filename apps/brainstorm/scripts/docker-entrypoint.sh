#!/bin/env bash

set -x

SCRIPT_PATH="/apps/$APP_NAME/scripts"

"$SCRIPT_PATH/create-user.sh" "$HIP_USER" "$APP_NAME"

#run $APP_NAME as $HIP_USER
exec "$SCRIPT_PATH/run-app.sh"
