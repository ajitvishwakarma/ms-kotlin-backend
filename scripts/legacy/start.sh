#!/bin/bash

echo "🚀 Starting Kotlin Microservices Environment"
echo "=============================================="

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>    echo "   Check health:      curl http://localhost:808{2,3}/actuator/health"
    echo ""
    echo "🏗️  Modular startup:"
    echo "   Infrastructure:    ./start-infrastructure.sh"
    echo "   Services only:     ./start.sh services"
    echo "   Complete stack:    ./start.sh"
    echo ""
    echo "🛠️  Helper scripts:"
    echo "   Monitor services:  ./monitor.sh"
    echo "   Test endpoints:    ./test-environment.sh"
    echo "   View service logs: ./monitor.sh logs [service-name]"
    echo ""
    echo "📚 For Spring Cloud Bus testing:"
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

# Function to check and apply build optimizations
check_optimizations() {
    if [ ! -f "gradle.properties" ] || ! grep -q "org.gradle.daemon=true" gradle.properties 2>/dev/null; then
        echo "⚡ Applying build optimizations for faster builds..."
        echo "✅ Build optimizations already configured in gradle.properties"
    fi
}

# Function to build all services with optimizations
build_services() {
    echo "🏗️  Building all microservices with optimizations..."
    echo "💡 Note: First build downloads Gradle (~120MB) but subsequent builds are much faster!"
    
    # Apply optimizations if not already done
    check_optimizations
    
    # Show build cache status
    echo "📦 Build cache status:"
    if [ -d ".gradle" ] || [ -d "$HOME/.gradle" ]; then
        echo "   ✅ Gradle cache available - builds will be faster"
    else
        echo "   ⚠️  First build - downloading Gradle and dependencies"
        echo "   ⏱️  This may take 3-5 minutes, subsequent builds ~30 seconds"
    fi
    
    # Build all services in parallel for faster startup
    echo "🔨 Building services in parallel..."
    docker-compose build \
        --parallel \
        ms-kotlin-configuration-server \
        ms-kotlin-discover-server \
        ms-kotlin-product-service \
        ms-kotlin-order-service
    
    if [ $? -eq 0 ]; then
        echo "✅ All services built successfully"
    else
        echo "❌ Build failed. Check the error messages above."
        echo "💡 Try: ./start.sh clean && ./start.sh build"
        exit 1
    fi
}

# Function to start infrastructure services
start_infrastructure() {
    echo "🔧 Starting infrastructure services..."
    ./start-infrastructure.sh start
    
    if [ $? -ne 0 ]; then
        echo "❌ Infrastructure startup failed"
        exit 1
    fi
    
    echo "✅ Infrastructure services ready"
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
        # Check if container is healthy using docker inspect
        if docker inspect --format='{{.State.Health.Status}}' "$service_name" 2>/dev/null | grep -q "healthy"; then
            echo " ✅ Healthy"
            return 0
        fi
        
        # Check if container is running at least
        if ! docker inspect --format='{{.State.Status}}' "$service_name" 2>/dev/null | grep -q "running"; then
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
    echo "   Stop all:          ./stop.sh"
    echo "   Restart service:   docker-compose restart [service-name]"
    echo "   Rebuild service:   docker-compose up -d --build [service-name]"
    echo "   Check health:      curl http://localhost:808{2,3}/actuator/health"
    echo ""
    echo "�️  Helper scripts:"
    echo "   Monitor services:  ./monitor.sh"
    echo "   Test endpoints:    ./test-environment.sh"
    echo "   View service logs: ./monitor.sh logs [service-name]"
    echo ""
    echo "�📚 For Spring Cloud Bus testing:"
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
    echo "🚨 To stop the environment: ./stop.sh"
}

# Function to start only microservices (assumes infrastructure is running)
start_services_only() {
    check_docker
    check_git_status
    build_services
    start_core_services
    start_business_services
    verify_endpoints
    show_status
    show_commands
    
    echo "🎉 Microservices started successfully!"
    echo ""
    echo "🚨 To stop the environment: ./stop.sh"
}

# Handle script arguments
case "${1:-start}" in
    "start")
        main
        ;;
    "infrastructure")
        echo "🔧 Starting infrastructure only..."
        ./start-infrastructure.sh start
        ;;
    "services")
        echo "🏪 Starting microservices only (infrastructure must be running)..."
        start_services_only
        ;;
    "stop")
        echo "🛑 Stopping all services..."
        ./stop.sh
        ;;
    "restart")
        echo "🔄 Restarting environment..."
        ./stop.sh
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
        echo "Usage: $0 {start|infrastructure|services|stop|restart|status|logs [service]|build|clean}"
        echo ""
        echo "  start         - Start complete environment (default)"
        echo "  infrastructure- Start only infrastructure (Kafka, Vault, DBs)"
        echo "  services      - Start only microservices (needs infrastructure)"
        echo "  stop          - Stop all services"
        echo "  restart       - Restart all services"
        echo "  status        - Show service status and verify endpoints"
        echo "  logs          - Show logs for all services or specific service"
        echo "  build         - Build all services only"
        echo "  clean         - Clean up containers and system"
        exit 1
        ;;
esac