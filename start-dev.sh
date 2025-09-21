#!/bin/bash

# =============================================================================
# 🚀 START DEVELOPMENT - Start core and business services
# =============================================================================

set -e

echo "🚀 Starting Development Services"
echo "================================"

# Check if infrastructure is running
if ! docker inspect ms-kotlin-mongodb >/dev/null 2>&1; then
    echo "❌ Infrastructure not running. Please run './start-infra.sh' first"
    exit 1
fi

echo "🔨 Building services..."
docker-compose -f docker-compose-services.yml build --parallel

echo "⚙️ Starting Configuration Server..."
docker-compose -f docker-compose-services.yml up -d ms-kotlin-configuration-server
sleep 15

echo "🔍 Starting Discovery Server..."
docker-compose -f docker-compose-services.yml up -d ms-kotlin-discover-server
sleep 10

echo "📦 Starting Business Services..."
docker-compose -f docker-compose-services.yml up -d ms-kotlin-product-service ms-kotlin-order-service
sleep 15

echo ""
echo "✅ Development services ready!"
echo ""
echo "🌐 Access URLs:"
echo "   🔍 Discovery:  http://localhost:8761"
echo "   ⚙️  Config:     http://localhost:8888"
echo "   📦 Products:   http://localhost:8082"
echo "   📋 Orders:     http://localhost:8083"
echo ""
echo "💡 For IntelliJ: Stop these containers and run services from IDE"
echo "💡 Status: './dev.sh status' or docker ps"