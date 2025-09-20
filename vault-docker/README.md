# HashiCorp Vault Docker Setup

This directory contains Docker configuration for running HashiCorp Vault locally for development purposes.

## 🚀 Quick Start

### Option 1: Using Scripts (Recommended)
**Windows:**
```bash
cd vault-docker
start-vault.bat
```

**Linux/Mac:**
```bash
cd vault-docker
chmod +x start-vault.sh
./start-vault.sh
```

### Option 2: Manual Docker Compose
```bash
cd vault-docker
docker-compose up -d
```

## 📋 What's Included

- **Vault Server**: Main Vault instance running in dev mode
- **Vault UI**: Optional web UI for easier management
- **Persistent Storage**: Data persists between container restarts
- **Network**: Isolated Docker network for microservices

## 🔑 Access Information

- **Vault API**: http://localhost:8200
- **Vault UI**: http://localhost:8200/ui
- **Optional UI**: http://localhost:8000 (alternative UI)
- **Root Token**: `myroot` (dev mode only)

## 📁 Directory Structure

```
vault-docker/
├── docker-compose.yml      # Main Docker Compose configuration
├── config/
│   └── vault.hcl          # Vault server configuration
├── start-vault.sh         # Linux/Mac startup script
├── start-vault.bat        # Windows startup script
└── README.md              # This file
```

## 🛠️ Useful Commands

```bash
# Start Vault
docker-compose up -d

# View logs
docker-compose logs vault

# Stop Vault
docker-compose down

# Check status
docker-compose ps

# Access Vault CLI inside container
docker exec -it vault-dev vault status
```

## 🔐 Creating Secrets for Microservices

Once Vault is running, you can create secrets via the UI or CLI:

### Via UI:
1. Go to http://localhost:8200/ui
2. Login with token: `myroot`
3. Enable KV v2 secrets engine
4. Create secrets at paths like:
   - `secret/product-service`
   - `secret/order-service`

### Via CLI:
```bash
# Enable KV v2 secrets engine
docker exec -it vault-dev vault secrets enable -version=2 kv

# Create secrets
docker exec -it vault-dev vault kv put secret/product-service \
    database.password=secret123 \
    api.key=dev-api-key

docker exec -it vault-dev vault kv put secret/order-service \
    database.password=secret456 \
    payment.gateway.key=payment-key
```

## ⚠️ Security Notes

- **Development Only**: This setup is for development and uses insecure settings
- **Root Token**: The root token `myroot` is hardcoded for convenience
- **TLS Disabled**: TLS is disabled for local development
- **Production**: Never use this configuration in production

## 🔗 Integration with Spring Cloud

After setting up Vault, you'll need to:
1. Add Spring Cloud Vault dependencies to your microservices
2. Configure Vault connection in `bootstrap.properties`
3. Use `@Value` annotations to inject secrets
4. Optionally use `@VaultPropertySource` for advanced configuration

See the main project README for Spring Cloud Vault integration steps.

## 🐳 Docker Network

The setup creates a `microservices-network` that your other services can join to communicate with Vault securely within Docker.

## 📚 Next Steps

1. **Start Vault**: Run the startup script
2. **Access UI**: Visit http://localhost:8200/ui
3. **Create Secrets**: Add secrets for your microservices  
4. **Configure Spring**: Add Vault integration to your services
5. **Test**: Verify secrets are loaded correctly

For troubleshooting and integration help, see the main project's TROUBLESHOOTING.md file.