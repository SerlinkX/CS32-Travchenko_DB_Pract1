SELECT * 
FROM Monitors
WHERE Price > 500;
SELECT * 
FROM Orders
WHERE OrderStatus = 'Completed';
SELECT * 
FROM Customers
WHERE FirstName LIKE 'FirstName1%';
SELECT * 
FROM Monitors
WHERE WarrantyPeriod > 24;
SELECT * 
FROM Suppliers
WHERE ContactInfo LIKE '%@supplier.com%';
SELECT * 
FROM Orders
WHERE OrderDate BETWEEN '2024-01-01' AND '2024-12-31';
SELECT * 
FROM Monitors
WHERE Price BETWEEN 300 AND 1000
  AND WarrantyPeriod > 12;
SELECT * 
FROM Orders
WHERE (OrderStatus = 'Pending' OR OrderStatus = 'Completed')
  AND OrderDate BETWEEN '2024-01-01' AND '2024-12-31';
SELECT * 
FROM Customers
WHERE FirstName LIKE 'FirstName1%'
   OR FirstName LIKE 'FirstName2%';
SELECT * 
FROM Monitors
WHERE NOT (CategoryID = 1 OR CategoryID = 2);
SELECT * 
FROM Suppliers
WHERE ContactInfo LIKE '%@supplier.com%'
   OR ContactInfo LIKE '%@distributors.com%';
