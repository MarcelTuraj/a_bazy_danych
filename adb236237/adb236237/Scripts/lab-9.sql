-- =============================================
-- Marcel
-- Turaj
-- 236237
-- =============================================
-- Zadanie 1
-- =============================================
CREATE FUNCTION Student_7.ufn_GetBestProductID
(
    @MinPrice MONEY = 100,
    @NameFilter NVARCHAR(50) = '',
    @Descending BIT = 1
)
RETURNS INT
AS
BEGIN
    DECLARE @Result INT;

    SELECT TOP 1 @Result = ProductID
    FROM v236237_order
    WHERE ListPrice >= @MinPrice
      AND Name LIKE '%' + @NameFilter + '%'
    ORDER BY
        CASE WHEN @Descending = 1 THEN ListPrice END DESC,
        CASE WHEN @Descending = 0 THEN ListPrice END ASC;

    RETURN @Result;
END;
GO
-- =============================================
-- Zadanie 2
-- =============================================
CREATE TABLE dbo.TopProducts (
    ProductID INT,
    Name NVARCHAR(100),
    ListPrice MONEY
);
GO

INSERT INTO dbo.TopProducts
SELECT TOP 25
    ProductID,
    Name,
    ListPrice
FROM SalesLT.Product
ORDER BY ListPrice DESC;
GO


CREATE FUNCTION Student_7.ufn_CalcAdjustedPrices()
RETURNS TABLE
AS
RETURN
(
    SELECT
        ProductID,
        Name,
        ListPrice AS OriginalPrice,
        ListPrice - (ListPrice * 0.07) AS AdjustedPrice
    FROM dbo.TopProducts
);
GO
-- =============================================
-- Zadanie 3
-- =============================================
CREATE FUNCTION Student_7.ufn_ProductsJsonByCategory
(
    @CategoryName NVARCHAR(50)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @Result NVARCHAR(MAX);

    SELECT @Result =
    (
        SELECT
            p.ProductID,
            p.Name,
            p.ListPrice
        FROM SalesLT.Product p
        JOIN SalesLT.ProductCategory pc
            ON p.ProductCategoryID = pc.ProductCategoryID
        WHERE pc.Name = @CategoryName
        FOR JSON PATH
    );

    RETURN @Result;
END;
GO
-- =============================================
-- Zadanie 4
-- =============================================
CREATE FUNCTION Student_7.ufn_IsPriceHigherThanCurrent
(
    @ProductJson NVARCHAR(MAX)
)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT = 0;

    IF EXISTS (
        SELECT 1
        FROM OPENJSON(@ProductJson)
        WITH (
            ProductID INT,
            NewPrice MONEY
        ) j
        JOIN SalesLT.Product p
            ON j.ProductID = p.ProductID
        WHERE j.NewPrice > p.ListPrice
    )
    SET @Result = 1;

    RETURN @Result;
END;
GO
-- jeœli cena bêdzie równa, to funkcja zwróci false 
-- =============================================
-- Zadanie 5
-- =============================================
CREATE FUNCTION Student_7.ufn_CheckJson
(
    @ProductJson NVARCHAR(MAX)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        Student_7.ufn_IsPriceHigherThanCurrent(@ProductJson) AS IsHigher
);
GO
-- =============================================
-- Zadanie 6
-- =============================================
-- iTVF
-- Problem - funkcja tabelaryczna zwracaj¹ca tabelê relatywnie drogich produktów w oparciu o dan¹ cenê minimaln¹ (parametr funkcji)

CREATE FUNCTION dbo.ufn_ExpensiveProducts(@MinPrice MONEY)
RETURNS TABLE
AS
RETURN
(
    SELECT
        ProductID,
        Name,
        ListPrice
    FROM SalesLT.Product
    WHERE ListPrice > @MinPrice
);
GO

-- mTVF
-- Problem - wynik zwracany przez funkcjê to tabela produktów z cen¹ potraktowan¹ rabatem 

CREATE FUNCTION dbo.ufn_DiscountProducts()
RETURNS @Result TABLE
(
    ProductID INT,
    Name NVARCHAR(100),
    DiscountPrice MONEY
)
AS
BEGIN
    INSERT INTO @Result
    SELECT
        ProductID,
        Name,
        ListPrice * 0.9
    FROM SalesLT.Product;

    RETURN;
END;
GO

-- Widok
-- Problem - szybki dostêp do klientów z customer

CREATE VIEW dbo.ActiveCustomers
AS
SELECT
    CustomerID,
    FirstName,
    LastName
FROM schemat236237.Customer;
GO

-- Funkcja skalarna
-- obliczanie VAT na zadeklarowanej cenie

CREATE FUNCTION dbo.ufn_AddVAT(@Price MONEY)
RETURNS MONEY
AS
BEGIN
    RETURN @Price * 1.23;
END;
GO
-- =============================================
-- Zadanie 7
-- =============================================

CREATE FUNCTION dbo.fn_GetCustomerCreditRisk
(
    @CustomerID INT
)
RETURNS NVARCHAR(20)
AS
BEGIN
    DECLARE @Orders TABLE
    (
        TotalDue MONEY,
        DueDate DATETIME,
        ShipDate DATETIME
    );

    INSERT INTO @Orders
    SELECT
        TotalDue,
        DueDate,
        ShipDate
    FROM SalesLT.SalesOrderHeader
    WHERE CustomerID = @CustomerID;

    DECLARE @Total MONEY;
    DECLARE @LateOrders INT;

    SELECT @Total = SUM(TotalDue)
    FROM @Orders;

    SELECT @LateOrders = COUNT(*)
    FROM @Orders
    WHERE DATEDIFF(DAY, DueDate, ShipDate) > 3;

    IF @Total > 100000 AND @LateOrders >= 2
        RETURN 'HIGH';

    IF @Total > 50000
        RETURN 'MEDIUM';

    RETURN 'LOW';
END;
GO

-- =============================================
-- Zadanie 8
-- =============================================
CREATE FUNCTION dbo.fn_GetCustomerFullInfo
(
    @CustomerID INT
)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @Result NVARCHAR(200);

    SELECT @Result =
        FirstName + ' ' + LastName +
        ' (Company: ' + CompanyName + ')'
    FROM schemat236237.Customer
    WHERE CustomerID = @CustomerID;

    RETURN @Result;
END;
GO


CREATE VIEW dbo.CustomerFullInfoView
AS
SELECT
    CustomerID,
    dbo.fn_GetCustomerFullInfo(CustomerID) AS CustomerInfo
FROM schemat236237.Customer;
GO

-- =============================================
-- Zadanie 9
-- =============================================
CREATE VIEW dbo.RecentCustomers
AS
SELECT DISTINCT
    c.CustomerID,
    c.FirstName,
    c.LastName
FROM schemat236237.Customer c
JOIN SalesLT.SalesOrderHeader soh
    ON c.CustomerID = soh.CustomerID
WHERE soh.OrderDate >= DATEADD(DAY, -365, GETDATE());
GO


DECLARE @MinOrders INT = 3;

SELECT
    rc.CustomerID,
    rc.FirstName,
    rc.LastName,
    COUNT(*) AS OrdersCount
FROM dbo.RecentCustomers rc
JOIN SalesLT.SalesOrderHeader soh
    ON rc.CustomerID = soh.CustomerID
GROUP BY
    rc.CustomerID,
    rc.FirstName,
    rc.LastName
HAVING COUNT(*) > @MinOrders;
GO




