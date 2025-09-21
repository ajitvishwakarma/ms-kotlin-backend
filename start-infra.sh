#!/bin/bash

# =============================================================================
# 🏗️ START INFRASTRUCTURE - Start databases, Kafka, and Vault
# =============================================================================

set -e

echo "🏗️ Starting Infrastructure Services"
echo "==================================="

# Create network if it doesn't exist
echo "📡 Creating network..."
docker network create ms-kotlin-microservices-network 2>/dev/null || echo "   Network already exists"

# Start databases with init data
echo "📊 Starting databases with initial data..."
cd infrastructure/databases && docker-compose up -d
cd ../..

echo "   ⏳ Waiting for databases..."
sleep 10

# Start Kafka
echo "📨 Starting Kafka..."
cd infrastructure/kafka && docker-compose up -d
cd ../..

echo "   ⏳ Waiting for Kafka..."
sleep 20

# Start Vault with secrets
echo "🔐 Starting Vault with secrets..."
cd infrastructure/vault && docker-compose up -d
cd ../..

echo "   ⏳ Waiting for Vault..."
sleep 10

echo ""
echo "✅ Infrastructure ready!"
echo ""
echo "🌐 Access URLs:"
echo "   📊 Kafka UI:  http://localhost:8090"
echo "   🔐 Vault:     http://localhost:8200 (token: myroot)"
echo "   📦 MongoDB:   mongodb://localhost:27018/product-service"
echo "   📋 MySQL:     jdbc:mysql://root:@localhost:3307/order-service"
echo ""
echo "💡 Next: Run './start-dev.sh' to start microservices"