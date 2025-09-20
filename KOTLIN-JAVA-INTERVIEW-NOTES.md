# Kotlin & Java: Interview Revision Notes

This file collects concise Q&A and explanations from our Kotlin/Java discussions, focused on microservice development
and interview prep. It will be updated as new topics are covered.

---

## Common Kotlin Interview Questions

### 1. Why Kotlin?

- Modern, concise, and expressive language for JVM, Android, and backend.
- Reduces boilerplate code compared to Java.
- Null safety built-in, reducing NullPointerExceptions.
- Interoperable with Java: can use Java libraries and frameworks directly.
- Officially supported for Android development.

### 2. Kotlin vs Java: Key Differences

| Aspect              | Kotlin                              | Java                     |
|---------------------|-------------------------------------|--------------------------|
| Null Safety         | Built-in (nullable types)           | No, must handle manually |
| Data Classes        | `data class` auto-generates methods | Manual or Lombok         |
| Extension Functions | Yes                                 | No                       |
| Coroutines          | Native support for async code       | No built-in, use threads |
| Type Inference      | Yes                                 | Limited                  |
| Default Arguments   | Yes                                 | No (must overload)       |
| Interoperability    | 100% with Java                      | N/A                      |

### 3. Pros and Cons of Kotlin

**Pros:**

- Concise syntax, less boilerplate
- Null safety
- Extension functions
- Coroutines for async programming
- Interoperable with Java

**Cons:**

- Slightly slower compilation than Java
- Smaller community (but growing)
- Some advanced features may be unfamiliar to Java devs

---

## 5. Other Kotlin Class Types (with Java Comparison)

| Kotlin Type       | Purpose / Usage                                                                  | Java Equivalent & Notes                              |
|-------------------|----------------------------------------------------------------------------------|------------------------------------------------------|
| `class` (default) | Final by default, cannot be subclassed unless marked `open` or `abstract`        | `final class` (default in Java is non-final)         |
| `open class`      | Can be subclassed (must be marked explicitly)                                    | Non-final class                                      |
| `final class`     | Explicitly prevents subclassing (redundant, as `class` is final by default)      | `final class`                                        |
| `abstract class`  | Cannot be instantiated, may have abstract functions                              | `abstract class`                                     |
| `data class`      | Holds data, auto-generates equals/hashCode/toString/copy/componentN              | POJO + Lombok @Data                                  |
| `object`          | Singleton instance, thread-safe, can have properties and functions               | Static class or singleton pattern                    |
| `enum class`      | Enum with properties, methods, and constructors                                  | Enum (Java), can have fields/methods since Java 5    |
| `sealed class`    | Restricted class hierarchy, all subclasses must be in same file, exhaustive when | Java 17+ sealed class, or abstract + package-private |
| `interface`       | Interface, can have default and abstract methods                                 | Interface (Java 8+), default methods supported       |

**Examples:**

**Notes:**

- In Kotlin, all classes are `final` by default. To allow inheritance, use `open` or `abstract`.
- `final class` can be used for clarity, but is redundant unless overriding an `open` class.

**Examples:**

```kotlin
// Singleton
object MySingleton {
    fun foo() = "bar"
}

// Enum
enum class Status { SUCCESS, ERROR }

// Sealed class
sealed class Result
class Success(val data: String) : Result()
class Error(val error: Throwable) : Result()
```

// In Java, sealed classes require Java 17+ and are more verbose.

**Q: Why use a data class in Kotlin?**

- Data classes are for holding data/state.
- Auto-generates: `equals()`, `hashCode()`, `toString()`, `copy()`, and destructuring methods.
- In Java, you need to write these or use Lombok's `@Data`.

**Example:**

```kotlin
data class Product(val id: String, val name: String)
```

**Q: How is a data class different from a normal class?**

- Normal class: No auto-generated methods; you must implement them yourself.
- Data class: Must have at least one property in the primary constructor, cannot be abstract/open/sealed/inner, and
  auto-generates the above methods.

