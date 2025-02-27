#!/bin/bash
KEY=$(awk 'NF {sub(/\r/, ""); printf "%s\\\\n",$0;}' keys/rsa_key.pem)

cat > config/snowflake-connector-config.json << EOF
{
  "name": "snowflake-sink-connector",
  "config": {
    "connector.class": "com.snowflake.kafka.connector.SnowflakeSinkConnector",
    "tasks.max": "8",
    "topics": "topic1",
    "snowflake.topic2table.map": "topic1:kafka_table1",
    "snowflake.url.name": "mr14846.east-us-2.azure.snowflakecomputing.com",
    "snowflake.user.name": "TEST_USER",
    "snowflake.private.key": "${KEY}",
    "snowflake.database.name": "KAFKA_TO_SF",
    "snowflake.schema.name": "NEWKAFKA",
    "snowflake.role.name": "KAFKA_TO_SF_POC_ROLE",
    "key.converter": "io.confluent.connect.protobuf.ProtobufConverter",
    "key.converter.schema.registry.url": "http://schema-registry:8081",
    "value.converter": "io.confluent.connect.protobuf.ProtobufConverter",
    "value.converter.schema.registry.url": "http://schema-registry:8081",
    "snowflake.ingestion.method": "SNOWPIPE_STREAMING",
    "snowflake.enable.schematization": "true", 
    "snowflake.schema.evolution": "true",
    "snowflake.flatten.json": "false",
    "errors.tolerance": "all",
    "errors.log.enable": "true"
  }
}
EOF

echo "Configuration file created successfully."
