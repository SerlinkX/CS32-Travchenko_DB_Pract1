-- Запит без індексів
SELECT * FROM Monitors WHERE Brand = 'Dell';
-- Запит з умовами фільтрації
SELECT m.Model, m.Price, c.CategoryName
FROM Monitors m
JOIN ProductCategories c ON m.CategoryID = c.CategoryID
WHERE m.Price > 500
ORDER BY m.Brand;
-- Кластеризований індекс для таблиці Monitors
CREATE CLUSTERED INDEX IX_Monitors_MonitorID ON Monitors(MonitorID);
-- Некластеризований індекс для полів Brand та Price
CREATE NONCLUSTERED INDEX IX_Monitors_Brand_Price ON Monitors(Brand, Price);
-- Унікальний індекс для email клієнтів
CREATE UNIQUE INDEX IX_Customers_Email_Unique ON Customers(Email);
-- Індекс з включеними стовпцями
CREATE NONCLUSTERED INDEX IX_Monitors_Brand_Include
ON Monitors(Brand)
INCLUDE (Model, Price);
-- Фільтрований індекс для замовлень зі статусом 'Pending'
CREATE NONCLUSTERED INDEX IX_Orders_Pending_Status
ON Orders(OrderStatus)
WHERE OrderStatus = 'Pending';
SELECT 
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    ips.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.avg_fragmentation_in_percent > 10;
-- Реорганізація індексу
ALTER INDEX IX_Monitors_Brand_Price ON Monitors REORGANIZE;
-- Повна перебудова індексу
ALTER INDEX IX_Monitors_Brand_Price ON Monitors REBUILD;
-- Видалення непотрібного індексу
DROP INDEX IX_Monitors_Brand_Price ON Monitors;
-- До створення індексу
SELECT * FROM Monitors WHERE Brand = 'Dell';
-- Після створення індексу
CREATE INDEX IX_Monitors_Brand ON Monitors(Brand);
SELECT * FROM Monitors WHERE Brand = 'Dell';