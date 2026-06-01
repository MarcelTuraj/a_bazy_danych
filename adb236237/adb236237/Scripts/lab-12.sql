-- =============================================
-- Marcel
-- Turaj
-- 236237
-- =============================================
-- Zadanie 1
-- =============================================

USE MASTER
GO


CREATE LOGIN [236237]
WITH PASSWORD = 'Haslo123!';
GO

CREATE USER [236237]
FOR LOGIN [236237];
GO

SELECT
    name,
    type_desc
FROM sys.database_principals
WHERE name = '236237';
GO

SELECT name, type_desc
FROM sys.sql_logins
WHERE name = '236237';
GO
-- =============================================
-- Zadanie 2
-- =============================================

CREATE SCHEMA SalesLT1;
GO

GRANT CONTROL
ON SCHEMA::SalesLT1
TO [236237];
GO


FROM sys.database_permissions
WHERE grantee_principal_id =
(
    SELECT principal_id
    FROM sys.database_principals
    WHERE name = '236237'
);
-- Zadanie 3

-- Treœæ:

-- odbierz pe³n¹ kontrolê nad SalesLT

-- Odebranie kontroli
REVOKE CONTROL
ON SCHEMA::SalesLT
FROM [236237];
GO
-- Tabela Product tylko odczyt
GRANT SELECT
ON SalesLT.Product
TO [236237];
GO

-- Dodatkowo warto odebraæ inne prawa:

DENY INSERT
ON SalesLT.Product
TO [236237];

DENY UPDATE
ON SalesLT.Product
TO [236237];

DENY DELETE
ON SalesLT.Product
TO [236237];
GO

