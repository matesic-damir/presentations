/* Damir Matešić - https://blog.matesic.info */
/* ######################################### */

/* MS SQL GENERATE_SERIES */

USE AdventureWorks2017;
GO
SET NOCOUNT ON;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- From 1 to 100
;WITH cte(n) AS 
(
  SELECT 1 UNION ALL 
  SELECT n + 1 FROM cte n WHERE n < 100
)
SELECT value = n FROM cte;

-- From 1 000 to 1 000 000
;WITH cte(n) AS 
(
  SELECT 1000 UNION ALL 
  SELECT n + 1 FROM cte n WHERE n <= 1000000
)
SELECT value = n FROM cte;

-- Find some objects
SELECT ROW_NUMBER() OVER (ORDER BY C.name) Rn FROM sys.columns C, sys.objects--, sys.tables, sys.all_objects

-- Subset
;WITH Cte AS (SELECT ROW_NUMBER() OVER (ORDER BY C.name) Rn FROM sys.columns C, sys.objects)
SELECT Cte.Rn
FROM Cte
WHERE Cte.Rn BETWEEN 1000 AND 1000000


-- Fnction
CREATE OR ALTER FUNCTION [dbo].[NumberRange]
(	
	@start BIGINT
	, @end BIGINT
)
RETURNS TABLE 
AS
RETURN 
(
	WITH CTE(n) AS(
		SELECT 1 AS Number UNION ALL SELECT 1
	),
	CTE2(n) AS (SELECT 1 AS Number  FROM CTE x, CTE y),
	CTE3(n) AS (SELECT 1 AS Number  FROM CTE2 x, CTE2 y),
	CTE4(n) AS (SELECT 1 AS Number  FROM CTE3 x, CTE3 y),
	CTE5(n) AS (SELECT 1 AS Number  FROM CTE4 x, CTE4 y),
	CTE6(n) AS (SELECT 0 AS Number  UNION ALL 
				SELECT TOP (@end-@start)
				ROW_NUMBER() OVER (ORDER BY (SELECT NULL))  AS Number
				FROM CTE5 x, CTE5 y)
	SELECT @start+n  AS Number
	FROM CTE6
	WHERE @start+n <= @end
)
GO

SELECT Number FROM  [dbo].[NumberRange] (1000, 1000000);

/*
DROP TABLE IF EXISTS [dbo].Numbers;

CREATE TABLE [dbo].Numbers (
Number INT NOT NULL,
 CONSTRAINT [PK_Number] PRIMARY KEY CLUSTERED 
(
	[Number] ASC
)
)

INSERT INTO dbo.Numbers (Number)
SELECT Number FROM  [dbo].[NumberRange] (1, 10000000);
*/

SELECT Number FROM  [dbo].[Numbers] WHERE NUmber BETWEEN 1000 AND 1000000;

-- New function
SELECT value FROM GENERATE_SERIES(1000, 1000000, 1);

-- Only even?
SELECT Number FROM  [dbo].[NumberRange] (1000, 1000000) WHERE Number%2 = 0;
SELECT value FROM GENERATE_SERIES(1000, 1000000, 2);


-- Widouth step
SELECT value FROM GENERATE_SERIES(1, 100);

-- Sort operator - execution planu
SELECT value FROM GENERATE_SERIES(1, 100) ORDER BY value ASC;
SELECT value FROM GENERATE_SERIES(1, 100) ORDER BY value DESC;

-- Decimal
DECLARE @start decimal(3,1) = 0.0;
DECLARE @stop decimal(3,1) = 10.0;
DECLARE @step decimal(3,1) = 0.1;

SELECT value FROM GENERATE_SERIES(@start, @stop, @step);


-- + DATE_BUCKET
USE AdventureWorks2019;
GO

-- Total sales per day
DECLARE 
	@Start date = '2014-06-01'
	, @End   datetime = '2014-08-01';

;WITH Days(OrderDate) AS 
(
    SELECT @Start
    UNION ALL
    SELECT DATEADD(DAY, 1, OrderDate) FROM Days 
	WHERE OrderDate < @End
),
SalesData AS
(
  SELECT OrderDate, DailySales = SUM(TotalDue)  
  FROM
  (
    SELECT TotalDue, OrderDate = DATEADD(DAY, DATEDIFF(DAY, @Start, OrderDate), @Start) 
    FROM Sales.SalesOrderHeader
    WHERE OrderDate >= @Start
      AND OrderDate <  @End
  ) AS sq
  GROUP BY OrderDate
)
SELECT OrderDate = h.OrderDate,
  DailySales = COALESCE(sd.DailySales, 0)
FROM Days AS h
LEFT OUTER JOIN SalesData AS sd
  ON h.OrderDate = sd.OrderDate
  WHERE h.OrderDate < @End;


;WITH Dates(OrderDate) AS
(
  SELECT DATE_BUCKET(DAY, 1, DATEADD(DAY, gs.value, @Start)) FROM GENERATE_SERIES (0, DATEDIFF(DAY, @Start, @End)-1) AS gs
)
SELECT 
	h.OrderDate
	, DailySales = COALESCE(SUM(TotalDue),0)
FROM 
	Dates AS h
	LEFT OUTER JOIN Sales.SalesOrderHeader  AS s
		ON h.OrderDate = DATE_BUCKET(DAY, 1, s.OrderDate) 
GROUP BY h.OrderDate
ORDER BY h.OrderDate; 