**Q: Constructors in Kotlin data classes**

- Primary constructor: Declared in the class header.
- Secondary constructors: Possible, but default parameter values are preferred.

```kotlin
data class Product(val id: String, val name: String = "DefaultName")
```

**Q: Lombok in Kotlin?**

- Not needed. Kotlin's data class already provides what Lombok's `@Data`, `@Getter`, `@Setter`, `@EqualsAndHashCode`,
  `@ToString` do in Java.
- Using Lombok in Kotlin is discouraged.

**Summary Table**

| Feature         | Java (POJO) + Lombok | Kotlin data class      |
|-----------------|----------------------|------------------------|
| Getters/Setters | @Getter/@Setter      | Auto-generated         |
| equals/hashCode | @EqualsAndHashCode   | Auto-generated         |
| toString        | @ToString            | Auto-generated         |
| Copy            | Manual               | copy() method          |
| Destructuring   | No                   | componentN() functions |

---

## Spring @Value Injection in Kotlin Constructors

**Q: How do you inject property values into Kotlin constructor parameters using @Value? Why is @field:Value needed?**

### Explanation

In Kotlin, when using Spring's `@Value` annotation to inject configuration properties into constructor parameters, you
must specify the use-site target (`@field:Value`). This tells Kotlin to apply the annotation to the backing field, not
just the constructor parameter, ensuring Spring can inject the value correctly. Without this, you may get warnings or
injection may not work as expected.

This is different from Java, where you simply annotate the field or constructor parameter with `@Value`.

### Example: Kotlin vs Java

| Aspect              | Kotlin Example (`TestController.kt`)             | Java Example                                  |
|---------------------|--------------------------------------------------|-----------------------------------------------|
| Property Injection  | `@field:Value("\${test.name}") val name: String` | `@Value("${test.name}") private String name;` |
| Required Annotation | `@field:Value` (use-site target)                 | `@Value` (no use-site target needed)          |

**Kotlin (see `TestController.kt`):**

```kotlin
@RestController
@RequestMapping("/api/test")
class TestController(
    @field:Value("\${test.name}") val name: String
) {
    @GetMapping
    fun test(): String = name
}
```

**Java:**

```java

@RestController
@RequestMapping("/api/test")
public class TestController {
    @Value("${test.name}")
    private String name;

    @GetMapping
    public String test() {
        return name;
    }
}
```

---

## Kotlin Constructor Parameter Declarations: val, var, private, and Best Practices

**Q: What is the right way to declare constructor parameters in Kotlin? What is the effect of using val, var, or
private?**

### Explanation

- `val` in the constructor makes the parameter a read-only property of the class (like a final field in Java).
- `var` makes it a mutable property (like a non-final field in Java).
- If you omit `val`/`var`, the parameter is just a constructor argument and not a property—it's not accessible outside
  the constructor.
- You can add `private` to restrict visibility (e.g., `private val name: String`).

**Best Practice:**

- For dependencies or configuration values that should not change, use `val`.
- Use `var` only if the value needs to be mutable.
- Use `private` if the property should not be exposed outside the class.

### Example Table: Kotlin vs Java

| Declaration                        | Kotlin Example              | Java Equivalent              |
|------------------------------------|-----------------------------|------------------------------|
| Read-only property                 | `val name: String`          | `private final String name;` |
| Mutable property                   | `var name: String`          | `private String name;`       |
| Private property                   | `private val name: String`  | `private final String name;` |
| Constructor arg only (not a field) | `name: String` (no val/var) | Constructor parameter only   |

---

## Kotlin: Private Properties in Constructors vs Class-Level Private

**Q: Are private properties in the constructor accessible from outside the class? What is the difference between class
private and constructor private?**

### Explanation

- If you declare a constructor parameter as `private val name: String`, it becomes a private property: only accessible
  inside the class, not from outside (just like `private` fields in Java).
