CREATE TRIGGER tr_Monitors_PriceUpdate
ON Monitors
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- ������ ���� ����� ���� �������� ����
    IF UPDATE(Price)
    BEGIN
        INSERT INTO PriceHistory (MonitorID, OldPrice, NewPrice, ChangeDate, ChangedBy)
        SELECT 
            i.MonitorID,
            d.Price AS OldPrice,
            i.Price AS NewPrice,
            GETDATE() AS ChangeDate,
            SYSTEM_USER AS ChangedBy
        FROM inserted i
        JOIN deleted d ON i.MonitorID = d.MonitorID
        WHERE i.Price <> d.Price;
        
        PRINT '���� ��� ������ ���������';
    END
END;
CREATE TRIGGER tr_Orders_BeforeInsert
ON Orders
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- ���� ������� Inventory ����, ���������� ��������
    IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Inventory')
    BEGIN
        -- ���������� �� ��� ����������
        IF EXISTS (
            SELECT 1 FROM inserted i
            JOIN Monitors m ON i.MonitorID = m.MonitorID
            JOIN Inventory inv ON m.MonitorID = inv.MonitorID
            WHERE inv.Quantity < 1
        )
        BEGIN
            RAISERROR('�� ����� �������� ���������� - ���� ������ ������ �� �����', 16, 1);
            RETURN;
        END
        
        -- ���� �� ������ � ��������, ������ ����������
        INSERT INTO Orders (CustomerID, MonitorID, OrderDate, TotalAmount, OrderStatus)
        SELECT CustomerID, MonitorID, OrderDate, TotalAmount, OrderStatus
        FROM inserted;
        
        -- ��������� ������� �� �����
        UPDATE inv
        SET inv.Quantity = inv.Quantity - 1
        FROM Inventory inv
        JOIN inserted i ON inv.MonitorID = i.MonitorID;
        
        PRINT '���������� ������ �������� �� ������� �� ����� ��������';
    END
    ELSE
    BEGIN
        -- ���� ������� Inventory ����, ������ ������ ����������
        INSERT INTO Orders (CustomerID, MonitorID, OrderDate, TotalAmount, OrderStatus)
        SELECT CustomerID, MonitorID, OrderDate, TotalAmount, OrderStatus
        FROM inserted;
    END
END;