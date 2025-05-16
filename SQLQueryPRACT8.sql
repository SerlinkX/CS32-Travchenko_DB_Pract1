-- �������� 3: ������ ������������� �볺���
CREATE VIEW vCustomerNames AS
SELECT CustomerID, FirstName, LastName
FROM Customers;
GO

-- �������� 4: ������������ �������� �������������
SELECT FirstName, LastName FROM vCustomerNames;
GO

-- �������� 5: ������������� � �������� (������ �������)
CREATE VIEW vPremiumMonitors AS
SELECT MonitorID, Model, Brand, Price
FROM Monitors
WHERE Price > 1000;
GO

-- �������� 6: ��������� ����� �������������
UPDATE vPremiumMonitors
SET Price = 1299.99
WHERE MonitorID = 5; -- ����������, �� MonitorID 5 ����
GO

-- �������� 7: ������������� � JOIN (�볺��� �� �� ����������)
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

-- �������� 8: ������������� � ���������� (������� ��������� �� �������)
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

-- �������� 10: VIP �볺��� (� ���� �� 3 ������������)
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

-- �������� 11: ���� ������������� (������ email �볺���)
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

-- �������� 12: ��������� �������������
DROP VIEW IF EXISTS vVIPCustomers;
GO

-- �������� 13: ������������� � �����������
CREATE VIEW vOrderSummary AS
SELECT 
    OrderID AS ���������������,
    TotalAmount AS ����,
    OrderDate AS ��������������,
    OrderStatus AS ������
FROM Orders;
GO

-- �������� 14: ������������� � ������������ �������� (���� � ���)
CREATE VIEW vMonitorPricesWithTax AS
SELECT 
    MonitorID,
    Model,
    Brand,
    Price AS BasePrice,
    Price * 1.2 AS PriceWithTax, -- ��� 20%
    Price * 0.2 AS TaxAmount
FROM Monitors;
GO

-- �������� 15: WITH CHECK OPTION (����� �������)
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

-- ������ ������ ������� ������ (������� �������)
-- INSERT INTO vExpensiveMonitors (Model, Brand, Price) 
-- VALUES ('Budget Model', 'Generic', 499.99);
GO

-- �������� 16: ��������� ������������� (�� ����������� � Express)
-- CREATE VIEW vEncryptedCustomers
-- WITH ENCRYPTION
-- AS
-- SELECT CustomerID, FirstName, LastName FROM Customers;
-- GO

-- �������� 17: ������������� ��� ���������� �������
CREATE VIEW vRestrictedMonitors AS
SELECT 
    MonitorID,
    Model,
    Brand,
    Price
FROM Monitors
WHERE Price BETWEEN 500 AND 2000;
GO

-- ������� ���� (����������, �� ���������� ����)
-- GRANT SELECT ON vRestrictedMonitors TO MonitorSalesUser;
GO