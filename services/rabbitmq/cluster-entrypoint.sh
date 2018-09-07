#!/bin/bash
set -e
if [ `hostname` != "rabbitmq1" ]; then
  /usr/local/bin/docker-entrypoint.sh rabbitmq-server -detached
  rabbitmqctl stop_app
  rabbitmqctl join_cluster rabbit@rabbitmq1
  rabbitmqctl stop
  sleep 5s
fi
rabbitmq-server
