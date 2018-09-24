#!/bin/bash

# Format namenode location if required
if [ -z "$(ls -A /opt/hadoop/data/name)" ]; then
  echo "Formatting namenode ..."
  /opt/hadoop/bin/hadoop namenode -format;
fi

/usr/bin/supervisord
