# 🚀 Kotlin Microservices - Simple Scripts

## **Main Scripts (Use These)**

### `./dev.sh` - Complete Development Environment
```bash
./dev.sh start      # Start everything (infrastructure + microservices)
./dev.sh stop       # Stop everything
./dev.sh status     # Check what's running
./dev.sh logs       # Show all logs
./dev.sh build      # Build microservices
./dev.sh clean      # Clean everything
```

### `./infra.sh` - Infrastructure Only
```bash
./infra.sh start    # Start databases, Kafka, Vault
./infra.sh stop     # Stop infrastructure
./infra.sh status   # Check infrastructure status
```

## **Quick Start for Interview Prep**

1. **Start Everything**: `./dev.sh start`
2. **Check Status**: `./dev.sh status`
3. **Focus on Business Services**: Open `business-services/` in your IDE
4. **Practice Kotlin**: Modify product-service and order-service

## **What's Running**

| Service | Port | Purpose |
|---------|------|---------|
| Product Service | 8082 | Business logic (MongoDB) |
| Order Service | 8083 | Business logic (MySQL) |
| Config Server | 8888 | Configuration management |
| Discovery Server | 8761 | Service registry |
| Kafka UI | 8090 | Message monitoring |
| Vault | 8200 | Secrets management |

## **File Organization**

```
📦 Root
├── dev.sh              → Main development script
├── infra.sh            → Infrastructure management
├── business-services/  → Your main focus (Kotlin code)
├── core-services/      → Config & Discovery
├── infrastructure/     → Docker configs only
└── scripts/legacy/     → Old scripts (ignore)
```

**Focus on `business-services/` for Kotlin learning and interview prep!** 🎯