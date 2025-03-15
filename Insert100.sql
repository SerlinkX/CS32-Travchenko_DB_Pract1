-- Заповнення таблиці ProductCategories
DECLARE @i INT = 1;
WHILE @i <= 100
BEGIN
    INSERT INTO ProductCategories (CategoryName) VALUES ('Category ' + CAST(@i AS NVARCHAR));
    SET @i = @i + 1;
END;

-- Заповнення таблиці Monitors
DECLARE @j INT = 1;
WHILE @j <= 100
BEGIN
    INSERT INTO Monitors (Model, Brand, Price, Specifications, CategoryID, WarrantyPeriod)
    VALUES ('Model ' + CAST(@j AS NVARCHAR), 'Brand ' + CAST(@j AS NVARCHAR), 100.00 + @j, 'Specifications for Model ' + CAST(@j AS NVARCHAR), @j, 12 + (@j % 24));
    SET @j = @j + 1;
END;

-- Заповнення таблиці Customers
DECLARE @k INT = 1;
WHILE @k <= 100
BEGIN
    INSERT INTO Customers (FirstName, LastName, Email, Phone)
    VALUES ('FirstName' + CAST(@k AS NVARCHAR), 'LastName' + CAST(@k AS NVARCHAR), 'user' + CAST(@k AS NVARCHAR) + '@example.com', '123456789' + CAST(@k AS NVARCHAR));
    SET @k = @k + 1;
END;

-- Заповнення таблиці Orders
DECLARE @l INT = 1;
WHILE @l <= 100
BEGIN
    INSERT INTO Orders (CustomerID, OrderDate, TotalAmount, OrderStatus)
    VALUES (@l, DATEADD(DAY, @l, '2024-01-01'), 100.00 + @l, CASE WHEN @l % 2 = 0 THEN 'Completed' ELSE 'Pending' END);
    SET @l = @l + 1;
END;

-- Заповнення таблиці Suppliers
DECLARE @m INT = 1;
WHILE @m <= 100
BEGIN
    INSERT INTO Suppliers (SupplierName, ContactInfo)
    VALUES ('Supplier ' + CAST(@m AS NVARCHAR), 'contact' + CAST(@m AS NVARCHAR) + '@supplier.com');
    SET @m = @m + 1;
END;