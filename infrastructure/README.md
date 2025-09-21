# 🏗️ Infrastructure Services

## Overview
This folder contains all infrastructure components that support the Kotlin microservices:
- **MongoDB**: Product data storage
- **MySQL**: Order data storage  
- **Kafka**: Event streaming and messaging
- **Vault**: Secrets management

## Structure
```
infrastructure/
├── databases/          → MongoDB + MySQL
├── kafka/             → Kafka + Zookeeper + UI
├── vault/             → HashiCorp Vault
└── init-data/         → Sample data for all services
    ├── mongodb/       → Product sample data
    ├── mysql/         → Order sample data
    └── vault/         → Application secrets
```

## Starting Infrastructure
```bash
# From project root
./start-infra.sh
```

## Access Points
- **Kafka UI**: http://localhost:8090
- **Vault**: http://localhost:8200 (token: myroot)
- **MongoDB**: mongodb://localhost:27018/product-service
- **MySQL**: jdbc:mysql://root:@localhost:3307/order-service

## Sample Data
All services start with pre-loaded sample data perfect for interview practice:
- **Products**: Electronics, books, software (MongoDB)
- **Orders**: Sample orders with items (MySQL)
- **Secrets**: Database connections, Kafka settings (Vault)