/* Damir Matešiæ - https://blog.matesic.info */
/* ######################################### */

/* JSON enhancements */
/* IS JSON */
SELECT ISJSON('[{"First name":"Bob","Last name":"Doe"}]');
SELECT ISJSON('[{"First name":"Bob","Last name:"Doe"}]');

DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"Born": 1979,
"FavoriteDrinks": [{"Name": "Gin and tonic","Drink": "Occasionally"},{"Name": "Coffe with milk","Drink": "Daily"}]
}';
SELECT ISJSON(@JSON_data);

DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"Born": 1979,
"FavoriteDrinks": [{"Name": "Gin and tonic","Drink": "Occasionally"},{"Name": "Coffe with milk","Drink": "Daily"}]
}';
SELECT ISJSON(@JSON_data, VALUE);

SELECT ISJSON ('test string', VALUE) 

SELECT ISJSON ('[{"First name":"Bob","Last name":"Doe"}]', VALUE) 

DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"BornAfterWoodstock": true,
"FavoriteDrinks": [{"Name": "Gin and tonic","Drink": "Occasionally"},{"Name": "Coffe with milk","Drink": "Daily"}]
}';
SELECT ISJSON (@JSON_data, OBJECT) 

SELECT ISJSON ('"test string"', OBJECT) 

DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "John Doe",
"Born": 1979,
"FavoriteDrinks": [{"Name": "Gin and tonic","Drink": "Occasionally"},{"Name": "Coffe with milk","Drink": "Daily"}]
}';
SELECT ISJSON (@JSON_data, ARRAY) 

SELECT ISJSON ('[{"Name": "Gin and tonic","Drink": "Occasionally"},{"Name": "Coffe with milk","Drink": "Daily"}]', ARRAY) 

SELECT ISJSON ('"test string"', SCALAR) 

SELECT ISJSON ('test string', SCALAR) 

/* JSON_OBJECT */

DROP TABLE IF EXISTS sql_requests_table_json_object;
GO
SELECT JSON_OBJECT('command': r.command, 'status': r.status, 'database_id': r.database_id, 'wait_type': r.wait_type, 'wait_resource': r.wait_resource, 'user': s.is_user_process) as json_object, r.command
INTO sql_requests_table_json_object
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_sessions s
ON r.session_id = s.session_id
ORDER BY r.session_id;
GO
SELECT * FROM sql_requests_table_json_object;
GO

/* JSON_PATH_EXISTS */

SELECT 
	JSON_PATH_EXISTS(json_object, '$.status')
	, JSON_PATH_EXISTS(command, '$.status')
FROM sql_requests_table_json_object;
GO

/* JSON_ARRAY */

DROP TABLE IF EXISTS sql_requests_json_array;
GO
SELECT r.session_id, JSON_ARRAY(r.command, r.status, r. database_id, r.wait_type, r.wait_resource, s.is_user_process) as json_array, r.command
INTO sql_requests_json_array
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_sessions s
ON r.session_id = s.session_id
ORDER BY r.session_id;
GO
SELECT * FROM sql_requests_json_array;
GO

DROP TABLE IF EXISTS sql_requests_table_json_object;
GO
DROP TABLE IF EXISTS sql_requests_json_array;
GO