- If you declare a property as `val name: String` (no `private`), it is public by default and accessible from outside.
- `private` on a constructor parameter only affects the property, not the constructor itself.
- You can also make the entire constructor private using `private constructor(...)`, which restricts instantiation of
  the class from outside (useful for singletons, factories, etc.).

### Example Table

| Declaration                            | Kotlin Example                                          | Java Equivalent                                             |
|----------------------------------------|---------------------------------------------------------|-------------------------------------------------------------|
| Private property in constructor        | `class C(private val name: String)`                     | `private final String name;`                                |
| Public property in constructor         | `class C(val name: String)`                             | `public final String name;`                                 |
| Private constructor (class-level)      | `class C private constructor(name: String)`             | `private C(String name) { ... }`                            |
| Private property + private constructor | `class C private constructor(private val name: String)` | `private final String name; private C(String name) { ... }` |

### Example

```kotlin
class Example1(private val name: String) {
    fun printName() = println(name) // OK
}

val e = Example1("foo")
// e.name // ERROR: 'name' is private in 'Example1'

class Example2(val name: String)

val e2 = Example2("bar")
println(e2.name) // OK: public

class Example3 private constructor(val name: String)
// Example3("baz") // ERROR: constructor is private
```

**Summary:**

- `private val`/`var` in constructor: property is private, not accessible from outside.
- `private constructor`: restricts class instantiation from outside.
- Both can be combined for fine-grained control, similar to Java.

```kotlin
// Read-only property, public by default
class TestController(@field:Value("\${test.name}") val name: String)

// Private property
class TestController(@field:Value("\${test.name}") private val name: String)

// Mutable property (not recommended for config)
class TestController(@field:Value("\${test.name}") var name: String)

// Constructor argument only (not a property)
class TestController(name: String) // 'name' not accessible as a property
```

**Note:**

- In most cases for Spring controllers/services, use `val` for injected dependencies/configuration.
- Use `private` if you don't want the property to be accessible from outside the class.
- Omitting `val`/`var` is rare in Spring apps, but useful for parameters only needed during construction.

```java

@RestController
@RequestMapping("/api/test")
public class TestController {
    @Value("${test.name}")
    private String name;

    @GetMapping
    public String test() {
        return name;
    }
}
```

**Note:**

- In Kotlin, always use `@field:Value` for property/constructor injection to avoid warnings and ensure correct behavior.
- This is a Kotlin language feature, not a Spring limitation.

---

## Spring @Value Injection in Kotlin: Constructor Parameter vs Field/Property

**Q: Why does using `@field:Value` on a constructor parameter in Kotlin cause an error, but using `@Value` works?**

### Short Answer

- Use `@Value` on constructor parameters for immutable (`val`) properties in Kotlin. This tells Spring to inject the
  value from properties/config server.
- Using `@field:Value` on a constructor parameter does **not** work for constructor injection. Spring will try to
  autowire a bean of type `String` from the application context, not from properties/config, causing an error.
- Use `@field:Value` only for mutable (`var`) properties (field/property injection).

### Table: When to Use Which

| Injection Style          | Kotlin Syntax Example                            | Use for |
|--------------------------|--------------------------------------------------|---------|
| Constructor Injection    | `@Value("\${test.name}") val name: String`       | `val`   |
| Field/Property Injection | `@field:Value("\${test.name}") var name: String` | `var`   |

### Example

```kotlin
// Correct: Constructor injection (for val)
class TestController(@Value("\${test.name}") private val name: String)

// Correct: Field/property injection (for var)
class TestController {
    @field:Value("\${test.name}")
    lateinit var name: String
}
```

### Why the Error?

- If you use `@field:Value` on a constructor parameter, Spring does **not** see @Value on the parameter, so it tries to
  inject a bean of type String from the context (not from properties/config). This bean does not exist, so you get an
  error.

### Error Example

If you use `@field:Value` on a constructor parameter, you may see this error:

