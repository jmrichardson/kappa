FROM hadoop-common
MAINTAINER John Richardson

ENV HIVE_VERSION 3.1.0
ENV MARIADB_VERSION 10.2.17
ENV HIVE_HOME /opt/hive
ENV HIVE_CONF_DIR=/opt/hive/conf
ENV PATH $HIVE_HOME/bin:$PATH
ENV CLASSPATH=$CLASSPATH:${HADOOP_HOME}/lib/*:.
ENV CLASSPATH=$CLASSPATH:${HIVE_HOME}/lib/*:.

WORKDIR /opt

# Hive
RUN wget https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz && \
      tar -xzvf apache-hive-$HIVE_VERSION-bin.tar.gz && \
      mv apache-hive-$HIVE_VERSION-bin hive

# Mariadb
# RUN wget https://downloads.mariadb.org/interstitial/mariadb-${MARIADB_VERSION}/source/mariadb-${MARIADB_VERSION}.tar.gz && 
# RUN tar -xzvf mariadb-${MARIADB_VERSION}.tar.gz 
# RUN mv mariadb-${MARIADB_VERSION} mariadb

# Mysql java connector
RUN apt-get install -y libmysql-java
RUN ln -s /usr/share/java/mysql-connector-java.jar $HIVE_HOME/lib/mysql-connector-java.jar


#Spark should be compiled with Hive to be able to use it
#hive-site.xml should be copied to $SPARK_HOME/conf folder

#Custom configuration goes here
# ADD conf/hive-site.xml $HIVE_HOME/conf
# ADD conf/beeline-log4j2.properties $HIVE_HOME/conf
# ADD conf/hive-env.sh $HIVE_HOME/conf
# ADD conf/hive-exec-log4j2.properties $HIVE_HOME/conf
# ADD conf/hive-log4j2.properties $HIVE_HOME/conf
# ADD conf/ivysettings.xml $HIVE_HOME/conf
# ADD conf/llap-daemon-log4j2.properties $HIVE_HOME/conf

# COPY startup.sh /usr/local/bin/
# RUN chmod +x /usr/local/bin/startup.sh

# COPY entrypoint.sh /usr/local/bin/
# RUN chmod +x /usr/local/bin/entrypoint.sh

# EXPOSE 10000
# EXPOSE 10002

# ENTRYPOINT ["entrypoint.sh"]
# CMD startup.sh
