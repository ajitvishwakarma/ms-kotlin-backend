#!/bin/bash

# =============================================================================
# 🚀 VAULT ENTRYPOINT - Start Vault and Auto-load Secrets
# =============================================================================

echo "🏗️ Starting Vault with auto-secret loading..."

# Start Vault server in the background
echo "📡 Starting Vault server..."
vault server -dev -dev-listen-address=0.0.0.0:8200 &
VAULT_PID=$!

# Wait for Vault to be ready
echo "⏳ Waiting for Vault to be ready..."
export VAULT_ADDR="http://localhost:8200"
export VAULT_TOKEN="myroot"

# Poll Vault status until it's ready
for i in {1..30}; do
    if vault status >/dev/null 2>&1; then
        echo "✅ Vault is ready!"
        break
    fi
    echo "   Waiting... (attempt $i/30)"
    sleep 2
done

# Check if Vault is ready
if ! vault status >/dev/null 2>&1; then
    echo "❌ Vault failed to start within 60 seconds"
    exit 1
fi

# Load secrets using the existing script
echo "🔑 Loading secrets..."
sh /vault/config/load-secrets.sh

# Keep Vault running in foreground
echo "🎯 Vault is running with secrets loaded!"
wait $VAULT_PID