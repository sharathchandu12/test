FROM bitnami/kafka:3.4

ENV KAFKA_CFG_ZOOKEEPER_CONNECT=zookeeper:2181

# Copy Snowflake properties file to Kafka config directory
COPY SF_connect.properties /opt/bitnami/kafka/config/

# Add plugin path to connect-standalone.properties
RUN echo "plugin.path=/opt/bitnami/kafka/libs" >> /opt/bitnami/kafka/config/connect-standalone.properties

# Download the Snowflake Kafka Connector
RUN curl -o /opt/bitnami/kafka/libs/snowflake-kafka-connector-3.1.0.jar \
    https://repo1.maven.org/maven2/com/snowflake/snowflake-kafka-connector/3.1.0/snowflake-kafka-connector-3.1.0.jar

# Copy the startup script
COPY --chmod=777 start-kafka.sh /opt/bitnami/scripts/start-kafka.sh

# Start Kafka with custom configuration
CMD ["/opt/bitnami/scripts/start-kafka.sh"]
