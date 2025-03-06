#!/usr/bin/env python3
import subprocess
import json
import time
import random
import string
from datetime import datetime

def produce_protobuf_message(topic, message_count=5):
    """Produce messages using the kafka-protobuf-console-producer tool"""
    for i in range(message_count):
        # Create message data
        name = ''.join(random.choice(string.ascii_uppercase) for _ in range(10))
        message = {
            "id": i,
            "name": name,
            "amount": round(random.uniform(100, 10000), 2),
            "timestamp": int(datetime.now().timestamp() * 1000),
            "is_active": random.choice([True, False]),
            "address": {
                "street": f"{random.randint(100, 999)} Main St",
                "city": random.choice(["New York", "Los Angeles", "Chicago"]),
                "state": random.choice(["NY", "CA", "IL"]),
                "zip": f"{random.randint(10000, 99999)}"
            }
        }
        
        # Convert to JSON
        json_str = json.dumps(message)
        
        # Use the kafka-protobuf-console-producer tool from schema-registry
        schema_definition = """
        syntax = "proto3";
        package com.example;
        message SampleRecord {
          int32 id = 1;
          string name = 2;
          double amount = 3;
          int64 timestamp = 4;
          bool is_active = 5;
          message Address {
            string street = 1;
            string city = 2;
            string state = 3;
            string zip = 4;
          }
          Address address = 6;
        }
        """
        
        # The command has to be carefully constructed to avoid issues with quotes
        cmd = [
            "sudo", "docker", "exec", "-i", "schema-registry", 
            "bash", "-c", 
            f"echo '{json_str}' | kafka-protobuf-console-producer " +
            f"--bootstrap-server kafka:29092 " +
            f"--topic {topic} " +
            f"--property schema.registry.url=http://schema-registry:8081 " +
            f"--property value.schema='{schema_definition}'"
        ]
        
        print(f"Sending message {i}: {json_str}")
        
        # Execute the command
        process = subprocess.Popen(
            cmd, 
            stdout=subprocess.PIPE, 
            stderr=subprocess.PIPE
        )
        stdout, stderr = process.communicate()
        
        if process.returncode != 0:
            print(f"Error sending message: {stderr.decode()}")
        else:
            print(f"Successfully sent message {i}")
        
        # Wait between messages
        time.sleep(0.5)
        
    print(f"Sent {message_count} messages to {topic}")

if __name__ == "__main__":
    produce_protobuf_message("topic1", 10)
