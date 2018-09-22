FROM openjdk:8u181-jdk-stretch
MAINTAINER John Richardson

RUN apt-get update 
RUN apt-get install -y curl unzip vim supervisor

# Hadoop
ENV HADOOP_VERSION 3.1.1
ENV HADOOP_HOME /opt/hadoop
ENV HADOOP_INSTALL=$HADOOP_HOME
ENV HADOOP_MAPRED_HOME=$HADOOP_HOME
ENV HADOOP_COMMON_HOME=$HADOOP_HOME
ENV HADOOP_HDFS_HOME=$HADOOP_HOME
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin
ENV YARN_HOME=$HADOOP_HOME
ENV HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
ENV PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
ENV JAVA_LIBRARY_PATH=${HADOOP_HOME}/lib/native/
ENV LD_LIBRARY_PATH=${HADOOP_HOME}/lib/native

RUN curl -sL --retry 3 \
  "http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
  | gunzip \
  | tar -x -C /opt

RUN mv /opt/hadoop-${HADOOP_VERSION} /opt/hadoop
RUN rm -rf $HADOOP_HOME/share/doc
RUN chown -R root:root $HADOOP_HOME
RUN mkdir -p ${HADOOP_HOME}/data/name
RUN mkdir -p ${HADOOP_HOME}/data/data

ENV HDFS_NAMENODE_USER root
ENV HDFS_DATANODE_USER root
ENV HDFS_SECONDARYNAMENODE_USER root
ENV YARN_RESOURCEMANAGER_USER root
ENV YARN_NODEMANAGER_USER root

CMD ["/usr/bin/supervisord"]

