-- =============================================
-- Marcel
-- Turaj
-- 236237
-- =============================================
-- Zadanie 1
-- =============================================
CREATE OR ALTER PROCEDURE dbo.InsertCustomerData
    @FirstName    Name,
    @LastName     M7_surname,
    @PasswordHash VARCHAR(128),
    @PasswordSalt VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [schemat236237].[Customer](
            [FirstName]
           ,[LastName]
           ,[PasswordHash]
           ,[PasswordSalt]
           ,[rowguid]
           ,[ModifiedDate])

    VALUES (
    @FirstName,
    @LastName,
    @PasswordHash,
    @PasswordSalt,
    NEWID(),
    GETDATE()
    )
END
GO

-- =============================================
-- Zadanie 2
-- =============================================

CREATE OR ALTER PROCEDURE dbo.GetCustomerData
    @CustomerId   INT = NULL,
    @FirstName    Name = NULL,
    @LastName     M7_surname = NULL,
    @EmailAddress Nvarchar(50) = NULL 
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        CustomerId,
        FirstName,
        LastName,
        EmailAddress
    FROM 
        [schemat236237].Customer
    WHERE 
        (@CustomerId IS NULL OR CustomerId = @CustomerId)
        AND (@FirstName IS NULL OR FirstName = @FirstName)
        AND (@LastName IS NULL OR LastName = @LastName)
        AND (@EmailAddress IS NULL OR EmailAddress = @EmailAddress)
END
GO

-- =============================================
-- Zadanie 3
-- =============================================

--  Zadanie niemo¿liwe do wykonania ze wzglêdu na fakt, i¿ nie funkcja nie mo¿e zwróciæ zmiennej tabelarycznej.

-- =============================================
-- Zadanie 4
-- =============================================
-- Za³o¿enie: nazwisko klienta jest unikalne, funkcja sprawdza tylko nazwisko.

CREATE OR ALTER FUNCTION IsLastNameUnique (
@LastName Nvarchar(50)
)
RETURNS BIT
AS
BEGIN 
    DECLARE @Exists BIT = 0 
    IF EXISTS(SELECT LastName FROM [schemat236237].Customer 
    WHERE LastNAME = @LastName)
        BEGIN 
            SET @Exists = 1 
        END
    RETURN @Exists 
END
GO


CREATE OR ALTER PROCEDURE dbo.InsertCustomerData
    @FirstName    NVARCHAR(50),
    @LastName     NVARCHAR(50),
    @PasswordHash VARCHAR(128),
    @PasswordSalt VARCHAR(10)
AS
BEGIN

    IF dbo.IsLastNameUnique(@LastName) = 1 
    BEGIN 
        RAISERROR ('User with such a last name already exists', 16, 1)
    END
    SET NOCOUNT ON;
    INSERT INTO [236495].[Customer](
            [FirstName]
           ,[LastName]
           ,[PasswordHash]
           ,[PasswordSalt]
           ,[rowguid]
           ,[ModifiedDate])

    VALUES (
    @FirstName,
    @LastName,
    @PasswordHash,
    @PasswordSalt,
    NEWID(),
    GETDATE()
    )
END
GO


-- =============================================
-- Zadanie 5
-- =============================================


CREATE OR ALTER PROCEDURE dbo.UpdateCustomer
    @CustomerId   INT,
    @FirstName    NVARCHAR(50),          
    @LastName     NVARCHAR(50)       
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS(SELECT 1 from [schemat236237].Customer
    WHERE CustomerID = @CustomerID)
    BEGIN 
        RAISERROR ('Row does not exists', 16, 1);
    END

    UPDATE [236495].Customer 
    SET 
        FirstName= @FirstName,
        LastName= @LastName,
        ModifiedDate = GETDATE()
    WHERE CustomerID = @CustomerID
END
GO

-- =============================================
-- Zadanie 6
-- =============================================

CREATE TABLE SalesLT.ProductInventory (
ProductID INT, 
Amount INT 
)
GO


CREATE OR ALTER PROCEDURE dbo.AddNewProduct (
    @ProductName     NVARCHAR(100),
    @Category        NVARCHAR(50),
    @ListPrice       MONEY,
    @AmountInStock INT,
    @ProductNumber NVARCHAR(25)
)
AS
BEGIN 

    IF @ListPrice <= 0
    BEGIN
        RAISERROR ('Price has to be greater than zero', 16, 1)
        RETURN
    END
    IF @AmountInStock < 0
    BEGIN
        RAISERROR ('Amount has to be greater than zero', 16, 1)
        RETURN
    END

    BEGIN TRY
        BEGIN TRAN;
        
            DECLARE @CategoryID INT
            SELECT @CategoryID = ProductCategoryID 
            FROM SalesLT.ProductCategory
            WHERE [Name] = @Category

            INSERT INTO SalesLT.Product (
            [Name],
            ProductNumber, 
            StandardCost, 
            ListPrice, 
            ProductCategoryID,
            SellStartDate, 
            rowguid,
            ModifiedDate
            )

            VALUES (
            @ProductName,
            @ProductNumber, 
            @ListPrice,
            @ListPrice, 
            @CategoryID, 
            GETDATE(),
            NEWID(),
            GETDATE()
            )

            DECLARE @ProductID INT
            SET @ProductID = @@IDENTITY

            INSERT INTO SalesLT.ProductInventory (ProductID, Amount)
            VALUES(@ProductID, @AmountInStock)

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

        SELECT ERROR_MESSAGE() AS ErrorMessage;
    END CATCH;
END
GO
-- =============================================
-- Zadanie 7
-- =============================================

-- Zadanie nie jest mo¿liwe do realizacji wpe³ni zgodnie z poleceniem, poniewa¿ zmienna tabelaryczna przekazywana 
-- do procedury jako parametr musi byæ oznaczona jako READONLY, co uniemo¿liwia zmodyfikowanie jej wewn¹trz procedury 