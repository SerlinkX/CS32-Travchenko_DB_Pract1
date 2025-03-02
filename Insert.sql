-- Заповнення таблиці ProductCategories
INSERT INTO ProductCategories (CategoryName) VALUES ('LED');
INSERT INTO ProductCategories (CategoryName) VALUES ('LCD');
INSERT INTO ProductCategories (CategoryName) VALUES ('OLED');

-- Заповнення таблиці Monitors
INSERT INTO Monitors (Model, Brand, Price, Specifications, CategoryID, WarrantyPeriod)
VALUES ('UltraSharp U2723QE', 'Dell', 750.00, '27-inch 4K IPS Monitor', 1, 36);

INSERT INTO Monitors (Model, Brand, Price, Specifications, CategoryID, WarrantyPeriod)
VALUES ('Pro Display XDR', 'Apple', 4999.00, '32-inch 6K Retina Monitor', 3, 24);

-- Заповнення таблиці Customers
INSERT INTO Customers (FirstName, LastName, Email, Phone)
VALUES ('John', 'Doe', 'john.doe@example.com', '123456789');

INSERT INTO Customers (FirstName, LastName, Email, Phone)
VALUES ('Jane', 'Smith', 'jane.smith@example.com', '987654321');

-- Заповнення таблиці Orders
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount, OrderStatus)
VALUES (1, '2024-11-21', 750.00, 'Completed');

INSERT INTO Orders (CustomerID, OrderDate, TotalAmount, OrderStatus)
VALUES (2, '2024-11-22', 4999.00, 'Pending');

-- Заповнення таблиці Suppliers
INSERT INTO Suppliers (SupplierName, ContactInfo)
VALUES ('TechDistributors', 'tech@distributors.com');

INSERT INTO Suppliers (SupplierName, ContactInfo)
VALUES ('GlobalMonitors', 'info@globalmonitors.com');
