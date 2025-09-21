#!/bin/bash

echo "💾 Managing Database Infrastructure..."
echo "===================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB_DIR="$SCRIPT_DIR"

# Function to check database health
check_database_health() {
    local count=0
    local max_attempts=30
    
    echo "⏳ Waiting for databases to be ready..."
    while [ $count -lt $max_attempts ]; do
        local mongodb_healthy=false
        local mysql_healthy=false
        
        # Check MongoDB (no auth)
        if docker exec ms-kotlin-mongodb mongosh --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
            mongodb_healthy=true
        fi
        
        # Check MySQL (empty password)
        if docker exec ms-kotlin-mysql mysqladmin ping -h localhost > /dev/null 2>&1; then
            mysql_healthy=true
        fi
        
        if [ "$mongodb_healthy" = true ] && [ "$mysql_healthy" = true ]; then
            echo "✅ All databases are healthy and ready"
            return 0
        fi
        
        echo -n "."
        sleep 2
        count=$((count + 1))
    done
    
    echo "❌ Databases failed to become healthy within 60 seconds"
    return 1
}

# Function to verify database setup
verify_databases() {
    echo ""
    echo "🔍 Verifying database setup..."
    
    # Check MongoDB
    echo "   MongoDB:"
    if docker exec ms-kotlin-mongodb mongosh --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
        echo "     ✅ MongoDB connection successful"
        echo "     📋 Available databases:"
        docker exec ms-kotlin-mongodb mongosh --eval "db.getMongo().getDBNames()" --quiet
    else
        echo "     ❌ MongoDB connection failed"
    fi
    
    # Check MySQL
    echo "   MySQL:"
    if docker exec ms-kotlin-mysql mysql -u root -e "SHOW DATABASES;" > /dev/null 2>&1; then
        echo "     ✅ MySQL connection successful"
        echo "     📋 Available databases:"
        docker exec ms-kotlin-mysql mysql -u root -e "SHOW DATABASES;"
    else
        echo "     ❌ MySQL connection failed"
    fi
}

# Function to show connection info
show_connection_info() {
    echo ""
    echo "🔗 Database Connection Information:"
    echo "=================================="
    echo ""
    echo "📊 MongoDB (Product Service):"
    echo "   Host:     localhost:27018"
    echo "   Database: product-service"
    echo "   Username: (none - no auth required)"
    echo "   Password: (none - no auth required)"
    echo "   URI:      mongodb://localhost:27018/product-service"
    echo ""
    echo "🗄️  MySQL (Order Service):"
    echo "   Host:     localhost:3307"
    echo "   Database: order-service"
    echo "   Username: root"
    echo "   Password: (empty)"
    echo "   JDBC:     jdbc:mysql://localhost:3307/order-service"
}

# Main execution
case "${1:-start}" in
    "start")
        echo "🚀 Starting database infrastructure..."
        cd "$DB_DIR"
        docker-compose up -d
        
        if check_database_health; then
            verify_databases
            show_connection_info
            echo ""
            echo "✅ Database infrastructure ready!"
        else
            echo "❌ Failed to start databases properly"
            exit 1
        fi
        ;;
    "stop")
        echo "🛑 Stopping database infrastructure..."
        cd "$DB_DIR"
        docker-compose down
        ;;
    "restart")
        echo "🔄 Restarting database infrastructure..."
        cd "$DB_DIR"
        docker-compose down
        docker-compose up -d
        
        if check_database_health; then
            verify_databases
        fi
        ;;
    "status")
        echo "📊 Database infrastructure status:"
        docker-compose ps
        ;;
    "info")
        show_connection_info
        ;;
    "reset")
        echo "🗑️  Resetting all database data..."
        cd "$DB_DIR"
        docker-compose down -v
        echo "   ✅ All database volumes removed"
        echo "   💡 Run 'start' to recreate databases with fresh data"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|info|reset}"
        echo ""
        echo "  start     - Start database infrastructure"
        echo "  stop      - Stop database infrastructure"
        echo "  restart   - Restart database infrastructure"
        echo "  status    - Show container status"
        echo "  info      - Show connection information"
        echo "  reset     - Reset all data (removes volumes)"
        exit 1
        ;;
esac