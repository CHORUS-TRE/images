#!/bin/sh

rm -rf /run/httpd/* /tmp/httpd*
sh /prescript.sh "$APP_ID"

exec /usr/sbin/apachectl -DFOREGROUND
