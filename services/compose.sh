#!/bin/bash

# Set working directory
homeDir=~/kappa/services
[ ! -d ${homeDir} ] && echo "Error: Unable to cd to home directory" && exit
cd ${homeDir}

# Get environment variables
source env.sh

for ip in `( set -o posix ; set ) | grep "^node[0-9]" | cut -d= -f2`
do
  ifconfig | grep $ip > /dev/null
  if [ $? -eq 0 ]; then
    whoami=`grep $ip env.sh | cut -d= -f1`
  fi
done
if [ -z "$whoami" ]; then
  echo "Error: Unable to detect IP address (check env.sh)"
  exit 1
fi

# My node number
node=`echo -n $whoami | tail -c 1`

# Number of nodes defined
node_count=`( set -o posix ; set ) | grep "^node[0-9]" | cut -d= -f2 | sort | uniq | wc -l`

# Make sure my ip address is configured
ifconfig -a | grep ${!whoami} > /dev/null
if [ $? -ne 0 ]; then
  echo "Error: whoami ip address is not configured on this host. Verify env.sh"
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

# Host entries
echo "    extra_hosts:" > yml/hosts.yml
( set -o posix ; set ) | grep "^node[0-9]" |  sed "s/^/      - \"/" | sed "s/=/:/" | sed 's/$/"/' >> yml/hosts.yml

# Docker compose file location
file='docker-compose.yml'

# Create docker-compose file
cat <<DOC > $file
# DON'T MODIFY THIS FILE MANUALLY
version: '3.4'
services:
DOC

# Elastic Search
sed "s/hostname: .*/hostname: node${node}/" yml/elasticsearch.yml >> $file
cat yml/hosts.yml >> $file

# Kibana
sed "s/hostname: .*/hostname: node${node}/" yml/kibana.yml >> $file
cat yml/hosts.yml >> $file

# Filebeat
### sed "s/hostname: .*/hostname: node${node}/" yml/filebeat.yml >> $file
### cat yml/hosts.yml >> $file

# Rabbitmq
### sed "s/hostname: .*/hostname: node${node}/" yml/rabbitmq.yml >> $file
### cat yml/hosts.yml >> $file

# Flower
### sed "s/hostname: .*/hostname: node${node}/" yml/flower.yml >> $file
### cat yml/hosts.yml >> $file

# Zookeeper
if [ ${zoo_cluster} = "true" ]; then
  sed "s/hostname: .*/hostname: node${node}/" yml/zookeeper.yml >> $file
  sed -i "s/^.*ZOO_MY_ID.*$/      - ZOO_MY_ID=${node}/" $file
  sed -i "s/^.*ZOO_SERVERS=.*$/      - ZOO_SERVERS=${servers}/" $file
  cat yml/hosts.yml >> $file
elif [ ${whoami} = "node1" ]; then
  sed "s/hostname: .*/hostname: node${node}/" yml/zookeeper.yml >> $file
  sed -i "s/^.*ZOO_MY_ID.*$/      - ZOO_MY_ID=${node}/" $file
  sed -i "/ZOO_SERVERS/d" $file
  cat yml/hosts.yml >> $file
fi

# Kafka
### sed "s/hostname: .*/hostname: node${node}/" yml/kafka.yml >> $file
### sed -i "s/^.*KAFKA_BROKER_ID.*$/      - KAFKA_BROKER_ID=${node}/" $file
### if [ ${zoo_cluster} = "true" ]; then
  ### sed -i "s/^.*KAFKA_ZOOKEEPER_CONNECT.*$/      - KAFKA_ZOOKEEPER_CONNECT=${servers}/" $file
### else
  ### sed -i "s/^.*KAFKA_ZOOKEEPER_CONNECT.*$/      - KAFKA_ZOOKEEPER_CONNECT=node1:2181/" $file
### fi
### if [ $node -ne 1 ]; then
  ### sed -i -e '/depends_on:/,+1d' $file
### fi
### cat yml/hosts.yml >> $file
### 
### # Kafka-manager
### sed "s/hostname: .*/hostname: node${node}/" yml/kafka-manager.yml >> $file
### sed -i "s/^.*ZK_HOSTS=localhost:2181.*$/      - ZK_HOSTS=node1:2181/" $file

# Monit
### sed "s/hostname: .*/hostname: node${node}/" yml/monit.yml >> $file
### cat yml/hosts.yml >> $file



# NFS 
if [ $node -eq 1 ]; then
  sed "s/hostname: .*/hostname: node1/" yml/nfs.yml >> $file
  cat yml/hosts.yml >> $file
fi

# Hadoop
if [ $node -eq 1 ]; then
  cat yml/hadoop.yml >> $file
  cat yml/hadoop-volumes.yml >> $file
  cat yml/hosts.yml >> $file
  sed "s/hostname: .*/hostname: node${node}/" yml/hive.yml >> $file
  cat yml/hadoop-volumes.yml >> $file
  cat yml/hosts.yml >> $file
  sed "s/hostname: .*/hostname: node${node}/" yml/hue.yml >> $file
  cat yml/hadoop-volumes.yml >> $file
  cat yml/hosts.yml >> $file
else
  cat yml/hadoop.yml >> $file
  sed "s/hostname: .*/hostname: node${node}/" yml/hadoop-datanode.yml >> $file
  cat yml/hosts.yml >> $file
fi



# Spark
sed "s/hostname: .*/hostname: node${node}/" yml/spark.yml >> $file
if [ $node -ne 1 ]; then
  echo "    command: sbin/start-slave.sh spark://node1:7077" >> $file
else
  echo "    entrypoint: /conf/entrypoint.sh" >> $file
fi
cat yml/hosts.yml >> $file


# Kylo
if [ $node -eq 1 ]; then
  sed "s/hostname: .*/hostname: node1/" yml/kylo.yml >> $file
  cat yml/hosts.yml >> $file
fi


# Jupyter
### if [ $node -eq 1 ]; then
  ### sed "s/hostname: .*/hostname: node1/" yml/jupyter.yml >> $file
  ### cat yml/hosts.yml >> $file
### fi


# ActiveMQ
if [ $node -eq 1 ]; then
  sed "s/hostname: .*/hostname: node1/" yml/activemq.yml >> $file
  cat yml/hosts.yml >> $file
fi

# Nifi
if [ $node -eq 1 ]; then
  sed "s/hostname: .*/hostname: node1/" yml/nifi.yml >> $file
  cat yml/hosts.yml >> $file
fi

# Mysql
if [ $node -eq 1 ]; then
  sed "s/hostname: .*/hostname: node1/" yml/mysql.yml >> $file
  cat yml/hosts.yml >> $file
fi

# Volumes
cat yml/volumes.yml >> $file

echo -e "\ndocker-compose.yml created"
