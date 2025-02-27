#!/bin/bash
set -e

# Wait for Kafka Connect to be available
echo "Waiting for Kafka Connect to be available..."
MAX_ATTEMPTS=30
ATTEMPTS=0

while [[ $ATTEMPTS -lt $MAX_ATTEMPTS ]]; do
    if curl -s http://localhost:8083/ > /dev/null; then
        echo "Kafka Connect is available!"
        break
    fi
    
    ATTEMPTS=$((ATTEMPTS+1))
    echo "Waiting for Kafka Connect to be available... Attempt ${ATTEMPTS}/${MAX_ATTEMPTS}"
    sleep 5
done

if [[ $ATTEMPTS -eq $MAX_ATTEMPTS ]]; then
    echo "Kafka Connect not available after ${MAX_ATTEMPTS} attempts. Exiting."
    exit 1
fi

# Deploy Snowflake Kafka connector
echo "Deploying Snowflake Kafka connector..."
curl -X POST -H "Content-Type: application/json" \
     -v --data @../config/snowflake-connector-config.json \
     http://localhost:8083/connectors

echo "Connector deployed successfully."

# Check connector status
echo "Checking connector status:"
curl -s http://localhost:8083/connectors/snowflake-sink-connector/status
