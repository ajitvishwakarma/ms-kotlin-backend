#!/bin/bash

# Quick test script for microservices environment
echo "🧪 Testing Microservices Environment"
echo "====================================="

# Function to test endpoint
test_endpoint() {
    local name=$1
    local url=$2
    local timeout=${3:-5}
    
    echo -n "Testing $name... "
    if timeout $timeout curl -s -f "$url" > /dev/null 2>&1; then
        echo "✅ OK"
        return 0
    else
        echo "❌ FAIL"
        return 1
    fi
}

# Function to test all endpoints
test_all_endpoints() {
    echo ""
    echo "🔍 Testing all service endpoints:"
    echo "---------------------------------"
    
    local failed=0
    
    # Infrastructure
    test_endpoint "Vault" "http://localhost:8200/v1/sys/health" || ((failed++))
    test_endpoint "Kafka UI" "http://localhost:8090" || ((failed++))
    
    # Core services
    test_endpoint "Config Server" "http://localhost:8888/actuator/health" || ((failed++))
    test_endpoint "Discovery Server" "http://localhost:8761/actuator/health" || ((failed++))
    
    # Business services
    test_endpoint "Product Service" "http://localhost:8082/actuator/health" || ((failed++))
    test_endpoint "Order Service" "http://localhost:8083/actuator/health" || ((failed++))
    
    echo ""
    if [ $failed -eq 0 ]; then
        echo "🎉 All endpoints are working!"
        return 0
    else
        echo "⚠️  $failed endpoint(s) failed"
        return 1
    fi
}

# Function to check container health
check_container_health() {
    echo ""
    echo "🏥 Container Health Status:"
    echo "---------------------------"
    
    local containers=(
        "ms-kotlin-zookeeper"
        "ms-kotlin-kafka"
        "ms-kotlin-vault"
        "ms-kotlin-mongodb"
        "ms-kotlin-mysql"
        "ms-kotlin-configuration-server"
        "ms-kotlin-discover-server"
        "ms-kotlin-product-service"
        "ms-kotlin-order-service"
    )
    
    for container in "${containers[@]}"; do
        if docker ps --format "table {{.Names}}" | grep -q "^$container$"; then
            local health=$(docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null || echo "no-health-check")
            local status=$(docker inspect --format='{{.State.Status}}' "$container" 2>/dev/null || echo "not-found")
            
            if [ "$health" = "healthy" ]; then
                echo "   $container: ✅ Healthy"
            elif [ "$health" = "unhealthy" ]; then
                echo "   $container: ❌ Unhealthy"
            elif [ "$status" = "running" ]; then
                echo "   $container: 🟡 Running (no health check)"
            else
                echo "   $container: 🔴 $status"
            fi
        else
            echo "   $container: ⚫ Not running"
        fi
    done
}

# Function to show service ports
show_service_ports() {
    echo ""
    echo "🔌 Service Port Status:"
    echo "-----------------------"
    
    local ports=(
        "2181:Zookeeper"
        "9092:Kafka"
        "8090:Kafka UI"
        "8200:Vault"
        "27018:MongoDB"
        "3307:MySQL"
        "8888:Config Server"
        "8761:Discovery Server"
        "8082:Product Service"
        "8083:Order Service"
    )
    
    for port_info in "${ports[@]}"; do
        local port=$(echo $port_info | cut -d: -f1)
        local service=$(echo $port_info | cut -d: -f2)
        
        if netstat -an 2>/dev/null | grep ":$port " | grep -q LISTEN; then
            echo "   Port $port ($service): ✅ Listening"
        else
            echo "   Port $port ($service): ❌ Not listening"
        fi
    done
}

# Function to run quick smoke tests
run_smoke_tests() {
    echo ""
    echo "💨 Running smoke tests:"
    echo "-----------------------"
    
    # Test configuration server
    echo -n "   Config server /actuator/info... "
    if curl -s "http://localhost:8888/actuator/info" | grep -q "app"; then
        echo "✅"
    else
        echo "❌"
    fi
    
    # Test service discovery
    echo -n "   Discovery server /eureka/apps... "
    if curl -s "http://localhost:8761/eureka/apps" | grep -q "application"; then
        echo "✅"
    else
        echo "❌"
    fi
    
    # Test Vault
    echo -n "   Vault status... "
    if curl -s "http://localhost:8200/v1/sys/health" | grep -q "sealed.*false"; then
        echo "✅"
    else
        echo "❌"
    fi
}

# Main execution
case "${1:-all}" in
    "endpoints")
        test_all_endpoints
        ;;
    "health")
        check_container_health
        ;;
    "ports")
        show_service_ports
        ;;
    "smoke")
        run_smoke_tests
        ;;
    "all")
        check_container_health
        show_service_ports
        test_all_endpoints
        run_smoke_tests
        ;;
    *)
        echo "Usage: $0 {all|endpoints|health|ports|smoke}"
        echo ""
        echo "  all       - Run all tests (default)"
        echo "  endpoints - Test HTTP endpoints"
        echo "  health    - Check container health"
        echo "  ports     - Check port availability"
        echo "  smoke     - Run smoke tests"
        exit 1
        ;;
esac