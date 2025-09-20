#!/bin/bash

echo "🚀 Starting Kotlin Microservices Environment"
echo "=============================================="

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo "❌ Docker is not running. Please start Docker and try again."
        exit 1
    fi
    echo "✅ Docker is running"
}

# Function to check if Git is available and clean workspace
check_git_status() {
    echo "🔍 Checking Git status..."
    if git status --porcelain | grep -q .; then
        echo "⚠️  Uncommitted changes detected. Committing automatically..."
        git add .
        git commit -m "auto: pre-deployment commit - $(date)"
    fi
    echo "✅ Git workspace is clean"
}

# Function to clean up any existing containers
cleanup_existing() {
    echo "🧹 Cleaning up any existing containers..."
    docker-compose down --remove-orphans > /dev/null 2>&1 || true
    docker container prune -f > /dev/null 2>&1 || true
    echo "✅ Cleanup completed"
}

# Function to build all services
build_services() {
    echo "🏗️  Building all microservices..."
    echo "This may take a few minutes on first run or after code changes..."
    
    # Build all services in parallel for faster startup
    docker-compose build \
        ms-kotlin-configuration-server \
        ms-kotlin-discover-server \
        ms-kotlin-product-service \
        ms-kotlin-order-service
    
    if [ $? -eq 0 ]; then
        echo "✅ All services built successfully"
    else
        echo "❌ Build failed. Check the error messages above."
        exit 1
    fi
}

# Function to start infrastructure services
start_infrastructure() {
    echo "🔧 Starting infrastructure services (Kafka, Vault, Databases, etc.)..."
    docker-compose up -d \
        ms-kotlin-zookeeper \
        ms-kotlin-kafka \
        ms-kotlin-kafka-ui \
        ms-kotlin-vault \
        ms-kotlin-mongodb \
        ms-kotlin-mysql

    echo "⏳ Waiting for infrastructure to be healthy..."
    wait_for_health "ms-kotlin-zookeeper" 60
    wait_for_health "ms-kotlin-kafka" 90
    wait_for_health "ms-kotlin-vault" 30
    wait_for_health "ms-kotlin-mongodb" 30
    wait_for_health "ms-kotlin-mysql" 30
    
    echo "✅ All infrastructure services are healthy"
}

# Function to start core services
start_core_services() {
    echo "🌐 Starting configuration and discovery services..."
    docker-compose up -d ms-kotlin-configuration-server
    
    echo "⏳ Waiting for configuration server to be healthy..."
    wait_for_health "ms-kotlin-configuration-server" 120
    
    docker-compose up -d ms-kotlin-discover-server
    
    echo "⏳ Waiting for discovery server to be healthy..."
    wait_for_health "ms-kotlin-discover-server" 90
    
    echo "✅ Core services are healthy"
}

# Function to start business services
start_business_services() {
    echo "🏪 Starting business services..."
    docker-compose up -d \
        ms-kotlin-product-service \
        ms-kotlin-order-service
    
    echo "⏳ Waiting for business services to be healthy..."
    wait_for_health "ms-kotlin-product-service" 120
    wait_for_health "ms-kotlin-order-service" 120
    
    echo "✅ All business services are healthy"
}

# Function to wait for service health
wait_for_health() {
    local service_name=$1
    local timeout=${2:-60}
    local count=0
    local interval=5
    
    echo -n "   Waiting for $service_name..."
    
    while [ $count -lt $timeout ]; do
        if docker-compose ps --format json | jq -r ".[] | select(.Name==\"$service_name\") | .Health" | grep -q "healthy"; then
            echo " ✅ Healthy"
            return 0
        fi
        
        # Check if container is running at least
        if ! docker-compose ps --format json | jq -r ".[] | select(.Name==\"$service_name\") | .State" | grep -q "running"; then
            echo " ❌ Container stopped"
            docker-compose logs --tail=20 "$service_name"
            return 1
        fi
        
        echo -n "."
        sleep $interval
        count=$((count + interval))
    done
    
    echo " ⚠️  Timeout after ${timeout}s"
    docker-compose logs --tail=20 "$service_name"
    return 1
}

