#!/bin/bash
set -e

# First, create the standalone properties file if it doesn't exist
cat > ../config/connect-standalone.properties << EOF
bootstrap.servers=kafka:29092
key.converter=io.confluent.connect.protobuf.ProtobufConverter
key.converter.schema.registry.url=http://schema-registry:8081
value.converter=io.confluent.connect.protobuf.ProtobufConverter
value.converter.schema.registry.url=http://schema-registry:8081
internal.key.converter=org.apache.kafka.connect.json.JsonConverter
internal.value.converter=org.apache.kafka.connect.json.JsonConverter
internal.key.converter.schemas.enable=false
internal.value.converter.schemas.enable=false
offset.storage.file.filename=/tmp/connect.offsets
offset.flush.interval.ms=10000
plugin.path=/usr/share/java,/usr/share/confluent-hub-components,/connectors
EOF

# Extract and format the private key correctly (single-line format without headers)
KEY=$(grep -v "KEY\|CERT" keys/private-key.pem | awk 'NF {sub(/\r/, ""); printf "%s",$0;}')

# Then create the Snowflake connector properties file
cat > ../config/SF_connect.properties << EOF
name=snowflake-sink-connector
connector.class=com.snowflake.kafka.connector.SnowflakeSinkConnector
tasks.max=8
topics=topic1
snowflake.topic2table.map=topic1:kafka_table1

# Snowflake connection settings
snowflake.url.name=mr14846.east-us-2.azure.snowflakecomputing.com
snowflake.user.name=TEST_USER
snowflake.private.key=${KEY}
snowflake.database.name=KAFKA_TO_SF
snowflake.schema.name=NEWKAFKA
snowflake.role.name=KAFKA_TO_SF_POC_ROLE

# Snowflake specific settings
snowflake.ingestion.method=SNOWPIPE_STREAMING
snowflake.enable.schematization=true
snowflake.schema.evolution=true
snowflake.flatten.json=false
EOF
