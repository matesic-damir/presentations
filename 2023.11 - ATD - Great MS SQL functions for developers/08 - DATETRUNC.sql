/* Damir Mate�i� - https://blog.matesic.info */
/* ######################################### */

/* DATETRUNC */
DECLARE @d datetime2 = GETDATE();
SELECT 'Year', DATETRUNC(year, @d);
SELECT 'Quarter', DATETRUNC(quarter, @d);
SELECT 'Month', DATETRUNC(month, @d);
SELECT 'Week', DATETRUNC(week, @d); -- Using the default DATEFIRST setting value of 7 (U.S. English)
SELECT 'Iso_week', DATETRUNC(iso_week, @d);
SELECT 'DayOfYear', DATETRUNC(dayofyear, @d);
SELECT 'Day', DATETRUNC(day, @d);
SELECT 'Hour', DATETRUNC(hour, @d);
SELECT 'Minute', DATETRUNC(minute, @d);
SELECT 'Second', DATETRUNC(second, @d);
SELECT 'Millisecond', DATETRUNC(millisecond, @d);
SELECT 'Microsecond', DATETRUNC(microsecond, @d);