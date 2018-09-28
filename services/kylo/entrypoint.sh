#!/bin/bash

# Need to make sure elastic and mysql and spark are up... 
# Do that here

# Create Elasticsearch Indexes
/opt/kylo/bin/create-kylo-indexes-es.sh node1 9200 1 1

# Start Activemq
service activemq start

# Start Nifi
service nifi start

# Start Kylo services
kylo-service start

# Wait for log file to be generated
while true; do
  if [ -f /var/log/kylo-services/kylo-services.log ]; then
    break
  else
    echo "Waiting for Kylo service log file to be created ..."
    sleep 2
  fi
done

# Tail log file and import templates on successful start
tail -f /var/log/kylo-services/kylo-services.log | while read line; do
  # echo $line | grep "Successfully built the NiFiFlowCache" >/dev/null
  echo $line | grep "Started KyloServerApplication in" >/dev/null
  if [ $? -eq 0 ]; then
    echo $line
    echo "Importing templates ..."
    /opt/kylo/setup/data/install-templates-locally.sh
    echo "Finished importing templates"
  else
    echo $line
  fi
done


