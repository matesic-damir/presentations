/* Intelligent Query Processing */
/* Damir Matešiæ - https://blog.matesic.info */
/* ######################################### */

/* T-SQL Scalar UDF Inlining */

USE [WideWorldImporters];
GO

-- Drop function if exist
DROP FUNCTION IF EXISTS dbo.Get_Tax_Amount;
GO

-- Create function
CREATE FUNCTION dbo.Get_Tax_Amount(
	@Price money
	,@TaxPercent money
) RETURNS DECIMAL (18, 2) AS
BEGIN
	RETURN @Price * 1 / @TaxPercent;
END;
GO

-- DB compatibility level to SQL 2017
USE [master];
GO
ALTER DATABASE [WideWorldImporters] SET COMPATIBILITY_LEVEL = 140;
GO
USE [WideWorldImporters];
GO

-- Turn on Actual Execution Plan (Ctrl + M)
-- Turn on statistics
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
-- Test query with function
SELECT 
	[OrderID]
	, SUM([UnitPrice] * [Quantity]) AS [Price]
	, SUM(dbo.Get_Tax_Amount([UnitPrice], [TaxRate])) AS Tax_Amount
FROM 
	[Sales].[OrderLines]
GROUP BY [OrderID]
ORDER BY [OrderID];
GO
-- Test query with no function
SELECT 
	[OrderID]
	, SUM([UnitPrice] * [Quantity]) AS [Price]
	, SUM([UnitPrice] * 1 / [TaxRate]) AS Tax_Amount 
FROM 
	[Sales].[OrderLines]
GROUP BY [OrderID]
ORDER BY [OrderID];
GO

-- DB compatibility level to SQL 2019
USE [master];
GO
ALTER DATABASE [WideWorldImporters] SET COMPATIBILITY_LEVEL = 150;
GO
USE [WideWorldImporters];
GO

-- Test query with function
SELECT 
	[OrderID]
	, SUM([UnitPrice] * [Quantity]) AS [Price]
	, SUM(dbo.Get_Tax_Amount([UnitPrice], [TaxRate])) AS Tax_Amount
FROM 
	[Sales].[OrderLines]
GROUP BY [OrderID]
ORDER BY [OrderID];
GO

-- Test query with no function
SELECT 
	[OrderID]
	, SUM([UnitPrice] * [Quantity]) AS [Price]
	, SUM([UnitPrice] * 1 / [TaxRate]) AS Tax_Amount 
FROM 
	[Sales].[OrderLines]
GROUP BY [OrderID]
ORDER BY [OrderID];
GO

-- Cleanup
DROP FUNCTION IF EXISTS dbo.Get_Discounted_Price;
GO

/* Approximate Query Processing */

USE [ContosoRetailDW];
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

SELECT COUNT(DISTINCT([SalesOrderNumber])) AS DistinctValues FROM [dbo].[FactOnlineSales];
GO
SELECT APPROX_COUNT_DISTINCT ([SalesOrderNumber]) AS Aprox_DistinctValues FROM [dbo].[FactOnlineSales];
GO

-- 2

USE master;
ALTER DATABASE WideWorldImportersDW SET COMPATIBILITY_LEVEL = 150;
USE WideWorldImportersDW

SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

SELECT
	APPROX_COUNT_DISTINCT(o.[Order Key]) AS Cnt
FROM Fact.[Order] o;
GO
SELECT
	COUNT(DISTINCT o.[Order Key]) AS Cnt
FROM Fact.[Order] o;

/* Batch and Row Mode Memory Grant Feedback */

USE master;

ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 150;

USE WideWorldImporters;

DBCC FREEPROCCACHE;

SELECT 
   o.PurchaseOrderID,
   o.OrderDate,
   o.Comments,
   o.InternalComments,
   ol.PurchaseOrderLineID,
   ol.LastEditedBy,
   ol.Description
FROM Purchasing.PurchaseOrders O
INNER JOIN Purchasing.PurchaseOrderLines OL ON O.PurchaseOrderID = OL.PurchaseOrderID
ORDER BY O.Comments;
GO

GO 5