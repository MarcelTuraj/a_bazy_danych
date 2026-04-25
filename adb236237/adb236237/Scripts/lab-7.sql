-- =============================================
-- Marcel
-- Turaj
-- 236237
-- =============================================
-- Zadanie 1
-- =============================================
CREATE TYPE M7_surname FROM NVARCHAR(50) NOT NULL;
GO 
ALTER TABLE schemat236237.Customer
ALTER COLUMN LastName M7_surname;
GO
-- =============================================
-- Zadanie 2
-- =============================================
CREATE VIEW dbo.ProductBaseView
AS
SELECT 
    ProductID,
    Name,
    ListPrice
FROM SalesLT.Product;
GO


DECLARE @ProductInfo NVARCHAR(MAX);
SET @ProductInfo = N'
[
    {"ProductID": 680, "NewPrice": 1500},
    {"ProductID": 706, "NewPrice": 900},
    {"ProductID": 707, "NewPrice": 950},
    {"ProductID": 708, "NewPrice": 1100},
    {"ProductID": 709, "NewPrice": 1200}
]';

SELECT 
    v.ProductID,
    v.Name,
    v.ListPrice AS CurrentPrice,
    j.NewPrice,
    (j.NewPrice - v.ListPrice) AS PriceDifference
FROM dbo.ProductBaseView v
JOIN OPENJSON(@ProductInfo)
WITH (
    ProductID INT,
    NewPrice MONEY
) j
ON v.ProductID = j.ProductID;
GO
-- Bez możliwości posłużenia się zmienną w widoku i deklarowaniem jej wewnątrz widoku tworzony jest widok podstawowy widok z tabeli 
-- produkt, a następnie zapytanie łączące widok ze zdeklarowaną zmienną JSON
-- =============================================
-- Zadanie 3
-- =============================================
CREATE VIEW v236237_order
AS
SELECT TOP 100 PERCENT
    ProductID,
    Name,
    ListPrice
FROM SalesLT.Product
ORDER BY ListPrice DESC;
GO
-- =============================================
-- Zadanie 4
-- =============================================
-- Firma chce zidentyfikować procentowe marże na produktach z listy - liczymy procent jaki stanowi zysk w stosunku do kosztu 
-- wykonania produktu. 
-- =============================================
CREATE VIEW Student_7.MarginComparison
AS
SELECT 
    ProductID,
    Name,
    ListPrice,
    StandardCost,
    
    CASE 
        WHEN StandardCost = 0 THEN NULL
        ELSE ((ListPrice - StandardCost) / StandardCost) * 100
    END AS MarginPercent,

    CASE 
        WHEN StandardCost = 0 THEN 'No Data'
        WHEN ((ListPrice - StandardCost) / StandardCost) * 100 > 100 THEN 'High Margin'
        WHEN ((ListPrice - StandardCost) / StandardCost) * 100 BETWEEN 40 AND 100 THEN 'Medium Margin'
        ELSE 'Low Margin'
    END AS MarginCategory

FROM SalesLT.Product;
GO

-- =============================================
-- Zadanie 5
-- =============================================
CREATE VIEW Student_7.vHighMarginProds
AS
SELECT * FROM Student_7.MarginComparison
WHERE MarginCategory = 'High Margin'
