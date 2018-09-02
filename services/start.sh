
# Function to wait for service ports
port() {
  port=$1
  attempts=$2
  i=1
  while [ $i -le $attempts ]; do
    nc -z localhost $port 
    if [ $? -ne 0 ]; then
      echo Waiting for locahost:$port: $i of $attempts
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


### Start docker containers

# Bring up required kappa services
echo "Starting services ..."

# Start elasticsearch cluster
docker-compose up -d elasticsearch

# Start elasticsearch cluster
docker-compose up -d kibana

# Start elasticsearch cluster
docker-compose up -d rabbitmq

# docker-compose exec rabbitmq rabbitmqctl stop_app
# docker-compose exec rabbitmq rabbitmqctl reset
# docker-compose exec rabbitmq rabbitmqctl start_app

# Start filebeat service
port 9200 30
if [ $? -ne 0 ]; then
  echo "Error: ES cluster is not online"
  exit 1
fi
curl -s -XPUT 'localhost:9200/_ingest/pipeline/filebeat' --header "Content-Type: application/json" -T "filebeat/pipeline.json" | grep -q ack
if [ $? -ne 0 ]; then
  echo "Error: Unable to create filebeat pipeline"
  exit 1
fi
docker-compose up -d filebeat


# Start flower
port 5672 30
if [ $? -ne 0 ]; then
  echo "Error: Unable to start rabbitmq"
  exit 1
fi
docker-compose up -d flower


# Start zookeeper
grep "zookeeper:" docker-compose.yml > /dev/null
if [ $? -eq 0 ]; then
  docker-compose up -d zookeeper
  port 2181 30
  if [ $? -ne 0 ]; then
    echo "Error: Unable to start zookeeper"
    exit 1
  fi
fi


# Start Kafka
docker-compose up -d kafka


docker-compose up -d kafka-manager

exit

### Start ingest workers daemons

cd ../src/ingest
echo Starting alphavantage worker
celery worker -D -A alphavantage --loglevel=info -f ../../logs/celery.log



