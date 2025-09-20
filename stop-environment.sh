#!/bin/bash

echo "🛑 Stopping Kotlin Microservices Environment"
echo "============================================="

# Function to stop services gracefully
stop_services() {
    echo ""
    echo "📊 Current service status:"
    docker-compose ps
    
    echo ""
    echo "🔄 Stopping all services gracefully..."
    
    # Stop in reverse order (business services first)
    echo "🏪 Stopping business services..."
    docker-compose stop ms-kotlin-order-service ms-kotlin-product-service
    
    echo "🌐 Stopping core services..."
    docker-compose stop ms-kotlin-discover-server ms-kotlin-configuration-server
    
    echo "🔧 Stopping infrastructure services..."
    docker-compose stop ms-kotlin-vault ms-kotlin-kafka-ui ms-kotlin-kafka ms-kotlin-zookeeper
    
    echo ""
    echo "🗑️  Removing containers..."
    docker-compose down
}

# Function to clean up (optional)
cleanup() {
    echo ""
    echo "🧹 Cleaning up Docker resources..."
    
    # Remove unused networks
    echo "   Removing unused networks..."
    docker network prune -f
    
    # Remove unused volumes (be careful with this)
    echo "   Removing unused volumes..."
    docker volume prune -f
    
    # Remove unused images (optional)
    read -p "🗑️  Remove unused Docker images? (y/N): " remove_images
    if [[ $remove_images =~ ^[Yy]$ ]]; then
        echo "   Removing unused images..."
        docker image prune -f
    fi
}

# Function to show status after stop
show_final_status() {
    echo ""
    echo "📊 Final Status:"
    echo "================"
    
    # Check if any containers are still running
    running_containers=$(docker ps --filter "name=ms-kotlin-backend" --format "table {{.Names}}\t{{.Status}}" 2>/dev/null)
    
    if [ -z "$running_containers" ]; then
        echo "✅ All microservices containers stopped"
    else
        echo "⚠️  Some containers still running:"
        echo "$running_containers"
    fi
    
    # Check ports
    echo ""
    echo "🔌 Port Status:"
    ports=(8082 8083 8200 8761 8888 8090 9092 2181)
    
    for port in "${ports[@]}"; do
        if netstat -an 2>/dev/null | grep ":$port " | grep -q LISTEN; then
            echo "   Port $port: ⚠️  Still in use"
        else
            echo "   Port $port: ✅ Available"
        fi
    done
}

# Main execution
main() {
    stop_services
    
    # Ask for cleanup
    echo ""
    read -p "🧹 Run cleanup (remove unused Docker resources)? (y/N): " do_cleanup
    if [[ $do_cleanup =~ ^[Yy]$ ]]; then
        cleanup
    fi
    
    show_final_status
    
    echo ""
    echo "🎉 Environment stopped successfully!"
    echo ""
    echo "💡 To start again:"
    echo "   ./start-environment.sh"
}

# Handle script arguments
case "${1:-stop}" in
    "stop")
        main
        ;;
    "force")
        echo "🚨 Force stopping all containers..."
        docker-compose down --remove-orphans
        docker container prune -f
        echo "✅ Force stop complete"
        ;;
    "clean")
        echo "🧹 Deep cleaning Docker environment..."
        docker-compose down --remove-orphans --volumes
        docker system prune -af --volumes
        echo "✅ Deep clean complete"
        ;;
    *)
        echo "Usage: $0 {stop|force|clean}"
        echo ""
        echo "  stop   - Graceful shutdown (default)"
        echo "  force  - Force remove all containers"
        echo "  clean  - Deep clean (removes volumes and images)"
        exit 1
        ;;
esac