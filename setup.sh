#!/bin/bash
set -e

# Print header
echo "============================================"
echo "Kafka to Snowflake v3.1 with Protobuf Setup"
echo "============================================"

# Start Docker containers
echo "Step 1: Starting Docker containers..."
cd ..
docker-compose up -d
echo "Containers started successfully."

# Wait for services to start
echo "Step 2: Waiting for services to start (30 seconds)..."
sleep 30

# Create Kafka topic
echo "Step 3: Creating Kafka topic..."
cd scripts
chmod +x create_topic.sh
./create_topic.sh

# Register Protobuf schema
echo "Step 4: Registering Protobuf schema with Schema Registry..."
chmod +x register_schema.py
python3 register_schema.py

# Deploy Snowflake connector
echo "Step 5: Deploying Snowflake connector..."
chmod +x deploy_connector.sh
./deploy_connector.sh

# Success message
echo "Step 6: Setup complete!"
echo ""
echo "To produce test data, run: python3 produce_test_data.py"
echo "To check connector status: curl -s http://localhost:8083/connectors/snowflake-sink-connector/status"
echo "To view connector logs: docker logs connect"
echo ""
echo "Don't forget to run the Snowflake SQL setup script in your Snowflake workspace!"
chmod +x produce_test_data.py

cd ..
