#!/bin/bash
set -e

# Deploy Snowflake Kafka connector
echo "Deploying Snowflake Kafka connector..."
curl -X POST -H "Content-Type: application/json" \
     --data @../config/snowflake-connector-config.json \
     http://localhost:8083/connectors

echo "Connector deployed successfully."

# Check connector status
echo "Checking connector status:"
curl -s http://localhost:8083/connectors/snowflake-sink-connector/status
