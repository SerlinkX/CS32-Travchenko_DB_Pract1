CREATE TRIGGER tr_Monitors_PriceUpdate
ON Monitors
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- ЋогуЇмо зм≥ни т≥льки €кщо зм≥нилас€ ц≥на
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
        
        PRINT '«м≥ни ц≥н усп≥шно залогован≥';
    END
END;
CREATE TRIGGER tr_Orders_BeforeInsert
ON Orders
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- якщо таблиц€ Inventory ≥снуЇ, перев≥р€Їмо на€вн≥сть
    IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Inventory')
    BEGIN
        -- ѕерев≥р€Їмо вс≥ нов≥ замовленн€
        IF EXISTS (
            SELECT 1 FROM inserted i
            JOIN Monitors m ON i.MonitorID = m.MonitorID
            JOIN Inventory inv ON m.MonitorID = inv.MonitorID
            WHERE inv.Quantity < 1
        )
        BEGIN
            RAISERROR('Ќе можна створити замовленн€ - де€к≥ товари в≥дсутн≥ на склад≥', 16, 1);
            RETURN;
        END
        
        -- якщо вс≥ товари в на€вност≥, додаЇмо замовленн€
        INSERT INTO Orders (CustomerID, MonitorID, OrderDate, TotalAmount, OrderStatus)
        SELECT CustomerID, MonitorID, OrderDate, TotalAmount, OrderStatus
        FROM inserted;
        
        -- ќновлюЇмо к≥льк≥сть на склад≥
        UPDATE inv
        SET inv.Quantity = inv.Quantity - 1
        FROM Inventory inv
        JOIN inserted i ON inv.MonitorID = i.MonitorID;
        
        PRINT '«амовленн€ усп≥шно створено та к≥льк≥сть на склад≥ оновлено';
    END
    ELSE
    BEGIN
        -- якщо таблиц≥ Inventory немаЇ, просто додаЇмо замовленн€
        INSERT INTO Orders (CustomerID, MonitorID, OrderDate, TotalAmount, OrderStatus)
        SELECT CustomerID, MonitorID, OrderDate, TotalAmount, OrderStatus
        FROM inserted;
    END
END;