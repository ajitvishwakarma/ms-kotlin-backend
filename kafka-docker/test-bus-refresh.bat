@echo off
echo.
echo 🧪 Testing Spring Cloud Bus Distributed Configuration Refresh
echo.

echo 📋 Prerequisites:
echo    ✅ Kafka is running (localhost:9092)
echo    ✅ Configuration Server is running (localhost:8888)
echo    ✅ Product Service is running
echo    ✅ Order Service is running
echo.

echo 🔍 Detecting running services...

set PRODUCT_PORT=
set ORDER_PORT=

REM Try to find product service
for %%p in (8082 8080 8081 8083 8084 8085 9000 9001 9002) do (
    curl -s "http://localhost:%%p/actuator/health" >nul 2>&1
    if !errorlevel! equ 0 (
        curl -s "http://localhost:%%p/api/config/test" 2>nul | findstr "product-service" >nul
        if !errorlevel! equ 0 (
            set PRODUCT_PORT=%%p
            echo    Found product-service on port %%p
            goto :found_product
        )
    )
)
:found_product

REM Try to find order service
for %%p in (8083 8080 8081 8082 8084 8085 9000 9001 9002) do (
    curl -s "http://localhost:%%p/actuator/health" >nul 2>&1
    if !errorlevel! equ 0 (
        curl -s "http://localhost:%%p/api/config/test" 2>nul | findstr "order-service" >nul
        if !errorlevel! equ 0 (
            set ORDER_PORT=%%p
            echo    Found order-service on port %%p
            goto :found_order
        )
    )
)
:found_order

if "%PRODUCT_PORT%"=="" if "%ORDER_PORT%"=="" (
    echo ❌ No services found. Please start your microservices first.
    pause
    exit /b 1
)

echo.
echo 📊 BEFORE Refresh - Current Configuration:
echo ================================================

if not "%PRODUCT_PORT%"=="" (
    echo 📡 Testing product-service configuration...
    echo    Before refresh:
    curl -s "http://localhost:%PRODUCT_PORT%/api/config/test"
    echo.
)

if not "%ORDER_PORT%"=="" (
    echo 📡 Testing order-service configuration...
    echo    Before refresh:
    curl -s "http://localhost:%ORDER_PORT%/api/config/test"
    echo.
)

echo.
echo 🚨 Now modify the configuration files:
echo    - Edit microservices-config-server/product-service.properties
echo    - Edit microservices-config-server/order-service.properties
echo    - Change app.test.message and app.test.version values
echo.
pause

REM Trigger refresh from any service
if not "%PRODUCT_PORT%"=="" (
    echo 🔄 Triggering distributed configuration refresh via /actuator/busrefresh...
    curl -s -X POST "http://localhost:%PRODUCT_PORT%/actuator/busrefresh"
) else (
    echo 🔄 Triggering distributed configuration refresh via /actuator/busrefresh...
    curl -s -X POST "http://localhost:%ORDER_PORT%/actuator/busrefresh"
)

echo.
echo ⏳ Waiting 3 seconds for configuration to propagate...
timeout /t 3 /nobreak >nul

echo.
echo 📊 AFTER Refresh - Updated Configuration:
echo ================================================

if not "%PRODUCT_PORT%"=="" (
    echo 📡 Testing product-service configuration...
    echo    After refresh:
    curl -s "http://localhost:%PRODUCT_PORT%/api/config/test"
    echo.
)

if not "%ORDER_PORT%"=="" (
    echo 📡 Testing order-service configuration...
    echo    After refresh:
    curl -s "http://localhost:%ORDER_PORT%/api/config/test"
    echo.
)

echo.
echo ✅ Spring Cloud Bus test complete!
echo.
echo 🔍 To monitor Kafka messages:
echo    - Open Kafka UI: http://localhost:8090
echo    - Check 'springCloudBus' topic for refresh events
echo.
echo 💡 Key Points:
echo    - Single /actuator/busrefresh call refreshes ALL services
echo    - Configuration changes propagate via Kafka messages
echo    - No need to call /actuator/refresh on each service individually
echo.
pause