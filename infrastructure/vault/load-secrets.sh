#!/bin/bash
# Vault secrets initialization
# This script loads secrets into Vault when it starts

echo "🔐 Loading Vault secrets..."

# Wait for Vault to be ready
sleep 5

# Set Vault address and token (works both inside container and outside)
export VAULT_ADDR="${VAULT_ADDR:-http://localhost:8200}"
export VAULT_TOKEN="${VAULT_TOKEN:-myroot}"

# Enable key-value secrets engine if not already enabled
vault secrets enable -path=secret kv-v2 2>/dev/null || echo "KV secrets engine already enabled"

# Function to load secrets from JSON file using Vault's native @file syntax
load_secrets_from_json() {
    local service_name=$1
    local json_file=$2
    
    if [ ! -f "$json_file" ]; then
        echo "⚠️  Warning: $json_file not found, skipping $service_name"
        return 1
    fi
    
    echo "📄 Loading secrets for $service_name from $json_file"
    
    # Use Vault's native @file syntax to load JSON directly
    if vault kv put secret/$service_name @"$json_file"; then
        echo "✅ Loaded secrets for $service_name"
    else
        echo "❌ Failed to load secrets for $service_name"
        return 1
    fi
}

# Load secrets from JSON files in the secrets folder
load_secrets_from_json "product-service" "/vault/secrets/product-service.json"
load_secrets_from_json "order-service" "/vault/secrets/order-service.json"

echo ""
echo "✅ All Vault secrets loaded successfully!"
echo "🔍 Secrets are available at:"
echo "   • secret/product-service (MongoDB credentials)"
echo "   • secret/order-service (MySQL credentials)"
echo ""
echo "🌐 Access Vault UI: http://localhost:8200/ui/vault/secrets/secret/list"
echo "🔑 Token: myroot"