# Function to verify all endpoints
verify_endpoints() {
    echo "🔍 Verifying service endpoints..."
    
    local endpoints=(
        "Configuration Server:http://localhost:8888/actuator/health"
        "Discovery Server:http://localhost:8761/actuator/health"
        "Product Service:http://localhost:8082/actuator/health"
        "Order Service:http://localhost:8083/actuator/health"
        "Kafka UI:http://localhost:8090"
        "Vault:http://localhost:8200/v1/sys/health"
    )
    
    for endpoint in "${endpoints[@]}"; do
        name=$(echo $endpoint | cut -d: -f1)
        url=$(echo $endpoint | cut -d: -f2-)
        
        if curl -s -f "$url" > /dev/null 2>&1; then
            echo "   $name: ✅ Accessible"
        else
            echo "   $name: ⚠️  Not accessible"
        fi
    done
}

# Function to show service status
show_status() {
    echo ""
    echo "📊 Service Status:"
    echo "=================="
    docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
    
    echo ""
    echo "🌐 Service URLs:"
    echo "================"
    echo "📋 Kafka UI:           http://localhost:8090"
    echo "🔐 Vault:              http://localhost:8200"
    echo "⚙️  Configuration:      http://localhost:8888"
    echo "🔍 Service Discovery:  http://localhost:8761"
    echo "📦 Product Service:    http://localhost:8082"
    echo "🛒 Order Service:      http://localhost:8083"
    echo "🍃 MongoDB:            localhost:27018"
    echo "🐬 MySQL:              localhost:3307"
    
    echo ""
    echo "🧪 Test Endpoints:"
    echo "=================="
    echo "Health Checks:     GET  http://localhost:808{2,3}/actuator/health"
    echo "Service Info:      GET  http://localhost:808{2,3}/actuator/info"
    echo "Config Refresh:    POST http://localhost:808{2,3}/actuator/refresh"
    echo "Bus Refresh:       POST http://localhost:8082/actuator/busrefresh"
    echo ""
}

# Function to show useful commands
show_commands() {
    echo "💡 Useful commands:"
    echo "   View logs:         docker-compose logs -f [service-name]"
    echo "   Stop all:          ./stop-environment.sh"
    echo "   Restart service:   docker-compose restart [service-name]"
    echo "   Rebuild service:   docker-compose up -d --build [service-name]"
    echo "   Check health:      curl http://localhost:808{2,3}/actuator/health"
    echo ""
    echo "📚 For Spring Cloud Bus testing:"
    echo "   1. Test config:    curl http://localhost:8082/api/test"
    echo "   2. Change property in microservices-config-server/"
    echo "   3. Refresh all:    curl -X POST http://localhost:8082/actuator/busrefresh"
    echo "   4. Verify update:  curl http://localhost:8082/api/test"
    echo ""
}

# Main execution function
main() {
    check_docker
    check_git_status
    cleanup_existing
    build_services
    start_infrastructure
    start_core_services
    start_business_services
    verify_endpoints
    show_status
    show_commands
    
    echo "🎉 Environment started successfully!"
    echo ""
    echo "🚨 To stop the environment: ./stop-environment.sh"
}

# Handle script arguments
case "${1:-start}" in
    "start")
        main
        ;;
    "stop")
        echo "🛑 Stopping all services..."
        ./stop-environment.sh
        ;;
    "restart")
        echo "🔄 Restarting environment..."
        ./stop-environment.sh
        main
        ;;
    "status")
        show_status
        verify_endpoints
        ;;
    "logs")
        if [ -n "$2" ]; then
            docker-compose logs -f "$2"
        else
            docker-compose logs -f
        fi
        ;;
    "build")
        check_docker
        build_services
        ;;
    "clean")
        cleanup_existing
        docker system prune -f
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs [service]|build|clean}"
        echo ""
        echo "  start    - Start all services (default)"
        echo "  stop     - Stop all services"
        echo "  restart  - Restart all services"
        echo "  status   - Show service status and verify endpoints"
        echo "  logs     - Show logs for all services or specific service"
        echo "  build    - Build all services only"
        echo "  clean    - Clean up containers and system"
        exit 1
        ;;
esac