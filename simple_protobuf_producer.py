#!/usr/bin/env python3
import json
import time
import random
import string
import subprocess
from datetime import datetime

def produce_messages(topic, num_messages=100):
    """Produce messages to Kafka using kafka-protobuf-console-producer in the container"""
    print(f"Producing {num_messages} Protobuf messages to topic {topic}")
    
    for i in range(num_messages):
        # Generate a sample message
        name = ''.join(random.choice(string.ascii_uppercase) for _ in range(10))
        # Create address data
        address = {
            "street": f"{random.randint(100, 999)} Main St",
            "city": random.choice(["New York", "Los Angeles", "Chicago"]),
            "state": random.choice(["NY", "CA", "IL"]),
            "zip": f"{random.randint(10000, 99999)}"
        }
        
        message = {
            "id": i,
            "name": name,
            "amount": round(random.uniform(100, 10000), 2),
            "timestamp": int(datetime.now().timestamp() * 1000),
            "is_active": random.choice([True, False]),
            "address": address
        }
        
        # Convert to JSON
        json_data = json.dumps(message)
        
        # Send to Kafka using schema registry's protobuf producer
        cmd = f"""
        echo '{json_data}' | docker exec -i schema-registry kafka-protobuf-console-producer \
          --bootstrap-server kafka:29092 \
          --topic {topic} \
          --property schema.registry.url=http://schema-registry:8081 \
          --property value.schema='
            syntax = "proto3";
            package com.example;
            message SampleRecord {{
              int32 id = 1;
              string name = 2;
              double amount = 3;
              int64 timestamp = 4;
              bool is_active = 5;
              message Address {{
                string street = 1;
                string city = 2;
                string state = 3;
                string zip = 4;
              }}
              Address address = 6;
            }}'
        """
        
        result = subprocess.run(cmd, shell=True, capture_output=True)
        
        if result.returncode != 0:
            print(f"Error: {result.stderr.decode()}")
            print(f"Command output: {result.stdout.decode()}")
        else:
            # Print progress occasionally
            if i % 10 == 0:
                print(f"Produced {i} messages")
        
        # Short delay between messages
        time.sleep(0.1)
    
    print(f"Successfully produced {num_messages} messages to {topic}")

if __name__ == "__main__":
    topic = "topic1"
    produce_messages(topic, 100)
