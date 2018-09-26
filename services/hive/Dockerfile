FROM hadoop
MAINTAINER John Richardson

WORKDIR /opt

# Hive
RUN wget https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz && \
      tar -xzvf apache-hive-$HIVE_VERSION-bin.tar.gz && \
      mv apache-hive-$HIVE_VERSION-bin hive
RUN rm -f apache-hive-$HIVE_VERSION-bin.tar.gz

# Mariadb
# RUN wget https://downloads.mariadb.org/interstitial/mariadb-${MARIADB_VERSION}/source/mariadb-${MARIADB_VERSION}.tar.gz && 
# RUN tar -xzvf mariadb-${MARIADB_VERSION}.tar.gz 
# RUN mv mariadb-${MARIADB_VERSION} mariadb

# Mysql java connector
RUN wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java_8.0.12-1debian9_all.deb
RUN dpkg -i mysql-connector-java_8.0.12-1debian9_all.deb
RUN ln -s /usr/share/java/mysql-connector-java-8.0.12.jar  $HIVE_HOME/lib/mysql-connector-java.jar
RUN rm mysql-connector-java_8.0.12-1debian9_all.deb

CMD hiveserver2 --hiveconf hive.server2.enable.doAs=false --hiveconf hive.root.logger=INFO,console
# CMD hiveserver2 --hiveconf hive.server2.enable.doAs=false

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
