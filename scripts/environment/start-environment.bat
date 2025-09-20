@echo off
setlocal enabledelayedexpansion

echo.
echo 🚀 Starting Kotlin Microservices Environment
echo ==============================================

REM Check if Docker is running
docker info >nul 2>&1
if !errorlevel! neq 0 (
    echo ❌ Docker is not running. Please start Docker and try again.
    pause
    exit /b 1
)
echo ✅ Docker is running

echo.
echo 📦 Building and starting all services...
echo This may take a few minutes on first run...

REM Start infrastructure first
echo 🔧 Starting infrastructure services (Kafka, Vault, Databases, etc.)...
docker-compose up -d ms-kotlin-zookeeper ms-kotlin-kafka ms-kotlin-kafka-ui ms-kotlin-vault ms-kotlin-mongodb ms-kotlin-mysql

echo ⏳ Waiting for infrastructure to be ready...
timeout /t 30 /nobreak >nul

REM Start core services
echo 🌐 Starting configuration and discovery services...
docker-compose up -d ms-kotlin-configuration-server ms-kotlin-discover-server

echo ⏳ Waiting for core services to be ready...
timeout /t 45 /nobreak >nul

REM Start business services
echo 🏪 Starting business services...
docker-compose up -d ms-kotlin-product-service ms-kotlin-order-service

echo ⏳ Waiting for all services to be ready...
timeout /t 30 /nobreak >nul

echo.
echo 📊 Service Status:
echo ==================
docker-compose ps

echo.
echo 🌐 Service URLs:
echo ================
echo 📋 Kafka UI:           http://localhost:8090
echo 🔐 Vault:              http://localhost:8200
echo ⚙️  Configuration:      http://localhost:8888
echo 🔍 Service Discovery:  http://localhost:8761
echo 📦 Product Service:    http://localhost:8082
echo 🛒 Order Service:      http://localhost:8083

echo.
echo 🧪 Test Endpoints:
echo ==================
echo Product Test:      GET  http://localhost:8082/api/test
echo Product Health:    GET  http://localhost:8082/actuator/health
echo Bus Refresh:       POST http://localhost:8082/actuator/busrefresh

echo.
echo 🎉 Environment started successfully!
echo.
echo 💡 Useful commands:
echo    View logs:     docker-compose logs -f [service-name]
echo    Stop all:      docker-compose down
echo    Restart:       docker-compose restart [service-name]
echo    Rebuild:       docker-compose up -d --build [service-name]
echo.
echo 📚 For Spring Cloud Bus testing:
echo    1. Test current config: GET http://localhost:8082/api/test
echo    2. Change property in microservices-config-server/
echo    3. Refresh all services: POST http://localhost:8082/actuator/busrefresh
echo    4. Verify update: GET http://localhost:8082/api/test
echo.

pause