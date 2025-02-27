 #!/bin/bash
set -e

echo "Creating Kafka topic 'topic1'..."
docker exec -it kafka kafka-topics --create \
    --topic topic1 \
    --bootstrap-server localhost:9092 \
    --partitions 3 \
    --replication-factor 1 \
    --config cleanup.policy=compact \
    --config retention.ms=604800000

echo "Topic created successfully."

# List topics to verify
echo "Listing Kafka topics:"
docker exec -it kafka kafka-topics --list --bootstrap-server localhost:9092
