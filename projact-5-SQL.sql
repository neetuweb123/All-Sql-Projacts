create database Library_Management;
CREATE TABLE Authors (
    author_id INT PRIMARY KEY,
    author_name VARCHAR(100),
    nationality VARCHAR(50),
    birth_year INT
);

CREATE TABLE Books (
    book_id INT PRIMARY KEY,
    title VARCHAR(150),
    genre VARCHAR(50),
    author_id INT,
    publication_year INT,
    isbn VARCHAR(20) UNIQUE,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id)
);

CREATE TABLE Members (
    member_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    join_date DATE
);

CREATE TABLE Loans (
    loan_id INT PRIMARY KEY,
    book_id INT,
    member_id INT,
    loan_date DATE,
    return_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (book_id) REFERENCES Books(book_id),
    FOREIGN KEY (member_id) REFERENCES Members(member_id)
);

INSERT INTO Authors (author_id, author_name, nationality, birth_year) VALUES
(1, 'J.K. Rowling', 'British', 1965),
(2, 'George R.R. Martin', 'American', 1948),
(3, 'Haruki Murakami', 'Japanese', 1949),
(4, 'Jane Austen', 'British', 1775),
(5, 'Agatha Christie', 'British', 1890),
(6, 'Mark Twain', 'American', 1835),
(7, 'Paulo Coelho', 'Brazilian', 1947),
(8, 'Dan Brown', 'American', 1964);

INSERT INTO Books (book_id, title, genre, author_id, publication_year, isbn) VALUES
(1, 'Harry Potter and the Philosopher\'s Stone', 'Fantasy', 1, 1997, '9780747532699'),
(2, 'A Game of Thrones', 'Fantasy', 2, 1996, '9780553103540'),
(3, 'Norwegian Wood', 'Fiction', 3, 1987, '9780375704024'),
(4, 'Pride and Prejudice', 'Romance', 4, 1813, '9780679783268'),
(5, 'Murder on the Orient Express', 'Mystery', 5, 1934, '9780062073495'),
(6, 'The Adventures of Tom Sawyer', 'Adventure', 6, 1876, '9780486400778'),
(7, 'The Alchemist', 'Philosophical', 7, 1988, '9780061122415'),
(8, 'The Da Vinci Code', 'Thriller', 8, 2003, '9780385504201');

INSERT INTO Members (member_id, name, email, phone, join_date) VALUES
(1, 'Alice Smith', 'alice@example.com', '9876543210', '2023-01-10'),
(2, 'Bob Johnson', 'bob@example.com', '9876543211', '2023-01-15'),
(3, 'Carol Lee', 'carol@example.com', '9876543212', '2023-01-20'),
(4, 'David Brown', 'david@example.com', '9876543213', '2023-01-25'),
(5, 'Emma Wilson', 'emma@example.com', '9876543214', '2023-02-01'),
(6, 'Frank Miller', 'frank@example.com', '9876543215', '2023-02-05'),
(7, 'Grace Davis', 'grace@example.com', '9876543216', '2023-02-10'),
(8, 'Hank Moore', 'hank@example.com', '9876543217', '2023-02-15');

INSERT INTO Loans (loan_id, book_id, member_id, loan_date, return_date, status) VALUES
(1, 1, 1, '2024-07-01', '2024-07-10', 'Returned'),
(2, 2, 2, '2024-07-03', '2024-07-13', 'Returned'),
(3, 3, 3, '2024-07-05', NULL, 'Borrowed'),
(4, 4, 4, '2024-07-07', NULL, 'Overdue'),
(5, 5, 5, '2024-07-10', '2024-07-18', 'Returned'),
(6, 6, 6, '2024-07-12', NULL, 'Borrowed'),
(7, 7, 7, '2024-07-14', NULL, 'Borrowed'),
(8, 8, 8, '2024-07-15', '2024-07-20', 'Returned');

# 3.Handle many-to-many relationships with bridge tables.
-- To handle many-to-many relationships, you use a bridge table (also called a junction or associative table).
--  Let’s go through this step-by-step using the Books and Authors example, 
-- as one book can have multiple authors, and one author can write multiple books.
CREATE TABLE BookAuthors (
    book_id INT,
    author_id INT,
    PRIMARY KEY (book_id , author_id),
    FOREIGN KEY (book_id)
        REFERENCES Books (book_id),
    FOREIGN KEY (author_id)
        REFERENCES Authors (author_id)
);

