FROM spark
MAINTAINER John Richardson

RUN useradd -r -m -s /bin/bash nifi && useradd -r -m -s /bin/bash kylo && useradd -r -m -s /bin/bash activemq

RUN apt update && apt upgrade
RUN apt install -y wget default-jre vim curl unzip

ENV JAVA_HOME /usr/lib/jvm/default-java

WORKDIR /opt
 
RUN wget -O kylo.deb http://bit.ly/2KDzKfc
RUN dpkg -i kylo.deb
RUN rm -f kylo.deb

WORKDIR /opt/kylo
 
ENV SETUP_DIR /opt/kylo/setup
ENV KYLO_HOME /opt/kylo
 
# Remove JAVA_HOME references
RUN $SETUP_DIR/java/remove-default-kylo-java-home.sh $KYLO_HOME
RUN $SETUP_DIR/java/change-kylo-java-home.sh $JAVA_HOME $KYLO_HOME
 
# Install java cryptographic extensions
RUN $SETUP_DIR/java/install-java-crypt-ext.sh $JAVA_HOME
 
# Create elastic indexes
# RUN /opt/kylo/bin/create-kylo-indexes-es.sh node1 9200 1 1

# ActiveMQ
RUN $SETUP_DIR/activemq/install-activemq.sh /opt/activemq activemq activemq $JAVA_HOME

# NiFi
RUN $SETUP_DIR/nifi/install-nifi.sh 1.6.0 /opt/nifi nifi nifi
RUN $SETUP_DIR/java/change-nifi-java-home.sh $JAVA_HOME /opt/nifi/current
RUN $SETUP_DIR/nifi/install-kylo-components.sh /opt/nifi /opt/kylo nifi nifi

# RUN mkdir /opt/nifi/ext-config
CMD bash
