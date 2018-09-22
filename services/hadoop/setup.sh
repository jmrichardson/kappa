#!/bin/bash

# Format namenode location if required
if [ -z "$(ls -A /opt/hadoop/data/name)" ]; then
  /opt/hadoop/bin/hadoop namenode -format;
fi
