#!/bin/bash

# Script to test Spring Cloud Bus distributed configuration refresh
echo "🧪 Testing Spring Cloud Bus Distributed Configuration Refresh"

# Function to test service config endpoint
test_service_config() {
    local service_name=$1
    local port=$2
    
    echo "📡 Testing $service_name configuration..."
    
    # Get current config
    echo "   Before refresh:"
    curl -s "http://localhost:$port/api/config/test" | jq '.'
    
    return 0
}

# Function to trigger bus refresh
trigger_bus_refresh() {
    local port=$1
    echo "🔄 Triggering distributed configuration refresh via /actuator/busrefresh..."
    
    response=$(curl -s -X POST "http://localhost:$port/actuator/busrefresh")
    echo "   Response: $response"
}

# Function to wait for refresh
wait_for_refresh() {
    echo "⏳ Waiting 3 seconds for configuration to propagate..."
    sleep 3
}

echo ""
echo "📋 Prerequisites:"
echo "   ✅ Kafka is running (localhost:9092)"
echo "   ✅ Configuration Server is running (localhost:8888)"
echo "   ✅ Product Service is running"
echo "   ✅ Order Service is running"
echo ""

# Check if services are running by detecting their ports
echo "🔍 Detecting running services..."

PRODUCT_PORT=""
ORDER_PORT=""

# Try to find product service port
for port in 8082 $(seq 8080 8090) $(seq 9000 9010); do
    if curl -s "http://localhost:$port/actuator/health" > /dev/null 2>&1; then
        app_name=$(curl -s "http://localhost:$port/actuator/info" 2>/dev/null | jq -r '.app.name // empty' 2>/dev/null)
        if [[ "$app_name" == "product-service" ]] || curl -s "http://localhost:$port/api/config/test" 2>/dev/null | grep -q "product-service"; then
            PRODUCT_PORT=$port
            echo "   Found product-service on port $port"
            break
        fi
    fi
done

# Try to find order service port
for port in 8083 $(seq 8080 8090) $(seq 9000 9010); do
    if curl -s "http://localhost:$port/actuator/health" > /dev/null 2>&1; then
        app_name=$(curl -s "http://localhost:$port/actuator/info" 2>/dev/null | jq -r '.app.name // empty' 2>/dev/null)
        if [[ "$app_name" == "order-service" ]] || curl -s "http://localhost:$port/api/config/test" 2>/dev/null | grep -q "order-service"; then
            ORDER_PORT=$port
            echo "   Found order-service on port $port"
            break
        fi
    fi
done

if [[ -z "$PRODUCT_PORT" ]] && [[ -z "$ORDER_PORT" ]]; then
    echo "❌ No services found. Please start your microservices first."
    exit 1
fi

echo ""
echo "📊 BEFORE Refresh - Current Configuration:"
echo "================================================"

if [[ -n "$PRODUCT_PORT" ]]; then
    test_service_config "product-service" "$PRODUCT_PORT"
fi

if [[ -n "$ORDER_PORT" ]]; then
    test_service_config "order-service" "$ORDER_PORT"
fi

echo ""
echo "🚨 Now modify the configuration files:"
echo "   - Edit microservices-config-server/product-service.properties"
echo "   - Edit microservices-config-server/order-service.properties"
echo "   - Change app.test.message and app.test.version values"
echo ""
read -p "Press Enter after modifying the configuration files..."

# Trigger refresh from any service (it will propagate to all via Kafka)
if [[ -n "$PRODUCT_PORT" ]]; then
    trigger_bus_refresh "$PRODUCT_PORT"
elif [[ -n "$ORDER_PORT" ]]; then
    trigger_bus_refresh "$ORDER_PORT"
fi

wait_for_refresh

echo ""
echo "📊 AFTER Refresh - Updated Configuration:"
echo "================================================"

if [[ -n "$PRODUCT_PORT" ]]; then
    test_service_config "product-service" "$PRODUCT_PORT"
fi

if [[ -n "$ORDER_PORT" ]]; then
    test_service_config "order-service" "$ORDER_PORT"
fi

echo ""
echo "✅ Spring Cloud Bus test complete!"
echo ""
echo "🔍 To monitor Kafka messages:"
echo "   - Open Kafka UI: http://localhost:8090"
echo "   - Check 'springCloudBus' topic for refresh events"
echo ""
echo "💡 Key Points:"
echo "   - Single /actuator/busrefresh call refreshes ALL services"
echo "   - Configuration changes propagate via Kafka messages"
echo "   - No need to call /actuator/refresh on each service individually"