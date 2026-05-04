-- =============================================
-- Marcel
-- Turaj
-- 236237
-- =============================================
-- Zadanie 1
-- =============================================
CREATE TABLE SalesLT.ProductPriceHistory (
    HistoryID INT IDENTITY PRIMARY KEY,
    ProductID INT,
    OldPrice MONEY,
    NewPrice MONEY,
    ChangeDate DATETIME DEFAULT GETDATE()
);
GO
CREATE TRIGGER trg_ProductPriceChange
ON SalesLT.Product
AFTER UPDATE
AS
BEGIN
    INSERT INTO SalesLT.ProductPriceHistory (ProductID, OldPrice, NewPrice)
    SELECT 
        d.ProductID,
        d.ListPrice,
        i.ListPrice
    FROM inserted i
    JOIN deleted d ON i.ProductID = d.ProductID
    WHERE i.ListPrice <> d.ListPrice;
END;
-- =============================================
-- Zadanie 2
-- =============================================
CREATE TABLE SalesLT.DeletedCustomersLog (
    CustomerID INT,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    DeletedDate DATETIME DEFAULT GETDATE()
);
GO


CREATE TRIGGER trg_CustomerDelete
ON schemat236237.Customer
INSTEAD OF DELETE
AS
BEGIN
    -- zamowienia
    INSERT INTO SalesLT.DeletedCustomersLog (CustomerID, FirstName, LastName)
    SELECT d.CustomerID, d.FirstName, d.LastName
    FROM deleted d
    WHERE EXISTS (
        SELECT 1 
        FROM SalesLT.SalesOrderHeader soh
        WHERE soh.CustomerID = d.CustomerID
    );
    -- bez zamowien
    DELETE FROM schemat236237.Customer
    WHERE CustomerID IN (
        SELECT d.CustomerID
        FROM deleted d
        WHERE NOT EXISTS (
            SELECT 1 
            FROM SalesLT.SalesOrderHeader soh
            WHERE soh.CustomerID = d.CustomerID
        )
    );
END;
GO

-- =============================================
-- Zadanie 3
-- =============================================
WITH CategoryCTE AS (
    SELECT 
        ProductCategoryID,
        ParentProductCategoryID,
        Name,
        CAST(Name AS NVARCHAR(MAX)) AS Path
    FROM SalesLT.ProductCategory
    WHERE ParentProductCategoryID IS NULL

    UNION ALL

    -- rekurencja
    SELECT 
        c.ProductCategoryID,
        c.ParentProductCategoryID,
        c.Name,
        CAST(cte.Path + N' → ' + c.Name AS NVARCHAR(MAX))
    FROM SalesLT.ProductCategory c
    JOIN CategoryCTE cte 
        ON c.ParentProductCategoryID = cte.ProductCategoryID
)
SELECT *
FROM CategoryCTE;

-- =============================================
-- Zadanie 4
-- =============================================
CREATE TABLE SalesLT.PriceChangeLog (
    LogID INT IDENTITY PRIMARY KEY,
    ProductID INT,
    OldPrice MONEY,
    NewPrice MONEY,
    AttemptDate DATETIME DEFAULT GETDATE()
);
GO

CREATE OR ALTER TRIGGER trg_ProductPriceLimit
ON SalesLT.Product
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- sprawdzamy czy ktoś przekroczył 20%
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN deleted d ON i.ProductID = d.ProductID
        WHERE i.ListPrice > d.ListPrice * 1.2
    )
    BEGIN
        -- logujemy próbę
        INSERT INTO SalesLT.PriceChangeLog (ProductID, OldPrice, NewPrice)
        SELECT 
            d.ProductID,
            d.ListPrice,
            i.ListPrice
        FROM inserted i
        JOIN deleted d ON i.ProductID = d.ProductID
        WHERE i.ListPrice > d.ListPrice * 1.2;

        -- blokujemy operację
        RAISERROR('Price increase exceeds 20%%', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO
-- =============================================
-- Zadanie 5
-- =============================================
CREATE TABLE dbo.DatabaseAuditLog (
    LogID INT IDENTITY PRIMARY KEY,
    EventType NVARCHAR(100),
    ObjectName NVARCHAR(100),
    SQLCommand NVARCHAR(MAX),
    UserName NVARCHAR(100),
    EventDate DATETIME DEFAULT GETDATE()
);
GO
CREATE TRIGGER trg_DatabaseAudit
ON DATABASE
FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE
AS
BEGIN
    INSERT INTO dbo.DatabaseAuditLog (
        EventType,
        ObjectName,
        SQLCommand,
        UserName
    )
    SELECT 
        EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)'),
        EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(100)'),
        EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'NVARCHAR(MAX)'),
        SYSTEM_USER;
END;
GO
-- =============================================
-- Zadanie 6
-- =============================================
-- Problem - rekurencyjne zapytanie CTE zwracające ścieżki poleceń przez klientów w znanej tabeli Customer. Utworzona została do niej tabela
-- Customer refferal 
CREATE TABLE dbo.CustomerReferral (
    CustomerID INT PRIMARY KEY,
    ReferrerID INT NULL
);
GO

ALTER TABLE dbo.CustomerReferral
ADD CONSTRAINT FK_Customer
FOREIGN KEY (CustomerID)
REFERENCES schemat236237.Customer(CustomerID);

ALTER TABLE dbo.CustomerReferral
ADD CONSTRAINT FK_Referrer
FOREIGN KEY (ReferrerID)
REFERENCES schemat236237.Customer(CustomerID);
GO

INSERT INTO dbo.CustomerReferral VALUES
(1, NULL),
(2, 1),
(3, 2),
(4, 2),
(5, 3);
GO

WITH ReferralCTE AS (
 
    SELECT 
        cr.CustomerID,
        cr.ReferrerID,
        CAST(c.FirstName + ' ' + c.LastName AS NVARCHAR(MAX)) AS Path
    FROM dbo.CustomerReferral cr
    JOIN schemat236237.Customer c 
        ON cr.CustomerID = c.CustomerID
    WHERE cr.ReferrerID IS NULL

    UNION ALL

    SELECT 
        cr.CustomerID,
        cr.ReferrerID,
        CAST(cte.Path + ' -> ' + c.FirstName + ' ' + c.LastName AS NVARCHAR(MAX))
    FROM dbo.CustomerReferral cr
    JOIN ReferralCTE cte 
        ON cr.ReferrerID = cte.CustomerID
    JOIN schemat236237.Customer c 
        ON cr.CustomerID = c.CustomerID
)
SELECT *
FROM ReferralCTE;
GO