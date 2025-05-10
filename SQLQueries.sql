SELECT 
    ProductID, 
    ProductName, 
    Brand, 
    ScreenSize, 
    Resolution, 
    QuantityInStock, 
    RetailPrice
FROM Products
WHERE QuantityInStock > 0
ORDER BY Brand, ProductName;
SELECT 
    O.OrderID,
    O.OrderDate,
    O.OrderStatus,
    O.TotalAmount
FROM Orders O
WHERE O.CustomerID = 1
ORDER BY O.OrderDate DESC;
SELECT 
    O.OrderID,
    P.ProductName,
    OI.Quantity,
    OI.UnitPrice,
    (OI.Quantity * OI.UnitPrice) AS TotalItemPrice
FROM OrderItems OI
JOIN Products P ON OI.ProductID = P.ProductID
JOIN Orders O ON OI.OrderID = O.OrderID
WHERE O.OrderID = 1;