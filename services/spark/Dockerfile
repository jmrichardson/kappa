FROM hive
MAINTAINER John Richardson

WORKDIR opt

# Spark
ENV SPARK_VERSION 2.3.1
ENV SPARK_HOME /opt/spark
ENV SPARK_PACKAGE spark-$SPARK_VERSION-bin-hadoop2.7
ENV SPARK_DIST_CLASSPATH="$HADOOP_HOME/etc/hadoop/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/tools/lib/*"
ENV PATH $PATH:${SPARK_HOME}/bin

RUN curl -sL --retry 3 http://apache.mirrors.tds.net/spark/spark-2.3.1/${SPARK_PACKAGE}.tgz | gunzip | tar -x -C /opt
RUN mv $SPARK_PACKAGE $SPARK_HOME 
RUN chown -R root:root $SPARK_HOME

# Python3
# RUN apt-get install -y python3.6 python3-setuptools 
# RUN rm /usr/bin/python
# RUN ln -s /usr/bin/python3 /usr/bin/python

CMD ["$SPARK_HOME/sbin/start-master.sh"]
