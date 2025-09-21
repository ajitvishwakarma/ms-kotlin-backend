# 📦 Business Services - Interview Focus

## Overview
**This is your main focus for Kotlin interview preparation!**

Both services demonstrate real-world Kotlin microservice patterns:
- REST API development
- Database integration (MongoDB + MySQL)
- Spring Boot + Kotlin best practices
- Microservice communication patterns

## Services

### 📦 Product Service (Port 8082)
- **Technology**: Kotlin + Spring Boot + MongoDB
- **Database**: MongoDB (Document-based)
- **API**: Product CRUD operations
- **Sample Data**: Electronics, books, software

### 📋 Order Service (Port 8083)  
- **Technology**: Kotlin + Spring Boot + MySQL
- **Database**: MySQL (Relational)
- **API**: Order management and items
- **Sample Data**: Orders with line items

## Quick Development

### Option 1: IntelliJ (Recommended for debugging)
```bash
# Start infrastructure only
./start-infra.sh

# Open each service in IntelliJ and run:
# - business-services/product-service
# - business-services/order-service
```

### Option 2: Docker
```bash
# Start everything
./start-dev.sh
```

## Key Kotlin Interview Topics
- **Data Classes**: Product, Order models
- **Null Safety**: Safe database operations
- **Extension Functions**: Utility methods
- **Coroutines**: Async database calls
- **Spring Boot Integration**: Controllers, Services, Repositories

## API Endpoints
- **Products**: http://localhost:8082/api/products
- **Orders**: http://localhost:8083/api/orders

Focus your practice time here! 🎯