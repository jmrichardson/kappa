docker container stop $(docker container ps -a | grep rabbit | awk '{print $1}')
docker container rm $(docker container ps -a | grep rabbit | awk '{print $1}')
docker volume rm services_rabbitmq
docker-compose up -d rabbitmq
docker-compose logs -f rabbitmq
