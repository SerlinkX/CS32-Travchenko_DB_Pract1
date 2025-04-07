-- =============================================
-- SCALAR FUNCTIONS (Скалярні функції)
-- =============================================

-- 1. Функція для форматування ціни зі знаком долара
CREATE FUNCTION dbo.FormatPrice (@price DECIMAL(10,2))
RETURNS NVARCHAR(20)
AS
BEGIN
    RETURN '$' + CAST(@price AS NVARCHAR(20))
END;
GO

-- Приклад використання:
SELECT 
    Model, 
    Price,
    dbo.FormatPrice(Price) AS FormattedPrice
FROM Monitors
WHERE Price > 500;

-- 2. Функція для розрахунку ціни зі знижкою
CREATE FUNCTION dbo.CalculateDiscount (@price DECIMAL(10,2), @discount DECIMAL(5,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @price * (1 - @discount/100))
END;
GO

-- Приклад використання:
SELECT 
    Model,
    Price,
    dbo.CalculateDiscount(Price, 15) AS PriceWith15PercentDiscount
FROM Monitors;

-- 3. Функція для визначення категорії ціни
CREATE FUNCTION dbo.GetPriceCategory (@price DECIMAL(10,2))
RETURNS NVARCHAR(20)
AS
BEGIN
    RETURN CASE
        WHEN @price < 300 THEN 'Budget'
        WHEN @price BETWEEN 300 AND 1000 THEN 'Mid-range'
        ELSE 'Premium'
    END
END;
GO

-- Приклад використання:
SELECT 
    Model,
    Price,
    dbo.GetPriceCategory(Price) AS PriceCategory
FROM Monitors;

-- =============================================
-- INLINE TABLE-VALUED FUNCTIONS (Вбудовані табличні функції)
-- =============================================

-- 1. Функція для отримання моніторів за брендом
CREATE FUNCTION dbo.GetMonitorsByBrand (@brand NVARCHAR(50))
RETURNS TABLE
AS
RETURN
    SELECT * FROM Monitors WHERE Brand = @brand;
GO

-- Приклад використання:
SELECT * FROM dbo.GetMonitorsByBrand('Dell');

-- 2. Функція для отримання замовлень за період
CREATE FUNCTION dbo.GetOrdersByDateRange (@startDate DATE, @endDate DATE)
RETURNS TABLE
AS
RETURN
    SELECT * FROM Orders 
    WHERE OrderDate BETWEEN @startDate AND @endDate;
GO

-- Приклад використання:
SELECT * FROM dbo.GetOrdersByDateRange('2024-01-01', '2024-06-30');

-- 3. Функція для отримання клієнтів за доменом email
CREATE FUNCTION dbo.GetCustomersByEmailDomain (@domain NVARCHAR(50))
RETURNS TABLE
AS
RETURN
    SELECT * FROM Customers 
    WHERE Email LIKE '%@' + @domain;
GO

-- Приклад використання:
SELECT * FROM dbo.GetCustomersByEmailDomain('example.com');

-- =============================================
-- MULTI-STATEMENT TABLE-VALUED FUNCTIONS (Багатооператорні табличні функції)
-- =============================================

-- 1. Функція для отримання статистики по категоріям
CREATE FUNCTION dbo.GetCategoryStats ()
RETURNS @stats TABLE (
    CategoryName NVARCHAR(50),
    MonitorCount INT,
    AvgPrice DECIMAL(10,2),
    MinPrice DECIMAL(10,2),
    MaxPrice DECIMAL(10,2)
)
AS
BEGIN
    INSERT INTO @stats
    SELECT 
        pc.CategoryName,
        COUNT(m.MonitorID) AS MonitorCount,
        AVG(m.Price) AS AvgPrice,
        MIN(m.Price) AS MinPrice,
        MAX(m.Price) AS MaxPrice
    FROM ProductCategories pc
    JOIN Monitors m ON pc.CategoryID = m.CategoryID
    GROUP BY pc.CategoryName;
    
    RETURN;
END;
GO

-- Приклад використання:
SELECT * FROM dbo.GetCategoryStats();

-- 2. Функція для отримання топ-N найдорожчих моніторів
CREATE FUNCTION dbo.GetTopExpensiveMonitors (@topCount INT)
RETURNS @result TABLE (
    Model NVARCHAR(100),
    Brand NVARCHAR(50),
    Price DECIMAL(10,2),
    PriceRank INT
)
AS
BEGIN
    INSERT INTO @result
    SELECT TOP (@topCount)
        Model,
        Brand,
        Price,
        RANK() OVER (ORDER BY Price DESC) AS PriceRank
    FROM Monitors
    ORDER BY Price DESC;
    
    RETURN;
END;
GO

-- Приклад використання:
SELECT * FROM dbo.GetTopExpensiveMonitors(10);

-- 3. Функція для отримання клієнтів з їхньою загальною сумою замовлень
CREATE FUNCTION dbo.GetCustomersWithOrderTotals ()
RETURNS @result TABLE (
    CustomerID INT,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    TotalOrders INT,
    TotalAmount DECIMAL(10,2)
)
AS
BEGIN
    INSERT INTO @result
    SELECT 
        c.CustomerID,
        c.FirstName,
        c.LastName,
        COUNT(o.OrderID) AS TotalOrders,
        SUM(o.TotalAmount) AS TotalAmount
    FROM Customers c
    LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
    GROUP BY c.CustomerID, c.FirstName, c.LastName;
    
    RETURN;
END;
GO

-- Приклад використання:
SELECT * FROM dbo.GetCustomersWithOrderTotals()
ORDER BY TotalAmount DESC;