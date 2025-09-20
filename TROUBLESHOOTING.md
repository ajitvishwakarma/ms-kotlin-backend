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

## 2. /actuator/refresh Endpoint Not Found (404)
**Error:**
```
{"status":404,"error":"Not Found","message":"No static resource actuator/refresh.", ...}
```
**Root Cause:**
- The Spring Cloud Actuator dependency is missing, or the endpoint is not exposed.

**Solution:**
- Add `implementation 'org.springframework.cloud:spring-cloud-starter-actuator'` to your `build.gradle`.
- Ensure `management.endpoints.web.exposure.include=refresh,health,info` is set in your properties.
- Use a POST request to `/actuator/refresh` on the correct service port.

---
