FROM confluentinc/cp-kafka-connect-base:7.3.0

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Protobuf Converter using Confluent Hub Client
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-protobuf-converter:7.3.0

# Install Snowflake Kafka Connector v3.1
RUN mkdir -p /connectors
RUN curl -O https://repo1.maven.org/maven2/com/snowflake/snowflake-kafka-connector/3.1.0/snowflake-kafka-connector-3.1.0.jar
RUN mv snowflake-kafka-connector-3.1.0.jar /connectors/

# Create directory for connector configuration
RUN mkdir -p /etc/kafka-connect/jars/

# Add log configuration for debugging
COPY config/connect-log4j.properties /etc/kafka/connect-log4j.properties
