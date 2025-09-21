#!/bin/bash

# =============================================================================
# 🏗️ KOTLIN MICROSERVICES - INFRASTRUCTURE SCRIPT
# =============================================================================
# Simple infrastructure management for databases, Kafka, and Vault
# Usage: ./infra.sh {start|stop|restart|status}

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# 🎨 HELPER FUNCTIONS
# =============================================================================

show_banner() {
    echo "🏗️ Infrastructure Management"
    echo "============================"
}

check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo "❌ Docker is not running. Please start Docker first."
        exit 1
    fi
}

ensure_network() {
    if ! docker network inspect ms-kotlin-microservices-network >/dev/null 2>&1; then
        echo "📡 Creating network ms-kotlin-microservices-network..."
        docker network create ms-kotlin-microservices-network
    fi
}

wait_for_service() {
    local service=$1
    local timeout=${2:-30}
    local count=0
    
    while [ $count -lt $timeout ]; do
        if docker inspect --format='{{.State.Health.Status}}' "$service" 2>/dev/null | grep -q "healthy"; then
            echo "   ⏳ $service ✅"
            return 0
        fi
        echo -n "."
        sleep 1
        count=$((count + 1))
    done
    echo "   ⏳ $service ⚠️ (timeout)"
}

# =============================================================================
# 🚀 MAIN FUNCTIONS  
# =============================================================================

start_infrastructure() {
    show_banner
    check_docker
    echo "🚀 Starting infrastructure services..."
    
    # Create network if it doesn't exist
    docker network create ms-kotlin-microservices-network 2>/dev/null || echo "   📡 Network already exists"
    
    echo "📊 Starting databases..."
    if cd infrastructure/databases && docker-compose up -d; then
        cd ../..
        wait_for_service "ms-kotlin-mongodb"
        wait_for_service "ms-kotlin-mysql"
    else
        echo "❌ Failed to start databases"
        return 1
    fi
    
    echo "📨 Starting Kafka..."
    if cd infrastructure/kafka && docker-compose up -d; then
        cd ../..
        wait_for_service "ms-kotlin-zookeeper"
        wait_for_service "ms-kotlin-kafka"
    else
        echo "❌ Failed to start Kafka"
        return 1
    fi
    
    echo "🔐 Starting Vault..."
    if cd infrastructure/vault && docker-compose up -d; then
        cd ../..
        echo "🔑 Loading secrets..."
        # TODO: Load vault secrets
        echo "   ⚠️ Vault secrets loading skipped"
    else
        echo "❌ Failed to start Vault"
        return 1
    fi
    
    echo ""
    echo "✅ Infrastructure ready!"
    show_infrastructure_status
}

stop_infrastructure() {
    show_banner
    echo "🛑 Stopping infrastructure..."
    
    cd "$SCRIPT_DIR/infrastructure/vault" && docker-compose down >/dev/null 2>&1 || true
    cd "$SCRIPT_DIR/infrastructure/kafka" && docker-compose down >/dev/null 2>&1 || true
    cd "$SCRIPT_DIR/infrastructure/databases" && docker-compose down >/dev/null 2>&1 || true
    cd "$SCRIPT_DIR"
    
    echo "✅ Infrastructure stopped!"
}

restart_infrastructure() {
    stop_infrastructure
    echo ""
    start_infrastructure
}

show_infrastructure_status() {
    echo "📊 Infrastructure Status:"
    echo "========================"
    
    local services=("ms-kotlin-mongodb" "ms-kotlin-mysql" "ms-kotlin-kafka" "ms-kotlin-kafka-ui" "ms-kotlin-vault")
    
    for service in "${services[@]}"; do
        if docker inspect --format='{{.State.Status}}' "$service" 2>/dev/null | grep -q "running"; then
            local health=$(docker inspect --format='{{.State.Health.Status}}' "$service" 2>/dev/null || echo "no-check")
            if [ "$health" = "healthy" ]; then
                echo "   ✅ $service (healthy)"
            elif [ "$health" = "no-check" ]; then
                echo "   ⚠️  $service (no health check)"
            else
                echo "   ⚠️  $service ($health)"
            fi
        else
            echo "   ❌ $service (not running)"
        fi
    done
    
    echo ""
    echo "🌐 Infrastructure URLs:"
    echo "======================"
    echo "   Kafka UI:  http://localhost:8090"
    echo "   Vault:     http://localhost:8200 (token: myroot)"
    echo "   MongoDB:   mongodb://localhost:27018/product-service"
    echo "   MySQL:     jdbc:mysql://root:@localhost:3307/order-service"
}

show_help() {
    echo "🏗️ Infrastructure Management"
    echo "============================"
    echo ""
    echo "Usage: ./infra.sh {command}"
    echo ""
    echo "Commands:"
    echo "  start      Start all infrastructure (databases, Kafka, Vault)"
    echo "  stop       Stop all infrastructure"
    echo "  restart    Restart all infrastructure"
    echo "  status     Show infrastructure status"
    echo ""
    echo "Infrastructure includes:"
    echo "  📊 Databases: MongoDB (27018), MySQL (3307)"
    echo "  📨 Messaging: Kafka (9092), Kafka UI (8090)"
    echo "  🔐 Security:  Vault (8200) with auto-loaded secrets"
}

# =============================================================================
# 📝 MAIN EXECUTION
# =============================================================================

case "${1:-}" in
    "start")
        start_infrastructure
        ;;
    "stop")
        stop_infrastructure
        ;;
    "restart")
        restart_infrastructure
        ;;
    "status")
        show_infrastructure_status
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