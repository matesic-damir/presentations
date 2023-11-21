/* Damir Matešić - https://blog.matesic.info */
/* ######################################### */

/* MS SQL DATE_BUCKET */

SET NOCOUNT ON;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- Old way
SELECT name, modify_date,
  MonthModified = DATEADD(MONTH, DATEDIFF(MONTH, '19000101', modify_date), '19000101')
FROM sys.all_objects;

-- New function
SELECT name, modify_date,
  MonthModified = DATE_BUCKET(MONTH, 1, modify_date)
FROM sys.all_objects;


USE AdventureWorks2019;
GO

-- Number of purchases per month
SELECT 
	Mjesec = DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1)
	, BrojKupovina = COUNT(*)
FROM 
	Sales.SalesOrderHeader 
GROUP BY 
	DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1);

SELECT 
	Mjesec = DATE_BUCKET(MONTH, 1, OrderDate)
	, BrojKupovina = COUNT(*)
FROM 
	Sales.SalesOrderHeader 
GROUP BY 
	DATE_BUCKET(MONTH, 1, OrderDate);


USE [WideWorldImporters];
GO

-- Number of deliveries per hour
SELECT 
	Interval = DATE_BUCKET(HOUR, 1, [ConfirmedDeliveryTime])
    , Number = COUNT(*)
FROM 
	[Sales].[Invoices]
GROUP BY 
	DATE_BUCKET(HOUR, 1, [ConfirmedDeliveryTime]);

