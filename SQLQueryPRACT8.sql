-- Завдання 3: Просте представлення клієнтів
CREATE VIEW vCustomerNames AS
SELECT CustomerID, FirstName, LastName
FROM Customers;
GO

-- Завдання 4: Використання простого представлення
SELECT FirstName, LastName FROM vCustomerNames;
GO

-- Завдання 5: Представлення з фільтром (преміум монітори)
CREATE VIEW vPremiumMonitors AS
SELECT MonitorID, Model, Brand, Price
FROM Monitors
WHERE Price > 1000;
GO

-- Завдання 6: Оновлення через представлення
UPDATE vPremiumMonitors
SET Price = 1299.99
WHERE MonitorID = 5; -- Припустимо, що MonitorID 5 існує
GO

-- Завдання 7: Представлення з JOIN (клієнти та їх замовлення)
CREATE VIEW vCustomerOrders AS
SELECT 
    C.CustomerID, 
    C.FirstName + ' ' + C.LastName AS CustomerName,
    O.OrderID, 
    O.OrderDate, 
    O.TotalAmount,
    O.OrderStatus
FROM Customers C
JOIN Orders O ON C.CustomerID = O.CustomerID;
GO

-- Завдання 8: Представлення з агрегацією (кількість замовлень по брендах)
CREATE VIEW vBrandOrderStats AS
SELECT 
    M.Brand,
    COUNT(O.OrderID) AS TotalOrders,
    SUM(O.TotalAmount) AS TotalRevenue,
    AVG(O.TotalAmount) AS AvgOrderValue
FROM Monitors M
LEFT JOIN Orders O ON M.MonitorID = O.MonitorID
GROUP BY M.Brand;
GO

-- Завдання 10: VIP клієнти (з більш ніж 3 замовленнями)
CREATE VIEW vVIPCustomers AS
SELECT 
    C.CustomerID,
    C.FirstName + ' ' + C.LastName AS CustomerName,
    COUNT(O.OrderID) AS OrderCount,
    SUM(O.TotalAmount) AS TotalSpent
FROM Customers C
JOIN Orders O ON C.CustomerID = O.CustomerID
GROUP BY C.CustomerID, C.FirstName, C.LastName
HAVING COUNT(O.OrderID) > 3;
GO

-- Завдання 11: Зміна представлення (додаємо email клієнта)
ALTER VIEW vCustomerOrders AS
SELECT 
    C.CustomerID, 
    C.FirstName + ' ' + C.LastName AS CustomerName,
    C.Email,
    O.OrderID, 
    O.OrderDate, 
    O.TotalAmount,
    O.OrderStatus
FROM Customers C
JOIN Orders O ON C.CustomerID = O.CustomerID;
GO

-- Завдання 12: Видалення представлення
DROP VIEW IF EXISTS vVIPCustomers;
GO

-- Завдання 13: Представлення з псевдонімами
CREATE VIEW vOrderSummary AS
SELECT 
    OrderID AS НомерЗамовлення,
    TotalAmount AS Сума,
    OrderDate AS ДатаЗамовлення,
    OrderStatus AS Статус
FROM Orders;
GO

-- Завдання 14: Представлення з обчислюваним стовпцем (ціна з ПДВ)
CREATE VIEW vMonitorPricesWithTax AS
SELECT 
    MonitorID,
    Model,
    Brand,
    Price AS BasePrice,
    Price * 1.2 AS PriceWithTax, -- ПДВ 20%
    Price * 0.2 AS TaxAmount
FROM Monitors;
GO

-- Завдання 15: WITH CHECK OPTION (дорогі монітори)
CREATE VIEW vExpensiveMonitors AS
SELECT 
    MonitorID,
    Model,
    Brand,
    Price
FROM Monitors
WHERE Price > 1500
WITH CHECK OPTION;
GO

-- Спроба додати дешевий монітор (викличе помилку)
-- INSERT INTO vExpensiveMonitors (Model, Brand, Price) 
-- VALUES ('Budget Model', 'Generic', 499.99);
GO

-- Завдання 16: Шифроване представлення (не підтримується в Express)
-- CREATE VIEW vEncryptedCustomers
-- WITH ENCRYPTION
-- AS
-- SELECT CustomerID, FirstName, LastName FROM Customers;
-- GO

-- Завдання 17: Представлення для обмеженого доступу
CREATE VIEW vRestrictedMonitors AS
SELECT 
    MonitorID,
    Model,
    Brand,
    Price
FROM Monitors
WHERE Price BETWEEN 500 AND 2000;
GO

-- Надання прав (припустимо, що користувач існує)
-- GRANT SELECT ON vRestrictedMonitors TO MonitorSalesUser;
GO