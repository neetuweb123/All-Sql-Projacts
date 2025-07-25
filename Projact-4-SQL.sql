create database Warehouse_Management;
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    unit_price DECIMAL(10, 2)
);

CREATE TABLE Warehouses (
    warehouse_id INT PRIMARY KEY,
    warehouse_name VARCHAR(100),
    location VARCHAR(100)
);

CREATE TABLE Suppliers (
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(100),
    contact_email VARCHAR(100),
    phone VARCHAR(20)
);

CREATE TABLE Stock (
    stock_id INT PRIMARY KEY,
    product_id INT,
    warehouse_id INT,
    supplier_id INT,
    quantity INT,
    last_updated DATE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (warehouse_id) REFERENCES Warehouses(warehouse_id),
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id)
);

INSERT INTO Products (product_id, product_name, category, unit_price) VALUES
(1, 'Laptop', 'Electronics', 55000.00),
(2, 'Smartphone', 'Electronics', 25000.00),
(3, 'Desk Chair', 'Furniture', 3500.00),
(4, 'LED Monitor', 'Electronics', 12000.00),
(5, 'Printer', 'Electronics', 8000.00),
(6, 'Notebook', 'Stationery', 50.00),
(7, 'Pen Pack', 'Stationery', 100.00),
(8, 'Desk Table', 'Furniture', 5000.00),
(9, 'USB Drive 32GB', 'Electronics', 600.00),
(10, 'Office Cabinet', 'Furniture', 7000.00);


INSERT INTO Warehouses (warehouse_id, warehouse_name, location) VALUES
(1, 'Central Warehouse', 'Delhi'),
(2, 'North Hub', 'Lucknow'),
(3, 'South Storage', 'Chennai'),
(4, 'West Depot', 'Mumbai'),
(5, 'East Facility', 'Kolkata'),
(6, 'NE Warehouse', 'Guwahati'),
(7, 'Backup Depot', 'Bhopal'),
(8, 'Mini Storage', 'Jaipur'),
(9, 'Express Storage', 'Bangalore'),
(10, 'Bulk Store', 'Hyderabad');


INSERT INTO Suppliers (supplier_id, supplier_name, contact_email, phone) VALUES
(1, 'ABC Tech Supplies', 'contact@abctech.com', '9876543210'),
(2, 'Smart Distributors', 'info@smartdist.com', '9988776655'),
(3, 'Urban Furniture Ltd', 'sales@urbanfurn.com', '9090909090'),
(4, 'Stationery World', 'support@stationeryworld.com', '8888777766'),
(5, 'Digital Gadgets Inc', 'sales@digitalgadgets.com', '9123456789'),
(6, 'Quick Office Supplies', 'hello@quickoffice.com', '9871234567'),
(7, 'WarehouseX India', 'info@warehousex.in', '9012345678'),
(8, 'CompuTech Traders', 'support@computech.com', '9345678123'),
(9, 'Infinity Supplies', 'hello@infinitysup.com', '9786543210'),
(10, 'Delta Retailers', 'retail@delta.com', '9988998899');


INSERT INTO Stock (stock_id, product_id, warehouse_id, supplier_id, quantity, last_updated) VALUES
(1, 1, 1, 1, 50, '2025-07-20'),
(2, 2, 2, 2, 100, '2025-07-21'),
(3, 3, 3, 3, 25, '2025-07-22'),
(4, 4, 4, 5, 40, '2025-07-23'),
(5, 5, 5, 5, 30, '2025-07-24'),
(6, 6, 6, 4, 500, '2025-07-20'),
(7, 7, 7, 4, 300, '2025-07-21'),
(8, 8, 8, 3, 15, '2025-07-22'),
(9, 9, 9, 8, 80, '2025-07-23'),
(10, 10, 10, 3, 10, '2025-07-24');


# 3.Create queries to check stock levels and reorder alerts.
SELECT 
    p.product_name,
    w.warehouse_name,
    s.supplier_name,
    st.quantity,
    st.last_updated
FROM Stock st
JOIN Products p ON st.product_id = p.product_id
JOIN Warehouses w ON st.warehouse_id = w.warehouse_id
JOIN Suppliers s ON st.supplier_id = s.supplier_id
ORDER BY st.quantity ASC;

# 4.Write triggers for low-stock notification.
CREATE TABLE low_stock_alerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    warehouse_id INT,
    alert_message VARCHAR(255),
    alert_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

# 5.Create stored procedure to transfer stock.
DELIMITER $$

CREATE PROCEDURE transfer_stock (
    IN prod_id INT,
    IN from_wh INT,
    IN to_wh INT,
    IN qty INT
)
BEGIN
    -- Decrease stock from source
    UPDATE Stock
    SET quantity = quantity - qty
    WHERE product_id = prod_id AND warehouse_id = from_wh;

    -- Increase stock in destination (if entry exists)
    UPDATE Stock
    SET quantity = quantity + qty
    WHERE product_id = prod_id AND warehouse_id = to_wh;

    -- Optional: If stock doesn't exist at destination, insert
    INSERT INTO Stock (product_id, warehouse_id, supplier_id, quantity, last_updated)
    SELECT prod_id, to_wh, supplier_id, qty, CURRENT_DATE
    FROM Stock
    WHERE product_id = prod_id AND warehouse_id = from_wh
    AND NOT EXISTS (
        SELECT 1 FROM Stock WHERE product_id = prod_id AND warehouse_id = to_wh
    );
END $$

DELIMITER ;

# 6.Document schema and queries
CREATE VIEW stock_summary AS
SELECT 
    p.product_name,
    w.warehouse_name,
    st.quantity,
    CASE 
        WHEN st.quantity < 50 THEN 'Low'
        WHEN st.quantity BETWEEN 50 AND 100 THEN 'Moderate'
        ELSE 'Good'
    END AS stock_status
FROM Stock st
JOIN Products p ON st.product_id = p.product_id
JOIN Warehouses w ON st.warehouse_id = w.warehouse_id;