INSERT INTO BookAuthors (book_id, author_id) VALUES (1, 1);
INSERT INTO BookAuthors (book_id, author_id) VALUES (2, 2);
INSERT INTO BookAuthors (book_id, author_id) VALUES (8, 2), (8, 8);
INSERT INTO BookAuthors (book_id, author_id) VALUES (3, 3);
INSERT INTO BookAuthors (book_id, author_id) VALUES (4, 4);

SELECT 
    b.title,
    a.author_name
FROM 
    BookAuthors ba
JOIN Books b ON ba.book_id = b.book_id
JOIN Authors a ON ba.author_id = a.author_id
ORDER BY b.title;


# 4.Create views for borrowed and overdue books.
CREATE VIEW View_BorrowedBooks AS
SELECT
    l.loan_id,
    b.title AS book_title,
    m.name AS member_name,
    l.loan_date,
    l.return_date,
    l.status
FROM
    Loans l
JOIN Books b ON l.book_id = b.book_id
JOIN Members m ON l.member_id = m.member_id;

SELECT * FROM View_BorrowedBooks;

# 5.Write triggers for due-date notifications.

CREATE TABLE DueNotifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    loan_id INT,
    member_id INT,
    book_id INT,
    due_date DATE,
    notification_date DATE,
    message TEXT,
    FOREIGN KEY (loan_id) REFERENCES Loans(loan_id),
    FOREIGN KEY (member_id) REFERENCES Members(member_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id)
);

DELIMITER //

CREATE TRIGGER trg_due_date_notification
AFTER UPDATE ON Loans
FOR EACH ROW
BEGIN
    IF NEW.status = 'borrowed' AND NEW.return_date < CURDATE() THEN
        INSERT INTO DueNotifications (
            loan_id, member_id, book_id, due_date, notification_date, message
        )
        VALUES (
            NEW.loan_id,
            NEW.member_id,
            NEW.book_id,
            NEW.return_date,
            CURDATE(),
            CONCAT('Book "', (SELECT title FROM Books WHERE book_id = NEW.book_id), '" is overdue!')
        );
    END IF;
END;
//

DELIMITER ;

# 6.Write reports using aggregation and JOINs.

SELECT 
    a.author_id,
    a.author_name,
    COUNT(b.book_id) AS total_books
FROM 
    Authors a
LEFT JOIN 
    Books b ON a.author_id = b.author_id
GROUP BY 
    a.author_id, a.author_name
ORDER BY 
    total_books DESC;

SELECT 
    m.member_id,
    m.name AS member_name,
    COUNT(l.loan_id) AS total_loans
FROM 
    Members m
LEFT JOIN 
    Loans l ON m.member_id = l.member_id
GROUP BY 
    m.member_id, m.name
ORDER BY 
    total_loans DESC;

SELECT 
    b.book_id,
    b.title,
    COUNT(l.loan_id) AS times_borrowed
FROM 
    Books b
JOIN 
    Loans l ON b.book_id = l.book_id
GROUP BY 
    b.book_id, b.title
ORDER BY 
    times_borrowed DESC
LIMIT 10;


SELECT 
    l.loan_id,
    m.name AS member_name,
    b.title AS book_title,
    l.loan_date,
    l.return_date,
    DATEDIFF(CURDATE(), l.return_date) AS days_overdue
FROM 
    Loans l
JOIN 
    Members m ON l.member_id = m.member_id
JOIN 
    Books b ON l.book_id = b.book_id
WHERE 
    l.status = 'borrowed'
    AND l.return_date < CURDATE()
ORDER BY 
    days_overdue DESC;

SELECT 
    genre,
    COUNT(*) AS total_books
FROM 
    Books
GROUP BY 
    genre
ORDER BY 
    total_books DESC;


SELECT 
    DATE_FORMAT(loan_date, '%Y-%m') AS loan_month,
    COUNT(*) AS total_loans
FROM 
    Loans
GROUP BY 
    loan_month
ORDER BY 
    loan_month DESC;



