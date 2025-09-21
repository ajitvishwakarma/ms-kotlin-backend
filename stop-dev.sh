#!/bin/bash

# =============================================================================
# 🛑 STOP DEVELOPMENT - Stop core and business services
# =============================================================================

echo "🛑 Stopping Development Services"
echo "================================"

echo "📦 Stopping business services..."
docker-compose -f docker-compose-services.yml stop ms-kotlin-product-service ms-kotlin-order-service 2>/dev/null || true

echo "🔍 Stopping discovery server..."
docker-compose -f docker-compose-services.yml stop ms-kotlin-discover-server 2>/dev/null || true

echo "⚙️ Stopping configuration server..."
docker-compose -f docker-compose-services.yml stop ms-kotlin-configuration-server 2>/dev/null || true

echo "🧹 Cleaning up containers..."
docker-compose -f docker-compose-services.yml down --remove-orphans 2>/dev/null || true

echo ""
echo "✅ Development services stopped!"
echo "💡 Infrastructure still running. Use './stop-infra.sh' to stop completely"