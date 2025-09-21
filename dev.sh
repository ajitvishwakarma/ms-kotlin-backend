#!/bin/bash

# =============================================================================
# 🚀 KOTLIN MICROSERVICES - DEVELOPMENT SCRIPT
# =============================================================================
# Simple, unified script for all development tasks
# Usage: ./dev.sh {start|stop|restart|status|logs|build|clean}

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# 🎨 HELPER FUNCTIONS
# =============================================================================

show_banner() {
    echo "🚀 Kotlin Microservices - Development Environment"
    echo "=================================================="
}

check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo "❌ Docker is not running. Please start Docker first."
        exit 1
    fi
}

show_status() {
    echo "📊 Service Status:"
    echo "=================="
    docker-compose -f docker-compose-services.yml ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "No services running"
    
    echo ""
    echo "🌐 Access URLs:"
    echo "==============="
    echo "   Kafka UI:         http://localhost:8090"
    echo "   Eureka Discovery: http://localhost:8761"
    echo "   Config Server:    http://localhost:8888"
    echo "   Product Service:  http://localhost:8082"
    echo "   Order Service:    http://localhost:8083"
    echo "   Vault:            http://localhost:8200 (token: myroot)"
}

check_health() {
    echo "🏥 Health Check:"
    echo "================"
    
    local services=("ms-kotlin-mongodb" "ms-kotlin-mysql" "ms-kotlin-kafka" "ms-kotlin-vault")
    
    for service in "${services[@]}"; do
        if docker inspect --format='{{.State.Status}}' "$service" 2>/dev/null | grep -q "running"; then
            local health=$(docker inspect --format='{{.State.Health.Status}}' "$service" 2>/dev/null || echo "no-check")
            if [ "$health" = "healthy" ]; then
                echo "   ✅ $service"
            elif [ "$health" = "no-check" ]; then
                echo "   ⚠️  $service (no health check)"
            else
                echo "   ⚠️  $service ($health)"
            fi
        else
            echo "   ❌ $service (not running)"
        fi
    done
}

show_access_urls() {
    echo ""
    echo "🌐 Quick Access:"
    echo "==============="
    echo "   📊 Kafka UI:     http://localhost:8090"
    echo "   🔍 Discovery:    http://localhost:8761"
    echo "   ⚙️  Config:       http://localhost:8888"
    echo "   📦 Products:     http://localhost:8082"
    echo "   📋 Orders:       http://localhost:8083"
    echo "   🔐 Vault:        http://localhost:8200"
}

# =============================================================================
# 🚀 MAIN FUNCTIONS
# =============================================================================

start_environment() {
    show_banner
    check_docker
    
    echo "🏗️ Starting infrastructure..."
    ./infra.sh start
    
    echo ""
    echo "🔨 Building microservices..."
    docker-compose -f docker-compose-services.yml build --parallel
    
    echo ""
    echo "🚀 Starting microservices..."
    docker-compose -f docker-compose-services.yml up -d ms-kotlin-configuration-server
    echo "   ⏳ Waiting for Config Server..."
    sleep 15
    
    docker-compose -f docker-compose-services.yml up -d ms-kotlin-discover-server
    echo "   ⏳ Waiting for Discovery Server..."
    sleep 10
    
    docker-compose -f docker-compose-services.yml up -d ms-kotlin-product-service ms-kotlin-order-service
    echo "   ⏳ Waiting for Business Services..."
    sleep 15
    
    echo ""
    echo "✅ Environment started!"
    show_status
}

stop_environment() {
    echo "🛑 Stopping environment..."
    docker-compose -f docker-compose-services.yml down --remove-orphans 2>/dev/null || true
    ./infra.sh stop
    echo "✅ Environment stopped!"
}

restart_environment() {
    stop_environment
    echo ""
    start_environment
}

show_logs() {
    echo "📝 Service Logs:"
    echo "================"
    docker-compose -f docker-compose-services.yml logs --tail=50 -f
}

build_services() {
    echo "🔨 Building microservices..."
    docker-compose -f docker-compose-services.yml build --parallel
    echo "✅ Build completed!"
}

clean_environment() {
    echo "🧹 Cleaning environment..."
    stop_environment
    docker-compose -f docker-compose-services.yml down --volumes --remove-orphans 2>/dev/null || true
    docker system prune -f
    echo "✅ Environment cleaned!"
}

show_help() {
    echo "🚀 Kotlin Microservices - Development Script"
    echo "============================================="
    echo ""
    echo "Usage: ./dev.sh {command}"
    echo ""
    echo "Commands:"
    echo "  start    - Start infrastructure + all microservices"
    echo "  stop     - Stop all services"
    echo "  restart  - Stop and start everything"
    echo "  status   - Show service status and URLs"
    echo "  logs     - Show service logs (follow mode)"
    echo "  build    - Build microservices"
    echo "  clean    - Stop and clean everything"
    echo "  help     - Show this help"
    echo ""
    echo "Examples:"
    echo "  ./dev.sh start     # Start everything for development"
    echo "  ./dev.sh status    # Check what's running"
    echo "  ./dev.sh logs      # Watch logs"
    echo "  ./dev.sh clean     # Clean shutdown"
}

# =============================================================================
# 📝 MAIN EXECUTION
# =============================================================================

case "${1:-}" in
    "start")
        start_environment
        ;;
    "stop")
        stop_environment
        ;;
    "restart")
        restart_environment
        ;;
    "status")
        show_status
        ;;
    "logs")
        show_logs
        ;;
    "build")
        build_services
        ;;
    "clean")
        clean_environment
        ;;
    "help"|"--help"|"-h")
        show_help
        ;;
    "")
        show_help
        ;;
    *)
        echo "❌ Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac