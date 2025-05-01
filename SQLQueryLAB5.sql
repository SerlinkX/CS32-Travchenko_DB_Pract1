-- 1. sp_help - отримання інформації про об'єкт бази даних
EXEC sp_help 'Monitors';
/*
Специфікація: 
Призначення: Виводить інформацію про структуру таблиці, індекси, обмеження
Використання: Коли потрібно швидко отримати метадані про таблицю
*/

-- 2. sp_who2 - моніторинг активних сеансів
EXEC sp_who2;
/*
Специфікація:
Призначення: Показує активні підключення до бази даних
Використання: Для аналізу навантаження та виявлення блокувань
*/

-- 3. sp_spaceused - аналіз використання простору
EXEC sp_spaceused 'Orders';
/*
Специфікація:
Призначення: Показує обсяг даних та індексів для таблиці
Використання: Для моніторингу зростання таблиць та планування резервних копій
*/
-- Створення глобальної тимчасової процедури
CREATE PROCEDURE ##GetExpensiveMonitors
AS
BEGIN
    SELECT Model, Brand, Price 
    FROM Monitors 
    WHERE Price > 1000
    ORDER BY Price DESC;
END;
GO

-- Виклик глобальної тимчасової процедури
EXEC ##GetExpensiveMonitors;
/*
Специфікація:
Призначення: Доступна для всіх сеансів, видаляється при перезавантаженні сервера
Використання: Для тимчасових завдань, що потребують спільного доступу
*/

-- Інший приклад
CREATE PROCEDURE ##GetRecentOrders
AS
BEGIN
    SELECT TOP 10 * FROM Orders ORDER BY OrderDate DESC;
END;
GO

-- Третій приклад
CREATE PROCEDURE ##UpdateMonitorPrice
    @MonitorID INT,
    @NewPrice DECIMAL(10,2)
AS
BEGIN
    UPDATE Monitors SET Price = @NewPrice WHERE MonitorID = @MonitorID;
END;
GO
-- Створення тимчасової процедури (доступна тільки в поточному сеансі)
CREATE PROCEDURE #GetPendingOrders
AS
BEGIN
    SELECT * FROM Orders WHERE OrderStatus = 'Pending';
END;
GO

-- Виклик тимчасової процедури
EXEC #GetPendingOrders;
/*
Специфікація:
Призначення: Доступна тільки в поточному підключенні, автоматично видаляється
Використання: Для тимчасових скриптів та тестування
*/

-- Інший приклад
CREATE PROCEDURE #GetMonitorsByCategory
    @CategoryID INT
AS
BEGIN
    SELECT * FROM Monitors WHERE CategoryID = @CategoryID;
END;
GO

-- Третій приклад
CREATE PROCEDURE #CountCustomers
AS
BEGIN
    SELECT COUNT(*) AS CustomerCount FROM Customers;
END;
GO
-- Процедура для додавання нового монітора з транзакцією
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
Специфікація:
Призначення: Безпечне додавання нового монітора з обробкою помилок
Використання: Для гарантованої цілісності даних при додаванні товарів
*/

-- Процедура для оновлення статусу замовлення
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
        RAISERROR('Замовлення з ID %d не знайдено', 16, 1, @OrderID);
        RETURN;
    END
    
    COMMIT TRANSACTION;
END;
GO

-- Процедура для видалення клієнта з усіма його замовленнями
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
               (@i % 3) + 1, -- Категорії 1-3
               12;
        
        SET @i = @i + 1;
    END
    
    SELECT @Count AS RowsAdded;
END;
GO

-- Виклик процедури для додавання 5 моніторів
EXEC usp_AddMultipleMonitors @Count = 5, @Brand = 'TestBrand', @BasePrice = 200.00;
-- Спочатку створимо послідовність, якщо її немає
IF NOT EXISTS (SELECT * FROM sys.sequences WHERE name = 'seq_MonitorID')
    CREATE SEQUENCE seq_MonitorID
    START WITH 1000
    INCREMENT BY 1;
GO

-- Процедура для вставки з автоматичним ID
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

-- Приклад виклику
EXEC usp_InsertMonitorWithGeneratedID 
    @Model = 'NewModel', 
    @Brand = 'PremiumBrand', 
    @Price = 799.99, 
    @CategoryID = 2;