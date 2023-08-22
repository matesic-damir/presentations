/* Damir Matešiæ - https://blog.matesic.info */
/* ######################################### */

/* TRIM, LTRIM, RTRIM */

USE master;
GO
-- The first statement is what was previously only supported
SELECT TRIM('STR' FROM 'STR mydata STR') as trim_strings;
SELECT TRIM(LEADING 'STR' FROM 'STRmydataSTR') as leading_string;
SELECT TRIM(TRAILING 'STR' FROM 'STRmydataSTR') as trailing_string;
-- Same as the previous release behavior but explicitly specifying BOTH
SELECT TRIM(BOTH 'STR' FROM 'STRmydataSTR') as both_strings_trimmed;
GO
-- Step 2: Use the new extension to the LTRIM function
USE master;
GO
SELECT LTRIM('STRmydataSTR', 'STR') as left_trimmed_string;
GO
-- Step 3: Use the new extension to the RTRIM function
USE master;
GO
SELECT RTRIM('STRmydataSTR', 'STR') as right_trimmed_string;
GO
