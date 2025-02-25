#!/bin/bash

# Wait for Zookeeper to start
sleep 10

# Check if the Kafka topic exists, and create it if it doesn't
TOPIC_NAME=topic1
EXISTING_TOPIC=$(/opt/bitnami/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092 | grep -w $TOPIC_NAME)

if [ -z "$EXISTING_TOPIC" ]; then
  /opt/bitnami/kafka/bin/kafka-topics.sh --create --topic $TOPIC_NAME --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1
else
  echo "Topic $TOPIC_NAME already exists"
fi

# Start Kafka Connect
exec connect-standalone.sh /opt/bitnami/kafka/config/connect-standalone.properties /opt/bitnami/kafka/config/SF_connect.properties
