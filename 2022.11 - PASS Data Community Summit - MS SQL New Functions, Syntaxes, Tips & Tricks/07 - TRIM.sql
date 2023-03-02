/* Damir Matešiæ - https://blog.matesic.info */
/* ######################################### */

/* TRIM, LTRIM, RTRIM */

USE master;
GO

-- The first statement is what was previously only supported
SELECT TRIM('STR' FROM 'STR mydata STR') as trim_strings;
GO

-- New LEADING and TRAILING
SELECT TRIM(LEADING 'STR' FROM 'STRmydataSTR') as leading_string;
SELECT TRIM(TRAILING 'STR' FROM 'STRmydataSTR') as trailing_string;
GO

-- Same as the previous release behavior but explicitly specifying BOTH
SELECT TRIM('STR' FROM 'STR mydata STR') as trim_strings;
SELECT TRIM(BOTH 'STR' FROM 'STRmydataSTR') as both_strings_trimmed;
GO

-- The new extension to the LTRIM function
SELECT LTRIM('STRmydataSTR', 'STR') as left_trimmed_string;
GO

-- The new extension to the RTRIM function
SELECT RTRIM('STRmydataSTR', 'STR') as right_trimmed_string;
GO
