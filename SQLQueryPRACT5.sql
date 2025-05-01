-- ����� ��� �������
SELECT * FROM Monitors WHERE Brand = 'Dell';
-- ����� � ������� ����������
SELECT m.Model, m.Price, c.CategoryName
FROM Monitors m
JOIN ProductCategories c ON m.CategoryID = c.CategoryID
WHERE m.Price > 500
ORDER BY m.Brand;
-- ��������������� ������ ��� ������� Monitors
CREATE CLUSTERED INDEX IX_Monitors_MonitorID ON Monitors(MonitorID);
-- ����������������� ������ ��� ���� Brand �� Price
CREATE NONCLUSTERED INDEX IX_Monitors_Brand_Price ON Monitors(Brand, Price);
-- ��������� ������ ��� email �볺���
CREATE UNIQUE INDEX IX_Customers_Email_Unique ON Customers(Email);
-- ������ � ���������� ���������
CREATE NONCLUSTERED INDEX IX_Monitors_Brand_Include
ON Monitors(Brand)
INCLUDE (Model, Price);
-- Գ���������� ������ ��� ��������� � �������� 'Pending'
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
-- ������������ �������
ALTER INDEX IX_Monitors_Brand_Price ON Monitors REORGANIZE;
-- ����� ���������� �������
ALTER INDEX IX_Monitors_Brand_Price ON Monitors REBUILD;
-- ��������� ����������� �������
DROP INDEX IX_Monitors_Brand_Price ON Monitors;
-- �� ��������� �������
SELECT * FROM Monitors WHERE Brand = 'Dell';
-- ϳ��� ��������� �������
CREATE INDEX IX_Monitors_Brand ON Monitors(Brand);
SELECT * FROM Monitors WHERE Brand = 'Dell';