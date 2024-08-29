DROP TABLE IF EXISTS [dbo].[OrdersJSON];
DROP TABLE IF EXISTS [dbo].[OrdersN];

CREATE TABLE [dbo].[OrdersJSON]
(
    [order_id] [INT] NOT NULL,
    [order_details] [JSON] NOT NULL,
    CONSTRAINT [PK_OrdersJSON] PRIMARY KEY CLUSTERED ([order_id] ASC)
);

CREATE TABLE [dbo].[OrdersN]
(
    [order_id] [INT] NOT NULL,
    [order_details] [NVARCHAR](MAX) NOT NULL,
    CONSTRAINT [PK_OrdersN] PRIMARY KEY CLUSTERED ([order_id] ASC)
);

INSERT INTO dbo.OrdersJSON
(
    order_id,
    order_details
)
SELECT OrderID, (SELECT o.* FROM sales.orders o WHERE o.OrderID=f.orderid FOR JSON AUTO) FROM Sales.Orders f;

INSERT INTO dbo.OrdersN
(
    order_id,
    order_details
)
SELECT OrderID, (SELECT o.* FROM sales.orders o WHERE o.OrderID=f.orderid FOR JSON AUTO) FROM Sales.Orders f;

SELECT TOP(100) * FROM dbo.OrdersJSON;
SELECT TOP(100) * FROM dbo.OrdersN;

-- compare
SELECT 
	JSON_VALUE(order_details, '$[0].CustomerID') AS CustomerID,
    COUNT(*) AS Cnt
FROM [dbo].[OrdersJSON]
WHERE JSON_VALUE(order_details, '$[0].CustomerID') = 1050
GROUP BY JSON_VALUE(order_details, '$[0].CustomerID')
ORDER BY CustomerID;

SELECT 
	JSON_VALUE(order_details, '$[0].CustomerID') AS CustomerID,
    COUNT(*) AS Cnt
FROM [dbo].[OrdersN]
WHERE JSON_VALUE(order_details, '$[0].CustomerID') = 1050
GROUP BY JSON_VALUE(order_details, '$[0].CustomerID')
ORDER BY CustomerID;

-- OPENJSON !?!?!
SELECT * FROM [dbo].[OrdersJSON] O CROSS APPLY OPENJSON(O.order_details)

-- compare
SELECT *
FROM [dbo].[OrdersJSON] O
    CROSS APPLY
    OPENJSON(CAST(O.order_details AS NVARCHAR(MAX)))
    WITH
    (
        OrderID INT '$.OrderID',
        OrderDate DATE '$.OrderDate'
    ) F
WHERE F.OrderDate = '2013-01-25';

SELECT *
FROM [dbo].[OrdersN] O
    CROSS APPLY
    OPENJSON(O.order_details)
    WITH
    (
        OrderID INT '$.OrderID',
        OrderDate DATE '$.OrderDate'
    ) F
WHERE F.OrderDate = '2013-01-25';