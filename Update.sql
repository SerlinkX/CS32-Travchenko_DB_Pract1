-- Оновлення ціни для монітора
UPDATE Monitors
SET Price = 700.00
WHERE MonitorID = 1;

-- Зміна статусу замовлення
UPDATE Orders
SET OrderStatus = 'Shipped'
WHERE OrderID = 2;

-- Видалення клієнта
DELETE FROM Customers
WHERE CustomerID = 2;
