FROM confluentinc/cp-kafka-connect-base:7.3.0

# Try multiple package managers to ensure compatibility
RUN if command -v apt-get >/dev/null 2>&1; then \
        apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*; \
    elif command -v apk >/dev/null 2>&1; then \
        apk update && apk add --no-cache curl unzip; \
    elif command -v yum >/dev/null 2>&1; then \
        yum -y update && yum -y install curl unzip && yum clean all; \
    else \
        echo "No supported package manager found"; \
    fi

# Install Protobuf Converter using Confluent Hub Client
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-protobuf-converter:7.3.0

# Install Snowflake Kafka Connector v3.1
RUN mkdir -p /usr/share/java/plugins
RUN curl -sSL https://repo1.maven.org/maven2/com/snowflake/snowflake-kafka-connector/3.1.0/snowflake-kafka-connector-3.1.0.jar -o /usr/share/java/plugins/snowflake-kafka-connector-3.1.0.jar

# Create directory for connector configuration
RUN mkdir -p /etc/kafka-connect/jars/
