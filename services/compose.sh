#!/bin/bash

# Set working directory
homeDir=~/kappa/services
[ ! -d ${homeDir} ] && echo "Error: Unable to cd to home directory" && exit
cd ${homeDir}

# Get environment variables
source env.sh

# My node number
node=`echo -n $whoami | tail -c 1`

# Number of nodes defined
node_count=`( set -o posix ; set ) | grep "^node[0-9]" | cut -d= -f2 | sort | uniq | wc -l`

# Make sure my ip address is configured
ifconfig -a | grep ${!whoami} > /dev/null
if [ $? -ne 0 ]; then
  echo "Error: whoami ip address is not configured on this host"
  exit 2
fi

# Make sure we have enough zoo keeper nodes if clusterd
if [ $((node_count%2)) -eq 0 -a ${zoo_cluster} = "true" ]; then
  echo "Error: Must have >=3 and odd number of nodes to create zoo cluster"
  exit 1
fi

echo -e "\nDefined nodes (* indicates this node):"
( set -o posix ; set ) | grep "^node[0-9]" | sed "s/\(^${whoami}.*\)/\1 */"
echo 

read -e -p "Create docker-compose.yml (yes/no): " -i "yes" create
if [ "${create}" != "yes" ]; then
  exit
fi


# Docker compose file location
file='docker-compose.yml'

# Create docker-compose file
cat <<DOC > $file
# DON'T MODIFY THIS FILE MANUALLY
version: '3.4'
services:
DOC

# Elastic Search
cat compose/elasticsearch.yml >> $file
echo "      - node1:${node1}" >> $file

# Kibana
cat compose/kibana.yml >> $file

# Filebeat
cat compose/filebeat.yml >> $file

# Rabbitmq
sed "s/hostname: rabbitmq/hostname: rabbitmq${node}/" compose/rabbitmq.yml >> $file
if [ ${node} -ne 1 ]; then
  echo "    volumes:" >> $file
  echo "      - ./rabbitmq/cluster-entrypoint.sh:/usr/local/bin/cluster-entrypoint.sh" >> $file
  echo "    entrypoint:" >> $file
  echo "      - sh" >> $file
  echo "      - /usr/local/bin/cluster-entrypoint.sh" >> $file
fi
sed -i "s/^.*RABBITMQ_NODE_NAME.*$/      - RABBITMQ_NODE_NAME=rabbitmq@rabbitmq${node}/" $file
echo "    extra_hosts:" >> $file
( set -o posix ; set ) | grep "^node[0-9]" | sed "s/node/      - \"rabbitmq/" | sed "s/=/:/" | sed 's/$/"/' >> $file

# Flower
cat compose/flower.yml >> $file

# Zookeeper
if [ ${zoo_cluster} = "true" ]; then
  sed "s/^.*ZOO_MY_ID.*$/      - ZOO_MY_ID=${node}/" compose/zookeeper.yml >> $file
  servers=`( set -o posix ; set ) | grep "^node[0-9]" | sed "s/node/server./" | sed "s/$/:2888:3888;2181/" | paste -s -d" "`
  sed -i "s/^.*ZOO_SERVERS=.*$/      - ZOO_SERVERS=${servers}/" $file
elif [ ${whoami} = "node1" ]; then
  sed "s/^.*ZOO_MY_ID.*$/      - ZOO_MY_ID=${node}/" compose/zookeeper.yml >> $file
  sed -i "/ZOO_SERVERS/d" $file
fi

# Kafka
sed "s/^.*KAFKA_BROKER_ID.*$/      - KAFKA_BROKER_ID=${node}/" compose/kafka.yml >> $file
sed -i "s/hostname: kafka/hostname: kafka${node}/" $file
if [ ${zoo_cluster} = "true" ]; then
  servers=`( set -o posix ; set ) | grep "^node[0-9]" | sed "s/node.*=//" | sed "s/$/:2181/" | paste -s -d","`
  sed -i "s/^.*KAFKA_ZOOKEEPER_CONNECT.*$/      - KAFKA_ZOOKEEPER_CONNECT=${servers}/" $file
else
  sed -i "s/^.*KAFKA_ZOOKEEPER_CONNECT.*$/      - KAFKA_ZOOKEEPER_CONNECT=${node1}:2181/" $file
fi
if [ $node -ne 1 ]; then
  sed -i -e '/depends_on:/,+1d' $file
fi
( set -o posix ; set ) | grep "^node[0-9]" | sed "s/node/      - \"kafka/" | sed "s/=/:/" | sed 's/$/"/' >> $file

# Kafka-manager
sed "s/^.*ZK_HOSTS=localhost:2181.*$/      - ZK_HOSTS=${node1}:2181/" compose/kafka-manager.yml >> $file
( set -o posix ; set ) | grep "^node[0-9]" | sed "s/node/      - \"kafka/" | sed "s/=/:/" | sed 's/$/"/' >> $file

# Volumes
cat compose/volumes.yml >> $file

echo -e "\ndocker-compose.yml created"
