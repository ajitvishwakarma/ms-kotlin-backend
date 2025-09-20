// MongoDB initialization script for Product Service
// This script runs when the container starts for the first time

print("Starting MongoDB initialization for Product Service...");

// Switch to the product-service database
db = db.getSiblingDB('product-service');

// Note: Using root credentials from docker-compose environment
// No need to create separate user since we're using root/root

// Create the products collection with some sample data
db.products.insertMany([
  {
    id: 1,
    name: "Laptop",
    description: "High-performance laptop",
    price: 999.99,
    quantity: 10,
    category: "Electronics",
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    id: 2,
    name: "Smartphone",
    description: "Latest smartphone with advanced features",
    price: 699.99,
    quantity: 25,
    category: "Electronics",
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    id: 3,
    name: "Book",
    description: "Programming book",
    price: 29.99,
    quantity: 50,
    category: "Books",
    createdAt: new Date(),
    updatedAt: new Date()
  }
]);

// Create indexes for better performance
db.products.createIndex({ "id": 1 }, { unique: true });
db.products.createIndex({ "category": 1 });
db.products.createIndex({ "name": "text", "description": "text" });

print("MongoDB initialization completed for Product Service!");
print("Created productdb database with productuser and sample products");
print("Products collection count: " + db.products.countDocuments());