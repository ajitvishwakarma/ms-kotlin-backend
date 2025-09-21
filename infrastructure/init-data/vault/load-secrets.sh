#!/bin/bash
# Vault secrets initialization
# This script loads secrets into Vault when it starts

echo "🔐 Loading Vault secrets..."

# Wait for Vault to be ready
sleep 5

# Set Vault address and token
export VAULT_ADDR="http://localhost:8200"
export VAULT_TOKEN="myroot"

# Enable key-value secrets engine if not already enabled
vault secrets enable -path=secret kv-v2 2>/dev/null || echo "KV secrets engine already enabled"

# Load application secrets
vault kv put secret/product-service \
    mongodb.uri="mongodb://ms-kotlin-mongodb:27017/product-service" \
    mongodb.database="product-service"

vault kv put secret/order-service \
    mysql.url="jdbc:mysql://ms-kotlin-mysql:3306/order-service" \
    mysql.username="root" \
    mysql.password=""

vault kv put secret/kafka \
    bootstrap.servers="ms-kotlin-kafka:29092" \
    topics.orders="order-events" \
    topics.products="product-events"

echo "✅ Vault secrets loaded successfully"