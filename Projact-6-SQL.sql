create database Airline_Reservation;

CREATE TABLE Flights (
    flight_id INT PRIMARY KEY,
    flight_number VARCHAR(20) UNIQUE,
    departure_city VARCHAR(100),
    arrival_city VARCHAR(100),
    departure_time DATETIME,
    arrival_time DATETIME,
    status VARCHAR(20)
);

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    passport_number VARCHAR(20) UNIQUE
);

CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY,
    customer_id INT,
    flight_id INT,
    booking_date DATE,
    status VARCHAR(20), -- e.g. confirmed, cancelled
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (flight_id) REFERENCES Flights(flight_id)
);

CREATE TABLE Seats (
    seat_id INT PRIMARY KEY,
    flight_id INT,
    seat_number VARCHAR(10),
    class VARCHAR(20), -- e.g. economy, business
    is_booked BOOLEAN DEFAULT FALSE,
    booking_id INT, -- Nullable
    FOREIGN KEY (flight_id) REFERENCES Flights(flight_id),
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);


# 1.Design schema: Flights, Customers, Bookings, Seats.
# 2.Normalize schema and define constraints.
# 3.Insert sample flight and booking records.

INSERT INTO Flights (flight_id, flight_number, departure_city, arrival_city, departure_time, arrival_time, status) VALUES
(1, 'FL1001', 'Delhi', 'Mumbai', '2025-08-01 09:00:00', '2025-08-01 11:15:00', 'On Time'),
(2, 'FL1002', 'Bangalore', 'Chennai', '2025-08-02 07:30:00', '2025-08-02 09:00:00', 'Delayed'),
(3, 'FL1003', 'Kolkata', 'Hyderabad', '2025-08-03 16:45:00', '2025-08-03 18:50:00', 'On Time'),
(4, 'FL1004', 'Mumbai', 'Delhi', '2025-08-04 13:00:00', '2025-08-04 15:15:00', 'Cancelled'),
(5, 'FL1005', 'Chennai', 'Bangalore', '2025-08-05 08:00:00', '2025-08-05 09:20:00', 'On Time'),
(6, 'FL1006', 'Hyderabad', 'Kolkata', '2025-08-06 10:00:00', '2025-08-06 12:00:00', 'On Time');

INSERT INTO Customers (customer_id, name, email, phone, passport_number) VALUES
(1, 'Amit Gupta', 'amit.gupta@example.com', '9123456780', 'IND1234567'),
(2, 'Neha Sharma', 'neha.sharma@example.com', '9123456781', 'IND1234568'),
(3, 'Ravi Kumar', 'ravi.kumar@example.com', '9123456782', 'IND1234569'),
(4, 'Sneha Desai', 'sneha.desai@example.com', '9123456783', 'IND1234570'),
(5, 'Alok Singh', 'alok.singh@example.com', '9123456784', 'IND1234571'),
(6, 'Pooja Mehta', 'pooja.mehta@example.com', '9123456785', 'IND1234572');

INSERT INTO Bookings (booking_id, customer_id, flight_id, booking_date, status) VALUES
(1, 1, 1, '2025-07-25', 'Confirmed'),
(2, 2, 2, '2025-07-26', 'Confirmed'),
(3, 3, 3, '2025-07-27', 'Cancelled'),
(4, 4, 4, '2025-07-28', 'Confirmed'),
(5, 5, 5, '2025-07-29', 'Confirmed'),
(6, 6, 6, '2025-07-30', 'Confirmed');

INSERT INTO Seats (seat_id, flight_id, seat_number, class, is_booked, booking_id) VALUES
(1, 1, '1A', 'Economy', TRUE, 1),
(2, 2, '2B', 'Business', TRUE, 2),
(3, 3, '3C', 'Economy', FALSE, NULL),  -- not booked
(4, 4, '4D', 'Business', TRUE, 4),
(5, 5, '5E', 'Economy', TRUE, 5),
(6, 6, '6F', 'Business', TRUE, 6);

# 4.Write queries for available seats, flight search

SELECT 
    f.flight_number,
    f.departure_city,
    f.arrival_city,
    f.departure_time,
    s.seat_number,
    s.class
FROM 
    Seats s
JOIN 
    Flights f ON s.flight_id = f.flight_id
WHERE 
    s.is_booked = FALSE
ORDER BY 
    f.flight_number, s.seat_number;

SELECT 
    flight_id,
    flight_number,
    departure_city,
    arrival_city,
    departure_time,
    arrival_time,
    status
FROM 
    Flights
WHERE 
    departure_city = 'New Delhi'
    AND arrival_city = 'Mumbai'
    AND DATE(departure_time) = '2025-08-01';

SELECT 
    seat_number,
    class
FROM 
    Seats
WHERE 
    flight_id = 1
    AND is_booked = FALSE;
    
# 5.Add triggers for booking updates and cancellations.
    DELIMITER $$

CREATE TRIGGER trg_confirm_booking
AFTER INSERT ON Bookings
FOR EACH ROW
BEGIN
    UPDATE Seats
    SET is_booked = TRUE,
        booking_id = NEW.booking_id
    WHERE flight_id = NEW.flight_id
      AND is_booked = FALSE
    LIMIT 1;  -- Assigns the first unbooked seat available
END $$

DELIMITER ;

    
DELIMITER $$

CREATE TRIGGER trg_cancel_booking
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
    IF NEW.status = 'cancelled' THEN
        UPDATE Seats
        SET is_booked = FALSE,
            booking_id = NULL
        WHERE booking_id = NEW.booking_id;
    END IF;
END $$

DELIMITER ;

    
 # 6.Generate booking summary report
-- To generate a booking summary report from your schema (Flights, Customers, Bookings, Seats), here’s a complete SQL query that includes:
-- Flight details
-- Customer name and contact
-- Booking status and date
-- Assigned seat info
-- Flight departure and arrival info

SELECT 
    B.booking_id,
    C.name AS customer_name,
    C.email AS customer_email,
    F.flight_number,
    F.departure_city,
    F.arrival_city,
    F.departure_time,
    F.arrival_time,
    B.booking_date,
    B.status AS booking_status,
    S.seat_number,
    S.class AS seat_class
FROM Bookings B
JOIN Customers C ON B.customer_id = C.customer_id
JOIN Flights F ON B.flight_id = F.flight_id
LEFT JOIN Seats S ON S.booking_id = B.booking_id
ORDER BY F.departure_time, B.booking_id;



