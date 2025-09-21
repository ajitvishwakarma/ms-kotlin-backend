#!/bin/bash

echo "🏗️  Centralized Infrastructure Management"
echo "========================================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$SCRIPT_DIR"

# Function to create network if it doesn't exist
ensure_network() {
    if ! docker network inspect ms-kotlin-microservices-network > /dev/null 2>&1; then
        echo "🌐 Creating microservices network..."
        docker network create ms-kotlin-microservices-network
        echo "   ✅ Network created"
    else
        echo "✅ Network already exists"
    fi
}

# Function to start all infrastructure
start_all() {
    echo "🚀 Starting all infrastructure services..."
    echo ""
    
    ensure_network
    
    echo "1️⃣  Starting databases..."
    cd "$INFRA_DIR/databases"
    ./manage-databases.sh start
    
    echo ""
    echo "2️⃣  Starting Kafka messaging..."
    cd "$INFRA_DIR/kafka"
    ./manage-kafka.sh start
    
    echo ""
    echo "3️⃣  Starting Vault secrets..."
    cd "$INFRA_DIR/vault"
    ./manage-vault.sh start
    
    echo ""
    echo "✅ All infrastructure services started!"
    show_status
}

# Function to stop all infrastructure
stop_all() {
    echo "🛑 Stopping all infrastructure services..."
    echo ""
    
    echo "1️⃣  Stopping Vault..."
    cd "$INFRA_DIR/vault"
    ./manage-vault.sh stop
    
    echo ""
    echo "2️⃣  Stopping Kafka..."
    cd "$INFRA_DIR/kafka"
    ./manage-kafka.sh stop
    
    echo ""
    echo "3️⃣  Stopping databases..."
    cd "$INFRA_DIR/databases"
    ./manage-databases.sh stop
    
    echo ""
    echo "✅ All infrastructure services stopped!"
}

# Function to show status
show_status() {
    echo ""
    echo "📊 Infrastructure Status:"
    echo "========================"
    echo ""
    
    echo "💾 Databases:"
    cd "$INFRA_DIR/databases"
    docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "   Not running"
    
    echo ""
    echo "📨 Kafka:"
    cd "$INFRA_DIR/kafka"
    docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "   Not running"
    
    echo ""
    echo "🔐 Vault:"
    cd "$INFRA_DIR/vault"
    docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "   Not running"
    
    echo ""
    echo "🌐 Access URLs:"
    echo "=============="
    echo "   Kafka UI:  http://localhost:8090"
    echo "   Vault:     http://localhost:8200 (token: myroot)"
    echo "   MongoDB:   mongodb://localhost:27018/product-service"
    echo "   MySQL:     jdbc:mysql://root:@localhost:3307/order-service"
}

# Function to restart all infrastructure
restart_all() {
    echo "🔄 Restarting all infrastructure..."
    stop_all
    sleep 2
    start_all
}

# Function to health check all services
health_check() {
    echo "🏥 Infrastructure Health Check:"
    echo "==============================="
    echo ""
    
    # Check databases
    echo "💾 Databases:"
    if docker exec ms-kotlin-mongodb mongosh --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
        echo "   ✅ MongoDB healthy"
    else
        echo "   ❌ MongoDB unhealthy"
    fi
    
    if docker exec ms-kotlin-mysql mysqladmin ping -h localhost > /dev/null 2>&1; then
        echo "   ✅ MySQL healthy"
    else
        echo "   ❌ MySQL unhealthy"
    fi
    
    # Check Kafka
    echo "📨 Kafka:"
    if docker exec ms-kotlin-kafka kafka-broker-api-versions --bootstrap-server localhost:9092 > /dev/null 2>&1; then
        echo "   ✅ Kafka healthy"
    else
        echo "   ❌ Kafka unhealthy"
    fi
    
    if curl -s http://localhost:8090 > /dev/null 2>&1; then
        echo "   ✅ Kafka UI healthy"
    else
        echo "   ❌ Kafka UI unhealthy"
    fi
    
    # Check Vault
    echo "🔐 Vault:"
    if curl -s http://localhost:8200/v1/sys/health > /dev/null 2>&1; then
        echo "   ✅ Vault healthy"
    else
        echo "   ❌ Vault unhealthy"
    fi
}

# Main execution
case "${1:-start}" in
    "start")
        start_all
        ;;
    "stop")
        stop_all
        ;;
    "restart")
        restart_all
        ;;
    "status")
        show_status
        ;;
    "health")
        health_check
        ;;
    "databases")
        echo "💾 Managing databases only..."
        cd "$INFRA_DIR/databases"
        ./manage-databases.sh "${2:-start}"
        ;;
    "kafka")
        echo "📨 Managing Kafka only..."
        cd "$INFRA_DIR/kafka"
        ./manage-kafka.sh "${2:-start}"
        ;;
    "vault")
        echo "🔐 Managing Vault only..."
        cd "$INFRA_DIR/vault"
        ./manage-vault.sh "${2:-start}"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|health|databases|kafka|vault} [action]"
        echo ""
        echo "General Commands:"
        echo "  start     - Start all infrastructure services"
        echo "  stop      - Stop all infrastructure services"
        echo "  restart   - Restart all infrastructure services"
        echo "  status    - Show status of all services"
        echo "  health    - Perform health check on all services"
        echo ""
        echo "Individual Services:"
        echo "  databases [action] - Manage databases only"
        echo "  kafka [action]     - Manage Kafka only"
        echo "  vault [action]     - Manage Vault only"
        echo ""
        echo "Available actions for individual services:"
        echo "  start, stop, restart, status"
        exit 1
        ;;
esac