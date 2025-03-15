SELECT * 
FROM Monitors
WHERE Price BETWEEN 300 AND 1000
  AND WarrantyPeriod > 12;
SELECT * 
FROM Customers
WHERE Email LIKE '%@example.com';
SELECT M.Model, M.Brand, M.Price, C.CategoryName
FROM Monitors M
INNER JOIN ProductCategories C ON M.CategoryID = C.CategoryID;
SELECT C.FirstName, C.LastName, O.OrderID
FROM Customers C
LEFT JOIN Orders O ON C.CustomerID = O.CustomerID;
SELECT Model, Brand, Price
FROM Monitors
WHERE Price > (SELECT AVG(Price) FROM Monitors);
SELECT C.FirstName, C.LastName, COUNT(O.OrderID) AS OrderCount
FROM Customers C
LEFT JOIN Orders O ON C.CustomerID = O.CustomerID
GROUP BY C.FirstName, C.LastName;
SELECT M.Model, M.Brand, C.Email
FROM Monitors M
INNER JOIN Orders O ON M.MonitorID = O.OrderID
INNER JOIN Customers C ON O.CustomerID = C.CustomerID
WHERE C.Email LIKE '%@example.com%';
SELECT M.Model, M.Brand, M.Price
FROM Monitors M
INNER JOIN ProductCategories C ON M.CategoryID = C.CategoryID
WHERE C.CategoryName = 'LED' AND M.Price < 500;










