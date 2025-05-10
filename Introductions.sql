CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY,
    ProductName NVARCHAR(150) NOT NULL,
    Brand NVARCHAR(50),
    ScreenSize DECIMAL(4,1), -- Наприклад, 24.5"
    Resolution NVARCHAR(50),
    MatrixType NVARCHAR(50),
    RefreshRate INT, -- Гц
    PurchasePrice MONEY,
    RetailPrice MONEY,
    QuantityInStock INT,
    SupplierID INT FOREIGN KEY REFERENCES Suppliers(SupplierID)
);
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    OrderDate DATETIME DEFAULT GETDATE(),
    OrderStatus NVARCHAR(50), -- Нове, Обробляється, Відправлено, Виконано, Скасовано
    TotalAmount MONEY
);
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY IDENTITY,
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    PaymentDate DATETIME DEFAULT GETDATE(),
    PaymentMethod NVARCHAR(50), -- Картка, Готівка, Накладений платіж
    PaymentStatus NVARCHAR(50) -- Очікується, Оплачено, Відмова
);