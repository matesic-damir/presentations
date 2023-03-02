/* Damir Matešiæ - https://blog.matesic.info */
/* ######################################### */

/* The WINDOW Clause */

USE AdventureWorks2019;

-- Retrieve all orders, order number for the customer, first and last date of order, sum of all 
-- orders as well as subtotal
-- Widouth the WINDOW Clause
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


-- By using the WINDOW Clause
SELECT 
	h.SalesOrderID
	, h.CustomerID
	, h.OrderDate
	, h.TotalDue
	, ROW_NUMBER() OVER P1 AS Order_Number
	, MIN(h.OrderDate) OVER P AS Customer_First_Order_Date
	, MAX(h.OrderDate) OVER P AS Customer_Last_Order_Date
	, SUM(h.TotalDue) OVER P AS Customer_Total_Due
	, SUM(h.TotalDue) OVER P2 AS Running_Sum_Total_Due
FROM 
	[Sales].[SalesOrderHeader] h
WINDOW
	P AS (PARTITION BY h.CustomerID)
	, P1 AS (P ORDER BY  h.OrderDate, h.SalesOrderID)
	, P2 AS (P1 ROWS UNBOUNDED PRECEDING)
ORDER BY
	h.CustomerID, h.OrderDate, h.SalesOrderID;
	
