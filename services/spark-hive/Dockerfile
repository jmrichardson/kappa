FROM hadoop
MAINTAINER John Richardson

# Environment
ENV HIVE_VERSION 3.1.0
ENV HIVE_HOME /opt/hive
ENV HIVE_CONF_DIR=/opt/hive/conf
ENV PATH $HIVE_HOME/bin:$PATH
ENV CLASSPATH=$CLASSPATH:${HIVE_HOME}/lib/*:.
ENV SPARK_VERSION 2.3.2
ENV SPARK_HOME /opt/spark
ENV SPARK_PACKAGE spark-$SPARK_VERSION
ENV PATH $PATH:${SPARK_HOME}/bin

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


# Spark
RUN curl -sL "https://archive.apache.org/dist/spark/$SPARK_PACKAGE/${SPARK_PACKAGE}.tgz" \
  | gunzip \
  | tar -x -C /opt && mv $SPARK_PACKAGE spark
RUN /opt/spark/dev/make-distribution.sh --name "hadoop2-without-hive" --tgz "-Pyarn,hadoop-provided,hadoop-2.7,parquet-provided,orc-provided"

RUN ln -s /opt/spark/dist/jars/spark-network-common_2.11-2.3.2.jar /opt/hive/lib/spark-network-common_2.11-2.3.2.jar
RUN ln -s /opt/spark/dist/jars/spark-core_2.11-2.3.2.jar /opt/hive/lib/spark-core_2.11-2.3.2.jar
RUN ln -s /opt/spark/dist/scala-library-2.11.8.jar /opt/hive/lib/scala-library-2.11.8.jar

