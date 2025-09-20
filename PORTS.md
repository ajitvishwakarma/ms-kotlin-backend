# Port Allocation Reference

This document tracks all port allocations across the microservices project to prevent conflicts.

## Current Port Allocations

### Infrastructure Services
| Service | Container Name | Host Port | Container Port | Purpose |
|---------|---------------|-----------|---------------|---------|
| **Zookeeper** | ms-kotlin-zookeeper | 2181 | 2181 | Kafka coordination |
| **Kafka** | ms-kotlin-kafka | 9092 | 9092 | Message broker (external) |
| **Kafka** | ms-kotlin-kafka | 29092 | 29092 | Message broker (internal) |
| **Kafka UI** | ms-kotlin-kafka-ui | 8090 | 8080 | Kafka monitoring dashboard |
| **Vault** | ms-kotlin-vault | 8200 | 8200 | Secrets management |

### Core Microservices
| Service | Container Name | Host Port | Container Port | Purpose |
|---------|---------------|-----------|---------------|---------|
| **Configuration Server** | ms-kotlin-config-server | 8888 | 8888 | Centralized configuration |
| **Discovery Server** | ms-kotlin-discovery-server | 8761 | 8761 | Service registry (Eureka) |

### Business Microservices
| Service | Container Name | Host Port | Container Port | Purpose |
|---------|---------------|-----------|---------------|---------|
| **Product Service** | ms-kotlin-product-service | 8082 | 8082 | Product management APIs |
| **Order Service** | ms-kotlin-order-service | 8083 | 8083 | Order management APIs |

## Reserved Ports (Avoid Using)

### devops-concepts Project Conflicts
| Port | Used By | Project | Notes |
|------|---------|---------|-------|
| 8080 | Jenkins Master | devops-concepts | Jenkins main UI |
| 50000 | Jenkins Master | devops-concepts | Jenkins agent communication |
| 9000 | Kafka UI (AKHQ) | devops-concepts | Alternative Kafka monitoring |

### Common Development Ports (Avoid)
| Port Range | Typical Usage | Recommendation |
|------------|---------------|----------------|
| 3000-3010 | React/Node development | Avoid for microservices |
| 4200-4210 | Angular development | Avoid for microservices |
| 5000-5010 | Flask/Python development | Avoid for microservices |
| 8080 | Common web server port | Already used by Jenkins |

## Port Assignment Strategy

### Current Strategy
- **Infrastructure**: 2181, 8200, 9092, 29092, 8090
- **Core Services**: 8888, 8761  
- **Business Services**: 8082, 8083
- **Future Services**: 8084, 8085, 8086...

### Guidelines
1. **Infrastructure services**: Use standard ports where possible
2. **Core services**: Use 87xx range for Spring Cloud services
3. **Business services**: Use 80xx range starting from 8082
4. **Avoid conflicts**: Check this document before adding new services
5. **Document changes**: Update this file when adding new services

## Adding New Services

When adding a new service:

1. **Check availability**: Ensure port is not in "Reserved Ports" list
2. **Follow strategy**: Use next available port in appropriate range
3. **Update documentation**: Add entry to "Current Port Allocations"
4. **Test locally**: Verify no conflicts with existing services
5. **Update Docker Compose**: Use new port in docker-compose.yml

## Future Services (Planned)

| Service | Planned Port | Purpose | Status |
|---------|-------------|---------|--------|
| **API Gateway** | 8084 | Central API routing | Planned |
| **Monitoring Service** | 8085 | Application monitoring | Planned |
| **Logging Service** | 8086 | Centralized logging | Planned |

## Network Configuration

### Docker Networks
- **Network Name**: `ms-kotlin-microservices-network`
- **Driver**: bridge
- **WSL Compatible**: Yes (includes host.docker.internal support)

### Container Communication
- **Internal**: Services communicate using container names (e.g., `ms-kotlin-kafka:29092`)
- **External**: Host access via localhost (e.g., `localhost:9092`)
- **WSL**: Docker socket mounted for Docker-in-Docker scenarios

---

**⚠️ Important**: Always check this document before:
- Adding new services
- Changing existing port assignments  
- Running multiple Docker environments simultaneously
- Setting up development environments

**📝 Maintenance**: Update this file whenever port assignments change!