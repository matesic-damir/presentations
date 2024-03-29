/* Damir Mate�i� - https://blog.matesic.info */
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

-- Orders on a date
DECLARE @dt datetime2 = '2013-01-01 12:00:00.0000000'
SELECT * FROM Sales.Orders WHERE
PickingCompletedWhen = @dt;
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

-- Combination - Index scan
DECLARE @dt AS DATE = NULL;
SELECT * FROM Sales.Orders 
WHERE PickingCompletedWhen = @dt OR (PickingCompletedWhen IS NULL AND @dt IS NULL);
GO

-- New operator - Index seek!
DECLARE @dt datetime2 = NULL
SELECT *
FROM Sales.Orders
WHERE PickingCompletedWhen IS NOT DISTINCT FROM @dt;
GO

-- All picked up
DECLARE @dt datetime2 = NULL
SELECT *
FROM Sales.Orders
WHERE PickingCompletedWhen IS DISTINCT FROM @dt;
GO