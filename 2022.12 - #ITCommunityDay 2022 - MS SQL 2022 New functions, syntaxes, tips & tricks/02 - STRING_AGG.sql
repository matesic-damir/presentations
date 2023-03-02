/* Damir Matešić - https://blog.matesic.info */
/* ######################################### */

/* MS SQL STRING_AGG */

-- Aggregate values
SELECT STRING_AGG(value, ' ') AS Result FROM (VALUES('Gin'),('and'),('tonic')) AS I(value);

-- Real database data - error
USE [WideWorldImporters];
-- Aggregate customer names - error
SELECT STRING_AGG(C.[CustomerName], ',') AS Result FROM [Sales].[Customers] AS C;

-- Aggregate customer names
SELECT STRING_AGG(CAST(C.[CustomerName] AS nvarchar(max)), ',') AS Result FROM [Sales].[Customers] AS C;

-- Aggregate NULL values
SELECT STRING_AGG(value, ' ') AS Result FROM (VALUES('Gin'),(NULL),('tonic')) AS I(value);

-- delimited invoiceID for every customerID in the table
SELECT
    [CustomerID]
    , STRING_AGG([InvoiceID], ',')  AS InvoicesList
FROM
    [Sales].[Invoices] I
GROUP BY
    [CustomerID]
ORDER BY
    [CustomerID] ASC;

-- delimited and sorted invoiceID for every customerID in the table with order by
SELECT
    [CustomerID]
    , STRING_AGG([InvoiceID], ',') WITHIN GROUP(ORDER BY [InvoiceID] DESC) AS InvoicesList
FROM
    [Sales].[Invoices] I
GROUP BY
    [CustomerID]
ORDER BY
    [CustomerID] ASC;

-- Performances
USE [WideWorldImporters];
SET NOCOUNT ON;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
-- Turn on statistics
-- Discard results after execution
-- Enable Execution plan
 
-- 1. The old way using XML and STUFF
SELECT
C.[CustomerID]
, STUFF((
        SELECT
            ',' + CAST(I.[InvoiceID] AS NVARCHAR(MAX)) 
        FROM 
            [Sales].[Invoices] I
        WHERE
            I.[CustomerID] = C.[CustomerID]
        ORDER BY
            I.[InvoiceID] ASC
        FOR XML PATH(''), TYPE).value('.', 'varchar(max)'),1,1,'') AS InvoicesList
FROM
    [Sales].[Customers] AS C
ORDER BY
    C.[CustomerID] ASC;
 
---- 2. The new way using STRING_AGG for aggregation 
 SELECT
	[CustomerID],
	STRING_AGG([InvoiceID], ',') WITHIN GROUP(ORDER BY [InvoiceID] ASC) AS InvoicesList
FROM
	[Sales].[Invoices] I
GROUP BY 
	I.CustomerID
ORDER BY
    I.[CustomerID] ASC;
