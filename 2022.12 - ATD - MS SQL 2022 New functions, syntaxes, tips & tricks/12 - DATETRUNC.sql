/* Damir Matešiæ - https://blog.matesic.info */
/* ######################################### */

/* DATETRUNC */
DECLARE @d datetime2 = GETDATE();
SELECT 'Current date time' AS Datepart, @d AS Value UNION ALL
SELECT 'Year', DATETRUNC(year, @d) UNION ALL
SELECT 'Quarter', DATETRUNC(quarter, @d) UNION ALL
SELECT 'Month', DATETRUNC(month, @d) UNION ALL
SELECT 'Week', DATETRUNC(week, @d) UNION ALL 
-- Using the default DATEFIRST setting value of 7 (U.S. English)
SELECT 'Iso_week', DATETRUNC(iso_week, @d) UNION ALL
SELECT 'DayOfYear', DATETRUNC(dayofyear, @d) UNION ALL
SELECT 'Day', DATETRUNC(day, @d) UNION ALL
SELECT 'Hour', DATETRUNC(hour, @d) UNION ALL
SELECT 'Minute', DATETRUNC(minute, @d) UNION ALL
SELECT 'Second', DATETRUNC(second, @d) UNION ALL
SELECT 'Millisecond', DATETRUNC(millisecond, @d) UNION ALL
SELECT 'Microsecond', DATETRUNC(microsecond, @d);


