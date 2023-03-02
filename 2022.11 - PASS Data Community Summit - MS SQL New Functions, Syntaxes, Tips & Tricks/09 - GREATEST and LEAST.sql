/* Damir Matešiæ - https://blog.matesic.info */
/* ######################################### */

/* GREATEST and LEAST */
USE master;
GO

-- Easy exammple
SELECT GREATEST(1, 5, 3); -- returns 5

-- How to do it widouth the function?
SELECT CASE 
  WHEN 1 > 5 THEN
    CASE WHEN 1 > 3 THEN 1 ELSE 3 END
  ELSE
    CASE WHEN 5 > 3 THEN 5 ELSE 3 END
  END;

-- What if we have 20 columns?
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

-- Use of the function :)
SELECT Year,
  BestMonth  = GREATEST([Jan],[Feb],[Mar]),
  WorstMonth = LEAST   ([Jan],[Feb],[Mar])
FROM #SummarizedSales;

-- Simple example, distinct data types
SELECT GREATEST(6.5, 3.5, 7) as greatest_of_numbers;
GO

-- Does it work even if datatypes are not the same?
SELECT GREATEST(6.5, 3.5, N'7') as greatest_of_values;
GO

-- What about strings?
SELECT GREATEST('Buffalo Bills', 'Cleveland Browns', 'Dallas Cowboys') as the_best_team
GO

-- NULL?
SELECT GREATEST(6.5, NULL, N'7') as greatest_of_values;
GO

-- All NULL
SELECT GREATEST(NULL, NULL, NULL) as greatest_of_values;
GO

-- Simple LEAST example
SELECT LEAST(6.5, 3.5, 7) as least_of_numbers;
GO

-- Clean up table
DROP TABLE IF EXISTS studies;
GO
