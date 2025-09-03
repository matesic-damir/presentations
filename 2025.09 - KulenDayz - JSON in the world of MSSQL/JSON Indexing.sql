/* START */

USE WideWorldImporters;
GO

/*
DROP TABLE IF EXISTS dbo.JSONIndexing;
GO

USE WideWorldImporters;
GO

CREATE TABLE dbo.JSONIndexing(
    OrderLineID INT NOT NULL,
    [OrderLineDetails] NVARCHAR(MAX) NULL,
    [OrderLineDetailsJSON] JSON NULL,
    CONSTRAINT PK_JSONIndexing PRIMARY KEY CLUSTERED(OrderLineID)
);

INSERT INTO dbo.JSONIndexing (OrderLineID, [OrderLineDetails], [OrderLineDetailsJSON])
SELECT 
    OL.OrderLineID 
    , (SELECT * FROM Sales.OrderLines X WHERE X.OrderLineID = OL.OrderLineID FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) [OrderLineDetails]
    , (SELECT * FROM Sales.OrderLines X WHERE X.OrderLineID = OL.OrderLineID FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) [OrderLineDetailsJSON]
FROM 
Sales.OrderLines OL
GO
*/

SELECT TOP(100) * FROM dbo.JSONIndexing /* Total rows 1 000 000, Size aprox 1GB */


SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

/* NOTHING */

SELECT [OrderLineID]
FROM dbo.JSONIndexing
WHERE JSON_VALUE([OrderLineDetails],'$.StockItemID') = '164';
GO

/*
Table 'JSONIndexing'. Scan count 21, logical reads 144347, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 16453 ms,  elapsed time = 2893 ms.
*/

/* COMPUTED COLUMN WITH INDEX (SQL 2016) */

ALTER TABLE dbo.JSONIndexing ADD StockItemID AS JSON_VALUE([OrderLineDetails], '$.StockItemID');
GO
CREATE INDEX IDX_StockItemID ON dbo.JSONIndexing(StockItemID);
GO

-- Repeat
SELECT [OrderLineID]
FROM dbo.JSONIndexing
WHERE JSON_VALUE([OrderLineDetails],'$.StockItemID') = '164';
GO
/*
Table 'JSONIndexing'. Scan count 1, logical reads 13326, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 188 ms,  elapsed time = 1126 ms.
*/

-- Drop index 
DROP INDEX IDX_StockItemID ON [dbo].[JSONIndexing]
GO
ALTER TABLE dbo.JSONIndexing DROP COLUMN StockItemID
GO

/* NOTHING ON JSON */

SELECT [OrderLineID]
FROM dbo.JSONIndexing
WHERE JSON_VALUE([OrderLineDetailsJSON],'$.StockItemID') = '164';
GO
/*
Table 'JSONIndexing'. Scan count 21, logical reads 144883, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 8201 ms,  elapsed time = 1497 ms.
*/

/* JSON INDEX (SQL 2025) 308635 ms */
CREATE JSON INDEX IX_JSON
   ON dbo.JSONIndexing ([OrderLineDetailsJSON])
   FOR ('$')
   WITH (DATA_COMPRESSION=PAGE);
GO


SELECT [OrderLineID]
FROM dbo.JSONIndexing
WHERE JSON_VALUE([OrderLineDetailsJSON],'$.StockItemID') = '164';
GO
/*
Table 'JSONIndexing'. Scan count 21, logical reads 144795, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 8123 ms,  elapsed time = 1534 ms.

   INDEX not used
*/
SELECT [OrderLineID]
FROM dbo.JSONIndexing  WITH (INDEX(IX_JSON))
WHERE JSON_VALUE([OrderLineDetailsJSON],'$.StockItemID') = '164';
GO
/*
Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'JSONIndexing'. Scan count 1, logical reads 143389, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'json_index_932198371_1216000'. Scan count 1, logical reads 1628, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 3047 ms,  elapsed time = 4195 ms.

   INDEX Used
*/


DROP INDEX IX_JSON  ON dbo.JSONIndexing
GO

CREATE JSON INDEX IX_JSON /*25488 ms*/
   ON dbo.JSONIndexing ([OrderLineDetailsJSON])
   FOR ('$.StockItemID')
   WITH (DATA_COMPRESSION=PAGE);

SELECT [OrderLineID]
FROM dbo.JSONIndexing 
WHERE JSON_VALUE([OrderLineDetailsJSON],'$.StockItemID') = '164';
GO

SELECT [OrderLineID]
FROM dbo.JSONIndexing WITH (INDEX(IX_JSON))
WHERE JSON_VALUE([OrderLineDetailsJSON],'$.StockItemID') = '164';
GO
/*
Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'JSONIndexing'. Scan count 1, logical reads 143389, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'json_index_932198371_1216000'. Scan count 1, logical reads 1627, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 2891 ms,  elapsed time = 3699 ms.
*/

DROP INDEX IX_JSON  ON dbo.JSONIndexing
GO