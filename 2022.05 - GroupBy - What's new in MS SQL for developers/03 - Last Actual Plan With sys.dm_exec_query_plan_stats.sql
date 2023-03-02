/* Last Actual Plan With sys.dm_exec_query_plan_stats */
/* Damir Matešiæ - https://blog.matesic.info */
/* ######################################### */

USE [AdventureWorksDW2016_EXT];
GO
SET NOCOUNT ON SET STATISTICS TIME ON;
GO
ALTER DATABASE SCOPED CONFIGURATION SET LAST_QUERY_PLAN_STATS = ON;
GO

CREATE OR ALTER PROCEDURE dbo.LightweightStats
AS
SELECT COUNT(*) FROM (SELECT DISTINCT UnitCost, UnitsIn,MovementDate FROM dbo.FactProductInventory)x;
GO

EXEC LightweightStats
GO 5

--check the cached plan
 SELECT 
	ep.usecounts,cacheobjtype,ep.objtype,
	q.text AS query_text, pl.query_plan,
	ep.size_in_bytes
FROM 
	sys.dm_exec_cached_plans ep
	CROSS APPLY sys.dm_exec_sql_text(ep.plan_handle) q
	CROSS APPLY sys.dm_exec_query_plan(ep.plan_handle) pl
WHERE
	ep.objtype = 'Proc'
	AND
	q.text LIKE '%LightweightStats%'

--check the actual plan
SELECT deqps.query_plan
FROM sys.dm_exec_procedure_stats AS deps
    CROSS APPLY sys.dm_exec_query_plan_stats(deps.plan_handle) AS deqps
WHERE deps.object_id = OBJECT_ID('dbo.LightweightStats');