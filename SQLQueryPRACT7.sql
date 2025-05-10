BEGIN TRANSACTION;
BEGIN TRY
    -- ��������� ���� �������
    UPDATE Monitors SET Price = 799.99 WHERE MonitorID = 5;
    
    -- ��������� ������ � ������ ��� ���
    INSERT INTO PriceHistory (MonitorID, OldPrice, NewPrice, ChangeDate)
    VALUES (5, 749.99, 799.99, GETDATE());
    
    COMMIT TRANSACTION;
    PRINT 'ֳ�� ������ �������� �� ���� ����������';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT '������� ��� �������� ����: ' + ERROR_MESSAGE();
END CATCH;
- 1. ��������� ����
ALTER TABLE Monitors
ADD CONSTRAINT PK_Monitors PRIMARY KEY (MonitorID);

-- 2. ������� ����
ALTER TABLE Monitors
ADD CONSTRAINT FK_Monitors_Categories 
FOREIGN KEY (CategoryID) REFERENCES ProductCategories(CategoryID);

-- 3. ���������� ����� � ����� ������
ALTER TABLE Monitors
ADD CONSTRAINT UQ_Model_Brand UNIQUE (Model, Brand);

-- 4. �������� �������� ����
ALTER TABLE Monitors
ADD CONSTRAINT CK_Price_Positive CHECK (Price > 0);

-- 5. �������� ����������� ������
ALTER TABLE Monitors
ADD CONSTRAINT CK_Warranty_Period CHECK (WarrantyPeriod BETWEEN 12 AND 36);

-- 6. �� NULL ���������
ALTER TABLE Monitors
ALTER COLUMN Model NVARCHAR(100) NOT NULL;

-- 7. �������� �� �������������
ALTER TABLE Monitors
ADD CONSTRAINT DF_Warranty_Period DEFAULT 12 FOR WarrantyPeriod;

-- 8. �������� ������� email �볺���
ALTER TABLE Customers
ADD CONSTRAINT CK_Email_Format CHECK (Email LIKE '%_@__%.__%');

-- 9. ���������� email
ALTER TABLE Customers
ADD CONSTRAINT UQ_Customer_Email UNIQUE (Email);

-- 10. �������� ������� ����������
ALTER TABLE Orders
ADD CONSTRAINT CK_Order_Status 
CHECK (OrderStatus IN ('New', 'Processing', 'Shipped', 'Delivered', 'Cancelled'));
-- ������� �������� (�� �������������)
ALTER TABLE Orders WITH CHECK
ADD CONSTRAINT CK_Order_Date_Immediate
CHECK (OrderDate <= GETDATE());

-- ³�������� �������� (������ SET IMPLICIT_TRANSACTIONS ON)
BEGIN TRANSACTION;
    SET CONSTRAINTS ALL DEFERRED;
    
    INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount, OrderStatus)
    VALUES (1001, 1, '2023-12-31', 999.99, 'New'); -- ���� � �����������
    
    -- ���� ��������...
    
    SET CONSTRAINTS ALL IMMEDIATE; -- �������� ���������� ���
COMMIT TRANSACTION;
-- 1. ��������� ������ (��� �����)
CREATE DOMAIN PriceDomain AS DECIMAL(10,2)
CHECK (VALUE > 0);

-- 2. ��������� �������� (�������� �������)
ALTER TABLE Monitors
ADD CONSTRAINT CK_Monitor_Price_Range
CHECK (Price BETWEEN 100 AND 5000);

-- 3. ��������� ������� (�����)
ALTER TABLE Orders
ADD CONSTRAINT CK_Order_Amount
CHECK (TotalAmount >= (SELECT Price FROM Monitors WHERE MonitorID = Orders.MonitorID));

-- 4. ��������� ��������� (�� ���������)
ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_Customers
FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
ON DELETE CASCADE;

-- 5. ��������� ���� ����� (�� ������� ���������)
-- ���������, ������������ ����, �� ���������� �� ����������� ��������� ������ �볺���
-- �� ������ ������� ��� �������� ��������