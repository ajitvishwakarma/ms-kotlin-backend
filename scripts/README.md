# 🚀 Simple Script Usage Guide

## **Main Scripts (Root Level)**

### Infrastructure Only
```bash
./start-infra.sh    # Start MongoDB, MySQL, Kafka, Vault
./stop-infra.sh     # Stop all infrastructure
```

### Development Services  
```bash
./start-dev.sh      # Start Config + Discovery + Business Services
./stop-dev.sh       # Stop development services only
```

### Complete Environment
```bash
./dev.sh start      # Everything (infrastructure + services)
./dev.sh stop       # Stop everything
./dev.sh status     # Check what's running
```

## **Recommended Workflow**

### For IntelliJ Development
```bash
# 1. Start infrastructure
./start-infra.sh

# 2. Run microservices from IntelliJ (better for debugging)
# - Open business-services/product-service in IntelliJ
# - Open business-services/order-service in IntelliJ
# - Run them directly from IDE
```

### For Docker Development
```bash
# Start everything in Docker
./start-infra.sh
./start-dev.sh

# Or simply
./dev.sh start
```

## **Services & Ports**

| Service | Port | Purpose |
|---------|------|---------|
| MongoDB | 27018 | Product data |
| MySQL | 3307 | Order data |
| Kafka UI | 8090 | Message monitoring |
| Vault | 8200 | Secrets (token: myroot) |
| Config Server | 8888 | Configuration |
| Discovery | 8761 | Service registry |
| Product Service | 8082 | Business logic |
| Order Service | 8083 | Business logic |

## **Interview Focus**

**Main Development**: Focus on `business-services/` folder
- `product-service/` - Kotlin + MongoDB patterns
- `order-service/` - Kotlin + MySQL patterns

**Infrastructure**: Automated via scripts, don't spend time on DevOps unless needed!