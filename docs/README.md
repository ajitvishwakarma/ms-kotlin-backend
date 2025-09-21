# Kotlin-Java Microservices Interview Reference

This project is a hands-on Kotlin microservices workspace designed for Java developers revising for interviews, learning Kotlin, and comparing both languages in real-world service scenarios.

## Project Structure

- `configuration-server/` – Spring Cloud Config server (Kotlin)
- `discover-server/` – Service discovery (Eureka, Kotlin)
- `order-service/` – Order microservice (Kotlin)
- `product-service/` – Product microservice (Kotlin)
- `microservices-config-server/` – Centralized config properties for services

## Key Features

- **Kotlin-first:** All main services are written in Kotlin, using idiomatic patterns.
- **Java Comparison:** Interview notes and code comments compare Kotlin and Java approaches for common patterns.
- **Spring Boot:** Each service uses Spring Boot for rapid development.
- **Config Server:** Centralized configuration for all microservices.
- **Service Discovery:** Eureka server for dynamic service registration and lookup.

## How to Build & Run

### **Automated Setup (Recommended)**
```bash
# Complete environment startup
./start.sh                         # Start everything (infrastructure + services)

# Modular approach
./start-infrastructure.sh          # Start infrastructure only
./start.sh services                # Start microservices only

# Monitoring and testing
./monitor.sh                       # Real-time monitoring
./test-environment.sh all          # Health checks
```

### **Manual Setup (Learning Purpose)**
1. **Infrastructure**: Start Kafka, Vault, databases first
2. **Configuration Server**: Provides configs to other services
3. **Discovery Server**: Service registry (Eureka)
4. **Business Services**: Product and Order services

```bash
# Manual service startup (learning purpose only)
cd configuration-server && ./gradlew bootRun
cd discover-server && ./gradlew bootRun
cd product-service && ./gradlew bootRun
cd order-service && ./gradlew bootRun
```

### **Development Commands**
```bash
./start.sh build                   # Build all services
./start.sh clean                   # Clean environment
./start.sh status                  # Check service health
./start.sh logs [service-name]     # View specific logs
./stop.sh                          # Stop everything
```

## 🐳 Complete Docker Environment

The project provides a complete Docker Compose setup with all infrastructure and microservices.

### Services Included:
- **Infrastructure**: Zookeeper, Kafka, Kafka UI, HashiCorp Vault
- **Databases**: MongoDB (Product Service), MySQL (Order Service)  
- **Microservices**: Configuration Server, Discovery Server, Product Service, Order Service

### Quick Start:
```bash
# Start complete environment
docker-compose up -d

# Check all services are running
docker-compose ps

# View logs of specific service
docker-compose logs -f ms-kotlin-product-service

# Stop all services
docker-compose down
```

### Database Setup:
- **MongoDB**: `ms-kotlin-mongodb:27017` with sample product data
- **MySQL**: `ms-kotlin-mysql:3306` with sample order data
- Databases auto-initialize with sample data via `init-scripts/`

### Service Ports:
- **Configuration Server**: 8888
- **Discovery Server**: 8761  
- **Product Service**: 8082 (MongoDB)
- **Order Service**: 8083 (MySQL)
- **Kafka UI**: 8090
- **Vault UI**: 8200
- **MongoDB**: 27017
- **MySQL**: 3306

### Environment Variables:
Services use Docker container hostnames with fallback to localhost for local development:
```properties
# Product Service MongoDB
MONGODB_HOST=ms-kotlin-mongodb
MONGODB_DATABASE=product-service

# Order Service MySQL  
MYSQL_HOST=ms-kotlin-mysql
MYSQL_DATABASE=order-service
```

## Interview & Learning Resources

- See [`Kotlin-Java-Interview-Notes.md`](./product-service/Kotlin-Java-Interview-Notes.md) for:
  - Kotlin vs Java syntax and feature comparisons
  - Data class, dependency injection, visibility, and more
  - Spring Boot idioms in Kotlin
  - Best practices and code samples

## Conventions

- Use `val` for dependencies/configuration unless mutability is required.
- Prefer constructor injection for Spring components.
- Use `@field:Value` for property injection in Kotlin.
- Avoid Lombok in Kotlin code (Kotlin provides similar features natively).

