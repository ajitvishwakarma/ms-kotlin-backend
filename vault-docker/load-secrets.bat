@echo off
REM Script to load JSON secrets into Vault

echo 🔐 Loading secrets into HashiCorp Vault...

REM Check if Vault is running
curl -s http://localhost:8200/v1/sys/health > nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Vault is not running. Please start Vault first with:
    echo    cd vault-docker ^&^& docker-compose up -d
    exit /b 1
)

echo 📋 Enabling KV v2 secrets engine...
docker exec vault-dev sh -c "VAULT_ADDR=http://localhost:8200 VAULT_TOKEN=myroot vault secrets enable -version=2 kv" > nul 2>&1
if %errorlevel% neq 0 (
    echo KV v2 already enabled or failed to enable
)

echo 📁 Loading order-service secrets...
if exist "secrets\order-service.json" (
    docker cp secrets\order-service.json vault-dev:/tmp/order-service.json
    docker exec vault-dev sh -c "VAULT_ADDR=http://localhost:8200 VAULT_TOKEN=myroot vault kv put secret/order-service @/tmp/order-service.json"
    echo ✅ order-service secrets loaded
) else (
    echo ⚠️ order-service.json not found
)

echo 📁 Loading product-service secrets...
if exist "secrets\product-service.json" (
    docker cp secrets\product-service.json vault-dev:/tmp/product-service.json
    docker exec vault-dev sh -c "VAULT_ADDR=http://localhost:8200 VAULT_TOKEN=myroot vault kv put secret/product-service @/tmp/product-service.json"
    echo ✅ product-service secrets loaded
) else (
    echo ⚠️ product-service.json not found
)

echo.
echo 🔍 Verifying secrets were loaded:
echo order-service secrets:
docker exec vault-dev sh -c "VAULT_ADDR=http://localhost:8200 VAULT_TOKEN=myroot vault kv get secret/order-service"

echo.
echo product-service secrets:
docker exec vault-dev sh -c "VAULT_ADDR=http://localhost:8200 VAULT_TOKEN=myroot vault kv get secret/product-service"

echo.
echo 🎉 Secret loading complete!
echo 💡 You can now access these secrets via:
echo    - Vault UI: http://localhost:8200/ui
echo    - CLI: docker exec vault-dev sh -c "VAULT_ADDR=http://localhost:8200 VAULT_TOKEN=myroot vault kv get secret/order-service"

pause