#!/bin/bash

echo "📨 Managing Kafka Infrastructure..."
echo "================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KAFKA_DIR="$SCRIPT_DIR"

# Function to check if Kafka is healthy
check_kafka_health() {
    local count=0
    local max_attempts=30
    
    echo "⏳ Waiting for Kafka to be ready..."
    while [ $count -lt $max_attempts ]; do
        if docker exec ms-kotlin-kafka kafka-broker-api-versions --bootstrap-server localhost:9092 > /dev/null 2>&1; then
            echo "✅ Kafka is healthy and ready"
            return 0
        fi
        echo -n "."
        sleep 2
        count=$((count + 1))
    done
    
    echo "❌ Kafka failed to become healthy within 60 seconds"
    return 1
}

# Function to create test topics
create_test_topics() {
    echo ""
    echo "📋 Creating test topics..."
    
    # Create order-events topic
    docker exec ms-kotlin-kafka kafka-topics --create \
        --bootstrap-server localhost:9092 \
        --topic order-events \
        --partitions 3 \
        --replication-factor 1 \
        --if-not-exists
    echo "   ✅ order-events topic created"
    
    # Create product-events topic
    docker exec ms-kotlin-kafka kafka-topics --create \
        --bootstrap-server localhost:9092 \
        --topic product-events \
        --partitions 3 \
        --replication-factor 1 \
        --if-not-exists
    echo "   ✅ product-events topic created"
    
    # Create config-refresh topic (for Spring Cloud Bus)
    docker exec ms-kotlin-kafka kafka-topics --create \
        --bootstrap-server localhost:9092 \
        --topic springCloudBus \
        --partitions 1 \
        --replication-factor 1 \
        --if-not-exists
    echo "   ✅ springCloudBus topic created"
    
    echo ""
    echo "📊 Available topics:"
    docker exec ms-kotlin-kafka kafka-topics --list --bootstrap-server localhost:9092
}

# Function to test messaging
test_messaging() {
    echo ""
    echo "🧪 Testing Kafka messaging..."
    
    # Send a test message
    echo '{"orderId": "test-001", "status": "created"}' | \
        docker exec -i ms-kotlin-kafka kafka-console-producer \
        --bootstrap-server localhost:9092 \
        --topic order-events
    
    echo "   ✅ Test message sent to order-events topic"
    echo "   💡 Check Kafka UI at http://localhost:8090 to see the message"
}

# Main execution
case "${1:-start}" in
    "start")
        echo "🚀 Starting Kafka infrastructure..."
        cd "$KAFKA_DIR"
        docker-compose up -d
        
        if check_kafka_health; then
            create_test_topics
            echo ""
            echo "✅ Kafka infrastructure ready!"
            echo "   Kafka UI:  http://localhost:8090"
            echo "   Brokers:   localhost:9092"
        else
            echo "❌ Failed to start Kafka properly"
            exit 1
        fi
        ;;
    "stop")
        echo "🛑 Stopping Kafka infrastructure..."
        cd "$KAFKA_DIR"
        docker-compose down
        ;;
    "restart")
        echo "🔄 Restarting Kafka infrastructure..."
        cd "$KAFKA_DIR"
        docker-compose down
        docker-compose up -d
        
        if check_kafka_health; then
            create_test_topics
        fi
        ;;
    "status")
        echo "📊 Kafka infrastructure status:"
        docker-compose ps
        ;;
    "topics")
        echo "📋 Available topics:"
        docker exec ms-kotlin-kafka kafka-topics --list --bootstrap-server localhost:9092
        ;;
    "test")
        if check_kafka_health; then
            test_messaging
        else
            echo "❌ Kafka is not running. Start it first with: $0 start"
            exit 1
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|topics|test}"
        echo ""
        echo "  start     - Start Kafka and create topics"
        echo "  stop      - Stop Kafka infrastructure"
        echo "  restart   - Restart Kafka infrastructure"
        echo "  status    - Show container status"
        echo "  topics    - List available topics"
        echo "  test      - Send test message"
        exit 1
        ;;
esac