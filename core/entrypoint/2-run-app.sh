#!/bin/bash

#export $APP_NAME specific environment variables to $CHORUS_USER .env file
while IFS='=' read -r -d '' k v; do
  if [[ "${k,,}" == ${APP_NAME}* ]]; then
    echo -n "Exporting ${k} for ${CHORUS_USER}... "
    echo "export ${k}=${v}" > /home/$CHORUS_USER/.env
    chown $CHORUS_USER:$CHORUS_USER /home/$CHORUS_USER/.env
    echo "done."
  fi
done < <(env -0)

#add DISPLAY to APP_PREFIX
if [ ! -z "${APP_CMD_PREFIX}" ]; then
  APP_CMD_PREFIX="export DISPLAY=$DISPLAY;$APP_CMD_PREFIX"
else
  APP_CMD_PREFIX="export DISPLAY=$DISPLAY"
fi

#run $APP_NAME as $CHORUS_USER
echo -n "Running $APP_NAME as $CHORUS_USER "
if [ $CARD == "none" ]; then
  echo "on CPU... "
  #CMD="$APP_CMD_PREFIX; QT_DEBUG_PLUGINS=1 $APP_CMD"
  CMD="$APP_CMD_PREFIX; $APP_CMD"
else
  echo "on GPU... "
  #CMD="$APP_CMD_PREFIX; vglrun -d /dev/dri/$CARD /opt/VirtualGL/bin/glxspheres64"
  #CMD="$APP_CMD_PREFIX; QT_DEBUG_PLUGINS=1 vglrun -d /dev/dri/$CARD $APP_CMD"
  CMD="$APP_CMD_PREFIX; vglrun -d /dev/dri/$CARD $APP_CMD"
fi

runuser -l $CHORUS_USER -c "$CMD &"
#runuser -l $CHORUS_USER -c 'sleep 1000000000000'

#wait until $APP_NAME has terminated
sleep 3
#ps ax
PID=`ps ax | grep "$PROCESS_NAME" | grep -v $0 | awk '{print $1}' | tr '\n' ' ' | awk '{print $1}'`
ps -p $PID > /dev/null
retVal=$?
if [ $retVal -eq 0 ]; then
  tail --pid=$PID -f /dev/null
fi
echo "$APP_NAME exited."
