# Spring Cloud Bus with Kafka - Distributed Configuration Refresh

This directory contains the complete setup for implementing **Spring Cloud Bus** with **Apache Kafka** to enable distributed configuration refresh across all microservices with a single API call.

## 🚀 Overview

**Problem Solved:** In Spring Cloud 2025.x, the traditional `/actuator/refresh` endpoint only refreshes the specific service instance that receives the call. In a microservices architecture with multiple instances, you would need to call refresh on each service individually.

**Solution:** Spring Cloud Bus + Kafka enables broadcasting configuration refresh events to all connected microservices through a message broker, ensuring all instances are updated simultaneously.

## 📁 Directory Structure

```
kafka-docker/
├── docker-compose.yml          # Complete Kafka ecosystem
├── start-kafka.sh/.bat         # Platform-specific startup scripts
├── test-bus-refresh.sh/.bat     # Testing scripts for bus refresh
└── README.md                   # This documentation
```

## 🐳 Kafka Infrastructure

### Components
- **Zookeeper** (localhost:2181) - Kafka cluster coordination
- **Kafka Broker** (localhost:9092) - Message broker for Spring Cloud Bus
- **Kafka UI** (localhost:8090) - Web interface for monitoring topics and messages

### Quick Start

**Linux/macOS:**
```bash
cd kafka-docker
chmod +x start-kafka.sh
./start-kafka.sh
```

**Windows:**
```cmd
cd kafka-docker
start-kafka.bat
```

### Verification
1. **Kafka UI:** http://localhost:8090
2. **Check Topics:** Look for `springCloudBus` topic
3. **Kafka Logs:** Monitor container logs for startup messages

## 🔧 Service Configuration

Both `order-service` and `product-service` have been enhanced with:

### Dependencies (`build.gradle`)
```kotlin
implementation 'org.springframework.cloud:spring-cloud-starter-bus-kafka'
```

### Bootstrap Configuration (`bootstrap.properties`)
```properties
# Spring Cloud Bus with Kafka
spring.cloud.bus.enabled=true
spring.kafka.bootstrap-servers=localhost:9092
spring.cloud.bus.destination=springCloudBus
```

### Test Controllers
Each service includes a `ConfigTestController` with:
- `@RefreshScope` annotation for dynamic configuration updates
- Test endpoints to verify configuration changes
- Demonstrates real-time config refresh via `/api/config/test`

## 🧪 Testing Distributed Refresh

### Automated Testing
Use the provided test scripts to verify end-to-end functionality:

```bash
# Linux/macOS
./test-bus-refresh.sh

# Windows
test-bus-refresh.bat
```

### Manual Testing Steps

1. **Start Infrastructure:**
   ```bash
   ./start-kafka.sh
   # Start configuration-server
   # Start product-service
   # Start order-service
   ```

2. **Verify Current Configuration:**
   ```bash
   curl http://localhost:8082/api/config/test  # product-service
   curl http://localhost:8083/api/config/test  # order-service
   ```

3. **Modify Configuration:**
   Edit `microservices-config-server/product-service.properties`:
   ```properties
   app.test.message=Updated message from config server!
   app.test.version=2.0.0
   ```

4. **Trigger Distributed Refresh:**
   ```bash
   curl -X POST http://localhost:8082/actuator/busrefresh
   # This single call updates ALL services via Kafka
   ```

5. **Verify Updates:**
   ```bash
   curl http://localhost:8082/api/config/test  # Should show new values
   curl http://localhost:8083/api/config/test  # Should also show updates
   ```

## 📊 Monitoring & Troubleshooting

### Kafka UI Dashboard
- **URL:** http://localhost:8090
- **Topic:** `springCloudBus`
- **Messages:** Configuration refresh events
- **Consumer Groups:** Spring Cloud Bus consumers

### Common Issues

1. **Services not receiving refresh events:**
   - Verify Kafka connectivity: `spring.kafka.bootstrap-servers=localhost:9092`
   - Check topic creation: `springCloudBus` should exist
   - Ensure `spring.cloud.bus.enabled=true`

2. **Configuration not updating:**
   - Verify `@RefreshScope` on controllers/components
   - Check configuration server connectivity
   - Confirm property injection with `@Value`

3. **Kafka connection errors:**
   - Ensure Kafka is running: `docker ps`
   - Check port availability: `localhost:9092`
   - Review container logs: `docker logs kafka`

### Logs to Monitor
```bash
# Spring Cloud Bus events
grep "RefreshBusEndpoint" application.log

# Kafka connectivity
grep "kafka" application.log

# Configuration refresh
grep "ContextRefresher" application.log
```

## 🚀 Benefits

### Before Spring Cloud Bus
```
Manual refresh required for each service:
POST /actuator/refresh → service-1
POST /actuator/refresh → service-2  
POST /actuator/refresh → service-3
POST /actuator/refresh → service-N
```

### After Spring Cloud Bus
```
Single refresh updates all services:
POST /actuator/busrefresh → Kafka → ALL services
```

### Key Advantages
- **Scalability:** Single API call refreshes unlimited service instances
- **Reliability:** Message-driven approach with delivery guarantees
- **Monitoring:** Centralized event tracking via Kafka topics
- **Flexibility:** Works across different service deployments and environments

## 🔗 Integration with Microservices

### Configuration Server
- Serves configuration to all microservices
- Properties stored in `microservices-config-server/`
- Changes immediately available after bus refresh

### Service Discovery
- All services register with `discover-server`
- Bus refresh works independently of service discovery
- Supports dynamic scaling and service instances

### Vault Integration
- Secure configuration management via HashiCorp Vault
- Combined with Spring Cloud Bus for secure + distributed updates
- Bootstrap context ensures proper loading order

## 📚 Further Reading

- [Spring Cloud Bus Documentation](https://spring.io/projects/spring-cloud-bus)
- [Apache Kafka Integration](https://kafka.apache.org/documentation/)
- [Spring Cloud Config Refresh](https://spring.io/guides/gs/centralized-configuration/)
- [Microservices Configuration Management Best Practices](https://microservices.io/patterns/externalized-configuration.html)

---

**💡 Pro Tip:** Use `/actuator/busrefresh` in production CI/CD pipelines to automatically update all service instances after configuration changes, ensuring zero-downtime configuration updates across your entire microservices ecosystem.