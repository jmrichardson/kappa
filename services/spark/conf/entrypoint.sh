#!/bin/sh
echo "Starting Spark Master and Slave ..."
sbin/start-master.sh & sleep 2 & sbin/start-slave.sh spark://spark1:7077
