CREATE FUNCTION [schemat236237].[ufnGetCustomerInformation](@CustomerID int)
RETURNS TABLE
AS
-- Returns the CustomerID, first name, and last name for the specified customer.
RETURN (
    SELECT
        CustomerID,
        FirstName,
        LastName
    FROM [schemat236237].[Customer]
    WHERE [CustomerID] = @CustomerID
);
