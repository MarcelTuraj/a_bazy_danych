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



GRANT CONTROL
ON SCHEMA::SalesLT
TO [236237];
GO


-- =============================================
-- Zadanie 3
-- =============================================

REVOKE CONTROL
ON SCHEMA::SalesLT
FROM [236237];
GO

GRANT SELECT
ON SalesLT.Product
TO [236237];
GO

GRANT SELECT
ON schemat236237.Customer
TO [236237];
GO

GRANT UPDATE
ON schemat236237.Customer
TO [236237];
GO

SELECT
    p.name,
    dp.permission_name,
    dp.state_desc
FROM sys.database_permissions dp
JOIN sys.database_principals p
    ON dp.grantee_principal_id = p.principal_id
WHERE p.name = '236237';
GO