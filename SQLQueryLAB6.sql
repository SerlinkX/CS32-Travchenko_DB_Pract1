BEGIN TRANSACTION;
    -- ��������� ���� �������
    UPDATE Monitors SET Price = Price * 1.1 WHERE Brand = 'Dell';
    
    -- ��������� ������ � ������ ��� ���
    INSERT INTO PriceHistory (MonitorID, OldPrice, NewPrice, ChangeDate)
    SELECT MonitorID, Price/1.1, Price, GETDATE() 
    FROM Monitors WHERE Brand = 'Dell';
    
    -- ����� ��� ROLLBACK (���� ���� ������� Dell)
    IF (SELECT COUNT(*) FROM Monitors WHERE Brand = 'Dell') = 0
    BEGIN
        ROLLBACK;
        PRINT '�� �������� ������� Dell ��� ���������';
    END
    ELSE
        COMMIT;
BEGIN TRANSACTION;
    -- ������ ������� ��������� �����
    UPDATE Monitors SET WarrantyPeriod = 36 WHERE MonitorID = 99999;
    
    -- �������� �� �������
    IF @@ERROR <> 0
    BEGIN
        ROLLBACK;
        PRINT '������� ��� �������� ����������� ������';
    END
    ELSE
        COMMIT;
BEGIN TRANSACTION;
BEGIN TRY
    -- ��������� ���� � ������� ���������
    UPDATE Monitors SET Price = -100 WHERE MonitorID = 10;
    
    -- ��������� �������
    UPDATE Monitors SET CategoryID = 5 WHERE MonitorID = 10;
    
    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT '������� ����������: ' + ERROR_MESSAGE();
    PRINT '��� �������: ' + CAST(ERROR_NUMBER() AS VARCHAR);
END CATCH;
-- ��������� ������� ��� ���������� (���� �� �� ����)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MonitorTestData')
CREATE TABLE MonitorTestData (
    TestID INT IDENTITY(1,1) PRIMARY KEY,
    Model NVARCHAR(100),
    Brand NVARCHAR(50),
    Price DECIMAL(10,2),
    TestDate DATETIME DEFAULT GETDATE()
);

-- ���������� ��� ��������� 100,000 ������
BEGIN TRANSACTION;
    DECLARE @i INT = 1;
    WHILE @i <= 100000
    BEGIN
        INSERT INTO MonitorTestData (Model, Brand, Price)
        VALUES ('TestModel-' + CAST(@i AS NVARCHAR), 
               'TestBrand-' + CAST(@i % 10 AS NVARCHAR), 
               100 + (@i % 900));
        
        SET @i = @i + 1;
        
        -- ���� ���� 10,000 ������ ��� ����������
        IF @i % 10000 = 0
        BEGIN
            COMMIT;
            BEGIN TRANSACTION;
        END
    END
    
    COMMIT;
	ALTER PROCEDURE usp_GetMonitorStats
AS
BEGIN
    DECLARE @StartTime DATETIME = GETDATE();
    PRINT '������� ��������� ���������: ' + CONVERT(VARCHAR, @StartTime, 120);
    
    -- �������� ��� ���������
    SELECT 
        m.Brand,
        COUNT(*) AS TotalModels,
        AVG(m.Price) AS AvgPrice,
        SUM(CASE WHEN m.WarrantyPeriod > 12 THEN 1 ELSE 0 END) AS ExtendedWarrantyCount
    FROM Monitors m
    GROUP BY m.Brand
    ORDER BY AvgPrice DESC;
    
    DECLARE @EndTime DATETIME = GETDATE();
    PRINT '��������� ��������� ���������: ' + CONVERT(VARCHAR, @EndTime, 120);
    PRINT '��������� ���������: ' + CAST(DATEDIFF(MILLISECOND, @StartTime, @EndTime) AS VARCHAR) + ' ��';
END;
CREATE TABLE PerformanceResults (
    TestID INT IDENTITY(1,1) PRIMARY KEY,
    TestDescription NVARCHAR(100),
    ExecutionTimeMs INT,
    TestDate DATETIME DEFAULT GETDATE()
);
DECLARE @StartTime DATETIME = GETDATE();

-- �������� ����� � JOIN, ����������� �� �����������
SELECT 
    m.Model,
    m.Price,
    c.CategoryName,
    o.OrderDate,
    cust.FirstName + ' ' + cust.LastName AS CustomerName
