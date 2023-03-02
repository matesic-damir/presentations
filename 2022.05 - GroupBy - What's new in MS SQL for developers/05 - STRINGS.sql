/* STRINGS */
/* Damir Matešić - https://blog.matesic.info */
/* ######################################### */

/* STRING_SPLIT */ 

-- Get all ingredients for a mojito cocktail
SELECT value AS "Ingredients" 
FROM STRING_SPLIT(N'1 1/2 oz White rum,6 leaves of Mint,Soda Water,1 oz Fresh lime juice,2 teaspoons Sugar',',');

-- Old solution vs new function performance
-------------------------------------------

USE [WideWorldImporters];
SET NOCOUNT ON;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Create the old test function
CREATE OR ALTER FUNCTION [dbo].[SplitString] (@Data NVARCHAR(MAX), @Delimiter NVARCHAR(5))
RETURNS @Table TABLE ( Data NVARCHAR(MAX) , ItemNo INT IDENTITY(1, 1))
AS
BEGIN

    DECLARE @TextXml XML;
    SELECT @TextXml = CAST('<d>' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@Data, '&', '&amp;'), '<', '&lt;'), '>', '&gt;'), '"', '&quot;'), '''', '&apos;'), @Delimiter, '</d><d>') + '</d>' AS XML);

    INSERT INTO @Table (Data)
    SELECT Data = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(T.split.value('.', 'nvarchar(max)'))), '&amp;', '&'), '&lt;', '<'), '&gt;', '>'), '&quot;', '"'), '&apos;', '''')
    FROM @TextXml.nodes('/d') T(Split)

    RETURN
END
GO

-- 1. The old way using XML
SELECT 
	SI.StockItemID
	, SI.StockItemName
	, SP.Data as Tag
FROM 
	[Warehouse].[StockItems] SI
	CROSS APPLY [dbo].[SplitString](REPLACE(REPLACE(REPLACE(Tags,'[',''), ']',''), '"', ''), ',') SP;

-- 2. The new way using STRING_SPLIT
SELECT 
	SI.StockItemID
	, SI.StockItemName
	, SP.value as Tag
FROM 
	[Warehouse].[StockItems] SI
	CROSS APPLY STRING_SPLIT(REPLACE(REPLACE(REPLACE(Tags,'[',''), ']',''), '"', ''), ',') SP;

DROP FUNCTION [dbo].[SplitString]

/* MS SQL STRING_ESCAPE */

DECLARE @InputValue NVARCHAR(MAX) = N'
https://blog.matesic.info
C:\\MS SQL STRING ESCAPE
TAB:	';
SELECT STRING_ESCAPE(@InputValue,'JSON') AS Result;

/* MS SQL FORMATMESSAGE */

-- Bullet proof solution :)
DECLARE @person_name nvarchar(max) = 'Damir';
DECLARE @drink_name nvarchar(max) = 'Gin and tonic';
DECLARE @number_of_drinks int = 3;
SELECT ISNULL(@person_name, '') + ' will order ' + ISNULL(CAST(@number_of_drinks AS nvarchar(max)), '') + 'x ' + ISNULL(@drink_name, '') + '. Cheers!' AS Result;

-- FORMATMESSAGE function
SELECT FORMATMESSAGE('%s will order %sx %s. Cheers!', @person_name, CAST(@number_of_drinks AS NVARCHAR(MAX)), @drink_name) AS Result;

/* MS SQL TRIM */

-- input value
DECLARE @StringValue nvarchar(max) = '  remove spaces from both sides of this string  ';
-- string with spaces
SELECT @StringValue AS Result UNION ALL
-- old way before introducing TRIM
SELECT LTRIM(RTRIM(@StringValue)) AS Result UNION ALL
-- new way with TRIM
SELECT TRIM(@StringValue) AS Result;

/* MS SQL STRING_AGG */

-- Real database data
USE [WideWorldImporters];
-- Aggregate customer names
SELECT STRING_AGG(CAST(C.[CustomerName] AS nvarchar(max)), ',') AS Result FROM [Sales].[Customers] AS C;

-- Performances
USE [WideWorldImporters];
SET NOCOUNT ON;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
-- Turn on statistics
-- Discard results after execution
-- Enable Execution plan
 