## Example: Kotlin vs Java (Dependency Injection)

| Aspect               | Kotlin Example                                 | Java Example                                  |
|----------------------|------------------------------------------------|-----------------------------------------------|
| Property Injection   | `@field:Value("\${test.name}") val name: String` | `@Value("${test.name}") private String name;` |
| Required Annotation  | `@field:Value` (use-site target)               | `@Value` (no use-site target needed)          |



## Spring Cloud Config & Actuator Refresh Setup (Spring Boot 3.5+ and Spring Cloud 2025.x)

- To load configuration from the config server, add to your `application.properties`:
  ```
  spring.config.import=optional:configserver:
  ```
- Add to your `build.gradle`:
  ```groovy
  implementation 'org.springframework.cloud:spring-cloud-starter-config'
  implementation 'org.springframework.boot:spring-boot-starter-actuator'
  implementation 'org.springframework.cloud:spring-cloud-starter-bootstrap' // Needed for /actuator/refresh in Spring Cloud 2025.x+
  ```
- Expose endpoints in `application.properties`:
  ```
  management.endpoints.web.exposure.include=*
  ```

**Note:**
- In Spring Cloud 2025.x, `/actuator/refresh` is not available by default. You must add `spring-cloud-starter-bootstrap` to restore the legacy local refresh endpoint. For distributed refresh, use Spring Cloud Bus and `/actuator/busrefresh`.
- See the TROUBLESHOOTING.md for detailed explanation, rationale, and troubleshooting steps if `/actuator/refresh` does not work as expected.
- **Known Issue:** Even with proper configuration, `/actuator/refresh` may still not work in Spring Cloud 2025.x + Spring Boot 3.5. Use application restart as workaround until resolved.

## HashiCorp Vault Integration

This project includes HashiCorp Vault for secure configuration management:

### Quick Start
```bash
# Start Vault in Docker
cd vault-docker
./start-vault.sh

# Load example secrets
./load-secrets.sh

# Access Vault UI: http://localhost:8200/ui (token: myroot)
```

### Configuration Pattern
- **Bootstrap Configuration** (`bootstrap.properties`): Vault connection settings
- **Application Configuration** (`application.properties`): App-specific settings  
- **Critical**: Vault config MUST be in `bootstrap.properties` (loads before main context)

### Spring Cloud Vault Dependencies
```groovy
implementation 'org.springframework.cloud:spring-cloud-starter-vault-config'
implementation 'org.springframework.cloud:spring-cloud-starter-bootstrap' // Required for external config
```

For detailed troubleshooting and configuration examples, see `TROUBLESHOOTING.md`.

## Spring Cloud Bus with Kafka - Distributed Configuration Refresh

**Problem:** In Spring Cloud 2025.x, `/actuator/refresh` only refreshes individual service instances, requiring manual refresh of each service.

**Solution:** Spring Cloud Bus + Kafka enables distributed configuration refresh across all microservices with a single API call.

### Quick Start
```bash
# 1. Start Kafka infrastructure
cd kafka-docker
./start-kafka.sh  # Linux/macOS
# or start-kafka.bat  # Windows

# 2. Start your microservices (they auto-connect to Kafka)

# 3. Test distributed refresh
curl -X POST http://localhost:8082/actuator/busrefresh
```

### Key Benefits
- **Single API Call:** One `/actuator/busrefresh` updates ALL service instances
- **Scalable:** Works with unlimited service instances 
- **Reliable:** Message-driven with delivery guarantees via Kafka
- **Monitorable:** Track refresh events via Kafka UI at http://localhost:8090

### Configuration
Services automatically include Spring Cloud Bus via:
```groovy
implementation 'org.springframework.cloud:spring-cloud-starter-bus-kafka'
```

Bootstrap configuration (both services):
```properties
spring.cloud.bus.enabled=true
spring.kafka.bootstrap-servers=localhost:9092
```

### Testing
Use provided test scripts to verify end-to-end functionality:
```bash
cd kafka-docker
./test-bus-refresh.sh    # Linux/macOS
# or test-bus-refresh.bat # Windows
```

For complete setup, testing, and troubleshooting details, see [`kafka-docker/README.md`](./kafka-docker/README.md).

## License

This project is for educational and interview preparation purposes.
