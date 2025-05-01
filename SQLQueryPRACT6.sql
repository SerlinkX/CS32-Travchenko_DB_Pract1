-- Приклад транзакції для оновлення ціни монітора та додавання запису в історію змін
BEGIN TRANSACTION;
    UPDATE Monitors SET Price = 599.99 WHERE MonitorID = 5;
    INSERT INTO PriceHistory (MonitorID, OldPrice, NewPrice, ChangeDate)
    VALUES (5, 549.99, 599.99, GETDATE());
COMMIT TRANSACTION;
-- Транзакція з умовним відкатом
BEGIN TRANSACTION;
    -- Оновлення гарантійного періоду
    UPDATE Monitors SET WarrantyPeriod = 36 WHERE MonitorID = 10;
    
    -- Перевірка умови (якщо немає моніторів з ціною > 5000 - відкат)
    IF (SELECT COUNT(*) FROM Monitors WHERE Price > 5000) = 0
        ROLLBACK;
    ELSE
        COMMIT;
	-- Транзакція з обробкою помилок через @@ERROR
BEGIN TRANSACTION;
    -- Спроба оновити неіснуючий запис
    UPDATE Monitors SET Price = 399.99 WHERE MonitorID = 999;
    
    IF @@ERROR <> 0
    BEGIN
        ROLLBACK;
        PRINT 'Помилка при оновленні монітора';
    END
    ELSE
        COMMIT;
		-- Транзакція з точкою збереження
BEGIN TRANSACTION;
    -- Оновлення бренду
    UPDATE Monitors SET Brand = 'Dell' WHERE MonitorID = 15;
    
    -- Точка збереження
    SAVE TRANSACTION BeforePriceUpdate;
    
    -- Спроба оновити ціну
    UPDATE Monitors SET Price = -100 WHERE MonitorID = 15; -- Невірна ціна
    
    -- Відкат до точки збереження
    ROLLBACK TRANSACTION BeforePriceUpdate;
    
    -- Підтвердження транзакції (лише оновлення бренду)
    COMMIT;
	-- Транзакція з обробкою помилок через TRY-CATCH
BEGIN TRANSACTION;
BEGIN TRY
    -- Оновлення категорії
    UPDATE Monitors SET CategoryID = 5 WHERE MonitorID = 20;
    
    -- Спроба встановити негативну ціну (викличе помилку)
    UPDATE Monitors SET Price = -100 WHERE MonitorID = 20;
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Сталася помилка: ' + ERROR_MESSAGE();
END CATCH;
-- Транзакція з логуванням змін
BEGIN TRANSACTION;
    DECLARE @OldPrice DECIMAL(10,2) = (SELECT Price FROM Monitors WHERE MonitorID = 25);
    
    UPDATE Monitors SET Price = 899.99 WHERE MonitorID = 25;
    
    INSERT INTO AuditLog (TableName, RecordID, Action, OldValue, NewValue, ChangeDate)
    VALUES ('Monitors', 25, 'Price update', CAST(@OldPrice AS NVARCHAR), '899.99', GETDATE());
    
    COMMIT TRANSACTION;
	-- Приклад атомарної транзакції (або все, або нічого)
BEGIN TRANSACTION;
    -- Додавання нового монітора
    INSERT INTO Monitors (Model, Brand, Price, CategoryID, WarrantyPeriod)
    VALUES ('UltraSharp U4323QE', 'Dell', 1299.99, 1, 36);
    
    -- Додавання інвентарного запису
    INSERT INTO Inventory (MonitorID, Quantity, Location)
    VALUES (SCOPE_IDENTITY(), 5, 'Warehouse A');
    
    -- Якщо все добре - коміт, якщо помилка - автоматичний відкат
    COMMIT TRANSACTION;
	-- Транзакція, що підтримує узгодженість даних
BEGIN TRANSACTION;
    -- Додавання нового замовлення
    INSERT INTO Orders (CustomerID, OrderDate, TotalAmount, OrderStatus)
    VALUES (15, GETDATE(), 1999.98, 'Processing');
    
    -- Оновлення лічильника замовлень клієнта
    UPDATE Customers SET OrderCount = OrderCount + 1 
    WHERE CustomerID = 15;
    
    -- Зменшення кількості на складі
    UPDATE Inventory SET Quantity = Quantity - 2 
    WHERE MonitorID = 42 AND Location = 'Warehouse A';
    
    COMMIT TRANSACTION;
	-- Комплексна транзакція з трьома діями
BEGIN TRANSACTION;
    -- 1. Додавання нового клієнта
    INSERT INTO Customers (FirstName, LastName, Email, Phone)
    VALUES ('Олександр', 'Петренко', 'alex.p@example.com', '+380991234567');
    
    DECLARE @NewCustomerID INT = SCOPE_IDENTITY();
    
    -- 2. Додавання замовлення для нового клієнта
    INSERT INTO Orders (CustomerID, OrderDate, TotalAmount, OrderStatus)
    VALUES (@NewCustomerID, GETDATE(), 3499.97, 'New');
    
    DECLARE @NewOrderID INT = SCOPE_IDENTITY();
    
    -- 3. Оновлення статистики по категоріях
    UPDATE CategoryStats SET TotalOrders = TotalOrders + 1 
    WHERE CategoryID = 3;
    
    COMMIT TRANSACTION;