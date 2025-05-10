CREATE FUNCTION dbo.fn_CheckMonitorAvailability
(
    @MonitorID INT,
    @RequiredQuantity INT = 1
)
RETURNS BIT
AS
BEGIN
    DECLARE @IsAvailable BIT = 0;
    DECLARE @CurrentStock INT;
    
    -- Отримуємо поточні запаси (якщо таблиця Inventory існує)
    IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Inventory')
    BEGIN
        SELECT @CurrentStock = Quantity 
        FROM Inventory 
        WHERE MonitorID = @MonitorID;
        
        IF @CurrentStock >= @RequiredQuantity
            SET @IsAvailable = 1;
    END
    ELSE
    BEGIN
        -- Якщо таблиці інвентарю немає, вважаємо що товар є в наявності
        SET @IsAvailable = 1;
    END
    
    RETURN @IsAvailable;
END;
CREATE FUNCTION dbo.fn_GetAveragePriceByBrand()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        Brand,
        AVG(Price) AS AveragePrice,
        COUNT(*) AS ModelsCount,
        MIN(Price) AS MinPrice,
        MAX(Price) AS MaxPrice
    FROM Monitors
    GROUP BY Brand
);
