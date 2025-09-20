# Docker Environment Setup

This directory contains a complete Docker Compose setup for running all microservices locally.

## Quick Start

### Prerequisites
- Docker Desktop installed and running
- At least 8GB RAM allocated to Docker
- Ports 8082, 8083, 8200, 8761, 8888, 8090, 9092, 2181 available

### Start Everything

**Linux/macOS:**
```bash
./start-environment.sh
```

**Windows:**
```cmd
start-environment.bat
```

### Manual Start
```bash
docker-compose up -d
```

## Service Startup Order

The services start in the following order to ensure proper dependencies:

1. **Infrastructure** (30s wait)
   - Zookeeper (Kafka coordination)
   - Kafka (Message broker)
   - Kafka UI (Monitoring)
   - Vault (Secrets management)

2. **Core Services** (45s wait)
   - Configuration Server (8888)
   - Discovery Server (8761)

3. **Business Services** (30s wait)
   - Product Service (8082)
   - Order Service (8083)

## Service URLs

| Service | URL | Purpose |
|---------|-----|---------|
| **Kafka UI** | http://localhost:8090 | Monitor Kafka topics and messages |
| **Vault** | http://localhost:8200 | Secrets management (token: `myroot`) |
| **Config Server** | http://localhost:8888 | Centralized configuration |
| **Discovery** | http://localhost:8761 | Service registry (Eureka) |
| **Product Service** | http://localhost:8082 | Product management APIs |
| **Order Service** | http://localhost:8083 | Order management APIs |

## WSL + Docker Compatibility

This setup is optimized for **WSL (Windows Subsystem for Linux) + Docker** environments:

### WSL-Specific Features
- **Docker Socket Mounting**: `/var/run/docker.sock:/var/run/docker.sock` enables Docker-in-Docker scenarios
- **Host Connectivity**: `DOCKER_HOST=tcp://host.docker.internal:2375` ensures proper Docker daemon connectivity
- **Container Naming**: Prefixed names (`ms-kotlin-*`) to avoid conflicts with other Docker projects
- **Network Configuration**: Custom bridge network with WSL-compatible settings

### Image Version Compatibility
- **Zookeeper**: `zookeeper:3.6` (matches devops-concepts project)
- **Kafka**: `confluentinc/cp-kafka:latest` (matches devops-concepts project)  
- **Kafka UI**: `provectuslabs/kafka-ui:latest`
- **Vault**: `hashicorp/vault:latest`

This ensures no duplicate image downloads when running alongside other Docker projects.

## Testing Endpoints

### Health Checks
```bash
curl http://localhost:8082/actuator/health  # Product Service
curl http://localhost:8083/actuator/health  # Order Service
```

### Configuration Testing
```bash
# Get current config
curl http://localhost:8082/api/test

# Refresh all services via Spring Cloud Bus
curl -X POST http://localhost:8082/actuator/busrefresh
```

## Useful Commands

### Management
```bash
# View all service status
docker-compose ps

# View logs for all services
docker-compose logs -f

# View logs for specific service
docker-compose logs -f ms-kotlin-product-service

# Stop all services
docker-compose down

# Restart specific service
docker-compose restart ms-kotlin-product-service

# Rebuild and restart service
docker-compose up -d --build ms-kotlin-product-service

# Use stop script
./stop-environment.sh
```

### Container Management
```bash
# List running containers with prefixed names
docker ps --filter "name=ms-kotlin-"

# Access container shell
docker exec -it ms-kotlin-product-service bash

# View container logs
docker logs ms-kotlin-kafka
```

### Troubleshooting
```bash
# Check service health
docker-compose ps

# View specific service logs
docker-compose logs product-service

# Enter service container
docker exec -it product-service bash

# Check network connectivity
docker network ls
docker network inspect ms-kotlin-backend_microservices-network
```

## Environment Variables

Services are configured with Docker-specific environment variables:

- `SPRING_PROFILES_ACTIVE=docker`
- Container-to-container communication (e.g., `kafka:9092` instead of `localhost:9092`)
- Service discovery URLs pointing to container names

## Spring Cloud Bus Testing

1. **Start Environment**: `./start-environment.sh`
2. **Verify Current Config**: `GET http://localhost:8082/api/test`
3. **Modify Config**: Edit `microservices-config-server/product-service.properties`
4. **Trigger Refresh**: `POST http://localhost:8082/actuator/busrefresh`
5. **Verify Update**: `GET http://localhost:8082/api/test`
6. **Monitor Messages**: Check Kafka UI at http://localhost:8090

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Kafka + UI    │    │      Vault      │    │   Zookeeper     │
│   (9092, 8090)  │    │     (8200)      │    │     (2181)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                        │                        │
         └────────────────────────┼────────────────────────┘
                                  │
                     ┌─────────────────┐
                     │  Config Server  │
                     │     (8888)      │
                     └─────────────────┘
                              │
                     ┌─────────────────┐
                     │ Discovery Server│
                     │     (8761)      │
                     └─────────────────┘
                              │
              ┌───────────────┼───────────────┐
    ┌─────────────────┐              ┌─────────────────┐
    │ Product Service │              │  Order Service  │
    │     (8082)      │ ◄────────── │     (8083)      │
    └─────────────────┘              └─────────────────┘
```

## Performance Notes

- **First Build**: May take 10-15 minutes to download images and build services
- **Subsequent Starts**: Should start in 2-3 minutes
- **Memory Usage**: ~4-6GB total for all services
- **Health Checks**: Services may take 30-60 seconds to report healthy

## Troubleshooting

### Common Issues

1. **Port Already in Use**
   ```bash
   netstat -an | findstr :8082  # Windows
   lsof -i :8082               # Linux/macOS
   ```

2. **Services Not Starting**
   - Check Docker memory allocation (recommend 8GB+)
   - Verify all ports are available
   - Check logs: `docker-compose logs [service-name]`

3. **Configuration Not Loading**
   - Ensure configuration-server is healthy
   - Check Vault connectivity
   - Verify bootstrap.properties configuration

4. **Kafka Connection Issues**
   - Verify Kafka is running: `docker-compose logs kafka`
   - Check Kafka UI: http://localhost:8090
   - Ensure `springCloudBus` topic is created