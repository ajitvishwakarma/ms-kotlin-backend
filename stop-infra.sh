#!/bin/bash

# =============================================================================
# 🛑 STOP INFRASTRUCTURE - Stop databases, Kafka, and Vault
# =============================================================================

echo "🛑 Stopping Infrastructure Services"
echo "==================================="

echo "🔐 Stopping Vault..."
cd infrastructure/vault && docker-compose down 2>/dev/null || true
cd ../..

echo "📨 Stopping Kafka..."
cd infrastructure/kafka && docker-compose down 2>/dev/null || true
cd ../..

echo "📊 Stopping databases..."
cd infrastructure/databases && docker-compose down 2>/dev/null || true
cd ../..

echo "📡 Removing network..."
docker network rm ms-kotlin-microservices-network 2>/dev/null || true

echo ""
echo "✅ Infrastructure stopped!"