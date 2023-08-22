/* Damir Matešiæ - https://blog.matesic.info */
/* ######################################### */

/* IS NOT DISTINCT - The Distinct Predicate */

USE [WideWorldImporters];
GO
DROP INDEX IF EXISTS Sales.Orders.pickingdateidx;
GO
CREATE INDEX pickingdateidx ON Sales.Orders (PickingCompletedWhen);
GO
SET NOCOUNT ON;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- Non picked up orders
DECLARE @dt datetime2 = NULL
SELECT * FROM Sales.Orders WHERE
PickingCompletedWhen = @dt;
GO

-- ISNULL - Index scan
DECLARE @dt AS DATE = NULL;
SELECT * FROM Sales.Orders 
WHERE ISNULL(PickingCompletedWhen, '99991231') = ISNULL(@dt, '99991231');
GO

-- Combination - Index Scan
DECLARE @dt AS DATE = NULL;
SELECT * FROM Sales.Orders 
WHERE PickingCompletedWhen = @dt OR (PickingCompletedWhen IS NULL AND @dt IS NULL);
GO

-- New operator - Index seek!
DECLARE @dt datetime2 = NULL;
SELECT *
FROM Sales.Orders
WHERE PickingCompletedWhen IS NOT DISTINCT FROM @dt;
GO

-- All picked up
SELECT *
FROM Sales.Orders
WHERE PickingCompletedWhen IS DISTINCT FROM NULL;
GO

-- IS DISTINCT FROM 
SELECT OrderID, PickingCompletedWhen FROM Sales.Orders
WHERE PickingCompletedWhen <> '2013-01-01 12:00:00.0000000' 
ORDER BY OrderID;

SELECT OrderID, PickingCompletedWhen FROM Sales.Orders
WHERE PickingCompletedWhen IS DISTINCT FROM '2013-01-01 12:00:00.0000000' 
ORDER BY OrderID;

-- IS NOT DISTINCT FROM - Orders on a date
SELECT OrderID, PickingCompletedWhen FROM Sales.Orders
WHERE PickingCompletedWhen = '2013-01-01 12:00:00.0000000';

SELECT OrderID, PickingCompletedWhen FROM Sales.Orders
WHERE PickingCompletedWhen IS NOT DISTINCT FROM '2013-01-01 12:00:00.0000000';

-- Cleanup
DROP INDEX IF EXISTS Sales.Orders.pickingdateidx;
GO