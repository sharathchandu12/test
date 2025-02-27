#!/usr/bin/env python3
import requests
import json
import os
import time
import sys

def register_protobuf_schema(schema_registry_url, subject, schema_file):
    """Register a Protobuf schema with the Schema Registry"""
    # Read the .proto file
    with open(schema_file, 'rb') as f:
        proto_content = f.read().decode('utf-8')
    
    # Prepare the registration payload
    payload = {
        "schemaType": "PROTOBUF",
        "schema": proto_content
    }
    
    # Register the schema
    url = f"{schema_registry_url}/subjects/{subject}/versions"
    headers = {
        "Content-Type": "application/vnd.schemaregistry.v1+json"
    }
    
    response = requests.post(url, headers=headers, data=json.dumps(payload))
    
    if response.status_code == 200:
        schema_id = response.json().get('id')
        print(f"Schema registered with ID: {schema_id}")
        return schema_id
    else:
        print(f"Error registering schema: {response.text}")
        return None

def wait_for_schema_registry(schema_registry_url, max_retries=10, sleep_interval=5):
    """Wait for Schema Registry to become available"""
    for i in range(max_retries):
        try:
            response = requests.get(f"{schema_registry_url}/subjects")
            if response.status_code == 200:
                print("Schema Registry is available")
                return True
        except requests.exceptions.ConnectionError:
            pass
        
        print(f"Waiting for Schema Registry to become available... ({i+1}/{max_retries})")
        time.sleep(sleep_interval)
    
    print("Timed out waiting for Schema Registry")
    return False

if __name__ == "__main__":
    schema_registry_url = "http://localhost:8081"
    subject = "topic1-value"
    schema_file = "../proto/sample.proto"
    
    if wait_for_schema_registry(schema_registry_url):
        register_protobuf_schema(schema_registry_url, subject, schema_file)
    else:
        sys.exit(1)
