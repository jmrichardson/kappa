
# Create kafka-manager cluster
curl 'http://localhost:9000/clusters' -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' -H 'Origin: http://192.168.1.100:9000' -H 'Upgrade-Insecure-Requests: 1' -H 'Content-Type: application/x-www-form-urlencoded' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Referer: http://192.168.1.100:9000/addCluster' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.9' --data 'name=Kappa&zkHosts=localhost%3A2181&kafkaVersion=0.9.0.1&jmxUser=&jmxPass=&tuning.brokerViewUpdatePeriodSeconds=30&tuning.clusterManagerThreadPoolSize=2&tuning.clusterManagerThreadPoolQueueSize=100&tuning.kafkaCommandThreadPoolSize=2&tuning.kafkaCommandThreadPoolQueueSize=100&tuning.logkafkaCommandThreadPoolSize=2&tuning.logkafkaCommandThreadPoolQueueSize=100&tuning.logkafkaUpdatePeriodSeconds=30&tuning.partitionOffsetCacheTimeoutSecs=5&tuning.brokerViewThreadPoolSize=2&tuning.brokerViewThreadPoolQueueSize=1000&tuning.offsetCacheThreadPoolSize=2&tuning.offsetCacheThreadPoolQueueSize=1000&tuning.kafkaAdminClientThreadPoolSize=2&tuning.kafkaAdminClientThreadPoolQueueSize=1000' --compressed ; > /dev/null

# Create kafka topics
# docker-compose exec kafka /opt/bitnami/kafka/bin/kafka-topics.sh --delete --zookeeper localhost:2181 --topic daily_alphavantage
docker-compose exec kafka /opt/bitnami/kafka/bin/kafka-topics.sh --create --zookeeper localhost:2181 --topic daily_alphavantage --partitions 4 --replication-factor 2

celery -A alphavantage worker -D --loglevel INFO --pidfile /tmp/celeryAlphavantage.pid  --workdir /home/kappa/kappa/src/ingest/alphavantage