-- 1. The old way using XML and STUFF
SELECT
C.InvoiceID
, STUFF((
        SELECT
            ',' + I.Description
        FROM 
            [Sales].[InvoiceLines] I
        WHERE
            I.InvoiceID = C.InvoiceID
        ORDER BY
            I.[InvoiceID] ASC
        FOR XML PATH(''), TYPE).value('.', 'varchar(max)'),1,1,'') AS Descriptions
FROM
    [Sales].Invoices AS C
ORDER BY
    C.InvoiceID ASC;
  
-- 2. The new way using STRING_AGG
SELECT
    C.InvoiceID
    , (
        SELECT
            STRING_AGG(Description, ',') WITHIN GROUP(ORDER BY [InvoiceID] ASC) AS InvoicesList
        FROM
            [Sales].[InvoiceLines] I
        WHERE
            I.InvoiceID = C.InvoiceID
	) AS Descriptions
FROM
    [Sales].Invoices AS C
ORDER BY
    C.InvoiceID ASC;

/* MS SQL TRANSLATE */

-- replace multiple characters (strings) at once
-- input value
DECLARE @StringValue nvarchar(max) = 'Replace all brackets with parentheses in [database].[schema].[table_name].';
-- result of TRANSLATE
SELECT TRANSLATE(@StringValue, '[]', '()') AS Result;
-- implementation of REPLACE
SELECT REPLACE(REPLACE(@StringValue,'[','('), ']', ')') AS Result;

/* String or binary data would be truncated */

USE [master];
GO
ALTER DATABASE [WideWorldImporters] SET COMPATIBILITY_LEVEL = 140;
GO
USE [WideWorldImporters];
GO
DROP TABLE IF EXISTS [dbo].[Data];
GO
CREATE TABLE Data(
	FirstName NVARCHAR(64) 
	, LastName NVARCHAR(6)
);

INSERT INTO Data(FirstName, LastName) VALUES ('Bob' , 'Marley'),('John' , 'Doe'),('Jack' , 'Daniels');
GO

USE [master];
GO
ALTER DATABASE [WideWorldImporters] SET COMPATIBILITY_LEVEL = 150;
GO
USE [WideWorldImporters];
GO
DROP TABLE IF EXISTS [dbo].[Data];
GO
CREATE TABLE Data(
	FirstName NVARCHAR(64) 
	, LastName NVARCHAR(6)
);

INSERT INTO Data(FirstName, LastName) VALUES ('Bob' , 'Marley'),('John' , 'Doe'),('Jack' , 'Daniels');
GO
DROP TABLE IF EXISTS [dbo].[Data];
GO

/* UTF8 */

EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'UTF8';
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'NONUTF8';
GO
USE [master];
GO
/****** Object:  Database [UTF8]    Script Date: 8.12.2019. 17:22:17 ******/
DROP DATABASE IF EXISTS [UTF8];
GO
DROP DATABASE IF EXISTS [NONUTF8];
GO
CREATE DATABASE [UTF8] COLLATE Latin1_General_100_CI_AS_SC_UTF8;
CREATE DATABASE [NONUTF8] COLLATE Latin1_General_100_CI_AS_SC;
GO

-- SQL2019 supports UTF8 collation -> SQL2019 поддерживает сопоставление UTF8

USE NONUTF8
GO

DECLARE @v VARCHAR(100) = 'SQL 2019 підтримує сортування UTF 8';
SELECT @v AS String, DATALENGTH(@v) AS DataLengthValue;
DECLARE @nv NVARCHAR(100) = N'SQL 2019 підтримує сортування UTF 8';
SELECT @nv AS String, DATALENGTH(@nv) AS DataLengthValue;
GO

USE UTF8;
GO

DECLARE @8v VARCHAR(100) = 'SQL 2019 підтримує сортування UTF 8';
SELECT @8v AS String, DATALENGTH(@8v) AS DataLengthValue;
DECLARE @8nv NVARCHAR(100) = N'SQL 2019 підтримує сортування UTF 8';
SELECT @8nv AS String, DATALENGTH(@8nv) AS DataLengthValue;
GO

EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'UTF8';
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'NONUTF8';
GO
USE [master];
GO
/****** Object:  Database [UTF8]    Script Date: 8.12.2019. 17:22:17 ******/
DROP DATABASE IF EXISTS [UTF8];
GO
DROP DATABASE IF EXISTS [NONUTF8];
GO