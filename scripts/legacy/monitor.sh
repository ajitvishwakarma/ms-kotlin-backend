#!/bin/bash

# Monitor startup progress
echo "📊 Monitoring Service Startup Progress"
echo "======================================"

# Function to get service status with color coding
get_status() {
    local service=$1
    if docker ps --format "table {{.Names}}" | grep -q "^$service$"; then
        local health=$(docker inspect --format='{{.State.Health.Status}}' "$service" 2>/dev/null || echo "no-health")
        local status=$(docker inspect --format='{{.State.Status}}' "$service" 2>/dev/null || echo "not-found")
        
        case "$health" in
            "healthy") echo "🟢 Healthy" ;;
            "unhealthy") echo "🔴 Unhealthy" ;;
            "starting") echo "🟡 Starting" ;;
            *) 
                case "$status" in
                    "running") echo "🟡 Running" ;;
                    "exited") echo "🔴 Exited" ;;
                    *) echo "⚫ $status" ;;
                esac
                ;;
        esac
    else
        echo "⚫ Not Started"
    fi
}

# Function to monitor all services
monitor_services() {
    local iteration=0
    
    while true; do
        clear
        echo "📊 Service Monitor - Iteration $((++iteration)) - $(date '+%H:%M:%S')"
        echo "=================================================================="
        echo ""
        
        echo "🏗️  Infrastructure Services:"
        printf "   %-25s %s\n" "Zookeeper:" "$(get_status ms-kotlin-zookeeper)"
        printf "   %-25s %s\n" "Kafka:" "$(get_status ms-kotlin-kafka)"
        printf "   %-25s %s\n" "Kafka UI:" "$(get_status ms-kotlin-kafka-ui)"
        printf "   %-25s %s\n" "Vault:" "$(get_status ms-kotlin-vault)"
        printf "   %-25s %s\n" "MongoDB:" "$(get_status ms-kotlin-mongodb)"
        printf "   %-25s %s\n" "MySQL:" "$(get_status ms-kotlin-mysql)"
        
        echo ""
        echo "🌐 Core Services:"
        printf "   %-25s %s\n" "Configuration Server:" "$(get_status ms-kotlin-configuration-server)"
        printf "   %-25s %s\n" "Discovery Server:" "$(get_status ms-kotlin-discover-server)"
        
        echo ""
        echo "🏪 Business Services:"
        printf "   %-25s %s\n" "Product Service:" "$(get_status ms-kotlin-product-service)"
        printf "   %-25s %s\n" "Order Service:" "$(get_status ms-kotlin-order-service)"
        
        echo ""
        echo "📈 Resource Usage:"
        echo "   Docker containers: $(docker ps -q | wc -l) running"
        echo "   Docker images: $(docker images -q | wc -l) total"
        echo "   Memory usage: $(docker stats --no-stream --format "table {{.Container}}\t{{.MemUsage}}" 2>/dev/null | tail -n +2 | wc -l) containers monitored"
        
        echo ""
        echo "💡 Commands:"
        echo "   Press Ctrl+C to exit monitoring"
        echo "   Run: ./test-environment.sh endpoints"
        echo "   Run: docker-compose logs -f [service-name]"
        
        sleep 3
    done
}

# Function to show logs for a specific service
show_logs() {
    local service=$1
    echo "📝 Showing logs for $service..."
    echo "================================"
    docker-compose logs --tail=50 -f "$service"
}

# Function to restart a service
restart_service() {
    local service=$1
    echo "🔄 Restarting $service..."
    docker-compose restart "$service"
    echo "✅ Restart initiated for $service"
}

# Handle arguments
case "${1:-monitor}" in
    "monitor")
        monitor_services
        ;;
    "logs")
        if [ -n "$2" ]; then
            show_logs "$2"
        else
            echo "Usage: $0 logs <service-name>"
            echo "Available services:"
            echo "  ms-kotlin-zookeeper"
            echo "  ms-kotlin-kafka"
            echo "  ms-kotlin-vault"
            echo "  ms-kotlin-mongodb"
            echo "  ms-kotlin-mysql"
            echo "  ms-kotlin-configuration-server"
            echo "  ms-kotlin-discover-server"
            echo "  ms-kotlin-product-service"
            echo "  ms-kotlin-order-service"
        fi
        ;;
    "restart")
        if [ -n "$2" ]; then
            restart_service "$2"
        else
            echo "Usage: $0 restart <service-name>"
        fi
        ;;
    *)
        echo "Usage: $0 {monitor|logs <service>|restart <service>}"
        echo ""
        echo "  monitor  - Real-time service monitoring (default)"
        echo "  logs     - Show logs for specific service"
        echo "  restart  - Restart specific service"
        exit 1
        ;;
esac