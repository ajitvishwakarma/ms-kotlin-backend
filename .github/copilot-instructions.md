
# Copilot Instructions for Kotlin-Java Microservice Project

## Project Purpose
This project is a **Kotlin-based microservice for interview preparation** and to help Java developers transition to Kotlin. The primary goal is to **quickly revise Kotlin concepts, microservices patterns, and real-world coding scenarios** for job interviews.

## 🎯 **FOCUS AREAS (Interview Priorities)**
1. **Kotlin Language Features**: Data classes, null safety, coroutines, extension functions
2. **Microservices Patterns**: Service discovery, configuration management, messaging
3. **Spring Boot + Kotlin**: Integration, best practices, common interview questions
4. **Real-world Scenarios**: Database integration, REST APIs, error handling

## ⚠️ **EFFICIENCY RULES**
- **Keep it simple**: Don't over-engineer solutions
- **Speed over perfection**: Focus on learning and quick iteration
- **Interview-relevant only**: Skip complex infrastructure unless directly needed
- **Time-conscious**: User has limited time for interview prep

## Microservice Overview

**Organized Structure:**
- **infrastructure/**: All infrastructure components (Kafka, Vault, DBs) with management scripts
- **core-services/**: Configuration and Discovery servers
- **business-services/**: Product and Order services (main focus for learning)

**Architecture:**
- **Infrastructure**: Automated startup with `./infrastructure/manage-infrastructure.sh`
- **Core Services**: Spring Cloud Config + Eureka Discovery
- **Business Services**: REST APIs with database integration (main interview focus)

## Planned/Upcoming Features

The project will be extended with:

- **API Gateway**: Central entry point for all APIs, routing, authentication, and rate limiting.
- **Fallback/Circuit Breaker**: Resilience patterns (e.g., Hystrix, Resilience4j) for handling service failures gracefully.
- **Centralized Logging**: Aggregated logs for all services (e.g., ELK stack, Loki, etc.).
- **HashiCorp Vault Integration**: Secure secrets management for sensitive configuration.

When adding new features (API Gateway, fallback, logging, Vault, etc.), update this file and `KOTLIN-JAVA-INTERVIEW-NOTES.md` with:
- A brief description of the feature and its purpose.
- How it integrates with existing services.
- Any new patterns, libraries, or best practices introduced.
- Interview-focused notes and code samples comparing Kotlin and Java approaches.

---

## Development & Testing Workflow

**EFFICIENCY FIRST - Interview Prep Focus:**
1. **Quick Start**: `./start.sh` - starts everything automatically
2. **Focus on Business Services**: `business-services/` folder - this is where you'll spend most time
3. **Test & Learn**: Use the running services to practice Kotlin coding patterns

**Infrastructure Management:**
- Infrastructure is automated - don't spend time on DevOps unless needed
- Use `./infrastructure/manage-infrastructure.sh` for infrastructure only
- Focus your time on Kotlin language features and business logic

**Code Changes Priority:**
1. **Business Services**: product-service, order-service (main learning focus)
2. **Kotlin Features**: Data classes, coroutines, extension functions
3. **Spring Boot Patterns**: Controllers, services, repositories
4. **Interview Scenarios**: REST APIs, database operations, error handling

**DON'T OVERCOMPLICATE:**
- Infrastructure is ready - focus on business logic
- Skip complex DevOps unless directly asked
- Prioritize Kotlin learning over infrastructure tweaks

---

## Git Commit Best Practices

**Logical Grouping:**
- Always group related changes into separate commits by their purpose
- Never combine unrelated changes (e.g., feature + documentation + fixes) into one commit
- Create focused, atomic commits that can be reviewed and reverted independently

**When Asked for Git Messages:**
- Suggest which files to group together and their respective commit messages
- Provide clear, descriptive commit messages following conventional commit format
- Group by: features, fixes, documentation, dependencies, configuration, etc.

**When Asked to Commit:**
- Automatically group and commit changes logically without asking
- Use meaningful commit messages with proper prefixes: `feat:`, `fix:`, `docs:`, `refactor:`, etc.
- Include detailed descriptions for complex changes
- Reference related issues or architectural decisions when relevant

**Commit Message Format:**
```
<type>: <subject>

<optional body with detailed explanation>
- Bullet points for multiple changes
- Technical details and reasoning
- Impact on other components
```

**Common Groupings:**
1. **Dependencies**: `build.gradle`, `pom.xml` changes
2. **Configuration**: Properties files, config changes
3. **Features**: New functionality implementation
4. **Fixes**: Bug fixes and error corrections
5. **Documentation**: README, troubleshooting, interview notes
6. **Refactoring**: Code improvements without behavior changes

---

## Documentation & Contribution Guidance

**Project Knowledge & Setup:**
- Update `README.md` with all project-specific knowledge, architecture, setup, and service integration details. This file is the single source of truth for understanding the project structure and service interactions.

**Troubleshooting:**
- Document all issues and their solutions in `TROUBLESHOOTING.md`. For each issue, include the error message, root cause, and the fix. This helps future contributors quickly resolve common issues.

**Kotlin/Java Q&A and Interview Notes:**
- All Kotlin/Java interview Q&A, explanations, and comparisons must be added to `KOTLIN-JAVA-INTERVIEW-NOTES.md` in the project root.
- When a new Kotlin/Java topic is discussed, update this file with concise, interview-focused notes and code samples.
- Use side-by-side comparisons (tables or code blocks) to highlight differences between Kotlin and Java, as seen in the current notes.
- Whenever you have any doubts or questions related to Kotlin (language features, patterns, best practices, etc.), research and update `KOTLIN-JAVA-INTERVIEW-NOTES.md` with your findings, explanations, and code samples. This will help grow the knowledge base for all contributors.

---

## Code Patterns & Conventions

- Use Kotlin idioms (data classes, null safety, extension functions, coroutines) and explain them with Java analogies where possible.
- For every Kotlin feature or pattern, provide a Java equivalent or note if there is none.
- Avoid using Lombok in Kotlin code; document why in the notes if asked.
- Build: Use Gradle wrapper scripts (`./gradlew build` or `gradlew.bat build`).
- Tests: Place tests under `src/test/kotlin/` and run with Gradle.
- Main code is under `src/main/kotlin/`.
- Keep explanations concise and interview-oriented.
- Use markdown tables for feature comparisons.
- Reference key files and directories in explanations (e.g., `Product.kt` for data class examples).
- When refactoring or enriching the notes, always preserve existing valuable content.

**Examples:**
- When documenting a Kotlin data class, show the Java POJO and Lombok equivalent.
- For null safety, show how Kotlin's nullable types compare to Java's approach.

---

## Motivation

The project is meant to help a Java developer quickly revise Kotlin, understand differences, and prepare for interviews with practical, side-by-side examples.

---

For more, see `KOTLIN-JAVA-INTERVIEW-NOTES.md` and update it as the single source of truth for Kotlin/Java Q&A in this project.
