/* Damir Matešiæ - https://blog.matesic.info */
/* ######################################### */

/* The WINDOW Clause */

USE AdventureWorks2019;
SET NOCOUNT ON;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- Retrieve all orders, order number for the customer, first and last date of order, sum of all orders as well as subtotal
SELECT 
	h.SalesOrderID
	, h.CustomerID
	, h.OrderDate
	, h.TotalDue
	, ROW_NUMBER() OVER (PARTITION BY h.CustomerID ORDER BY  h.OrderDate, h.SalesOrderID) AS Order_Number
	, MIN(h.OrderDate) OVER (PARTITION BY h.CustomerID) AS Customer_First_Order_Date
	, MAX(h.OrderDate) OVER (PARTITION BY h.CustomerID) AS Customer_Last_Order_Date
	, SUM(h.TotalDue) OVER (PARTITION BY h.CustomerID) AS Customer_Total_Due
	, SUM(h.TotalDue) OVER (PARTITION BY h.CustomerID ORDER BY h.OrderDate, h.SalesOrderID ROWS UNBOUNDED PRECEDING) AS Running_Sum_Total_Due
FROM 
	[Sales].[SalesOrderHeader] h
ORDER BY
	h.CustomerID, h.OrderDate, h.SalesOrderID;



SELECT 
	h.SalesOrderID
	, h.CustomerID
	, h.OrderDate
	, h.TotalDue
	, ROW_NUMBER() OVER PO AS Order_Number
	, MIN(h.OrderDate) OVER P AS Customer_First_Order_Date
	, MAX(h.OrderDate) OVER P AS Customer_Last_Order_Date
	, SUM(h.TotalDue) OVER P AS Customer_Total_Due
	, SUM(h.TotalDue) OVER POUP AS Running_Sum_Total_Due
FROM 
	[Sales].[SalesOrderHeader] h
WINDOW
	P AS (PARTITION BY h.CustomerID)
	, PO AS (P ORDER BY  h.OrderDate, h.SalesOrderID)
	, POUP AS (PO ROWS UNBOUNDED PRECEDING)
ORDER BY
	h.CustomerID, h.OrderDate, h.SalesOrderID;
	
