#!/bin/sh

cat /conftemp/etc/httpd/conf.d/i2b2_proxy.conf | sed -e s/9090/8080/ > /etc/httpd/conf.d/i2b2_proxy.conf
rm /etc/httpd/conf.d/ssl.conf