SELECT * 
FROM Customers
WHERE Email LIKE '%@example.com';
SELECT * 
FROM Monitors
WHERE Model LIKE '%UltraSharp%';
SELECT * 
FROM Suppliers
WHERE SupplierName LIKE 'Tech%';
SELECT * 
FROM Orders
WHERE OrderStatus LIKE '%Complete%';
SELECT * 
FROM Monitors
WHERE Specifications LIKE '%4K%';
SELECT M.Model, M.Brand, M.Price, C.CategoryName
FROM Monitors M
INNER JOIN ProductCategories C ON M.CategoryID = C.CategoryID;
SELECT O.OrderID, O.OrderDate, O.TotalAmount, C.FirstName, C.LastName
FROM Orders O
INNER JOIN Customers C ON O.CustomerID = C.CustomerID;
SELECT M.Model, M.Brand, O.OrderID, O.OrderDate
FROM Monitors M
INNER JOIN Orders O ON M.MonitorID = O.OrderID;
SELECT C.FirstName, C.LastName, O.TotalAmount
FROM Customers C
INNER JOIN Orders O ON C.CustomerID = O.CustomerID
WHERE O.TotalAmount > 1000;
SELECT S.SupplierName, M.Model, M.Brand
FROM Suppliers S
INNER JOIN Monitors M ON S.SupplierID = M.MonitorID;
SELECT C.FirstName, C.LastName, O.OrderID
FROM Customers C
LEFT JOIN Orders O ON C.CustomerID = O.CustomerID;
SELECT O.OrderID, O.OrderDate, C.FirstName, C.LastName
FROM Orders O
RIGHT JOIN Customers C ON O.CustomerID = C.CustomerID;
SELECT M.Model, C.CategoryName
FROM Monitors M
FULL JOIN ProductCategories C ON M.CategoryID = C.CategoryID;
SELECT C.FirstName, C.LastName
FROM Customers C
LEFT JOIN Orders O ON C.CustomerID = O.CustomerID
WHERE O.OrderID IS NULL;
SELECT M.Model
FROM Monitors M
RIGHT JOIN ProductCategories C ON M.CategoryID = C.CategoryID
WHERE M.MonitorID IS NULL;
SELECT Model, Brand, Price
FROM Monitors
WHERE Price > (SELECT AVG(Price) FROM Monitors);
SELECT FirstName, LastName
FROM Customers
WHERE CustomerID IN (SELECT CustomerID FROM Orders WHERE TotalAmount > 1000);
SELECT Model, Brand
FROM Monitors
WHERE CategoryID = (SELECT CategoryID FROM ProductCategories WHERE CategoryName = 'LED');
SELECT OrderID, OrderDate, TotalAmount
FROM Orders
WHERE CustomerID IN (SELECT CustomerID FROM Customers WHERE Email LIKE '%@example.com%');
SELECT SupplierName
FROM Suppliers
WHERE SupplierID NOT IN (SELECT SupplierID FROM Monitors);
SELECT C.FirstName, C.LastName, COUNT(O.OrderID) AS OrderCount
FROM Customers C
LEFT JOIN Orders O ON C.CustomerID = O.CustomerID
GROUP BY C.FirstName, C.LastName;
SELECT C.CategoryName, AVG(M.Price) AS AveragePrice
FROM Monitors M
INNER JOIN ProductCategories C ON M.CategoryID = C.CategoryID
GROUP BY C.CategoryName;
SELECT C.CategoryName, COUNT(M.MonitorID) AS MonitorCount
FROM Monitors M
INNER JOIN ProductCategories C ON M.CategoryID = C.CategoryID
GROUP BY C.CategoryName
HAVING COUNT(M.MonitorID) > 5;
SELECT C.FirstName, C.LastName, SUM(O.TotalAmount) AS TotalSpent
FROM Customers C
INNER JOIN Orders O ON C.CustomerID = O.CustomerID
GROUP BY C.FirstName, C.LastName
HAVING SUM(O.TotalAmount) > 2000;
SELECT S.SupplierName, COUNT(M.MonitorID) AS MonitorCount
FROM Suppliers S
INNER JOIN Monitors M ON S.SupplierID = M.MonitorID
GROUP BY S.SupplierName
HAVING COUNT(M.MonitorID) > 10;
SELECT M.Model, M.Brand, C.Email
FROM Monitors M
INNER JOIN Orders O ON M.MonitorID = O.OrderID
INNER JOIN Customers C ON O.CustomerID = C.CustomerID
WHERE C.Email LIKE '%@example.com%';
SELECT O.OrderID, O.OrderDate, M.Model, M.WarrantyPeriod
FROM Orders O
INNER JOIN Monitors M ON O.OrderID = M.MonitorID
WHERE M.WarrantyPeriod > 24;
SELECT DISTINCT C.FirstName, C.LastName
FROM Customers C
INNER JOIN Orders O ON C.CustomerID = O.CustomerID
INNER JOIN Monitors M ON O.OrderID = M.MonitorID
INNER JOIN ProductCategories PC ON M.CategoryID = PC.CategoryID
WHERE PC.CategoryName = 'LED';
SELECT S.SupplierName, M.Model, M.Price
FROM Suppliers S
INNER JOIN Monitors M ON S.SupplierID = M.MonitorID
WHERE M.Price > (SELECT AVG(Price) FROM Monitors);
SELECT C.FirstName, C.LastName, M.Model, M.WarrantyPeriod
FROM Customers C
INNER JOIN Orders O ON C.CustomerID = O.CustomerID
INNER JOIN Monitors M ON O.OrderID = M.MonitorID
WHERE M.WarrantyPeriod > 12;
SELECT M.Model, M.Brand, M.Price
FROM Monitors M
INNER JOIN ProductCategories C ON M.CategoryID = C.CategoryID
WHERE C.CategoryName = 'LED' AND M.Price < 500
SELECT O.OrderID, O.OrderDate, O.TotalAmount
FROM Orders O
INNER JOIN Customers C ON O.CustomerID = C.CustomerID
WHERE C.FirstName = 'John';
SELECT M.Model, M.Brand, O.OrderDate
FROM Monitors M
INNER JOIN Orders O ON M.MonitorID = O.OrderID
WHERE O.OrderDate BETWEEN '2024-01-01' AND '2024-12-31';
SELECT DISTINCT C.FirstName, C.LastName
FROM Customers C
INNER JOIN Orders O ON C.CustomerID = O.CustomerID
INNER JOIN Monitors M ON O.OrderID = M.MonitorID
WHERE M.WarrantyPeriod = 24;
SELECT S.SupplierName, M.Model, M.Price
FROM Suppliers S
INNER JOIN Monitors M ON S.SupplierID = M.MonitorID
WHERE M.Price > 1000;