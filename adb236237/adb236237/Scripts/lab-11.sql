-- =============================================
-- Marcel
-- Turaj
-- 236237
-- =============================================
-- Zadanie 1
-- =============================================
SELECT DISTINCT
    pc.Name AS CategoryName,
    MIN(p.ListPrice) OVER(PARTITION BY p.ProductCategoryID) AS MinPrice,
    MAX(p.ListPrice) OVER(PARTITION BY p.ProductCategoryID) AS MaxPrice,
    COUNT(*) OVER(PARTITION BY p.ProductCategoryID) AS ProductCount
FROM SalesLT.Product p
JOIN SalesLT.ProductCategory pc
    ON p.ProductCategoryID = pc.ProductCategoryID;
GO
-- =============================================
-- Zadanie 2
-- =============================================

-- Porównywanie œredniego wynagrodzenia pracownika ze œrednim wynagrodzeniem w jego dziale, tworzymy tabelê salary oraz wprowadzamy 
-- niej dane (imiê, dzia³, wyp³ata), nastêpnie funkcja okienkowa liczy œredni¹.
CREATE TABLE dbo.EmployeeSalary
(
    EmployeeID INT,
    EmployeeName NVARCHAR(50),
    Department NVARCHAR(50),
    Salary MONEY
);

INSERT INTO dbo.EmployeeSalary VALUES
(1,'Jan','IT',7000),
(2,'Anna','IT',8000),
(3,'Piotr','IT',9000),
(4,'Adam','HR',5000),
(5,'Maria','HR',6000);
GO

SELECT
    EmployeeName,
    Department,
    Salary,
    AVG(Salary) OVER(PARTITION BY Department) AS AvgDepartmentSalary,
    Salary - AVG(Salary) OVER(PARTITION BY Department) AS Difference
FROM dbo.EmployeeSalary;
GO

-- =============================================
-- Zadanie 3
-- =============================================

-- tworzymy raport miesiêcznej sprzeda¿y prodkuktów w formie pivot, potem przywracamy dane z powrotem do wierszy za pomoc¹ unpivot

CREATE TABLE dbo.MonthlySales
(
    ProductName NVARCHAR(50),
    MonthName NVARCHAR(20),
    Amount MONEY
);
GO

INSERT INTO dbo.MonthlySales VALUES
('Bike','Jan',1000),
('Bike','Feb',1500),
('Bike','Mar',1200),
('Helmet','Jan',300),
('Helmet','Feb',500),
('Helmet','Mar',450);
GO

SELECT *
FROM
(
    SELECT ProductName, MonthName, Amount
    FROM dbo.MonthlySales
) src
PIVOT
(
    SUM(Amount)
    FOR MonthName IN ([Jan],[Feb],[Mar])
) p;
GO
-- wersja unpivot 
SELECT
    ProductName,
    MonthName,
    Amount
FROM
(
    SELECT *
    FROM
    (
        SELECT ProductName, MonthName, Amount
        FROM dbo.MonthlySales
    ) src
    PIVOT
    (
        SUM(Amount)
        FOR MonthName IN ([Jan],[Feb],[Mar])
    ) p
) pv
UNPIVOT
(
    Amount FOR MonthName IN ([Jan],[Feb],[Mar])
) unp;

-- =============================================
-- Zadanie 4
-- =============================================
-- u¿ycie funkcji rollup() dla raportu sprzeda¿y odnoœnie produktu, kategorii i ca³ej firmy w jednym zapytaniu
CREATE TABLE dbo.SalesSummary
(
    CategoryName NVARCHAR(50),
    ProductName NVARCHAR(50),
    Amount MONEY
);
GO

INSERT INTO dbo.SalesSummary VALUES
('Bikes','Road Bike',10000),
('Bikes','Mountain Bike',8000),
('Accessories','Helmet',1000),
('Accessories','Gloves',500);
GO


SELECT
    CategoryName,
    ProductName,
    SUM(Amount) AS TotalAmount
FROM dbo.SalesSummary
GROUP BY ROLLUP(CategoryName, ProductName);
GO