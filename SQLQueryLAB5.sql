-- 1. sp_help - ��������� ���������� ��� ��'��� ���� �����
EXEC sp_help 'Monitors';
/*
������������: 
�����������: �������� ���������� ��� ��������� �������, �������, ���������
������������: ���� ������� ������ �������� ������� ��� �������
*/

-- 2. sp_who2 - ��������� �������� ������
EXEC sp_who2;
/*
������������:
�����������: ������ ������ ���������� �� ���� �����
������������: ��� ������ ������������ �� ��������� ���������
*/

-- 3. sp_spaceused - ����� ������������ ��������
EXEC sp_spaceused 'Orders';
/*
������������:
�����������: ������ ����� ����� �� ������� ��� �������
������������: ��� ���������� ��������� ������� �� ���������� ��������� ����
*/
-- ��������� ��������� ��������� ���������
CREATE PROCEDURE ##GetExpensiveMonitors
AS
BEGIN
    SELECT Model, Brand, Price 
    FROM Monitors 
    WHERE Price > 1000
    ORDER BY Price DESC;
END;
GO

-- ������ ��������� ��������� ���������
EXEC ##GetExpensiveMonitors;
/*
������������:
�����������: �������� ��� ��� ������, ����������� ��� ��������������� �������
������������: ��� ���������� �������, �� ���������� �������� �������
*/

-- ����� �������
CREATE PROCEDURE ##GetRecentOrders
AS
BEGIN
    SELECT TOP 10 * FROM Orders ORDER BY OrderDate DESC;
END;
GO

-- ����� �������
CREATE PROCEDURE ##UpdateMonitorPrice
    @MonitorID INT,
    @NewPrice DECIMAL(10,2)
AS
BEGIN
    UPDATE Monitors SET Price = @NewPrice WHERE MonitorID = @MonitorID;
END;
GO
-- ��������� ��������� ��������� (�������� ����� � ��������� �����)
CREATE PROCEDURE #GetPendingOrders
AS
BEGIN
    SELECT * FROM Orders WHERE OrderStatus = 'Pending';
END;
GO

-- ������ ��������� ���������
EXEC #GetPendingOrders;
/*
������������:
�����������: �������� ����� � ��������� ���������, ����������� �����������
������������: ��� ���������� ������� �� ����������
*/

-- ����� �������
CREATE PROCEDURE #GetMonitorsByCategory
    @CategoryID INT
AS
BEGIN
    SELECT * FROM Monitors WHERE CategoryID = @CategoryID;
END;
GO

-- ����� �������
CREATE PROCEDURE #CountCustomers
AS
BEGIN
    SELECT COUNT(*) AS CustomerCount FROM Customers;
END;
GO
-- ��������� ��� ��������� ������ ������� � �����������
CREATE PROCEDURE usp_AddNewMonitor
    @Model NVARCHAR(100),
    @Brand NVARCHAR(50),
    @Price DECIMAL(10,2),
    @CategoryID INT,
    @WarrantyPeriod INT = 12
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        INSERT INTO Monitors (Model, Brand, Price, CategoryID, WarrantyPeriod)
        VALUES (@Model, @Brand, @Price, @CategoryID, @WarrantyPeriod);
        
        COMMIT TRANSACTION;
        SELECT SCOPE_IDENTITY() AS NewMonitorID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT NULL AS NewMonitorID;
        THROW;
    END CATCH
END;
GO
/*
������������:
�����������: �������� ��������� ������ ������� � �������� �������
������������: ��� ����������� �������� ����� ��� �������� ������
*/

-- ��������� ��� ��������� ������� ����������
CREATE PROCEDURE usp_UpdateOrderStatus
    @OrderID INT,
    @NewStatus NVARCHAR(20)
AS
BEGIN
    BEGIN TRANSACTION;
    
    UPDATE Orders 
    SET OrderStatus = @NewStatus 
    WHERE OrderID = @OrderID;
    
    IF @@ROWCOUNT = 0
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('���������� � ID %d �� ��������', 16, 1, @OrderID);
        RETURN;
    END
    
    COMMIT TRANSACTION;
END;
GO

-- ��������� ��� ��������� �볺��� � ���� ���� ������������
CREATE PROCEDURE usp_DeleteCustomerWithOrders
    @CustomerID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DELETE FROM Orders WHERE CustomerID = @CustomerID;
        DELETE FROM Customers WHERE CustomerID = @CustomerID;
        
        COMMIT TRANSACTION;
        SELECT 1 AS Success;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT 0 AS Success;
        THROW;
    END CATCH
END;
GO
CREATE PROCEDURE usp_AddMultipleMonitors
    @Count INT,
    @Brand NVARCHAR(50) = 'Generic',
    @BasePrice DECIMAL(10,2) = 100.00
AS
BEGIN
    DECLARE @i INT = 1;
    
    WHILE @i <= @Count
    BEGIN
        INSERT INTO Monitors (Model, Brand, Price, CategoryID, WarrantyPeriod)
        VALUES ('Model-' + CAST(@i AS NVARCHAR(10)), 
               @Brand, 
               @BasePrice + (@i * 10), 
               (@i % 3) + 1, -- ������� 1-3
               12;
        
        SET @i = @i + 1;
    END
    
    SELECT @Count AS RowsAdded;
END;
GO

-- ������ ��������� ��� ��������� 5 �������
EXEC usp_AddMultipleMonitors @Count = 5, @Brand = 'TestBrand', @BasePrice = 200.00;
-- �������� �������� �����������, ���� �� ����
IF NOT EXISTS (SELECT * FROM sys.sequences WHERE name = 'seq_MonitorID')
    CREATE SEQUENCE seq_MonitorID
    START WITH 1000
    INCREMENT BY 1;
GO

-- ��������� ��� ������� � ������������ ID
CREATE PROCEDURE usp_InsertMonitorWithGeneratedID
    @Model NVARCHAR(100),
    @Brand NVARCHAR(50),
    @Price DECIMAL(10,2),
    @CategoryID INT,
    @WarrantyPeriod INT = 12
AS
BEGIN
    BEGIN TRY
        DECLARE @NewID INT = NEXT VALUE FOR seq_MonitorID;
        
        INSERT INTO Monitors (MonitorID, Model, Brand, Price, CategoryID, WarrantyPeriod)
        VALUES (@NewID, @Model, @Brand, @Price, @CategoryID, @WarrantyPeriod);
        
        SELECT @NewID AS InsertedMonitorID;
    END TRY
    BEGIN CATCH
        SELECT NULL AS InsertedMonitorID;
        THROW;
    END CATCH
END;
GO

-- ������� �������
EXEC usp_InsertMonitorWithGeneratedID 
    @Model = 'NewModel', 
    @Brand = 'PremiumBrand', 
    @Price = 799.99, 
    @CategoryID = 2;