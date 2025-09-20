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

## License

This project is for educational and interview preparation purposes.
