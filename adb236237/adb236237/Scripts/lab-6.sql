-- =============================================
-- Marcel
-- Turaj
-- 236237
-- =============================================
-- Zadanie 1
-- =============================================
BEGIN TRANSACTION;

UPDATE schemat236237.Customer
SET FirstName = FirstName
WHERE CustomerID = 1;

WAITFOR DELAY '00:02:00';

ROLLBACK;
GO
-- Begin rozpoczyna transakcję, update wraz z set i where (w tym wypadku klauzule nie zmieniają nic) zakładają blokadę, waitfor delay dla opóźnienia. Rollback wycofuje blok 
-- instrukcji wewnątrz transakcji i kończy ją. Blokady są niebezpieczne, bo szczególnie przy tabelach używanych często i przy dużym ruchu na bazie danych wszystkie zapytania odnośnie tej 
-- tabeli będą czekać, mogą pojawić się timeouty, użytkownicy będą blokowani. 

-- =============================================
-- Zadanie 2
-- =============================================

BEGIN TRAN;

UPDATE TOP (10) schemat236237.Customer
SET FirstName = 'MTest';

UPDATE TOP (10) SalesLT.Product
SET Name = Name + '_M';

UPDATE TOP (10) SalesLT.ProductCategory
SET Name = Name + '_M';

INSERT INTO SalesLT.ProductCategory (Name, rowguid, ModifiedDate)
SELECT TOP (10)
Name + '_NEW', NEWID(), GETDATE()
FROM SalesLT.ProductCategory;


DELETE TOP (10) FROM schemat236237.Customer;


SELECT COUNT(*) FROM schemat236237.Customer;
SELECT COUNT(*) FROM SalesLT.Product;
SELECT COUNT(*) FROM SalesLT.ProductCategory;

SELECT TOP (10) * FROM schemat236237.Customer;
SELECT TOP (10) * FROM SalesLT.Product;
SELECT TOP (10) * FROM SalesLT.ProductCategory;

-- TRUNCATE TABLE SalesLT.ProductDescription;


ROLLBACK;


SELECT COUNT(*) FROM schemat236237.Customer;
SELECT COUNT(*) FROM SalesLT.Product;
SELECT COUNT(*) FROM SalesLT.ProductCategory;

SELECT TOP (10) * FROM schemat236237.Customer;
SELECT TOP (10) * FROM SalesLT.Product;
SELECT TOP (10) * FROM SalesLT.ProductCategory;
GO

-- Zmiany dokonane wewnątrz transakcji były widoczne jako wynik zapytań przed rollbackiem, natomiast po nim zostały wycofane 
-- i widzimy stan sprzed nich. Widzimy inne liczby przy count tam, gdzie dodawaliśmy/usuwaliśmy rekordy. Widzimy też różnice w updateowanych rekordach. Wszystko zgodnie z ACID szczególnie z regułą atomowości. W tym wypadku truncate został wzięty w komentarz - normalnie rollback wycofałby polecenie truncate, tutaj
-- to polecenie nie mogło zostać zrealizowane, ponieważ wybrana tabela jest powiązana kluczem obcym i zgodnie ze specyfikacją bazy nie można
-- na niej go zastosować. Dobór innej tabeli, gdzie dałoby się to zrobić był problematyczny. W przypadku Customer np. na drodze stanęło system-versioning, którego trzeba
-- by się było pozbyć. 


-- =============================================
-- Zadanie 3
-- =============================================
BEGIN TRAN;

UPDATE schemat236237.Customer
SET FirstName = 'MTest';

UPDATE SalesLT.Product
SET Name = Name + '_M';

UPDATE SalesLT.ProductCategory
SET Name = Name + '_M';

INSERT INTO SalesLT.ProductCategory (Name, rowguid, ModifiedDate)
SELECT TOP (10)
Name + '_NEW', NEWID(), GETDATE()
FROM SalesLT.ProductCategory;


DELETE TOP (10) FROM schemat236237.Customer;



-- TRUNCATE TABLE SalesLT.ProductDescription;
WAITFOR DELAY '00:05:00'

ROLLBACK;
GO
-- zapytanie zwracające dane mimo blokady
SELECT * FROM schemat236237.Customer WITH (NOLOCK);


-- =============================================
-- Zadanie 4
-- =============================================

BEGIN TRY
    INSERT INTO schemat236237.Customer(FirstName, LastName)
    VALUES (NULL, 'Test'); 
END TRY
BEGIN CATCH
    SELECT
      ERROR_NUMBER(),
      ERROR_MESSAGE()
END CATCH 
GO

-- =============================================
-- Zadanie 5
-- =============================================
-- Proces biznesowy: dokonywana jest próba usunięcia z bazy danych o określonym produkcie przechowywanym w tabeli Product przy zadeklarowanym jako zmienna,
-- identyifkatorze. W scenariuszu zakładamy, że jest to produkt wpisany na listę, który z jakichś powodów nie został dalej wprowadzony
-- do sprzedaży/został od razu wycofany/nikt go nie kupił itd. Kod sprawdza (if statement) czy produkt o szukanym ID w ogóle istnieje. Jeśli natomiast 
-- jest on powiązany kluczem obcym - pojawia się choćby w SalesOrderDetail czyli był zamawiany i zostało to zarejestrowane w bazie, uwydatni się 
-- błąd w zw. z fk constraint jako wynik próby usunięcia rekordu.


DECLARE @ProductID INT = 1;

BEGIN TRY

    IF NOT EXISTS (
        SELECT 1 FROM SalesLT.Product WHERE ProductID = @ProductID
    )
    BEGIN
        RAISERROR('Produkt nie istnieje',16,1);
    END

    DELETE FROM SalesLT.Product
    WHERE ProductID = @ProductID;

END TRY
BEGIN CATCH

    SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;

END CATCH;
GO
-- =============================================
-- Zadanie 6
-- =============================================
DECLARE @ProductID INT = 1;

BEGIN TRAN;

BEGIN TRY

    IF NOT EXISTS (
        SELECT 1 FROM SalesLT.Product WHERE ProductID = @ProductID
    )
    BEGIN
        RAISERROR('Produkt nie istnieje',16,1);
    END

    DELETE FROM SalesLT.Product
    WHERE ProductID = @ProductID;

    COMMIT;

END TRY
BEGIN CATCH

    ROLLBACK;

    SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;

END CATCH;
GO