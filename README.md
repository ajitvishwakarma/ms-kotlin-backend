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

1. Clone the repository.
2. Each service/module has its own Gradle wrapper (`./gradlew build` or `gradlew.bat build` on Windows).
3. Run services individually from their folders:
   ```bash
   cd product-service
   ./gradlew bootRun
   ```
4. Configuration is managed via the `microservices-config-server` folder.

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

## License

This project is for educational and interview preparation purposes.
