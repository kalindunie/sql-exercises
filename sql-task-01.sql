CREATE TABLE Users (
	User_id INT AUTO_INCREMENT PRIMARY KEY, 
	User_country VARCHAR(100),
	User_device_id INT,
	User_registration_timestamp_utc DATETIME,
	User_first_purchase_timestamp_utc DATETIME
);


CREATE TABLE Sales (
	Purchase_id INT AUTO_INCREMENT PRIMARY KEY,
	User_id INT,
	Venue_id INT,
	Timestamp_utc DATETIME,
	Total_number_units INT,
	Value_eur DOUBLE, FOREIGN KEY (user_id) REFERENCES Users(user_id) 
		ON UPDATE CASCADE 
		ON DELETE SET NULL
);


CREATE TABLE Purchases (
	Purchase_id INT,
	Product_id INT,
	Price DOUBLE,
	Quantity INT,
	FOREIGN KEY (Purchase_id) REFERENCES Sales(Purchase_id)
		ON UPDATE CASCADE
	   ON DELETE SET NULL
);


-- Querues for insert

-- Insert User data
INSERT INTO Users (`User_country`, `User_device_id`, `User_registration_timestamp_utc`) 
VALUES
('Finland', '1', '2025-03-01'),
('Finland', '7', '2025-03-14'),
('Finland', '8', '2025-03-15'),
('Finland', '2', '2025-03-20'),
('Finland', '3', '2025-04-02'),
('Finland', '4', '2025-04-02'),
('Finland', '5', '2025-04-02'),
('Finland', '6', '2025-04-10') ;

SELECT * FROM users;


-- Insert Sales data
INSERT INTO Sales (`User_id`, `Venue_id`, `Timestamp_utc`, `Total_number_units`, `Value_eur`)
VALUES
('1', '123', '2025-03-01', '4', '10.50'),
('2', '234', '2025-03-20', '7', '20.50'),
('3', '345', '2025-04-02', '2', '5.50'),
('4', '456', '2025-04-02', '3', '7.00'),
('5', '567', '2025-04-02', '6', '18.20'),
('6', '678', '2025-04-10', '2', '4.50'),
('2', '678', '2025-04-10', '2', '4.50'),
('2', '678', '2025-04-10', '2', '4.50'),
('6', '678', '2025-04-10', '2', '4.50'),
('5', '678', '2025-04-10', '2', '4.50');

SELECT * FROM sales;

-- Insert Purchases data
INSERT INTO Purchases (`Purchase_id`, `Product_id`, `Price`, `Quantity`)
VALUES
('1', '111', '1.00', '2'),
('2', '112', '2.00', '4'),  
('3', '113', '1.20', '1'),
('4', '114', '3.00', '4'),
('5', '115', '4.00', '8'),
('6', '116', '2.00', '2'),
('7', '117', '3.00', '4'),
('8', '118', '4.00', '8'),
('9', '119', '2.00', '2'),
('10', '120', '2.00', '2');

SELECT * FROM purchases;



-- TASKS

-- Query 1: Calculate number of users registered in Finland in the last 30 days.
SELECT COUNT(*) AS Total_users_for_last_month
FROM Users
WHERE User_country = 'Finland' 
AND User_registration_timestamp_utc >= Now() - INTERVAL 30 DAY;


-- Query 2: Count the number of users who have made at least one purchase in the past 30 days, where their purchases include more than one unique product.
SELECT COUNT(*) as count
FROM (
	SELECT Sales.user_id FROM Sales
	JOIN Purchases ON Sales.Purchase_id = Purchases.Purchase_id
	WHERE Sales.Timestamp_utc >= Now() - INTERVAL 30 DAY
	GROUP BY Sales.User_id
	HAVING COUNT(DISTINCT Purchases.Product_id) > 1
) AS Qualified_users ;


-- Query 3: Retrieve the most recent price for each purchased product. Bonus points if you can provide two different methods to achieve this.
SELECT Purchases.Product_id, Purchases.Price FROM Purchases JOIN
 (SELECT 
   Product_id, 
   MAX(Sales.Timestamp_utc) AS MaxTimestamp
FROM 
	Purchases
	JOIN 
   Sales ON Purchases.Purchase_id = Sales.Purchase_id
   GROUP BY Product_id) AS T
ON Purchases.Product_id = T.Product_id
JOIN 
	sales ON purchases.Purchase_id = Sales.Purchase_id AND Sales.Timestamp_utc = T.MaxTimestamp;
	

-- Query 3 improved version
WITH ProductMaxTimestamps AS (
    SELECT 
        p.Product_id, 
        MAX(s.Timestamp_utc) AS MaxTimestamp
    FROM 
        Purchases p
    JOIN 
        Sales s ON p.Purchase_id = s.Purchase_id
    GROUP BY 
        p.Product_id
)
SELECT 
    p.Product_id, 
    p.Price
FROM 
    Purchases p
JOIN 
    ProductMaxTimestamps t ON p.Product_id = t.Product_id
JOIN 
    Sales s ON p.Purchase_id = s.Purchase_id AND s.Timestamp_utc = t.MaxTimestamp;