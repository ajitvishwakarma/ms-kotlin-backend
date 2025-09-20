
# Sensitive Information Warning

**This is a public repository. Do NOT include any personal, confidential, or sensitive information (such as passwords, API keys, secrets, or private data) anywhere in the project. Review all code, configuration, and documentation before committing to ensure no sensitive data is present.**

---

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

When adding new features (API Gateway, fallback, logging, Vault, etc.), update this file and `KOTLIN-JAVA-INTERVIEW-NOTES.md` with:
- A brief description of the feature and its purpose.
- How it integrates with existing services.
- Any new patterns, libraries, or best practices introduced.
- Interview-focused notes and code samples comparing Kotlin and Java approaches.

---

## Development & Testing Workflow

**ALWAYS Follow This Order:**
1. **Analyze First**: Check existing code, understand current implementation
2. **Plan & Discuss**: Propose approach, ask for clarification if needed  
3. **Implement**: Make only the requested changes
4. **Test & Verify**: Let user test everything first before committing
5. **Commit Only After Verification**: Never commit untested changes

**Before Adding New Code:**
- **Search for existing implementations** using grep_search, file_search, or semantic_search
- **Check what's already there** - don't duplicate functionality
- **Ask before assuming** - if you think something might be useful, offer it as a suggestion
- **Read existing controllers, services, configs** to understand patterns

**Testing Protocol:**
- User tests functionality first
- Fix any issues found during testing
- Only commit after user confirms everything works
- Never commit "untested" or "assumed working" code

**Code Changes:**
- Make minimal, focused changes that address the specific request
- Don't add extra features unless explicitly asked
- If you see opportunities for improvement, suggest them separately
- Respect existing code patterns and conventions
- **NEVER implement solutions proactively** - always ask first
- **STOP and ASK** before creating additional files, features, or "improvements"
- Only do exactly what is requested, nothing more

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
