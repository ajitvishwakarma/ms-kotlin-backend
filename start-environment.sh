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

# Function to build and start services
start_services() {
    echo ""
    echo "📦 Building and starting all services..."
    echo "This may take a few minutes on first run..."
    
    # Start infrastructure first
    echo "🔧 Starting infrastructure services (Kafka, Vault, etc.)..."
    docker-compose up -d ms-kotlin-zookeeper ms-kotlin-kafka ms-kotlin-kafka-ui ms-kotlin-vault
    
    echo "⏳ Waiting for infrastructure to be ready..."
    sleep 30
    
    # Start core services
    echo "🌐 Starting configuration and discovery services..."
    docker-compose up -d ms-kotlin-configuration-server ms-kotlin-discover-server
    
    echo "⏳ Waiting for core services to be ready..."
    sleep 45
    
    # Start business services
    echo "🏪 Starting business services..."
    docker-compose up -d ms-kotlin-product-service ms-kotlin-order-service
    
    echo "⏳ Waiting for all services to be ready..."
    sleep 30
}

# Function to show service status
show_status() {
    echo ""
    echo "📊 Service Status:"
    echo "=================="
    docker-compose ps
    
    echo ""
    echo "🌐 Service URLs:"
    echo "================"
    echo "📋 Kafka UI:           http://localhost:8090"
    echo "🔐 Vault:              http://localhost:8200"
    echo "⚙️  Configuration:      http://localhost:8888"
    echo "🔍 Service Discovery:  http://localhost:8761"
    echo "📦 Product Service:    http://localhost:8082"
    echo "🛒 Order Service:      http://localhost:8083"
    
    echo ""
    echo "🧪 Test Endpoints:"
    echo "=================="
    echo "Product Test:      GET  http://localhost:8082/api/test"
    echo "Product Health:    GET  http://localhost:8082/actuator/health"
    echo "Bus Refresh:       POST http://localhost:8082/actuator/busrefresh"
    echo ""
}

# Function to wait for services to be healthy
wait_for_services() {
    echo "🔍 Checking service health..."
    
    services=("ms-kotlin-kafka-ui:8090" "ms-kotlin-vault:8200" "ms-kotlin-configuration-server:8888" "ms-kotlin-discover-server:8761" "ms-kotlin-product-service:8082" "ms-kotlin-order-service:8083")
    
    for service in "${services[@]}"; do
        name=$(echo $service | cut -d: -f1)
        port=$(echo $service | cut -d: -f2)
        
        echo -n "   Waiting for $name..."
        for i in {1..30}; do
            if curl -s "http://localhost:$port/actuator/health" > /dev/null 2>&1 || 
               curl -s "http://localhost:$port" > /dev/null 2>&1; then
                echo " ✅ Ready"
                break
            fi
            if [ $i -eq 30 ]; then
                echo " ⚠️  Timeout (check logs: docker-compose logs $name)"
            fi
            sleep 2
        done
    done
}

# Main execution
main() {
    check_docker
    start_services
    wait_for_services
    show_status
    
    echo ""
    echo "🎉 Environment started successfully!"
    echo ""
    echo "💡 Useful commands:"
    echo "   View logs:     docker-compose logs -f [service-name]"
    echo "   Stop all:      docker-compose down"
    echo "   Restart:       docker-compose restart [service-name]"
    echo "   Rebuild:       docker-compose up -d --build [service-name]"
    echo ""
    echo "📚 For Spring Cloud Bus testing:"
    echo "   1. Test current config: GET http://localhost:8082/api/test"
    echo "   2. Change property in microservices-config-server/"
    echo "   3. Refresh all services: POST http://localhost:8082/actuator/busrefresh"
    echo "   4. Verify update: GET http://localhost:8082/api/test"
}

# Handle script arguments
case "${1:-start}" in
    "start")
        main
        ;;
    "stop")
        echo "🛑 Stopping all services..."
        docker-compose down
        ;;
    "restart")
        echo "🔄 Restarting environment..."
        docker-compose down
        main
        ;;
    "status")
        show_status
        ;;
    "logs")
        if [ -n "$2" ]; then
            docker-compose logs -f "$2"
        else
            docker-compose logs -f
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs [service-name]}"
        exit 1
        ;;
esac