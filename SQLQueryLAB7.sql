CREATE TRIGGER tr_Monitors_AfterInsert
ON Monitors
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO MonitorLog (LogDate, Action, MonitorID, Details)
    SELECT GETDATE(), 'INSERT', i.MonitorID, 
           'Додано новий монітор: ' + i.Brand + ' ' + i.Model + ' за ціною ' + CAST(i.Price AS NVARCHAR)
    FROM inserted i;
    
    PRINT 'Новий монітор залоговано в системі';
END;
CREATE TRIGGER tr_Monitors_InsteadOfUpdate
ON Monitors
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Блокуємо зниження ціни більше ніж на 20%
    IF UPDATE(Price)
    BEGIN
        IF EXISTS (
            SELECT 1 FROM inserted i
            JOIN deleted d ON i.MonitorID = d.MonitorID
            WHERE i.Price < d.Price * 0.8
        )
        BEGIN
            RAISERROR('Зниження ціни більше ніж на 20% заборонено', 16, 1);
            RETURN;
        END
    END
    
    -- Якщо все в порядку, виконуємо оновлення
    UPDATE m
    SET 
        m.Model = i.Model,
        m.Brand = i.Brand,
        m.Price = i.Price,
        m.Specifications = i.Specifications,
        m.CategoryID = i.CategoryID,
        m.WarrantyPeriod = i.WarrantyPeriod
    FROM Monitors m
    JOIN inserted i ON m.MonitorID = i.MonitorID;
    
    PRINT 'Дані монітора успішно оновлено';
END;
CREATE TRIGGER tr_Orders_AfterDelete
ON Orders
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO OrdersArchive (OrderID, CustomerID, MonitorID, OrderDate, TotalAmount, OrderStatus, ArchiveDate)
    SELECT 
        d.OrderID, d.CustomerID, d.MonitorID, d.OrderDate, d.TotalAmount, d.OrderStatus, GETDATE()
    FROM deleted d;
    
    PRINT 'Видалене замовлення архівовано';
END;
CREATE TRIGGER tr_Database_TableChanges
ON DATABASE
FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @EventData XML = EVENTDATA();
    
    INSERT INTO DatabaseChangeLog (ChangeDate, ChangeType, ObjectName, UserName, SQLCommand)
    VALUES (
        GETDATE(),
        @EventData.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(100)'),
        @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]', 'nvarchar(100)'),
        @EventData.value('(/EVENT_INSTANCE/UserName)[1]', 'nvarchar(100)'),
        @EventData.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'nvarchar(max)')
    );
    
    PRINT 'Зміна структури БД залогована';
END;
CREATE TRIGGER tr_Reviews_UpdateRating
ON MonitorReviews
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Оновлюємо середній рейтинг для всіх моніторів, які були зачіплені
    UPDATE m
    SET 
        m.AverageRating = (
            SELECT AVG(CAST(r.Rating AS DECIMAL(3,1)))
            FROM MonitorReviews r
            WHERE r.MonitorID = m.MonitorID
        ),
        m.ReviewCount = (
            SELECT COUNT(*)
            FROM MonitorReviews r
            WHERE r.MonitorID = m.MonitorID
        )
    FROM Monitors m
    WHERE m.MonitorID IN (
        SELECT MonitorID FROM inserted
        UNION
        SELECT MonitorID FROM deleted
    );
END;
CREATE TRIGGER tr_Monitors_CheckSerialNumber
ON Monitors
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(SerialNumber)
    BEGIN
        IF EXISTS (
            SELECT 1 FROM inserted i
            GROUP BY i.SerialNumber
            HAVING COUNT(*) > 1
        )
        OR EXISTS (
            SELECT 1 FROM inserted i
            JOIN Monitors m ON i.SerialNumber = m.SerialNumber
            WHERE i.MonitorID <> m.MonitorID
        )
        BEGIN
            RAISERROR('Серійний номер повинен бути унікальним', 16, 1);
            ROLLBACK TRANSACTION;
        END
    END
END;