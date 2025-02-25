import json
import time
from kafka import KafkaProducer

def create_large_message(num_keys):
    """Create a large message with the specified number of keys."""
    message = {f"key_{i}": f"value_{i}" for i in range(num_keys)}
    message["epoch_time"] = round(time.time() * 1000)
    return json.dumps(message).encode('utf-8')

def produce_large_message(broker, topic, num_keys):
    """Produce a large message with many keys to a Kafka topic."""
    producer = KafkaProducer(bootstrap_servers=broker)

    try:
        message = create_large_message(num_keys)
        future = producer.send(topic, message)
        result = future.get(timeout=60)
        print(f"Message sent to topic {topic}: {result}")
    except Exception as e:
        print(f"Failed to send message: {e}")
    finally:
        producer.close()

if __name__ == "__main__":
    kafka_broker = 'localhost:9092'
    kafka_topic = 'topic1'
    num_keys = 10

    for _ in range(1000):
        produce_large_message(kafka_broker, kafka_topic, num_keys)
