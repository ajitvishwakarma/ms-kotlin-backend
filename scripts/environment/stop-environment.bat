@echo off
setlocal enabledelayedexpansion

echo.
echo 🛑 Stopping Kotlin Microservices Environment
echo =============================================

REM Function to stop services gracefully
echo.
echo 📊 Current service status:
docker-compose ps

echo.
echo 🔄 Stopping all services gracefully...

REM Stop in reverse order (business services first)
echo 🏪 Stopping business services...
docker-compose stop ms-kotlin-order-service ms-kotlin-product-service

echo 🌐 Stopping core services...
docker-compose stop ms-kotlin-discover-server ms-kotlin-configuration-server

echo 🔧 Stopping infrastructure services...
docker-compose stop ms-kotlin-vault ms-kotlin-kafka-ui ms-kotlin-kafka ms-kotlin-zookeeper

echo.
echo 🗑️  Removing containers...
docker-compose down

REM Ask for cleanup
echo.
set /p do_cleanup="🧹 Run cleanup (remove unused Docker resources)? (y/N): "
if /i "!do_cleanup!"=="y" (
    echo.
    echo 🧹 Cleaning up Docker resources...
    
    REM Remove unused networks
    echo    Removing unused networks...
    docker network prune -f
    
    REM Remove unused volumes
    echo    Removing unused volumes...
    docker volume prune -f
    
    REM Ask about images
    set /p remove_images="🗑️  Remove unused Docker images? (y/N): "
    if /i "!remove_images!"=="y" (
        echo    Removing unused images...
        docker image prune -f
    )
)

echo.
echo 📊 Final Status:
echo ================

REM Check if any containers are still running
for /f "tokens=*" %%i in ('docker ps --filter "name=ms-kotlin-backend" --format "table {{.Names}}\t{{.Status}}" 2^>nul') do (
    echo ⚠️  Some containers still running:
    docker ps --filter "name=ms-kotlin-backend" --format "table {{.Names}}\t{{.Status}}"
    goto :port_check
)
echo ✅ All microservices containers stopped

:port_check
echo.
echo 🔌 Port Status:
echo    Port 8082: Product Service
echo    Port 8083: Order Service  
echo    Port 8200: Vault
echo    Port 8761: Discovery
echo    Port 8888: Config Server
echo    Port 8090: Kafka UI
echo    Port 9092: Kafka
echo    Port 2181: Zookeeper

echo.
echo 🎉 Environment stopped successfully!
echo.
echo 💡 To start again:
echo    start-environment.bat

pause