#!/bin/bash

echo "🔐 Starting Vault and Loading Secrets..."
echo "======================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_DIR="$SCRIPT_DIR"

# Function to check if Vault is healthy
check_vault_health() {
    local count=0
    local max_attempts=30
    
    echo "⏳ Waiting for Vault to be ready..."
    while [ $count -lt $max_attempts ]; do
        if curl -s http://localhost:8200/v1/sys/health > /dev/null 2>&1; then
            echo "✅ Vault is healthy and ready"
            return 0
        fi
        echo -n "."
        sleep 2
        count=$((count + 1))
    done
    
    echo "❌ Vault failed to become healthy within 60 seconds"
    return 1
}

# Function to load secrets from JSON files
load_secrets() {
    echo ""
    echo "📋 Enabling KV v2 secrets engine..."
    docker exec ms-kotlin-vault sh -c 'VAULT_ADDR=http://localhost:8200 VAULT_TOKEN=myroot vault secrets enable -version=2 kv' 2>/dev/null || echo "   KV v2 already enabled"
    
    echo ""
    echo "📁 Loading service secrets..."
    
    # Load order-service secrets
    if [ -f "$VAULT_DIR/secrets/order-service.json" ]; then
        echo "   Loading order-service secrets..."
        docker cp "$VAULT_DIR/secrets/order-service.json" ms-kotlin-vault:/tmp/order-service.json
        docker exec ms-kotlin-vault sh -c 'VAULT_ADDR=http://localhost:8200 VAULT_TOKEN=myroot vault kv put secret/order-service @/tmp/order-service.json'
        echo "   ✅ order-service secrets loaded"
    else
        echo "   ⚠️ order-service.json not found"
    fi
    
    # Load product-service secrets
    if [ -f "$VAULT_DIR/secrets/product-service.json" ]; then
        echo "   Loading product-service secrets..."
        docker cp "$VAULT_DIR/secrets/product-service.json" ms-kotlin-vault:/tmp/product-service.json
        docker exec ms-kotlin-vault sh -c 'VAULT_ADDR=http://localhost:8200 VAULT_TOKEN=myroot vault kv put secret/product-service @/tmp/product-service.json'
        echo "   ✅ product-service secrets loaded"
    else
        echo "   ⚠️ product-service.json not found"
    fi
    
    echo ""
    echo "🔍 Verifying loaded secrets..."
    docker exec ms-kotlin-vault sh -c 'VAULT_ADDR=http://localhost:8200 VAULT_TOKEN=myroot vault kv list secret/' 2>/dev/null || echo "   No secrets found"
    
    echo ""
    echo "✅ Vault setup complete!"
    echo "   Access: http://localhost:8200"
    echo "   Token:  myroot"
}

# Main execution
case "${1:-start}" in
    "start")
        echo "🚀 Starting Vault service..."
        cd "$VAULT_DIR"
        docker-compose up -d
        
        if check_vault_health; then
            load_secrets
        else
            echo "❌ Failed to start Vault properly"
            exit 1
        fi
        ;;
    "stop")
        echo "🛑 Stopping Vault service..."
        cd "$VAULT_DIR"
        docker-compose down
        ;;
    "restart")
        echo "🔄 Restarting Vault service..."
        cd "$VAULT_DIR"
        docker-compose down
        docker-compose up -d
        
        if check_vault_health; then
            load_secrets
        fi
        ;;
    "status")
        echo "📊 Vault status:"
        docker-compose ps
        ;;
    "reload-secrets")
        echo "🔄 Reloading secrets only..."
        if check_vault_health; then
            load_secrets
        else
            echo "❌ Vault is not running. Start it first with: $0 start"
            exit 1
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|reload-secrets}"
        echo ""
        echo "  start         - Start Vault and load secrets"
        echo "  stop          - Stop Vault service"
        echo "  restart       - Restart Vault and reload secrets"
        echo "  status        - Show Vault container status"
        echo "  reload-secrets- Reload secrets into running Vault"
        exit 1
        ;;
esac