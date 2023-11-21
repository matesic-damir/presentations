DECLARE @Q NVARCHAR(MAX) 

SET @Q = N'Šta ima kod tebe?'
--SET @Q = N'Kakva je to konferencija Sinergija'

--SET @Q = N'Can you write a code for a MS SQL tables containing 
--1. Customer table: ID (auto generated), First name, Last Name, Address information 
--2. Book author table: ID (auto generated), First name, Last Name
--3. Book table: ID (auto generated), Book name, Author (foregien key to Authors table), ISBN
--4. Purchase table: ID (auto generated), Customer (foregien key to Customer table), Book (foregien key to Book table), Date of purchase, Shipment date (nullable)
--Please add covering indexes for best performance when querying purchases, especially not shipped.
--Also, please create a MS SQL Query to get all not shipped purchases, with all related data and the result should be a JSON document.'

DECLARE @APIKey NVARCHAR(256) = (SELECT [ApiKey] FROM [dbo].[Settings])
DECLARE @Uri NVARCHAR(256) = (SELECT [Uri] FROM [dbo].[Settings])
DECLARE @url nvarchar(4000) = N'https://' + @Uri + '/openai/deployments/test/chat/completions?api-version=2023-08-01-preview';
declare @headers nvarchar(102) = N'{"api-key":"' + @APIKey + '"}'
SET @q = REPLACE(REPLACE(REPLACE(@q, CHAR(13),' '), CHAR(10),' '), CHAR(9),' ')
declare @payload nvarchar(max) = N'{"messages":[{"role":"system","content":"'+ @Q +'"}]}'
declare @response nvarchar(max);

exec  sp_invoke_external_rest_endpoint 
@url = @url,
@method = 'POST',
@headers = @headers,
@payload = @payload,
@timeout = 230,
@response = @response output;

--SELECT @response as Response;

SELECT * FROM OPENJSON(@response, '$.result.choices[0].message') WITH (
    content NVARCHAR(max) '$.content'
) Data


