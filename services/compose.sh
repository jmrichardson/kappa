# Script to dynamically build docker-compose.yml

### USER DEFINED VARIABLES
node1='192.168.1.100'
# node2='192.168.1.101'
whoami="node1"
### END USER DEFINED VARIABLES

# Node number
node=`echo -n $whoami | tail -c 1`

# Docker compose file
file='docker-compose.yml'

# Create file
cat <<DOC > $file
# DON'T MODIFY THIS FILE MANUALLY
version: '3.4'
services:
DOC

#--------- Elastic Search
edit1="      - node1:192.168.1.100"
sed "s/.*EDIT1.*/${edit1}/" compose/elasticsearch.yml >> $file

#--------- Kibana
cat compose/kibana.yml >> $file

#--------- Filebeat
cat compose/filebeat.yml >> $file

#--------- Rabbitmq
rabbit="compose/rabbitmq.yml"
if [ -v node2 ]; then
  edit1="      - RABBITMQ_CLUSTER_NODE_NAME=rabbitmq1@rabbitmq1"
  sed "s/.*EDIT1.*/${edit1}/" $rabbit >> $file
else
  sed "/.*EDIT1.*/d" $rabbit >> $file
fi

edit2="      - RABBITMQ_NODE_NAME=rabbitmq${node}@rabbitmq${node}"
sed -i "s/.*EDIT2.*/${edit2}/" $file

if [ $node -eq 1 ]; then
  edit3="      - RABBITMQ_NODE_TYPE=stats"
  sed -i "s/.*EDIT3.*/${edit3}/" $file
else
  edit3="      - RABBITMQ_NODE_TYPE=queue-disc"
  sed -i "s/.*EDIT3.*/${edit3}/" $file
fi

( set -o posix ; set ) | grep "^node[0-9]" | sed "s/node/      - \"rabbitmq/" | sed "s/=/:/" | sed 's/$/"/' >> $file

#--------- Flower
cat compose/flower.yml >> $file

#--------- Zookeeper
edit1="      - ZOO_SERVER_ID=${node}"
sed "s/.*EDIT1.*/${edit1}/" compose/zookeeper.yml >> $file

edit2=`( set -o posix ; set ) | grep "^node[0-9]" | sed "s/node/server./" | sed "s/$/:2888:3888/" | paste -s -d","`
sed -i "s/.*EDIT2.*/      - ZOO_SERVERS=${edit2}/" $file




#--------- Kafka
edit1="      - KAFKA_BROKER_ID=${node}"
sed "s/.*EDIT1.*/${edit1}/" compose/kafka.yml >> $file

edit2=`( set -o posix ; set ) | grep "^node[0-9]" | sed "s/node.*=//" | sed "s/$/:2181/" | paste -s -d","`
sed -i "s/.*EDIT2.*/      - KAFKA_ZOOKEEPER_CONNECT=${edit2}/" $file

edit3="kafka:${node1}"
sed -i "s/.*EDIT3.*/      - \"${edit3}\"/" $file

#--------- Kafka-manager
cat compose/kafka-manager.yml >> $file


#--------- Volumes
cat compose/volumes.yml >> $file

