#!/bin/bash
set -e

echo "Starting Kafka Connect in standalone mode..."

# Start Kafka Connect in standalone mode
docker exec -d connect connect-standalone /etc/kafka-connect/config/connect-standalone.properties /etc/kafka-connect/config/SF_connect.properties

echo "Connector started successfully in standalone mode."
