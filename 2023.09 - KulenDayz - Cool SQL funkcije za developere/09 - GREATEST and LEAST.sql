/* Damir Matešiæ - https://blog.matesic.info */
/* ######################################### */

/* GREATEST and LEAST */
USE master;
GO

-- Example
SELECT GREATEST(1, 5, 3); -- returns 5

-- Widouth function?
SELECT CASE 
  WHEN 1 > 5 THEN
    CASE WHEN 1 > 3 THEN 1 ELSE 3 END
  ELSE
    CASE WHEN 5 > 3 THEN 5 ELSE 3 END
  END;

-- 20 columns?
CREATE TABLE #SummarizedSales
(
    Year int, 
    Jan  int, 
    Feb  int, 
    Mar  int --,...
);

INSERT #SummarizedSales(Year, Jan, Feb, Mar) 
VALUES
(2021, 55000, 81000, 74000),
(2022, 60000, 92000, 86000);

-- CASE
SELECT Year, 
  BestMonth = CASE 
    WHEN Jan > Feb THEN 
      CASE WHEN Jan > Mar THEN Jan ELSE Mar END
    ELSE
      CASE WHEN Mar > Feb THEN Mar ELSE Feb END
    END,
  WorstMonth = CASE 
    WHEN Jan < Feb THEN 
      CASE WHEN Jan < Mar THEN Jan ELSE Mar END
    ELSE
      CASE WHEN Mar < Feb THEN Mar ELSE Feb END
    END
FROM #SummarizedSales;

-- UNPIVOT
SELECT Year, 
  BestMonth  = MAX(Months.MonthlyTotal), 
  WorstMonth = MIN(Months.MonthlyTotal)
FROM #SummarizedSales AS s
UNPIVOT
(
  MonthlyTotal FOR [Month] IN ([Jan],[Feb],[Mar])
) AS Months
GROUP BY Year;

-- CROSS APPLY
SELECT Year,
  BestMonth  = MAX(MonthlyTotal),
  WorstMonth = MIN(MonthlyTotal)
FROM
(
  SELECT s.Year, Months.MonthlyTotal 
  FROM #SummarizedSales AS s
  CROSS APPLY (VALUES([Jan]),([Feb]),([Mar])) AS [Months](MonthlyTotal)
) AS Sales
GROUP BY Year;

-- GREAT :)
SELECT Year,
  BestMonth  = GREATEST([Jan],[Feb],[Mar]),
  WorstMonth = LEAST   ([Jan],[Feb],[Mar])
FROM #SummarizedSales;

-- Simple example
SELECT GREATEST(6.5, 3.5, 7) as greatest_of_numbers;
GO

-- Does it work even if datatypes are not the same?
SELECT GREATEST(6.5, 3.5, N'7') as greatest_of_values;
GO

-- What about strings?
SELECT GREATEST('Buffalo Bills', 'Cleveland Browns', 'Dallas Cowboys') as the_best_team
GO

-- Use it in a comparison
DROP TABLE IF EXISTS studies;
GO
CREATE TABLE studies (    
    VarX varchar(10) NOT NULL,    
    Correlation decimal(4, 3) NULL 
); 
INSERT INTO dbo.studies VALUES ('Var1', 0.2), ('Var2', 0.825), ('Var3', 0.61); 
GO 
DECLARE @PredictionA DECIMAL(4,3) = 0.7;  
DECLARE @PredictionB DECIMAL(4,3) = 0.65;  
SELECT VarX, Correlation  
FROM dbo.studies 
WHERE Correlation > GREATEST(@PredictionA, @PredictionB); 
GO

-- Simple LEAST example
SELECT LEAST(6.5, 3.5, 7) as least_of_numbers;
GO

-- Combine with variables
DECLARE @VarX decimal(4, 3) = 0.59;  
SELECT VarX, Correlation, LEAST(Correlation, 1.0, @VarX) AS LeastVar  
FROM dbo.studies;
GO

-- Clean up table
DROP TABLE IF EXISTS studies;
GO
