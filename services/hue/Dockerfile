FROM hadoop
MAINTAINER John Richardson

WORKDIR /opt

RUN apt-get install -y ant gcc g++ libkrb5-dev default-libmysqlclient-dev libssl-dev libsasl2-dev libsasl2-modules-gssapi-mit libsqlite3-dev libtidy-dev libxml2-dev libxslt-dev make libldap2-dev maven python-dev python-setuptools libgmp3-dev libffi-dev python2.7-dev python-pip 
RUN ln -s /usr/lib/python2.7/plat-*/_sysconfigdata_nd.py /usr/lib/python2.7/

# Hue
RUN git clone https://github.com/cloudera/hue.git

WORKDIR /opt/hue
RUN make apps




