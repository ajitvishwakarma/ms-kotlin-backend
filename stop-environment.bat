@echo off
setlocal enabledelayedexpansion

echo.
echo 🛑 Stopping Kotlin Microservices Environment
echo =============================================

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

echo.
set /p cleanup="🧹 Run cleanup (remove unused Docker resources)? (y/N): "
if /i "!cleanup!"=="y" (
    echo.
    echo 🧹 Cleaning up Docker resources...
    echo    Removing unused networks...
    docker network prune -f
    echo    Removing unused volumes...
    docker volume prune -f
    
    set /p remove_images="🗑️  Remove unused Docker images? (y/N): "
    if /i "!remove_images!"=="y" (
        echo    Removing unused images...
        docker image prune -f
    )
)

echo.
echo 📊 Final Status:
echo ================

REM Check if containers are still running
echo ✅ All microservices containers stopped

echo.
echo 🔌 Port Status:
for %%p in (8082 8083 8200 8761 8888 8090 9092 2181) do (
    netstat -an | findstr ":%%p " | findstr LISTENING >nul 2>&1
    if !errorlevel! equ 0 (
        echo    Port %%p: ⚠️  Still in use
    ) else (
        echo    Port %%p: ✅ Available
    )
)

echo.
echo 🎉 Environment stopped successfully!
echo.
echo 💡 To start again:
echo    start-environment.bat
echo.

pause