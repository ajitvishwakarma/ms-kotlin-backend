#!/bin/bash

echo "🛑 Stopping Kotlin Microservices Environment"
echo "============================================="

# Function to show current status
show_current_status() {
    echo ""
    echo "📊 Current service status:"
    docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "No services running"
}

# Function to stop services gracefully in reverse order
stop_services_gracefully() {
    echo ""
    echo "🔄 Stopping all services gracefully..."
    
    # Stop in reverse order (business services first)
    echo "🏪 Stopping business services..."
    docker-compose stop ms-kotlin-order-service ms-kotlin-product-service 2>/dev/null || true
    
    echo "🌐 Stopping core services..."
    docker-compose stop ms-kotlin-discover-server ms-kotlin-configuration-server 2>/dev/null || true
    
    echo "🔧 Stopping infrastructure services..."
    docker-compose stop ms-kotlin-vault ms-kotlin-kafka-ui ms-kotlin-kafka ms-kotlin-zookeeper 2>/dev/null || true
    
    echo "🗄️  Stopping databases..."
    docker-compose stop ms-kotlin-mongodb ms-kotlin-mysql 2>/dev/null || true
    
    echo ""
    echo "🗑️  Removing containers and networks..."
    docker-compose down --remove-orphans 2>/dev/null || true
}

# Function to force stop everything
force_stop() {
    echo ""
    echo "🚨 Force stopping all containers..."
    docker-compose down --remove-orphans 2>/dev/null || true
    
    # Stop any containers that might still be running
    docker ps -q --filter "name=ms-kotlin-" | xargs -r docker stop
    docker ps -aq --filter "name=ms-kotlin-" | xargs -r docker rm
    
    echo "✅ Force stop complete"
}

# Function to clean up Docker resources
cleanup_resources() {
    echo ""
    echo "🧹 Cleaning up Docker resources..."
    
    # Remove unused networks
    echo "   Removing unused networks..."
    docker network prune -f 2>/dev/null || true
    
    # Remove unused volumes (with confirmation for persistent data)
    read -p "🗄️  Remove database volumes (will delete all data)? (y/N): " remove_volumes
    if [[ $remove_volumes =~ ^[Yy]$ ]]; then
        echo "   Removing volumes..."
        docker volume prune -f 2>/dev/null || true
        docker volume rm ms-kotlin-backend_ms-kotlin-mongodb-data ms-kotlin-backend_ms-kotlin-mysql-data 2>/dev/null || true
        echo "   ⚠️  Database data has been deleted"
    else
        echo "   Database volumes preserved"
    fi
    
    # Remove unused images (optional)
    read -p "🗑️  Remove unused Docker images? (y/N): " remove_images
    if [[ $remove_images =~ ^[Yy]$ ]]; then
        echo "   Removing unused images..."
        docker image prune -f 2>/dev/null || true
        echo "   Removed unused images"
    fi
}

# Function to deep clean everything
deep_clean() {
    echo ""
    echo "🧹 Deep cleaning Docker environment..."
    echo "⚠️  This will remove ALL Docker containers, images, volumes, and networks!"
    read -p "Are you sure? (y/N): " confirm_clean
    
    if [[ $confirm_clean =~ ^[Yy]$ ]]; then
        docker-compose down --remove-orphans --volumes 2>/dev/null || true
        docker system prune -af --volumes 2>/dev/null || true
        echo "✅ Deep clean complete - everything removed"
    else
        echo "❌ Deep clean cancelled"
    fi
}

# Function to show final status
show_final_status() {
    echo ""
    echo "📊 Final Status:"
    echo "================"
    
    # Check if any containers are still running
    running_containers=$(docker ps --filter "name=ms-kotlin-" --format "table {{.Names}}\t{{.Status}}" 2>/dev/null)
    
    if [ -z "$running_containers" ] || [ "$running_containers" = "NAMES	STATUS" ]; then
        echo "✅ All microservices containers stopped"
    else
        echo "⚠️  Some containers still running:"
        echo "$running_containers"
    fi
    
    # Check Docker volumes (persistent data)
    echo ""
    echo "💾 Persistent Data:"
    volumes=$(docker volume ls --filter "name=ms-kotlin-" --format "table {{.Name}}\t{{.Driver}}" 2>/dev/null)
    if [ -n "$volumes" ] && [ "$volumes" != "VOLUME NAME	DRIVER" ]; then
        echo "$volumes"
    else
        echo "No persistent volumes found"
    fi
    
    # Check ports
    echo ""
    echo "🔌 Port Status:"
    ports=(8082 8083 8200 8761 8888 8090 9092 2181 27018 3307)
    
    for port in "${ports[@]}"; do
        if netstat -an 2>/dev/null | grep ":$port " | grep -q LISTEN; then
            echo "   Port $port: ⚠️  Still in use"
        else
            echo "   Port $port: ✅ Available"
        fi
    done
}

# Function to backup important data before stopping
backup_data() {
    echo ""
    echo "💾 Creating backup of important data..."
    
    backup_dir="./backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup MongoDB data
    if docker ps --filter "name=ms-kotlin-mongodb" --filter "status=running" -q | grep -q .; then
        echo "   Backing up MongoDB..."
        docker exec ms-kotlin-mongodb mongodump --out /tmp/backup 2>/dev/null || true
        docker cp ms-kotlin-mongodb:/tmp/backup "$backup_dir/mongodb" 2>/dev/null || true
    fi
    
    # Backup MySQL data
    if docker ps --filter "name=ms-kotlin-mysql" --filter "status=running" -q | grep -q .; then
        echo "   Backing up MySQL..."
        docker exec ms-kotlin-mysql mysqldump --all-databases > "$backup_dir/mysql_backup.sql" 2>/dev/null || true
    fi
    
    # Backup configuration
    cp -r microservices-config-server "$backup_dir/" 2>/dev/null || true
    
    if [ -d "$backup_dir" ] && [ "$(ls -A $backup_dir 2>/dev/null)" ]; then
        echo "   ✅ Backup created: $backup_dir"
    else
        echo "   ⚠️  No data to backup"
        rmdir "$backup_dir" 2>/dev/null || true
    fi
}

# Main execution function
main() {
    show_current_status
    stop_services_gracefully
    show_final_status
    
    # Ask for cleanup
    echo ""
    read -p "🧹 Run cleanup (remove unused Docker resources)? (y/N): " do_cleanup
    if [[ $do_cleanup =~ ^[Yy]$ ]]; then
        cleanup_resources
    fi
    
    echo ""
    echo "🎉 Environment stopped successfully!"
    echo ""
    echo "💡 To start again:"
    echo "   ./start-environment.sh"
    echo ""
    echo "💡 Other options:"
    echo "   ./start-environment.sh status  - Check current status"
    echo "   ./stop-environment.sh clean   - Deep clean everything"
    echo "   ./stop-environment.sh backup  - Backup data before stopping"
}

# Handle script arguments
case "${1:-stop}" in
    "stop")
        main
        ;;
    "force")
        echo "🚨 Force stopping all containers..."
        force_stop
        show_final_status
        echo "✅ Force stop complete"
        ;;
    "clean")
        deep_clean
        ;;
    "backup")
        backup_data
        main
        ;;
    "status")
        show_current_status
        show_final_status
        ;;
    *)
        echo "Usage: $0 {stop|force|clean|backup|status}"
        echo ""
        echo "  stop    - Graceful shutdown (default)"
        echo "  force   - Force remove all containers"
        echo "  clean   - Deep clean (removes all Docker data)"
        echo "  backup  - Backup data before stopping"
        echo "  status  - Show current status only"
        exit 1
        ;;
esac