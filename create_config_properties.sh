#!/bin/bash
set -e

# First, create the standalone properties file if it doesn't exist
cat > /home/newadmin/kafka-sfv3/config/connect-standalone.properties << EOF
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
#KEY=$(grep -v "KEY\|CERT" keys/private-key.pem | awk 'NF {sub(/\r/, ""); printf "%s",$0;}')


# Then create the Snowflake connector properties file
cat > /home/newadmin/kafka-sfv3/config/SF_connect.properties << EOF
name=snowflake-sink-connector
connector.class=com.snowflake.kafka.connector.SnowflakeSinkConnector
tasks.max=8
topics=topic1
snowflake.topic2table.map=topic1:kafka_table1

# Snowflake connection settings
snowflake.url.name=mr14846.east-us-2.azure.snowflakecomputing.com
snowflake.user.name=TEST_USER
snowflake.private.key=MIIEuwIBADANBgkqhkiG9w0BAQEFAASCBKUwggShAgEAAoIBAQC0g3hlFMskMgqvzMK5vlnZROzSisTl2vdInptcp5dwt9tG45Xsiaxukvp3OpcDwbj+MAzN72DmyJUofgQ7bZgi
s+0HQjbAvc9+pJj8LsgyYvBpAKyWjHedF48qXOuSjkXE9cIw1Ah+yxFxPR3v9KOQN6l6zc2Dq5LGGAluaCjjxnjCI7SRXUTfAOOjFArM/PPrG7hLQ7G3XviPp8hgDUDXUVR6iX6l
eS45VagKRGFjU9eEw4q59++a3EcTAiy2PcR1MKBfq5bw2ExJ37aVsqRTibY9iaozx7QQz42LLeAJMBMPE8sF0nuhjfhThSFrVU0ur3BqfLeAGQd2121dgf/JAgMBAAECgf8Oqp/q
Y1+3kSYZ71Xi9MeLRg5eQBtY+AsfdPbEKgzwtTK1XJU4PF3GN8SIUdPzRv1adoz6LnjkR2fXFZlCbguH+XziTUu/KhNLahQ3NfxBTvvTJdR5miNRBpkBpPF+9t0avUNwTcn8g1Aa
sA++oohBL3fI6O/JwvPDiv05LnCKd3KfCg8YvyQEI0f4SvRCeanP6xl41aP7oJQKTLDDsc45OY9VG14beJiK78roVJs1Bris6l4vrHMYfaq8w+Kub2EbHI9qIBJWPKR7LCpje38Y
jNhWYaCMRgXqzAiT6pAlxfRcdst8AF52l4v94U66lyOf0Faylhg/AISczrKCWaECgYEA7q4Ky1jPwRd1WyJaLklpjUPZedwVnlKmSbwKNghmWVkHAl2clSXrIXiSmMdRHHSKqlEG
eRGLJBlLyYJLWRVngGxMzp/y91/OA1RyK3Bfa1ighLvD4PLC8HNIkTPzeZ3cLYet4gvIrPSyosxeavTzKxXMZnYDQQiN6VLhO+qm7+cCgYEAwZzfTu6jNXfPQkEMBvH7u7stLVJ0
Ey27nzoKu2aa90VM/Hwacyti7wtwKctIBbNO+rg1Jo9MWqc4VdU97iHQmHQUPIEhaKXbxQtllXhtQKG4sG3BTJXu92wMhAkTvj/Nt5ED/U3GsFcu5vWWuNBBS8NPzYG0omAy8adX
TY1ZXM8CgYEAu2FBsjEQMXx0Ms7+U5Zo2nGo+8Vv53Llf7+zmIXxrDV7jjzl4CX7ubRKCs13/Un1Tw77cPL39KgzWokDFHX8YtMjXZgvDExXlT+nvjijgMf8hRhQCHst1c3765sI
i7MGF2yMc4liy33z/GFLwtZ5TZr4dHwzw8uudb4Oe5aV5oMCgYAqk6DX7sqdW3eMjllivZwqMINC0DsObKQx48WwaGPztJ21eGUopoXfI5jK2BVCi6f2osOtcx3LYbKVzYsM7wq8
O+qnU45RQQgPUO5J7G26JNZElh5IBUDD0FMARi69S7Klh5JlBdGHveRmjeNTSRjS3GSUQM3EV3tcgPxF5audKQKBgEGbP0OVT/qtTqazio4rUccMFoWbfyhkJG9kqqULhptkn/lF
ru1bOJ0uVX9N/z2kVc5Yb9Z0bj4cBJOOKiFvhUPiDjL5g96anuxtCweX8gg+KWsjogHoHfMDHCUWnph3aItrrTLVuKtVf2o4wnBuKxegQbNEWFJ6SkIVCni2KLb9
snowflake.database.name=KAFKA_TO_SF
snowflake.schema.name=NEWKAFKA
snowflake.role.name=KAFKA_TO_SF_POC_ROLE

# Snowflake specific settings
snowflake.ingestion.method=SNOWPIPE_STREAMING
snowflake.enable.schematization=true
snowflake.schema.evolution=true
snowflake.flatten.json=false
EOF
