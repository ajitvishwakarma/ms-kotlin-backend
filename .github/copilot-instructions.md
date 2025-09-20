# Copilot Instructions for Kotlin-Java Microservice Project

## Project Purpose
This project is a Kotlin-based microservice, designed for interview preparation and to help Java developers transition to Kotlin. The goal is to compare Kotlin and Java approaches, document key differences, and build a practical reference for both languages in a real-world service context.

## Microservice Overview

This workspace contains several microservices, each with a specific role:

- **configuration-server**: Centralized configuration management for all services. Likely uses Spring Cloud Config or similar. Stores and serves configuration properties for other microservices.
- **discover-server**: Service discovery (Eureka or similar). Allows services to register and discover each other dynamically.
- **order-service**: Handles order management (CRUD, business logic). Connects to product-service and uses configuration-server for config.
- **product-service**: Manages product catalog and related operations. Interacts with order-service and uses configuration-server for config.

**Architecture:**
- Services are likely RESTful, using Spring Boot or Kotlin frameworks.
- Configuration is externalized via configuration-server.
- Service discovery is handled by discover-server.
- Each service has its own Gradle build and follows a standard src/main/kotlin and src/test/kotlin structure.

## Planned/Upcoming Features

The project will be extended with:

- **API Gateway**: Central entry point for all APIs, routing, authentication, and rate limiting.
- **Fallback/Circuit Breaker**: Resilience patterns (e.g., Hystrix, Resilience4j) for handling service failures gracefully.
- **Centralized Logging**: Aggregated logs for all services (e.g., ELK stack, Loki, etc.).
- **HashiCorp Vault Integration**: Secure secrets management for sensitive configuration.

**Instructions for Contributors:**
- When adding new features (API Gateway, fallback, logging, Vault, etc.), update this file and `Kotlin-Java-Interview-Notes.md` with:
  - A brief description of the feature and its purpose.
  - How it integrates with existing services.
  - Any new patterns, libraries, or best practices introduced.
  - Interview-focused notes and code samples comparing Kotlin and Java approaches.


## Key Guidance for AI Agents

- **Documentation Updates:**

  - All Kotlin/Java interview Q&A, explanations, and comparisons must be added to `Kotlin-Java-Interview-Notes.md` in the project root.
  - When a new Kotlin/Java topic is discussed, update this file with concise, interview-focused notes and code samples.
  - Use side-by-side comparisons (tables or code blocks) to highlight differences between Kotlin and Java, as seen in the current notes.
  - **Whenever I have any doubts or questions related to Kotlin (language features, patterns, best practices, etc.), research and update `Kotlin-Java-Interview-Notes.md` with your findings, explanations, and code samples. This will help grow the knowledge base for all contributors.**

---

**Sensitive Information Warning:**

This is a public repository. Do NOT include any personal, confidential, or sensitive information (such as passwords, API keys, secrets, or private data) anywhere in the project. Review all code, configuration, and documentation before committing to ensure no sensitive data is present.

- **Code Patterns:**
  - Use Kotlin idioms (data classes, null safety, extension functions, coroutines) and explain them with Java analogies where possible.
  - For every Kotlin feature or pattern, provide a Java equivalent or note if there is none.
  - Avoid using Lombok in Kotlin code; document why in the notes if asked.

- **Workflow:**
  - Build: Use Gradle wrapper scripts (`./gradlew build` or `gradlew.bat build`).
  - Tests: Place tests under `src/test/kotlin/` and run with Gradle.
  - Main code is under `src/main/kotlin/`.

- **Conventions:**
  - Keep explanations concise and interview-oriented.
  - Use markdown tables for feature comparisons.
  - Reference key files and directories in explanations (e.g., `Product.kt` for data class examples).
  - When refactoring or enriching the notes, always preserve existing valuable content.

- **Examples:**
  - When documenting a Kotlin data class, show the Java POJO and Lombok equivalent.
  - For null safety, show how Kotlin's nullable types compare to Java's approach.

- **Motivation:**
  - The project is meant to help a Java developer quickly revise Kotlin, understand differences, and prepare for interviews with practical, side-by-side examples.

---

For more, see `Kotlin-Java-Interview-Notes.md` and update it as the single source of truth for Kotlin/Java Q&A in this project.
