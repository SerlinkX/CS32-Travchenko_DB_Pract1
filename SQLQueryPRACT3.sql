-- Загальна кількість записів у кожній таблиці
SELECT 
    'ProductCategories' AS TableName, 
    COUNT(*) AS RecordCount 
FROM ProductCategories
UNION ALL
SELECT 
    'Monitors', 
    COUNT(*) 
FROM Monitors
UNION ALL
SELECT 
    'Customers', 
    COUNT(*) 
FROM Customers
UNION ALL
SELECT 
    'Orders', 
    COUNT(*) 
FROM Orders
UNION ALL
SELECT 
    'Suppliers', 
    COUNT(*) 
FROM Suppliers;
SELECT 
    C.CategoryName, 
    AVG(M.Price) AS AvgPrice
FROM Monitors M
JOIN ProductCategories C ON M.CategoryID = C.CategoryID
GROUP BY C.CategoryName;
SELECT 
    MAX(TotalAmount) AS MaxOrderAmount,
    MIN(TotalAmount) AS MinOrderAmount
FROM Orders;
SELECT 
    C.FirstName, 
    C.LastName, 
    SUM(O.TotalAmount) AS TotalSpent
FROM Customers C
JOIN Orders O ON C.CustomerID = O.CustomerID
GROUP BY C.FirstName, C.LastName;
SELECT 
    Model, 
    Brand, 
    Price,
    RANK() OVER (ORDER BY Price DESC) AS PriceRank
FROM Monitors;
SELECT 
    OrderID, 
    OrderDate, 
    TotalAmount,
    SUM(TotalAmount) OVER (ORDER BY OrderDate) AS RunningTotal
FROM Orders;
SELECT 
    Model, 
    Brand, 
    Price,
    AVG(Price) OVER (PARTITION BY CategoryID) AS AvgCategoryPrice
FROM Monitors;
SELECT 
    CONCAT(FirstName, ' ', LastName) AS FullName,
    Email
FROM Customers;
SELECT 
    Model, 
    LEN(Specifications) AS SpecLength
FROM Monitors;
SELECT 
    Email,
    SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email)) AS Domain
FROM Customers;
SELECT 
    OrderID, 
    OrderDate,
    DATEDIFF(DAY, OrderDate, GETDATE()) AS DaysSinceOrder
FROM Orders;
SELECT 
    OrderID, 
    OrderDate,
    DATEADD(DAY, 30, OrderDate) AS ExpectedDeliveryDate
FROM Orders;
ELECT 
    OrderID, 
    OrderDate
FROM Orders
WHERE DATEPART(MONTH, OrderDate) = 11; -- Листопад