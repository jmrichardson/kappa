# Script to dynamically build docker-compose.yml

### USER DEFINED VARIABLES

# Define nodes in cluster
node1='192.168.1.100'
node2='192.168.1.101'

# Specify node this script is on
whoami="node2"

# Zookeeper needs to have at least 3 nodes specified above to cluster
zoo_cluster="false"

### END USER DEFINED VARIABLES

# Node number
node=`echo -n $whoami | tail -c 1`

node_count=`( set -o posix ; set ) | grep "^node[0-9]" | cut -d= -f2 | sort | uniq | wc -l`

# ifconfig -a | grep ${!whoami} > /dev/null
# if [ $? -ne 0 ]; then
  # echo "Error: whoami ip address is not configured on this host"
  # exit 2
# fi



if [ $((node_count%2)) -eq 0 -a ${zoo_cluster} = "true" ]; then
  echo "Error: Must have >=3 and odd number of nodes to create zoo cluster"
  exit 1
fi

# Docker compose file
file='docker-compose.yml'

# Create file
cat <<DOC > $file
# DON'T MODIFY THIS FILE MANUALLY
version: '3.4'
services:
DOC



#--------- Elastic Search
cat compose/elasticsearch.yml >> $file
echo "      - node1:${node1}" >> $file



#--------- Kibana
cat compose/kibana.yml >> $file



#--------- Filebeat
cat compose/filebeat.yml >> $file



#--------- Rabbitmq
rabbit="compose/rabbitmq.yml"
if [ -v node2 ]; then
  sed "s/^.*RABBITMQ_CLUSTER_NODE_NAME.*$/      - RABBITMQ_CLUSTER_NODE_NAME=rabbitmq1@rabbitmq1/" $rabbit >> $file
else
  sed "/^.*RABBITMQ_CLUSTER_NODE_NAME.*$/d" $rabbit >> $file
fi
sed -i "s/^.*RABBITMQ_NODE_NAME.*$/      - RABBITMQ_NODE_NAME=rabbitmq${node}@rabbitmq${node}/" $file
if [ $node -eq 1 ]; then
  sed -i "s/^.*RABBITMQ_NODE_TYPE.*$/      - RABBITMQ_NODE_TYPE=stats/" $file
else
  sed -i "s/^.*RABBITMQ_NODE_TYPE.*$/      - RABBITMQ_NODE_TYPE=queue-disc/" $file
fi
( set -o posix ; set ) | grep "^node[0-9]" | sed "s/node/      - \"rabbitmq/" | sed "s/=/:/" | sed 's/$/"/' >> $file



#--------- Flower
cat compose/flower.yml >> $file



#--------- Zookeeper
if [ ${zoo_cluster} = "true" ]; then
  sed "s/^.*ZOO_MY_ID.*$/      - ZOO_MY_ID=${node}/" compose/zookeeper.yml >> $file
  servers=`( set -o posix ; set ) | grep "^node[0-9]" | sed "s/node/server./" | sed "s/$/:2888:3888;2181/" | paste -s -d" "`
  sed -i "s/^.*ZOO_SERVERS=.*$/      - ZOO_SERVERS=${servers}/" $file
elif [ ${whoami} = "node1" ]; then
  sed "s/^.*ZOO_MY_ID.*$/      - ZOO_MY_ID=${node}/" compose/zookeeper.yml >> $file
  sed -i "/ZOO_SERVERS/d" $file
fi



#--------- Kafka
sed "s/^.*KAFKA_BROKER_ID.*$/      - KAFKA_BROKER_ID=${node}/" compose/kafka.yml >> $file
if [ ${zoo_cluster} = "true" ]; then
  servers=`( set -o posix ; set ) | grep "^node[0-9]" | sed "s/node.*=//" | sed "s/$/:2181/" | paste -s -d","`
  sed -i "s/^.*KAFKA_ZOOKEEPER_CONNECT.*$/      - KAFKA_ZOOKEEPER_CONNECT=${servers}/" $file
else
  sed -i "s/^.*KAFKA_ZOOKEEPER_CONNECT.*$/      - KAFKA_ZOOKEEPER_CONNECT=${node1}:2181/" $file
fi
sed -i "s/^.*kafka:192.168.1.100.*$/      - \"kafka:${node1}\"/" $file



#--------- Kafka-manager
cat compose/kafka-manager.yml >> $file



#--------- Volumes
cat compose/volumes.yml >> $file

