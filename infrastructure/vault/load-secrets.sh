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

# Function to load secrets from JSON file
load_secrets_from_json() {
    local service_name=$1
    local json_file=$2
    
    if [ ! -f "$json_file" ]; then
        echo "⚠️  Warning: $json_file not found, skipping $service_name"
        return 1
    fi
    
    echo "📄 Loading secrets for $service_name from $json_file"
    
    # Read JSON and convert to vault kv put format
    local secrets=""
    while IFS="=" read -r key value; do
        # Clean up quotes and whitespace
        key=$(echo "$key" | tr -d '"' | xargs)
        value=$(echo "$value" | tr -d '"' | xargs)
        secrets="$secrets $key=\"$value\""
    done < <(jq -r 'to_entries[] | "\(.key)=\(.value)"' "$json_file")
    
    # Load secrets into Vault
    if [ -n "$secrets" ]; then
        eval "vault kv put secret/$service_name $secrets"
        echo "✅ Loaded secrets for $service_name"
    else
        echo "⚠️  No secrets found in $json_file"
    fi
}

# Load secrets from JSON files in the secrets folder
load_secrets_from_json "product-service" "/vault/secrets/product-service.json"
load_secrets_from_json "order-service" "/vault/secrets/order-service.json"

# Load additional static secrets (Kafka, etc.)
vault kv put secret/kafka \
    bootstrap.servers="ms-kotlin-kafka:29092" \
    topics.orders="order-events" \
    topics.products="product-events"

echo "✅ All Vault secrets loaded successfully"