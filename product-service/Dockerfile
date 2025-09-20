# Product Service Dockerfile
FROM openjdk:21-jdk-slim

WORKDIR /app

# Copy Gradle wrapper and build files
COPY gradlew gradlew.bat build.gradle settings.gradle ./
COPY gradle ./gradle/

# Copy source code
COPY src ./src/

# Make gradlew executable
RUN chmod +x gradlew

# Build the application
RUN ./gradlew build -x test

# Expose port
EXPOSE 8082

# Run the application
CMD ["java", "-jar", "build/libs/product-service.jar"]