#!/bin/bash

echo "🔧 Starting Infrastructure Services"
echo "==================================="

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo "❌ Docker is not running. Please start Docker and try again."
        exit 1
    fi
    echo "✅ Docker is running"
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

# Function to start messaging infrastructure
start_messaging() {
    echo "📨 Starting messaging infrastructure (Zookeeper + Kafka)..."
    docker-compose up -d ms-kotlin-zookeeper
    
    echo "⏳ Waiting for Zookeeper to be healthy..."
    wait_for_health "ms-kotlin-zookeeper" 60
    
    echo "📨 Starting Kafka..."
    docker-compose up -d ms-kotlin-kafka
    
    echo "⏳ Waiting for Kafka to be healthy..."
    wait_for_health "ms-kotlin-kafka" 90
    
    echo "🖥️  Starting Kafka UI..."
    docker-compose up -d ms-kotlin-kafka-ui
    
    echo "✅ Messaging infrastructure ready"
}

# Function to start security infrastructure  
start_security() {
    echo "🔐 Starting security infrastructure (Vault)..."
    docker-compose up -d ms-kotlin-vault
    
    echo "⏳ Waiting for Vault to be healthy..."
    wait_for_health "ms-kotlin-vault" 30
    
    echo "✅ Security infrastructure ready"
}

# Function to start database infrastructure
start_databases() {
    echo "🗄️  Starting database infrastructure..."
    
    echo "   Starting MongoDB..."
    docker-compose up -d ms-kotlin-mongodb
    
    echo "   Starting MySQL..."
    docker-compose up -d ms-kotlin-mysql
    
    echo "⏳ Waiting for databases to be healthy..."
    wait_for_health "ms-kotlin-mongodb" 30
    wait_for_health "ms-kotlin-mysql" 30
    
    echo "✅ Database infrastructure ready"
}

# Function to verify infrastructure
verify_infrastructure() {
    echo "🔍 Verifying infrastructure endpoints..."
    
    local endpoints=(
        "Vault:http://localhost:8200/v1/sys/health"
        "Kafka UI:http://localhost:8090"
    )
    
    for endpoint in "${endpoints[@]}"; do
        name=$(echo $endpoint | cut -d: -f1)
        url=$(echo $endpoint | cut -d: -f2-)
        
        if curl -s -f "$url" > /dev/null 2>&1; then
            echo "   $name: ✅ Accessible"
        else
            echo "   $name: ⚠️  Not accessible (may still be starting)"
        fi
    done
}

# Function to show infrastructure status
show_infrastructure_status() {
    echo ""
    echo "📊 Infrastructure Status:"
    echo "========================="
    docker-compose ps ms-kotlin-zookeeper ms-kotlin-kafka ms-kotlin-kafka-ui ms-kotlin-vault ms-kotlin-mongodb ms-kotlin-mysql --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
    
    echo ""
    echo "🌐 Infrastructure URLs:"
    echo "======================="
    echo "📋 Kafka UI:    http://localhost:8090"
    echo "🔐 Vault:       http://localhost:8200"
    echo "🍃 MongoDB:     localhost:27018"
    echo "🐬 MySQL:       localhost:3307"
    echo "📨 Kafka:       localhost:9092"
    echo "🏠 Zookeeper:   localhost:2181"
}

# Function to stop infrastructure
stop_infrastructure() {
    echo "🛑 Stopping infrastructure services..."
    
    # Stop in reverse order
    echo "   Stopping Kafka UI..."
    docker-compose stop ms-kotlin-kafka-ui 2>/dev/null || true
    
    echo "   Stopping Kafka..."
    docker-compose stop ms-kotlin-kafka 2>/dev/null || true
    
    echo "   Stopping Zookeeper..."
    docker-compose stop ms-kotlin-zookeeper 2>/dev/null || true
    
    echo "   Stopping Vault..."
    docker-compose stop ms-kotlin-vault 2>/dev/null || true
    
    echo "   Stopping databases..."
    docker-compose stop ms-kotlin-mongodb ms-kotlin-mysql 2>/dev/null || true
    
    echo "✅ Infrastructure stopped"
}

# Function to restart infrastructure
restart_infrastructure() {
    echo "🔄 Restarting infrastructure..."
    stop_infrastructure
    sleep 2
    start_infrastructure
}

# Function to start all infrastructure
start_infrastructure() {
    check_docker
    
    echo "🚀 Starting complete infrastructure stack..."
    echo ""
    
    # Start in dependency order
    start_messaging
    echo ""
    start_security  
    echo ""
    start_databases
    echo ""
    
    verify_infrastructure
    show_infrastructure_status
    
    echo ""
    echo "🎉 Infrastructure started successfully!"
    echo ""
    echo "💡 Next steps:"
    echo "   - Start microservices: ./start.sh services"
    echo "   - Monitor infrastructure: ./monitor.sh"
    echo "   - Test infrastructure: ./test-environment.sh"
}

# Main execution function
main() {
    case "${1:-start}" in
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
            verify_infrastructure
            ;;
        "messaging")
            check_docker
            start_messaging
            ;;
        "security")
            check_docker
            start_security
            ;;
        "databases")
            check_docker
            start_databases
            ;;
        *)
            echo "Usage: $0 {start|stop|restart|status|messaging|security|databases}"
            echo ""
            echo "  start      - Start all infrastructure (default)"
            echo "  stop       - Stop all infrastructure"
            echo "  restart    - Restart all infrastructure"
            echo "  status     - Show infrastructure status"
            echo "  messaging  - Start only messaging (Zookeeper + Kafka)"
            echo "  security   - Start only security (Vault)"
            echo "  databases  - Start only databases (MongoDB + MySQL)"
            exit 1
            ;;
    esac
}

main "$@"