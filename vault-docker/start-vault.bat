@echo off
REM HashiCorp Vault Docker Setup Script for Windows

echo Starting HashiCorp Vault with Docker...

REM Start Vault containers
docker-compose up -d

echo Waiting for Vault to start...
timeout /t 10 /nobreak > nul

REM Check if Vault is running (Windows equivalent)
curl -s http://localhost:8200/v1/sys/health > nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Vault is running successfully!
    echo.
    echo 🔑 Vault Access Information:
    echo    Vault URL: http://localhost:8200
    echo    Root Token: myroot
    echo    Vault UI: http://localhost:8000 ^(optional^)
    echo.
    echo 📖 Next Steps:
    echo    1. Access Vault UI at http://localhost:8200
    echo    2. Use root token 'myroot' to login
    echo    3. Create secrets for your microservices
    echo    4. Configure Spring Cloud Vault in your services
    echo.
    echo 🛠️ Useful Commands:
    echo    docker-compose logs vault     # View Vault logs
    echo    docker-compose down           # Stop Vault
    echo    docker-compose ps             # Check status
) else (
    echo ❌ Vault failed to start. Check logs with: docker-compose logs vault
)

pause