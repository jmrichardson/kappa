
# Create kafka topics
docker-compose exec kafka /opt/bitnami/kafka/bin/kafka-topics.sh --delete --zookeeper localhost:2181 --topic daily_alphavantage
docker-compose exec kafka /opt/bitnami/kafka/bin/kafka-topics.sh --create --zookeeper localhost:2181 --topic daily_alphavantage --partitions 4 --replication-factor 2

