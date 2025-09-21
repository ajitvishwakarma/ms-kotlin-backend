# Troubleshooting Guide

## Common Issues and Solutions

### 🚨 Build Issues

#### **Issue**: Gradle build fails with "Could not resolve dependencies"
**Solution**:
```bash
# Clear Gradle cache and rebuild
./start.sh clean
docker system prune -f
./start.sh build
```

#### **Issue**: Docker build fails with "no space left on device"
**Solution**:
```bash
# Clean up Docker resources
docker system prune -af --volumes
docker builder prune -af
```

### 🐳 Container Issues

#### **Issue**: Service containers keep restarting
**Solution**:
```bash
# Check logs for specific service
docker-compose logs ms-kotlin-[service-name]

# Check container health
docker inspect ms-kotlin-[service-name] | grep -A 10 Health
```

#### **Issue**: Health checks failing
**Solution**:
```bash
# Test health endpoint manually
curl -v http://localhost:8082/actuator/health

# Check if curl is available in container
docker exec ms-kotlin-product-service which curl
```

### 🔌 Port Issues

#### **Issue**: Port already in use (e.g., "bind: address already in use")
**Solution**:
```bash
# Find process using the port
netstat -tulpn | grep :8082

# Kill process using port (Windows)
netstat -ano | findstr :8082
taskkill /PID [PID_NUMBER] /F

# Or change port in docker-compose.yml
```

### 🌐 Network Issues

#### **Issue**: Services can't communicate with each other
**Solution**:
```bash
# Check network exists
docker network ls | grep ms-kotlin

# Test inter-service connectivity
docker exec ms-kotlin-product-service ping ms-kotlin-mongodb

# Restart with fresh network
docker-compose down
docker network prune -f
docker-compose up -d
```

### 🗄️ Database Issues

#### **Issue**: MongoDB connection failed
**Solution**:
```bash
# Check MongoDB is running and healthy
docker-compose ps ms-kotlin-mongodb

# Test MongoDB connection
docker exec ms-kotlin-mongodb mongosh --eval "db.adminCommand('ping')"

# Check MongoDB logs
docker-compose logs ms-kotlin-mongodb
```

#### **Issue**: MySQL connection failed
**Solution**:
```bash
# Check MySQL is running
docker-compose ps ms-kotlin-mysql

# Test MySQL connection
docker exec ms-kotlin-mysql mysql -u root -e "SELECT 1;"

# Reset MySQL if needed
docker-compose restart ms-kotlin-mysql
```

### ⚙️ Configuration Issues

#### **Issue**: Configuration server not accessible
**Solution**:
```bash
# Check if config server is healthy
curl http://localhost:8888/actuator/health

# Verify GitHub repository access
curl -I https://github.com/ajitvishwakarma/ms-kotlin-backend

# Check config server logs
docker-compose logs ms-kotlin-configuration-server
```

#### **Issue**: Vault secrets not loading
**Solution**:
```bash
# Check Vault status
curl http://localhost:8200/v1/sys/health

# Verify Vault is unsealed
docker exec ms-kotlin-vault vault status

# Check Vault logs
docker-compose logs ms-kotlin-vault
```

### 🔍 Service Discovery Issues

#### **Issue**: Services not registering with Eureka
**Solution**:
```bash
# Check Eureka dashboard
curl http://localhost:8761/eureka/apps

# Verify service registration
curl http://localhost:8761/eureka/apps/PRODUCT-SERVICE

# Check discovery server logs
docker-compose logs ms-kotlin-discover-server
```

### 📊 Kafka Issues

#### **Issue**: Kafka not responding
**Solution**:
```bash
# Check Kafka health
docker exec ms-kotlin-kafka kafka-topics --bootstrap-server localhost:9092 --list

# Check Zookeeper first (Kafka dependency)
docker exec ms-kotlin-zookeeper nc -z localhost 2181

# Restart Kafka stack
docker-compose restart ms-kotlin-zookeeper ms-kotlin-kafka
```

## Performance Issues

### **Issue**: Slow startup times
**Solutions**:
1. **Enable build cache**: Already configured in `gradle.properties`
2. **Use optimized Dockerfiles**: Already using `Dockerfile.optimized`
3. **Increase Docker resources**: In Docker Desktop settings
4. **Parallel builds**: Already enabled in start script

### **Issue**: High memory usage
**Solutions**:
```bash
# Check memory usage
docker stats

# Adjust JVM heap sizes in Dockerfiles
# Add: ENV JAVA_OPTS="-Xmx512m -Xms256m"

# Use Alpine-based images (already using openjdk:17-jdk-alpine)
```

## Debugging Commands

### Quick Health Check All Services
```bash
./test-environment.sh health
```

### Monitor Real-time Status
```bash
./monitor.sh
```

### View All Service Logs
```bash
docker-compose logs -f
```

### Individual Service Logs
```bash
./monitor.sh logs ms-kotlin-product-service
```

### Check Resource Usage
```bash
docker stats --no-stream
```

### Network Inspection
```bash
docker network inspect ms-kotlin-backend_ms-kotlin-microservices-network
```

## Emergency Commands

### Force Stop Everything
```bash
docker-compose down --remove-orphans
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
```

### Complete Reset (⚠️ Removes all data)
```bash
./stop.sh clean
docker system prune -af --volumes
docker volume prune -f
```

### Clean Start
```bash
./stop.sh
docker system prune -f
./start.sh
```

## Windows/WSL Specific Issues

### **Issue**: Docker socket permission denied
**Solution**:
```bash
# Add user to docker group (WSL)
sudo usermod -aG docker $USER
newgrp docker

# Or restart Docker Desktop
```

### **Issue**: File permission issues on Windows
**Solution**:
```bash
# Convert line endings (if needed)
sed -i 's/\r$//' start.sh stop.sh

# Fix permissions
chmod +x *.sh
```

### **Issue**: Path issues in WSL
**Solution**:
```bash
# Use absolute paths
cd /d/workspace/java-techie-kotlin/ms-kotlin-backend

# Check current directory
pwd

# Verify files exist
ls -la *.sh
```

## Getting Help

1. **Check container status**: `./test-environment.sh health`
2. **Monitor services**: `./monitor.sh`
3. **View specific logs**: `./monitor.sh logs [service-name]`
4. **Test endpoints**: `./test-environment.sh endpoints`
5. **Full diagnostic**: `./test-environment.sh all`

## Useful Docker Commands

```bash
# View running containers
docker ps

# View all containers (including stopped)
docker ps -a

# View container logs
docker logs ms-kotlin-[service-name]

# Execute command in container
docker exec -it ms-kotlin-[service-name] bash

# Inspect container details
docker inspect ms-kotlin-[service-name]

# View Docker networks
docker network ls

# View Docker volumes
docker volume ls

# Clean up unused resources
docker system prune -f
```