-- MySQL initialization script for Order Service
-- This script runs when the container starts for the first time

-- Use the order-service database (created by MYSQL_DATABASE env var)
USE `order-service`;

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(100) NOT NULL UNIQUE,
    customer_id BIGINT NOT NULL,
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    status ENUM('PENDING', 'CONFIRMED', 'SHIPPED', 'DELIVERED', 'CANCELLED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_customer_id (customer_id),
    INDEX idx_order_number (order_number),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
);

-- Create order_items table
CREATE TABLE IF NOT EXISTS order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_order_id (order_id),
    INDEX idx_product_id (product_id)
);

-- Insert sample data
INSERT INTO orders (order_number, customer_id, customer_name, customer_email, total_amount, status) VALUES
('ORD-001', 1, 'John Doe', 'john.doe@example.com', 1029.98, 'CONFIRMED'),
('ORD-002', 2, 'Jane Smith', 'jane.smith@example.com', 699.99, 'PENDING'),
('ORD-003', 3, 'Bob Johnson', 'bob.johnson@example.com', 59.98, 'SHIPPED');

-- Insert sample order items
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, total_price) VALUES
(1, 1, 'Laptop', 1, 999.99, 999.99),
(1, 3, 'Book', 1, 29.99, 29.99),
(2, 2, 'Smartphone', 1, 699.99, 699.99),
(3, 3, 'Book', 2, 29.99, 59.98);

-- Create additional indexes for better performance
CREATE INDEX idx_customer_email ON orders(customer_email);
CREATE INDEX idx_product_name ON order_items(product_name);

-- Grant permissions to orderuser (already has access via MYSQL_USER env var)
-- GRANT ALL PRIVILEGES ON orderdb.* TO 'orderuser'@'%';
-- FLUSH PRIVILEGES;

-- Display initialization results
SELECT 'MySQL initialization completed!' AS Message;
SELECT CONCAT('Orders table created with ', COUNT(*), ' sample records') AS OrdersStatus FROM orders;
SELECT CONCAT('Order items table created with ', COUNT(*), ' sample records') AS OrderItemsStatus FROM order_items;