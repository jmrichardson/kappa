#!/bin/sh
echo "Starting Monit service ..."
cp -r /tmp/monit /etc
chown root:root /etc/monit/monitrc
chmod 0700 /etc/monit/monitrc
[ -f /var/run/monit.pid ] && rm -f /var/run/monit.pid
monit -I -c /etc/monitrc
