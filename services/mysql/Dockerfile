FROM mysql

RUN apt-get update 
RUN apt-get install -y curl unzip
RUN apt-get install -y vim

RUN echo "create database metastore" | mysql -uroot -proot
RUN mysql -uroot -proot --database=metastore < /tmp/hive-schema-3.1.0.mysql.sql
