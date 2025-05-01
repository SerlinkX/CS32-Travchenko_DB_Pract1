-- ������� ���������� ��� ��������� ���� ������� �� ��������� ������ � ������ ���
BEGIN TRANSACTION;
    UPDATE Monitors SET Price = 599.99 WHERE MonitorID = 5;
    INSERT INTO PriceHistory (MonitorID, OldPrice, NewPrice, ChangeDate)
    VALUES (5, 549.99, 599.99, GETDATE());
COMMIT TRANSACTION;
-- ���������� � ������� �������
BEGIN TRANSACTION;
    -- ��������� ����������� ������
    UPDATE Monitors SET WarrantyPeriod = 36 WHERE MonitorID = 10;
    
    -- �������� ����� (���� ���� ������� � ����� > 5000 - �����)
    IF (SELECT COUNT(*) FROM Monitors WHERE Price > 5000) = 0
        ROLLBACK;
    ELSE
        COMMIT;
	-- ���������� � �������� ������� ����� @@ERROR
BEGIN TRANSACTION;
    -- ������ ������� ��������� �����
    UPDATE Monitors SET Price = 399.99 WHERE MonitorID = 999;
    
    IF @@ERROR <> 0
    BEGIN
        ROLLBACK;
        PRINT '������� ��� �������� �������';
    END
    ELSE
        COMMIT;
		-- ���������� � ������ ����������
BEGIN TRANSACTION;
    -- ��������� ������
    UPDATE Monitors SET Brand = 'Dell' WHERE MonitorID = 15;
    
    -- ����� ����������
    SAVE TRANSACTION BeforePriceUpdate;
    
    -- ������ ������� ����
    UPDATE Monitors SET Price = -100 WHERE MonitorID = 15; -- ������ ����
    
    -- ³���� �� ����� ����������
    ROLLBACK TRANSACTION BeforePriceUpdate;
    
    -- ϳ����������� ���������� (���� ��������� ������)
    COMMIT;
	-- ���������� � �������� ������� ����� TRY-CATCH
BEGIN TRANSACTION;
BEGIN TRY
    -- ��������� �������
    UPDATE Monitors SET CategoryID = 5 WHERE MonitorID = 20;
    
    -- ������ ���������� ��������� ���� (������� �������)
    UPDATE Monitors SET Price = -100 WHERE MonitorID = 20;
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT '������� �������: ' + ERROR_MESSAGE();
END CATCH;
-- ���������� � ���������� ���
BEGIN TRANSACTION;
    DECLARE @OldPrice DECIMAL(10,2) = (SELECT Price FROM Monitors WHERE MonitorID = 25);
    
    UPDATE Monitors SET Price = 899.99 WHERE MonitorID = 25;
    
    INSERT INTO AuditLog (TableName, RecordID, Action, OldValue, NewValue, ChangeDate)
    VALUES ('Monitors', 25, 'Price update', CAST(@OldPrice AS NVARCHAR), '899.99', GETDATE());
    
    COMMIT TRANSACTION;
	-- ������� �������� ���������� (��� ���, ��� �����)
BEGIN TRANSACTION;
    -- ��������� ������ �������
    INSERT INTO Monitors (Model, Brand, Price, CategoryID, WarrantyPeriod)
    VALUES ('UltraSharp U4323QE', 'Dell', 1299.99, 1, 36);
    
    -- ��������� ������������ ������
    INSERT INTO Inventory (MonitorID, Quantity, Location)
    VALUES (SCOPE_IDENTITY(), 5, 'Warehouse A');
    
    -- ���� ��� ����� - ����, ���� ������� - ������������ �����
    COMMIT TRANSACTION;
	-- ����������, �� ������� ����������� �����
BEGIN TRANSACTION;
    -- ��������� ������ ����������
    INSERT INTO Orders (CustomerID, OrderDate, TotalAmount, OrderStatus)
    VALUES (15, GETDATE(), 1999.98, 'Processing');
    
    -- ��������� ��������� ��������� �볺���
    UPDATE Customers SET OrderCount = OrderCount + 1 
    WHERE CustomerID = 15;
    
    -- ��������� ������� �� �����
    UPDATE Inventory SET Quantity = Quantity - 2 
    WHERE MonitorID = 42 AND Location = 'Warehouse A';
    
    COMMIT TRANSACTION;
	-- ���������� ���������� � ������ ����
BEGIN TRANSACTION;
    -- 1. ��������� ������ �볺���
    INSERT INTO Customers (FirstName, LastName, Email, Phone)
    VALUES ('���������', '��������', 'alex.p@example.com', '+380991234567');
    
    DECLARE @NewCustomerID INT = SCOPE_IDENTITY();
    
    -- 2. ��������� ���������� ��� ������ �볺���
    INSERT INTO Orders (CustomerID, OrderDate, TotalAmount, OrderStatus)
    VALUES (@NewCustomerID, GETDATE(), 3499.97, 'New');
    
    DECLARE @NewOrderID INT = SCOPE_IDENTITY();
    
    -- 3. ��������� ���������� �� ���������
    UPDATE CategoryStats SET TotalOrders = TotalOrders + 1 
    WHERE CategoryID = 3;
    
    COMMIT TRANSACTION;