create database Finance_Tracker;


-- Users Table
CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    password VARCHAR(100),
    phone VARCHAR(15),
    created_at DATE
);

-- Categories Table
CREATE TABLE Categories (
    category_id INT PRIMARY KEY,
    name VARCHAR(100),
    type VARCHAR(10) -- 'Income' or 'Expense'
);

-- Income Table
CREATE TABLE Income (
    income_id INT PRIMARY KEY,
    user_id INT,
    category_id INT,
    amount DECIMAL(10, 2),
    income_date DATE,
    description TEXT,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- Expenses Table
CREATE TABLE Expenses (
    expense_id INT PRIMARY KEY,
    user_id INT,
    category_id INT,
    amount DECIMAL(10, 2),
    expense_date DATE,
    description TEXT,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

INSERT INTO Users VALUES (1, 'Amit Sharma', 'amit@example.com', 'pass123', '9123456780', '2024-01-10');
INSERT INTO Users VALUES (2, 'Neha Singh', 'neha@example.com', 'pass456', '9876543210', '2024-01-15');
INSERT INTO Users VALUES (3, 'Ravi Kumar', 'ravi@example.com', 'pass789', '9988776655', '2024-02-01');
INSERT INTO Users VALUES (4, 'John Doe', 'john@example.com', 'pass321', '9000000001', '2024-02-12');
INSERT INTO Users VALUES (5, 'Priya Mehta', 'priya@example.com', 'passabc', '9111111111', '2024-03-05');
INSERT INTO Users VALUES (6, 'Sneha Roy', 'sneha@example.com', 'passxyz', '9222222222', '2024-03-15');
INSERT INTO Users VALUES (7, 'Alok Gupta', 'alok@example.com', 'passqwe', '9333333333', '2024-04-01');

INSERT INTO Categories VALUES (1, 'Salary', 'Income');
INSERT INTO Categories VALUES (2, 'Freelance', 'Income');
INSERT INTO Categories VALUES (3, 'Bonus', 'Income');
INSERT INTO Categories VALUES (4, 'Rent', 'Expense');
INSERT INTO Categories VALUES (5, 'Groceries', 'Expense');
INSERT INTO Categories VALUES (6, 'Utilities', 'Expense');
INSERT INTO Categories VALUES (7, 'Dining', 'Expense');

INSERT INTO Income VALUES (1, 1, 1, 50000.00, '2024-07-01', 'Monthly Salary');
INSERT INTO Income VALUES (2, 2, 2, 20000.00, '2024-07-05', 'Freelance Project');
INSERT INTO Income VALUES (3, 3, 1, 48000.00, '2024-07-01', 'Salary');
INSERT INTO Income VALUES (4, 4, 3, 5000.00, '2024-07-10', 'Performance Bonus');
INSERT INTO Income VALUES (5, 5, 1, 51000.00, '2024-07-01', 'July Salary');
INSERT INTO Income VALUES (6, 6, 2, 15000.00, '2024-07-08', 'Blogging Income');
INSERT INTO Income VALUES (7, 7, 1, 47000.00, '2024-07-01', 'Monthly Pay');

INSERT INTO Expenses VALUES (1, 1, 4, 15000.00, '2024-07-02', 'House Rent');
INSERT INTO Expenses VALUES (2, 2, 5, 3000.00, '2024-07-03', 'Grocery Shopping');
INSERT INTO Expenses VALUES (3, 3, 6, 2200.00, '2024-07-04', 'Electricity Bill');
INSERT INTO Expenses VALUES (4, 4, 7, 1200.00, '2024-07-05', 'Dinner Out');
INSERT INTO Expenses VALUES (5, 5, 5, 3500.00, '2024-07-06', 'Groceries');
INSERT INTO Expenses VALUES (6, 6, 6, 1800.00, '2024-07-07', 'Water + Internet');
INSERT INTO Expenses VALUES (7, 7, 4, 16000.00, '2024-07-01', 'Monthly Rent');


# 3.Write queries to summarize expenses monthly.
SELECT 
    u.user_id,
    u.name,
    DATE_FORMAT(e.expense_date, '%Y-%m') AS month,
    SUM(e.amount) AS total_expense
FROM 
    Expenses e
JOIN 
    Users u ON e.user_id = u.user_id
GROUP BY 
    u.user_id, month
ORDER BY 
    u.user_id, month;

SELECT 
    u.name AS user,
    DATE_FORMAT(e.expense_date, '%Y-%m') AS month,
    c.name AS category,
    SUM(e.amount) AS total_expense
FROM 
    Expenses e
JOIN 
    Users u ON e.user_id = u.user_id
JOIN 
    Categories c ON e.category_id = c.category_id
GROUP BY 
    u.name, month, category
ORDER BY 
    u.name, month, total_expense DESC;

SELECT 
    u.name,
    SUM(e.amount) AS total_expense
FROM 
    Expenses e
JOIN 
    Users u ON e.user_id = u.user_id
WHERE 
    MONTH(e.expense_date) = 7 AND YEAR(e.expense_date) = 2025
GROUP BY 
    u.name;
    
 # 4.Use GROUP BY for category-wise spending.
   
    SELECT 
    c.name AS category,
    SUM(e.amount) AS total_spent
FROM 
    Expenses e
JOIN 
    Categories c ON e.category_id = c.category_id
GROUP BY 
    c.name
ORDER BY 
    total_spent DESC;

# 5.Create views for balance tracking.
CREATE VIEW user_total_income AS
SELECT 
    u.user_id,
    u.name,
    SUM(i.amount) AS total_income
FROM 
    Users u
LEFT JOIN 
    Income i ON u.user_id = i.user_id
GROUP BY 
    u.user_id, u.name;
    
 # 6.Export monthly reports.   
    
SELECT 
    u.user_id,
    u.name,
    DATE_FORMAT(COALESCE(i.income_date, e.expense_date), '%Y-%m') AS month,
    SUM(i.amount) AS total_income,
    SUM(e.amount) AS total_expense,
    SUM(IFNULL(i.amount, 0)) - SUM(IFNULL(e.amount, 0)) AS balance
FROM 
    Users u
LEFT JOIN 
    Income i ON u.user_id = i.user_id
LEFT JOIN 
    Expenses e ON u.user_id = e.user_id
    AND DATE_FORMAT(i.income_date, '%Y-%m') = DATE_FORMAT(e.expense_date, '%Y-%m')
GROUP BY 
    u.user_id, month
ORDER BY 
    u.user_id, month;
    
