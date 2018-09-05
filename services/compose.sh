#!/bin/bash
# Script to build and start services

# Define nodes in cluster
node1='192.168.1.100'
node2='192.168.1.101'

# Specify node this script is on
whoami="node1"

# Zookeeper needs to have at least 3 nodes specified above to cluster
zoo_cluster="false"

########################## DO NOT EDIT BELOW THIS LINE

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
read -e -p "Start services(yes/no): " -i "yes" start



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
# if [ ${node} -eq 1 ]; then
  # sed -i "/^.*RABBITMQ_CLUSTER_NODE_NAME.*$/d" $file
  # sed -i "s/^.*RABBITMQ_NODE_TYPE.*$/      - RABBITMQ_NODE_TYPE=stats/" $file
# else
  # sed -i "s/^.*RABBITMQ_CLUSTER_NODE_NAME.*$/      - RABBITMQ_CLUSTER_NODE_NAME=rabbitmq@rabbitmq1/" $file
  # sed -i "s/^.*RABBITMQ_NODE_TYPE.*$/      - RABBITMQ_NODE_TYPE=queue-disc/" $file
# fi
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

# Volumes
cat compose/volumes.yml >> $file

echo -e "\ndocker-compose.yml created"
if [ "$start" != "yes" ]; then
  exit
fi

# Function to wait for service ports
port() {
  service=$1
  port=$2
  attempts=$3
  i=1
  while [ $i -le $attempts ]; do
    nc -z localhost $port 
    if [ $? -ne 0 ]; then
      echo Waiting for $service on port $port: $i of $attempts
      state=1
      let i=i+1 
      sleep 15
    else
      state=0
      break 
    fi
  done
  return $state
}

# Bring up required kappa services
echo "Starting services ..."

# Start elasticsearch 
docker-compose up -d elasticsearch

# Start kibana
docker-compose up -d kibana

# Start rabbitmq
docker-compose up -d rabbitmq

# docker-compose exec rabbitmq rabbitmqctl stop_app
# docker-compose exec rabbitmq rabbitmqctl reset
# docker-compose exec rabbitmq rabbitmqctl start_app

# Wait for elasticsearch
port "elasticsearch" 9200 30
if [ $? -ne 0 ]; then
  echo "Error: ES cluster is not online"
  exit 1
fi

# Create filebeat pipeline
curl -s -XPUT 'localhost:9200/_ingest/pipeline/filebeat' --header "Content-Type: application/json" -T "filebeat/pipeline.json" | grep -q ack
if [ $? -ne 0 ]; then
  echo "Error: Unable to create filebeat pipeline"
  exit 1
fi

# Start filebeat
docker-compose up -d filebeat

# Start zookeeper if required
grep "image: zookeeper" docker-compose.yml > /dev/null
if [ $? -eq 0 ]; then
  docker-compose up -d zookeeper
  port "zookeeper" 2181 30
  if [ $? -ne 0 ]; then
    echo "Error: Unable to start zookeeper"
    exit 1
  fi
fi

# Wait for rabbitmq
port "rabbitmq" 5672 30
if [ $? -ne 0 ]; then
  echo "Error: Unable to start rabbitmq"
  exit 1
fi

# Start flower
docker-compose up -d flower

# Start Kafka
docker-compose up -d kafka

# Start Kafka Manager
docker-compose up -d kafka-manager

exit

### Start ingest workers daemons

cd ../src/ingest
echo Starting alphavantage worker
celery worker -D -A alphavantage --loglevel=info -f ../../logs/celery.log



