FROM hadoop
MAINTAINER John Richardson

ENV HIVE_VERSION 3.1.0
ENV HIVE_HOME /opt/hive
ENV HIVE_CONF_DIR=/opt/hive/conf
ENV PATH $HIVE_HOME/bin:$PATH
ENV CLASSPATH=$CLASSPATH:${HIVE_HOME}/lib/*:.

WORKDIR /opt

# Hive
RUN wget https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz
RUN tar -xzvf apache-hive-$HIVE_VERSION-bin.tar.gz
RUN mv apache-hive-$HIVE_VERSION-bin hive
RUN rm -f apache-hive-$HIVE_VERSION-bin.tar.gz

# Mysql java connector
RUN wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java_8.0.12-1debian9_all.deb
RUN dpkg -i mysql-connector-java_8.0.12-1debian9_all.deb
RUN ln -s /usr/share/java/mysql-connector-java-8.0.12.jar  $HIVE_HOME/lib/mysql-connector-java.jar
RUN rm mysql-connector-java_8.0.12-1debian9_all.deb

CMD hiveserver2 --hiveconf hive.server2.enable.doAs=false --hiveconf hive.root.logger=INFO,console
# CMD hiveserver2 --hiveconf hive.server2.enable.doAs=false
