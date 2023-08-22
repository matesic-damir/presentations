-- Get hashes for customer invoices
USE [WideWorldImporters];
GO
SELECT TOP(100)
	C.CustomerID
	, HASHBYTES ('SHA2_512', (
		SELECT 
			*
		FROM 
			[Sales].[Invoices] I 
			INNER JOIN [Sales].[InvoiceLines] IL ON I.InvoiceID = IL.InvoiceID
		WHERE 
			I.CustomerID = C.CustomerID 
		FOR XML AUTO)
		) AS [Invoices hash]
FROM 
	[Sales].[Customers] C

-- Compare records with HASHBYTES
;WITH CTE AS(
	SELECT 1 AS ID, 'John' AS Name, NULL AS Address, '1979-03-14 17:20' AS BornOn UNION ALL
	SELECT 2 AS ID, 'Dan' AS Name, 'Unknown street' AS Address, '1973-05-12 00:20' AS BornOn UNION ALL
	SELECT 3 AS ID, 'John' AS Name, 'Coling street' AS Address, '1922-02-24 12:20' AS BornOn UNION ALL
	SELECT 4 AS ID, 'Carl' AS Name, 'Philadelphia street' AS Address, '1933-03-14 11:11' AS BornOn UNION ALL
	SELECT 5 AS ID, 'John' AS Name, NULL AS Address, '1979-03-14 17:20' AS BornOn UNION ALL
	SELECT 6 AS ID, 'Dan' AS Name, 'Unknown street' AS Address, '1973-05-12 00:20' AS BornOn UNION ALL
	SELECT 7 AS ID, 'DaN' AS Name, 'Unknown street' AS Address, '1973-05-12 00:20' AS BornOn
)
, CTEHash AS (
SELECT 
	ID
	, Name
	, Address
	, BornOn
	, (SELECT * FROM CTE WHERE CTE.ID = D.ID FOR JSON AUTO, INCLUDE_NULL_VALUES) AS JSON
	, HASHBYTES ('SHA2_512', (SELECT C.Name, C.Address, C.BornOn FROM CTE C WHERE C.ID = D.ID FOR JSON AUTO, INCLUDE_NULL_VALUES)) AS Hash
FROM
	CTE D
)
SELECT * FROM CTEHash ORDER BY Hash, ID;