FROM Monitors m
JOIN ProductCategories c ON m.CategoryID = c.CategoryID
LEFT JOIN Orders o ON m.MonitorID = o.OrderID
LEFT JOIN Customers cust ON o.CustomerID = cust.CustomerID
WHERE m.Price > 500 AND m.WarrantyPeriod > 12
ORDER BY m.Price DESC, o.OrderDate;

INSERT INTO PerformanceResults (TestDescription, ExecutionTimeMs)
VALUES ('��� �������', DATEDIFF(MILLISECOND, @StartTime, GETDATE()));
-- ��������� ������� ��� ����������
CREATE INDEX IX_Monitors_Price_Warranty ON Monitors(Price, WarrantyPeriod);
CREATE INDEX IX_Orders_CustomerID ON Orders(CustomerID);

DECLARE @StartTime DATETIME = GETDATE();

-- ��� �� �����, ��� ����� � ���������
SELECT 
    m.Model,
    m.Price,
    c.CategoryName,
    o.OrderDate,
    cust.FirstName + ' ' + cust.LastName AS CustomerName
FROM Monitors m
JOIN ProductCategories c ON m.CategoryID = c.CategoryID
LEFT JOIN Orders o ON m.MonitorID = o.OrderID
LEFT JOIN Customers cust ON o.CustomerID = cust.CustomerID
WHERE m.Price > 500 AND m.WarrantyPeriod > 12
ORDER BY m.Price DESC, o.OrderDate;

INSERT INTO PerformanceResults (TestDescription, ExecutionTimeMs)
VALUES ('� ���������', DATEDIFF(MILLISECOND, @StartTime, GETDATE()));
DECLARE @StartTime DATETIME = GETDATE();

DECLARE @ResultTable TABLE (
    Model NVARCHAR(100),
    Price DECIMAL(10,2),
    CategoryName NVARCHAR(50),
    OrderDate DATE,
    CustomerName NVARCHAR(101)
);

DECLARE @Model NVARCHAR(100), @Price DECIMAL(10,2), @CategoryID INT;

DECLARE monitor_cursor CURSOR FOR
SELECT m.Model, m.Price, m.CategoryID
FROM Monitors m
WHERE m.Price > 500 AND m.WarrantyPeriod > 12
ORDER BY m.Price DESC;

OPEN monitor_cursor;
FETCH NEXT FROM monitor_cursor INTO @Model, @Price, @CategoryID;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @CategoryName NVARCHAR(50), @OrderDate DATE, @CustomerName NVARCHAR(101);
    
    SELECT @CategoryName = CategoryName FROM ProductCategories WHERE CategoryID = @CategoryID;
    
    SELECT TOP 1 @OrderDate = o.OrderDate, 
                 @CustomerName = c.FirstName + ' ' + c.LastName
    FROM Orders o
    JOIN Customers c ON o.CustomerID = c.CustomerID
    WHERE o.OrderID = (SELECT TOP 1 MonitorID FROM Monitors WHERE Model = @Model);
    
    INSERT INTO @ResultTable VALUES (@Model, @Price, @CategoryName, @OrderDate, @CustomerName);
    
    FETCH NEXT FROM monitor_cursor INTO @Model, @Price, @CategoryID;
END

CLOSE monitor_cursor;
DEALLOCATE monitor_cursor;

SELECT * FROM @ResultTable ORDER BY Price DESC, OrderDate;

INSERT INTO PerformanceResults (TestDescription, ExecutionTimeMs)
VALUES ('������ (� DEALLOCATE)', DATEDIFF(MILLISECOND, @StartTime, GETDATE()));
-- ������ ������
DECLARE @StartTime DATETIME = GETDATE();
-- ��� �� ��� �������, ��� ��� DEALLOCATE
-- ...
INSERT INTO PerformanceResults (TestDescription, ExecutionTimeMs)
VALUES ('������ (��� DEALLOCATE, 1� ������)', DATEDIFF(MILLISECOND, @StartTime, GETDATE()));

-- ������ ������
SET @StartTime = GETDATE();
-- ��� �� ��� �������
-- ...
INSERT INTO PerformanceResults (TestDescription, ExecutionTimeMs)
VALUES ('������ (��� DEALLOCATE, 2� ������)', DATEDIFF(MILLISECOND, @StartTime, GETDATE()));
-- ��������� ���������� ����������
SELECT 
    ROW_NUMBER() OVER (ORDER BY TestID) AS �,
    TestDescription AS '���� ������� �/�',
    ExecutionTimeMs AS '��� ��������� ������ (��)'
FROM PerformanceResults
ORDER BY TestID;