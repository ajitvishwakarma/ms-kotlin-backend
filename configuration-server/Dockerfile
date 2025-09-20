# Configuration Server Dockerfile
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
EXPOSE 8888

# Run the application
CMD ["java", "-jar", "build/libs/configuration-server.jar"]