```
Error creating bean with name 'testController':
Unsatisfied dependency expressed through constructor parameter 0: No qualifying bean of type 'java.lang.String' available: expected at least 1 bean which qualifies as autowire candidate. Dependency annotations: {}
```

**What does this mean?**

- Spring is trying to inject a bean of type String from the application context (not from properties/config), because it
  does not see @Value on the constructor parameter.
- This happens because `@field:Value` only annotates the field, not the constructor parameter.

---

### Java Comparison

```java
// Java: Field injection
@Value("${test.name}")
private String name;

// Java: Constructor injection
private final String name;

public TestController(@Value("${test.name}") String name) {
    this.name = name;
}
```

**Key Takeaway:**

- Use `@Value` for constructor parameters (`val`), `@field:Value` for mutable fields (`var`).
- If you see "No qualifying bean of type 'String'", check your annotation placement!

---

**Q: How does dependency injection (autowiring) work in Kotlin controllers without explicit `@Autowired`?**

### Explanation

In Kotlin, constructor injection is the preferred and idiomatic way to inject dependencies in Spring components (like
controllers, services, etc.).

- If a class (e.g., `ProductController`) is annotated with `@RestController` and its constructor has parameters (e.g.,
  `val productRepository: ProductRepository`), Spring will automatically inject the required bean by type.
- You do **not** need to annotate the constructor with `@Autowired` in Kotlin if the class has only one constructor (
  which is the default for Kotlin primary constructors). Spring detects it automatically.
- This is different from Java, where you often see `@Autowired` on constructors or fields, especially if there are
  multiple constructors.

### Example: Kotlin vs Java

| Aspect               |   | Kotlin Example (`ProductController.kt`)                | Java Example                                                                  |
|----------------------|:--|--------------------------------------------------------|-------------------------------------------------------------------------------|
| Dependency Injection |   | `class ProductController(val repo: ProductRepository)` | `@Autowired ProductRepository repo;` (field) or constructor with `@Autowired` |
| Required Annotation  |   | None (if single constructor)                           | `@Autowired` required (field or constructor)                                  |

**Kotlin (see `ProductController.kt`):**

```kotlin
@RestController
@RequestMapping("/api/product")
class ProductController(val productRepository: ProductRepository) {
    // ...
}
```

**Java:**

```java

@RestController
@RequestMapping("/api/product")
public class ProductController {
    @Autowired
    private ProductRepository productRepository;
    // ...
}
```

**Note:**

- Field injection is discouraged in both languages; constructor injection is preferred for testability and immutability.
- In Kotlin, the lack of `@Autowired` is not an error—it's a feature of Spring's support for Kotlin's primary
  constructors.

---

## Troubleshooting Guide

This section collects common issues, error messages, and their solutions encountered during development.

### 1. @Value/@field:Value Injection Error in Kotlin
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

### 2. /actuator/refresh Endpoint Not Found (404)
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

### 3. Spring Cloud Vault Authentication Error
**Error:**
```
Cannot create authentication mechanism for TOKEN. This method requires either a Token (spring.cloud.vault.token) or a token file at ~/.vault-token.
```
**Root Cause:**
- Vault configuration placed in `application.properties` instead of `bootstrap.properties`
- Spring Cloud loads external configuration sources during **bootstrap phase** (before main application context)

**Solution:**
- Move ALL Vault configuration to `bootstrap.properties`:
```properties
# bootstrap.properties (loads FIRST)
spring.cloud.vault.host=localhost
spring.cloud.vault.port=8200
spring.cloud.vault.scheme=http
spring.cloud.vault.token=myroot
spring.cloud.vault.kv.enabled=true
spring.cloud.vault.kv.backend=secret
spring.cloud.vault.kv.default-context=product-service
```

**Key Interview Points:**
- **Bootstrap vs Application context**: Bootstrap loads external config, Application receives config from external sources
- **Loading order matters**: Vault connection must be established before Spring tries to load properties from Vault
- **Common mistake**: Putting external config source setup in `application.properties` instead of `bootstrap.properties`

---
