/* Damir Matešiæ - https://blog.matesic.info */
/* ######################################### */

/* Approximate Percentile Functions */

USE AdventureWorks2019;
GO
SET NOCOUNT ON;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO


SELECT DISTINCT [SalesOrderID], 
  PERCENTILE_CONT (0.5) WITHIN GROUP (ORDER BY [OrderQty]) 
        OVER (PARTITION BY [SalesOrderID]) AS medianscore_cont, 
  PERCENTILE_DISC (0.5) WITHIN GROUP (ORDER BY [OrderQty]) 
        OVER (PARTITION BY [SalesOrderID]) AS medianscore_disc
FROM [Sales].[SalesOrderDetail]
ORDER BY SalesOrderID;

SELECT [SalesOrderID], 
APPROX_PERCENTILE_CONT (0.5) WITHIN GROUP (ORDER BY [OrderQty]) AS medianscore_cont, 
APPROX_PERCENTILE_DISC (0.5) WITHIN GROUP (ORDER BY [OrderQty]) AS medianscore_disc
FROM [Sales].[SalesOrderDetail]
GROUP BY [SalesOrderID]
ORDER BY SalesOrderID;