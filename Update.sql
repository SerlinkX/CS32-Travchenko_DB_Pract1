-- ��������� ���� ��� �������
UPDATE Monitors
SET Price = 700.00
WHERE MonitorID = 1;

-- ���� ������� ����������
UPDATE Orders
SET OrderStatus = 'Shipped'
WHERE OrderID = 2;

-- ��������� �볺���
DELETE FROM Customers
WHERE CustomerID = 2;
