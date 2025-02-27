#!/usr/bin/env python3
import sys
import os
import time
import random
import string
import json
import requests
from datetime import datetime

# Add the proto directory to the path
sys.path.append('../proto')

# Import the generated protobuf module
from sample_pb2 import SampleRecord

def wait_for_kafka(bootstrap_server, max_retries=10, sleep_interval=5):
    """Wait for Kafka to become available"""
    import socket
    
    host, port = bootstrap_server.split(':')
    
    for i in range(max_retries):
        try:
            socket_obj = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            socket_obj.settimeout(1)
            result = socket_obj.connect_ex((host, int(port)))
            socket_obj.close()
            
            if result == 0:
                print("Kafka is available")
                return True
        except:
            pass
        
        print(f"Waiting for Kafka to become available... ({i+1}/{max_retries})")
        time.sleep(sleep_interval)
    
    print("Timed out waiting for Kafka")
    return False

def produce_messages(bootstrap_servers, schema_registry_url, topic, num_messages):
    """Produce test messages to Kafka using the Kafka REST Proxy"""
    try:
        from confluent_kafka import Producer
        from confluent_kafka.serialization import SerializationContext, MessageField
        from confluent_kafka.schema_registry import SchemaRegistryClient
        from confluent_kafka.schema_registry.protobuf import ProtobufSerializer
        
        # Set up Schema Registry client
        schema_registry_conf = {'url': schema_registry_url}
        schema_registry_client = SchemaRegistryClient(schema_registry_conf)
        
        # Set up Protobuf serializer
        protobuf_serializer = ProtobufSerializer(SampleRecord, schema_registry_client)
        
        # Set up Kafka producer
        producer_conf = {'bootstrap.servers': bootstrap_servers}
        producer = Producer(producer_conf)
        
        # Generate and send messages
        for i in range(num_messages):
            # Generate a random name
            name = ''.join(random.choice(string.ascii_uppercase) for _ in range(10))
            
            # Create a SampleRecord message
            record = SampleRecord()
            record.id = i
            record.name = name
            record.amount = round(random.uniform(1.0, 10000.0), 2)
            record.timestamp = int(datetime.now().timestamp() * 1000)
            record.is_active = random.choice([True, False])
            
            # Add address data for some records
            if random.random() > 0.5:
                address = record.Address()
                address.street = f"{random.randint(100, 999)} {random.choice(['Main', 'Oak', 'Maple', 'Pine'])} St"
                address.city = random.choice(['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix'])
                address.state = random.choice(['NY', 'CA', 'IL', 'TX', 'AZ'])
                address.zip = f"{random.randint(10000, 99999)}"
                record.address.CopyFrom(address)
            
            # Produce message
            producer.produce(
                topic=topic,
                value=protobuf_serializer(record, SerializationContext(topic, MessageField.VALUE))
            )
            
            # Flush every 100 messages
            if i > 0 and i % 100 == 0:
                producer.flush()
                print(f"Produced {i} messages")
            
            # Sleep briefly between messages
            time.sleep(0.01)
        
        # Final flush
        producer.flush()
        print(f"Successfully produced {num_messages} messages to {topic}")
        
    except ImportError:
        print("Error: confluent-kafka Python package not found.")
        print("Please install with: pip install confluent-kafka")
        return False
    except Exception as e:
        print(f"Error producing messages: {e}")
        return False
    
    return True

if __name__ == "__main__":
    bootstrap_servers = "localhost:9092"
    schema_registry_url = "http://localhost:8081"
    topic = "topic1"
    num_messages = 1000
    
    if wait_for_kafka(bootstrap_servers):
        produce_messages(bootstrap_servers, schema_registry_url, topic, num_messages)
    else:
        sys.exit(1)
