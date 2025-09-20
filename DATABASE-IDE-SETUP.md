# Database IDE Connection Guide

This guide shows how to connect to the Docker databases using popular database IDEs like DBeaver and MongoDB Compass.

## 🐳 Docker Database Setup

The project uses empty passwords for easier IDE connections:
- **MongoDB**: `root` user with empty password
- **MySQL**: `root` user with empty password

## 📊 DBeaver (MySQL Connection)

### Connection Details:
- **Host**: `localhost`
- **Port**: `3306`
- **Database**: `order-service`
- **Username**: `root`
- **Password**: *(leave empty)*

### Step-by-Step Setup:

1. **Open DBeaver** and click "New Database Connection"
2. **Select MySQL** from the database list
3. **Configure Connection**:
   ```
   Server Host: localhost
   Port: 3306
   Database: order-service
   Username: root
   Password: (leave empty)
   ```
4. **Test Connection** - should connect successfully
5. **Finish** - you can now browse the `order-service` database

### Sample Queries:
```sql
-- View all orders
SELECT * FROM orders;

-- View order items
SELECT * FROM order_items;

-- Join orders with items
SELECT o.order_number, o.customer_name, oi.product_name, oi.quantity, oi.price
FROM orders o
JOIN order_items oi ON o.id = oi.order_id;
```

## 🍃 MongoDB Compass (MongoDB Connection)

### Connection Details:
- **Host**: `localhost`
- **Port**: `27017`
- **Database**: `product-service`
- **Username**: `root`
- **Password**: *(leave empty)*
- **Authentication Database**: `admin`

### Connection URI:
```
mongodb://root@localhost:27017/product-service?authSource=admin
```

### Step-by-Step Setup:

1. **Open MongoDB Compass**
2. **New Connection** 
3. **Fill in Connection String**:
   ```
   mongodb://root@localhost:27017/product-service?authSource=admin
   ```
   Or use **Advanced Connection Options**:
   ```
   Hostname: localhost
   Port: 27017
   Authentication: Username/Password
   Username: root
   Password: (leave empty)
   Authentication Database: admin
   Default Database: product-service
   ```
4. **Connect** - you should see the `product-service` database
5. **Browse Collections** - you can see the `products` collection with sample data

### Sample Queries:
```javascript
// Find all products
db.products.find({})

// Find products by category
db.products.find({"category": "Electronics"})

// Find products in stock
db.products.find({"inStock": true})

// Count products by category
db.products.aggregate([
  {"$group": {"_id": "$category", "count": {"$sum": 1}}}
])
```

## 🐳 Docker Commands for Database Management

### Starting/Stopping Databases:
```bash
# Start only databases
docker-compose up -d ms-kotlin-mongodb ms-kotlin-mysql

# Stop databases
docker-compose stop ms-kotlin-mongodb ms-kotlin-mysql

# View database logs
docker-compose logs ms-kotlin-mongodb
docker-compose logs ms-kotlin-mysql
```

### Direct Database Access:
```bash
# MongoDB Shell
docker exec -it ms-kotlin-mongodb mongosh -u root --authenticationDatabase admin

# MySQL Shell
docker exec -it ms-kotlin-mysql mysql -u root
```

## 🔧 Alternative IDE Connections

### IntelliJ IDEA Database Tool:

**MySQL:**
```
Host: localhost
Port: 3306
Database: order-service
User: root
Password: (empty)
```

**MongoDB:**
```
Host: localhost
Port: 27017
Database: product-service
User: root
Password: (empty)
Auth Database: admin
```

### VS Code Extensions:

1. **MySQL**: Use "MySQL" extension by Jun Han
2. **MongoDB**: Use "MongoDB for VS Code" by MongoDB

## 🚀 Quick Start:

1. **Start Docker containers**:
   ```bash
   docker-compose up -d ms-kotlin-mongodb ms-kotlin-mysql
   ```

2. **Wait for containers to be ready** (check health):
   ```bash
   docker-compose ps
   ```

3. **Connect using your preferred IDE** with the settings above

4. **Browse sample data**:
   - MongoDB: `product-service.products` collection
   - MySQL: `order-service.orders` and `order-service.order_items` tables

## 🔍 Troubleshooting:

### MongoDB Connection Issues:
- Ensure authentication database is set to `admin`
- Use empty password (not no password)
- Wait for container to be fully started

### MySQL Connection Issues:
- Check that `MYSQL_ALLOW_EMPTY_PASSWORD=yes` is set
- Use empty password field
- Ensure container health check passes

### Container Status:
```bash
# Check if containers are running and healthy
docker-compose ps

# Check container logs for errors
docker-compose logs ms-kotlin-mongodb
docker-compose logs ms-kotlin-mysql
```