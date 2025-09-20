#!/bin/bash

# Script to load JSON secrets into Vault
echo "🔐 Loading secrets into HashiCorp Vault..."

# Check if Vault is running
if ! curl -s http://localhost:8200/v1/sys/health > /dev/null; then
    echo "❌ Vault is not running. Please start Vault first with:"
    echo "   cd vault-docker && docker-compose up -d"
    exit 1
fi

echo "📋 Enabling KV v2 secrets engine..."
docker exec vault-dev sh -c 'VAULT_ADDR=http://localhost:8200 VAULT_TOKEN=myroot vault secrets enable -version=2 kv' 2>/dev/null || echo "KV v2 already enabled"

echo "📁 Loading order-service secrets..."
if [ -f "secrets/order-service.json" ]; then
    docker cp secrets/order-service.json vault-dev:/tmp/order-service.json
    docker exec vault-dev sh -c 'VAULT_ADDR=http://localhost:8200 VAULT_TOKEN=myroot vault kv put secret/order-service @/tmp/order-service.json'
    echo "✅ order-service secrets loaded"
else
    echo "⚠️ order-service.json not found"
fi

echo "📁 Loading product-service secrets..."
if [ -f "secrets/product-service.json" ]; then
    docker cp secrets/product-service.json vault-dev:/tmp/product-service.json
    docker exec vault-dev sh -c 'VAULT_ADDR=http://localhost:8200 VAULT_TOKEN=myroot vault kv put secret/product-service @/tmp/product-service.json'
    echo "✅ product-service secrets loaded"
else
    echo "⚠️ product-service.json not found"
fi

echo ""
echo "🔍 Verifying secrets were loaded:"
echo "order-service secrets:"
docker exec vault-dev sh -c 'VAULT_ADDR=http://localhost:8200 VAULT_TOKEN=myroot vault kv get -format=json secret/order-service' 2>/dev/null || echo "Failed to read order-service secrets"

echo ""
echo "product-service secrets:"
docker exec vault-dev sh -c 'VAULT_ADDR=http://localhost:8200 VAULT_TOKEN=myroot vault kv get -format=json secret/product-service' 2>/dev/null || echo "Failed to read product-service secrets"

echo ""
echo "🎉 Secret loading complete!"
echo "💡 You can now access these secrets via:"
echo "   - Vault UI: http://localhost:8200/ui"
echo "   - CLI: docker exec vault-dev sh -c 'VAULT_ADDR=http://localhost:8200 VAULT_TOKEN=myroot vault kv get secret/order-service'"