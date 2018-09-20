FROM hadoop-common
MAINTAINER John Richardson

# Initialize if required and start namenode
CMD sh -c 'if [ -z "$(ls -A /opt/hadoop/data/name)" ]; then \
       ${HADOOP_HOME}/bin/hadoop namenode -format; \
    fi' \
    && ${HADOOP_HOME}/bin/hdfs --config ${HADOOP_CONF_DIR} namenode
