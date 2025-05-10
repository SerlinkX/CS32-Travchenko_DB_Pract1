BEGIN TRANSACTION;
BEGIN TRY
    -- Оновлення ціни монітора
    UPDATE Monitors SET Price = 799.99 WHERE MonitorID = 5;
    
    -- Додавання запису в історію змін цін
    INSERT INTO PriceHistory (MonitorID, OldPrice, NewPrice, ChangeDate)
    VALUES (5, 749.99, 799.99, GETDATE());
    
    COMMIT TRANSACTION;
    PRINT 'Ціну успішно оновлено та зміни залоговано';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Помилка при оновленні ціни: ' + ERROR_MESSAGE();
END CATCH;
- 1. Первинний ключ
ALTER TABLE Monitors
ADD CONSTRAINT PK_Monitors PRIMARY KEY (MonitorID);

-- 2. Зовнішній ключ
ALTER TABLE Monitors
ADD CONSTRAINT FK_Monitors_Categories 
FOREIGN KEY (CategoryID) REFERENCES ProductCategories(CategoryID);

-- 3. Унікальність моделі в межах бренду
ALTER TABLE Monitors
ADD CONSTRAINT UQ_Model_Brand UNIQUE (Model, Brand);

-- 4. Перевірка діапазону ціни
ALTER TABLE Monitors
ADD CONSTRAINT CK_Price_Positive CHECK (Price > 0);

-- 5. Перевірка гарантійного періоду
ALTER TABLE Monitors
ADD CONSTRAINT CK_Warranty_Period CHECK (WarrantyPeriod BETWEEN 12 AND 36);

-- 6. Не NULL обмеження
ALTER TABLE Monitors
ALTER COLUMN Model NVARCHAR(100) NOT NULL;

-- 7. Значення за замовчуванням
ALTER TABLE Monitors
ADD CONSTRAINT DF_Warranty_Period DEFAULT 12 FOR WarrantyPeriod;

-- 8. Перевірка формату email клієнта
ALTER TABLE Customers
ADD CONSTRAINT CK_Email_Format CHECK (Email LIKE '%_@__%.__%');

-- 9. Унікальність email
ALTER TABLE Customers
ADD CONSTRAINT UQ_Customer_Email UNIQUE (Email);

-- 10. Перевірка статусу замовлення
ALTER TABLE Orders
ADD CONSTRAINT CK_Order_Status 
CHECK (OrderStatus IN ('New', 'Processing', 'Shipped', 'Delivered', 'Cancelled'));
-- Негайна перевірка (за замовчуванням)
ALTER TABLE Orders WITH CHECK
ADD CONSTRAINT CK_Order_Date_Immediate
CHECK (OrderDate <= GETDATE());

-- Відкладена перевірка (вимагає SET IMPLICIT_TRANSACTIONS ON)
BEGIN TRANSACTION;
    SET CONSTRAINTS ALL DEFERRED;
    
    INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount, OrderStatus)
    VALUES (1001, 1, '2023-12-31', 999.99, 'New'); -- Дата в майбутньому
    
    -- Інші операції...
    
    SET CONSTRAINTS ALL IMMEDIATE; -- Перевірка відбувається тут
COMMIT TRANSACTION;
-- 1. Обмеження домена (тип даних)
CREATE DOMAIN PriceDomain AS DECIMAL(10,2)
CHECK (VALUE > 0);

-- 2. Обмеження атрибута (окремого стовпця)
ALTER TABLE Monitors
ADD CONSTRAINT CK_Monitor_Price_Range
CHECK (Price BETWEEN 100 AND 5000);

-- 3. Обмеження кортежу (рядка)
ALTER TABLE Orders
ADD CONSTRAINT CK_Order_Amount
CHECK (TotalAmount >= (SELECT Price FROM Monitors WHERE MonitorID = Orders.MonitorID));

-- 4. Обмеження відношення (між таблицями)
ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_Customers
FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
ON DELETE CASCADE;

-- 5. Обмеження бази даних (між кількома таблицями)
-- Наприклад, забезпечення того, що замовлення не перевищують загальний бюджет клієнта
-- Це вимагає тригерів або складних перевірок