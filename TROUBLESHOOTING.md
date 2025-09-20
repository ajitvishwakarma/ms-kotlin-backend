# Troubleshooting Guide for Kotlin-Java Microservice Project

This guide collects common issues, error messages, and their solutions encountered during development.

---

## 1. @Value/@field:Value Injection Error in Kotlin
**Error:**
```
Error creating bean with name 'testController':
Unsatisfied dependency expressed through constructor parameter 0: No qualifying bean of type 'java.lang.String' available: expected at least 1 bean which qualifies as autowire candidate. Dependency annotations: {}
```
**Root Cause:**
- Using `@field:Value` on a constructor parameter in Kotlin does not work for constructor injection. Spring tries to autowire a bean of type String instead of injecting from properties/config.

**Solution:**
- Use `@Value` on constructor parameters for immutable (`val`) properties.
- Use `@field:Value` only for mutable (`var`) properties (field/property injection).

---


## 2. /actuator/refresh Endpoint Not Found or Missing (Spring Boot 3.5 + Spring Cloud 2025.x)
**Error:**
```
{"status":404,"error":"Not Found","message":"No static resource actuator/refresh.", ...}
```
or `/actuator/refresh` endpoint does not appear in `/actuator` listing.

**Root Cause:**
- In Spring Cloud 2025.x, the `/actuator/refresh` endpoint is no longer available by default, even if you have `spring-boot-starter-actuator` and `spring-cloud-starter-config`.
- The legacy local refresh endpoint now requires the bootstrap context, which is enabled by adding `spring-cloud-starter-bootstrap`.
- Without this dependency, only distributed refresh via Spring Cloud Bus (`/actuator/busrefresh`) is available.

**Complete Solution (Checklist):**
1. **Add bootstrap dependency** to your `build.gradle`:
   ```groovy
   implementation 'org.springframework.cloud:spring-cloud-starter-bootstrap' // Enables bootstrap context and restores /actuator/refresh
   ```

2. **Create `bootstrap.properties`** in `src/main/resources/`:
   ```properties
   spring.application.name=your-service-name
   spring.cloud.config.uri=http://localhost:8888
   spring.cloud.config.initialize-on-context-refresh=true
   spring.cloud.config.allowOverride=true
   ```

3. **Update `application.properties`**:
   ```properties
   spring.config.import=optional:configserver:
   management.endpoints.web.exposure.include=*
   management.endpoint.refresh.enabled=true
   ```

4. **Add `@RefreshScope`** to beans that use config values:
   ```kotlin
   @RefreshScope
   @RestController
   class MyController(@Value("\${some.prop}") val prop: String) {
       // ...
   }
   ```

5. **Test with POST request**:
   ```bash
   curl -X POST http://localhost:8080/actuator/refresh
   ```

**Why This Happens:**
- Spring Cloud 2025.x+ changed the default behavior to encourage distributed refresh via Spring Cloud Bus. Local refresh is now opt-in via the bootstrap context.
- The bootstrap context must be explicitly enabled and configured to reload remote property sources during refresh.

**If you want distributed refresh:**
- Use Spring Cloud Bus (`spring-cloud-starter-bus-amqp` or `spring-cloud-starter-bus-kafka`) and POST to `/actuator/busrefresh` instead.

**Known Issue - Still Not Working:**
- Even with all the above configurations in place (bootstrap dependency, bootstrap.properties, @RefreshScope, proper endpoint exposure), the `/actuator/refresh` endpoint may still not work in Spring Cloud 2025.x + Spring Boot 3.5.
- This appears to be a deeper compatibility or configuration issue that requires further investigation.
- **Workaround:** Use application restart for config changes until this is resolved.
- **TODO:** Investigate Spring Cloud Bus as alternative for distributed refresh, or consider downgrading to a more stable Spring Cloud version.

---
