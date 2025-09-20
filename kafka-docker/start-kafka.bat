@echo off
REM Script to start Kafka and Zookeeper with Docker Compose

echo 🚀 Starting Kafka and Zookeeper with Docker...

REM Check if Docker is running
docker info > nul 2>&1
if errorlevel 1 (
    echo ❌ Docker is not running. Please start Docker first.
    exit /b 1
)

echo 📋 Starting Kafka infrastructure...
docker-compose up -d

REM Wait for services to start
echo ⏳ Waiting for services to start...
timeout /t 10 > nul

REM Check if services are running
echo 🔍 Checking service status...
docker-compose ps

echo.
echo ✅ Kafka infrastructure started successfully!
echo.
echo 🔗 Access Information:
echo    Kafka: localhost:9092
echo    Zookeeper: localhost:2181
echo    Kafka UI: http://localhost:8090
echo.
echo 📖 Next Steps:
echo    1. Configure Spring Cloud Bus in your microservices
echo    2. Use /actuator/busrefresh for distributed configuration refresh
echo    3. Monitor topics and messages via Kafka UI
echo.
echo 🛠️ Useful Commands:
echo    docker-compose logs kafka     # View Kafka logs
echo    docker-compose down           # Stop Kafka
echo    docker-compose ps             # Check status