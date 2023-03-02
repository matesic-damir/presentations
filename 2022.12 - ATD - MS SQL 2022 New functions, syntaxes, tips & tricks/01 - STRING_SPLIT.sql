/* Damir Matešić - https://blog.matesic.info */
/* ######################################### */

/* MS SQL STRING_SPLIT */
-- Get all ingredients for a mojito cocktail separated by comma 
SELECT value AS "Ingredients" FROM STRING_SPLIT(N'1 1/2 oz White rum,6 leaves of Mint,Soda Water,1 oz Fresh lime juice,2 teaspoons Sugar',',');

-- Get all ingredients for a mojito cocktail. There are two separators between the Mint and Soda with no text between
SELECT value AS "Ingredients" FROM STRING_SPLIT(N'1 1/2 oz White rum,6 leaves of Mint,,Soda Water,1 oz Fresh lime juice,2 teaspoons Sugar',',');

-- Split by two characters :(
SELECT value FROM STRING_SPLIT(N'Value 1..Value2..Value3','..');

-- Get all tags for stock items using CROSS APPLY (originally JSON)
USE WideWorldImporters;
SELECT 
	SI.StockItemID
	, SI.StockItemName
	, SP.value as Tag
FROM 
	[Warehouse].[StockItems] SI
	CROSS APPLY STRING_SPLIT(REPLACE(REPLACE(REPLACE(Tags,'[',''), ']',''), '"', ''), ',') SP;

-- Get all Invoices that have at least one of the stock items in the list (WHERE IN)
DECLARE @StockItemIDs NVARCHAR(MAX) = N'68,121,54'
SELECT 
    IL.InvoiceID
FROM
    [Sales].[InvoiceLines] IL
WHERE
    EXISTS (SELECT 1 FROM STRING_SPLIT(@StockItemIDs, ',') WHERE CAST(value AS INT) = IL.StockItemID)
GROUP BY 
    IL.InvoiceID
ORDER BY 
    IL.InvoiceID;

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

SELECT * FROM [dbo].[SplitString]('Gin and tonic', ' ');

SET NOCOUNT ON;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
-- Turn on statistics
-- Discard results after execution
-- Enable Execution plan

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

-- SQL 2022

SELECT * FROM [dbo].[SplitString]('Gin and tonic', ' ') WHERE ItemNo = 2;

SELECT * FROM STRING_SPLIT('Gin and tonic', ' ', 1) WHERE ordinal = 2;


SET NOCOUNT ON;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
-- 1. The old way using XML
SELECT 
	SI.StockItemID
	, SI.StockItemName
	, SP.Data as Tag
FROM 
	[Warehouse].[StockItems] SI
	CROSS APPLY [dbo].[SplitString](REPLACE(REPLACE(REPLACE(Tags,'[',''), ']',''), '"', ''), ',') SP
WHERE
	SP.ItemNo = 2;

-- 2. The new way using STRING_SPLIT
SELECT 
	SI.StockItemID
	, SI.StockItemName
	, SP.value as Tag
FROM 
	[Warehouse].[StockItems] SI
	CROSS APPLY STRING_SPLIT(REPLACE(REPLACE(REPLACE(Tags,'[',''), ']',''), '"', ''), ',', 1) SP 
WHERE 
	ordinal = 2;