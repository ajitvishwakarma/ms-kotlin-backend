#!/bin/bash

# Script to start Kafka and Zookeeper with Docker Compose
echo "🚀 Starting Kafka and Zookeeper with Docker..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "📋 Starting Kafka infrastructure..."
docker-compose up -d

# Wait for services to start
echo "⏳ Waiting for services to start..."
sleep 10

# Check if services are running
echo "🔍 Checking service status..."
docker-compose ps

echo ""
echo "✅ Kafka infrastructure started successfully!"
echo ""
echo "🔗 Access Information:"
echo "   Kafka: localhost:9092"
echo "   Zookeeper: localhost:2181" 
echo "   Kafka UI: http://localhost:8090"
echo ""
echo "📖 Next Steps:"
echo "   1. Configure Spring Cloud Bus in your microservices"
echo "   2. Use /actuator/busrefresh for distributed configuration refresh"
echo "   3. Monitor topics and messages via Kafka UI"
echo ""
echo "🛠️ Useful Commands:"
echo "   docker-compose logs ms-kotlin-kafka     # View Kafka logs"
echo "   docker-compose logs ms-kotlin-zookeeper # View Zookeeper logs"
echo "   docker-compose down                     # Stop Kafka"
echo "   docker-compose ps                       # Check status"
echo ""
echo "📊 Container Names:"
echo "   Kafka: ms-kotlin-kafka"
echo "   Zookeeper: ms-kotlin-zookeeper" 
echo "   Kafka UI: ms-kotlin-kafka-ui"