CREATE PROCEDURE usp_GenerateRandomMonitors
    @Count INT = 100,
    @MinPrice DECIMAL(10,2) = 100.00,
    @MaxPrice DECIMAL(10,2) = 5000.00,
    @MinWarranty INT = 12,
    @MaxWarranty INT = 36
AS
BEGIN
    DECLARE @i INT = 1;
    DECLARE @Brands TABLE (ID INT IDENTITY, BrandName NVARCHAR(50));
    DECLARE @Categories TABLE (ID INT IDENTITY, CategoryID INT));
    
    -- Популярні бренди моніторів
    INSERT INTO @Brands (BrandName) VALUES 
    ('Dell'), ('Samsung'), ('LG'), ('Asus'), ('Acer'),
    ('BenQ'), ('HP'), ('Lenovo'), ('MSI'), ('Philips');
    
    -- Отримуємо всі наявні категорії
    INSERT INTO @Categories (CategoryID)
    SELECT CategoryID FROM ProductCategories;
    
    -- Генерація моніторів
    WHILE @i <= @Count
    BEGIN
        DECLARE @Brand NVARCHAR(50) = (SELECT BrandName FROM @Brands WHERE ID = 1 + ABS(CHECKSUM(NEWID())) % 10);
        DECLARE @Model NVARCHAR(100) = @Brand + ' ' + 
            CAST(ROUND(100 + (RAND() * 900), 0) AS NVARCHAR) + 
            CASE WHEN RAND() > 0.5 THEN 'UHD' ELSE 'FHD' END;
        DECLARE @Price DECIMAL(10,2) = ROUND(@MinPrice + (RAND() * (@MaxPrice - @MinPrice)), 2);
        DECLARE @CategoryID INT = (SELECT CategoryID FROM @Categories WHERE ID = 1 + ABS(CHECKSUM(NEWID())) % (SELECT COUNT(*) FROM @Categories));
        DECLARE @Warranty INT = @MinWarranty + (ABS(CHECKSUM(NEWID())) % (@MaxWarranty - @MinWarranty + 1));
        DECLARE @Specs NVARCHAR(500) = CASE 
            WHEN @Price > 3000 THEN '4K UHD, HDR1000, 144Hz, G-Sync'
            WHEN @Price > 1500 THEN 'QHD, HDR400, 120Hz, FreeSync'
            ELSE 'FHD, 75Hz, AMD FreeSync'
        END;
        
        INSERT INTO Monitors (Model, Brand, Price, Specifications, CategoryID, WarrantyPeriod)
        VALUES (@Model, @Brand, @Price, @Specs, @CategoryID, @Warranty);
        
        SET @i = @i + 1;
    END
    
    PRINT 'Згенеровано ' + CAST(@Count AS NVARCHAR) + ' моніторів';
END;
CREATE PROCEDURE usp_GenerateRandomCustomers
    @Count INT = 50
AS
BEGIN
    DECLARE @i INT = 1;
    DECLARE @FirstNames TABLE (ID INT IDENTITY, Name NVARCHAR(50));
    DECLARE @LastNames TABLE (ID INT IDENTITY, Name NVARCHAR(50));
    
    -- Чоловічі та жіночі імена
    INSERT INTO @FirstNames (Name) VALUES 
    ('John'), ('Mary'), ('Robert'), ('Jennifer'), ('Michael'),
    ('Linda'), ('William'), ('Elizabeth'), ('David'), ('Patricia'),
    ('Richard'), ('Susan'), ('Joseph'), ('Jessica'), ('Thomas'),
    ('Sarah'), ('Daniel'), ('Karen'), ('Matthew'), ('Nancy');
    
    -- Прізвища
    INSERT INTO @LastNames (Name) VALUES 
    ('Smith'), ('Johnson'), ('Williams'), ('Brown'), ('Jones'),
    ('Miller'), ('Davis'), ('Garcia'), ('Rodriguez'), ('Wilson'),
    ('Martinez'), ('Anderson'), ('Taylor'), ('Thomas'), ('Hernandez'),
    ('Moore'), ('Martin'), ('Jackson'), ('Thompson'), ('White');
    
    -- Генерація клієнтів
    WHILE @i <= @Count
    BEGIN
        DECLARE @FirstName NVARCHAR(50) = (SELECT Name FROM @FirstNames WHERE ID = 1 + ABS(CHECKSUM(NEWID())) % 20);
        DECLARE @LastName NVARCHAR(50) = (SELECT Name FROM @LastNames WHERE ID = 1 + ABS(CHECKSUM(NEWID())) % 20);
        DECLARE @Email NVARCHAR(100) = LOWER(@FirstName + '.' + @LastName + CAST(ABS(CHECKSUM(NEWID())) % 100 AS NVARCHAR) + '@example.com');
        DECLARE @Phone NVARCHAR(15) = '+380' + RIGHT('00000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS NVARCHAR), 9);
        
        INSERT INTO Customers (FirstName, LastName, Email, Phone)
        VALUES (@FirstName, @LastName, @Email, @Phone);
        
        SET @i = @i + 1;
    END
    
    PRINT 'Згенеровано ' + CAST(@Count AS NVARCHAR) + ' клієнтів';
END;