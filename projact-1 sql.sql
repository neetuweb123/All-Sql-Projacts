use retailsales;
DROP TABLE IF EXISTS Payments;
DROP TABLE IF EXISTS Orderss;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;

-- Customers Table
CREATE TABLE Customers (
    customer_id INT UNSIGNED PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    address TEXT
);

-- Products Table
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    price DECIMAL(10, 2)
);

-- Orders Table
CREATE TABLE Orderss (
    order_id INT PRIMARY KEY,
    customer_id INT UNSIGNED,
    order_date DATE,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Payments Table
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY,
    order_id INT,
    payment_date DATE,
    payment_method VARCHAR(50),
    amount DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES Orderss(order_id)
);


#  Normalize to 3NF (Confirmed)
-- Your schema already satisfies 3NF:
-- All tables have atomic attributes
-- No partial or transitive dependencies
-- Foreign keys manage relationships between entities

-- Sample Customers
INSERT INTO Customers VALUES
(1, 'Amit Sharma', 'amit@gmail.com', '9876543210', 'Delhi'),
(2, 'Priya Mehta', 'priya@gmail.com', '9823456789', 'Mumbai');

-- Sample Products
INSERT INTO Products VALUES
(1, 'Laptop', 'Dell Inspiron 15', 55000.00),
(2, 'Smartphone', 'iPhone 14', 79000.00);

-- Sample Orders
INSERT INTO Orderss VALUES
(101, 1, '2025-07-20', 55000.00),
(102, 2, '2025-07-21', 79000.00);

-- Sample Payments
INSERT INTO Payments VALUES
(1001, 101, '2025-07-20', 'Credit Card', 55000.00),
(1002, 102, '2025-07-21', 'UPI', 79000.00);


SELECT 
    o.order_id,
    c.name AS customer_name,
    o.order_date,
    o.total_amount
FROM
    Orderss o
        JOIN
    Customers c ON o.customer_id = c.customer_id;
    
    
    
SELECT 
    p.payment_id,
    c.name AS customer_name,
    o.order_date,
    p.amount,
    p.payment_method
FROM
    Payments p
        JOIN
    Orderss o ON p.order_id = o.order_id
        JOIN
    Customers c ON o.customer_id = c.customer_id;
    
    
CREATE VIEW SalesSummary AS
    SELECT 
        o.order_id,
        c.name AS customer_name,
        o.order_date,
        o.total_amount,
        p.payment_method
    FROM
        Orderss o
            JOIN
        Customers c ON o.customer_id = c.customer_id
            JOIN
        Payments p ON o.order_id = p.order_id;
    
    
    

