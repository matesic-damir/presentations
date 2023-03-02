/* Memory-Optimized TempDB Metadata */
/* Damir Matešiæ - https://blog.matesic.info */
/* ######################################### */

-- 1)

EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'TestDb';
GO
USE [master];
GO
DROP DATABASE IF EXISTS [TestDb];
GO

CREATE DATABASE TestDb;
GO
ALTER DATABASE [TestDb] ADD FILEGROUP [TestDbMemFG] CONTAINS MEMORY_OPTIMIZED_DATA 
GO
ALTER DATABASE [TestDb] ADD FILE ( NAME = N'TestDbMemDB', FILENAME = N'C:\SQL\Data\TestDbMemDB' ) TO FILEGROUP [TestDbMemFG]
GO
USE TestDb;
GO
--check the IsTempdbMetadataMemoryOptimized attribute, it should be OFF by default
SELECT SERVERPROPERTY('IsTempdbMetadataMemoryOptimized');
GO

ALTER SERVER CONFIGURATION SET MEMORY_OPTIMIZED TEMPDB_METADATA = OFF;

--turn on STATISTICS IO in order to see system tables involved in SQL commands
SET NOCOUNT ON;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
 
--create a temp table (you can take any existing table instead of WideWorldImporters.Sales.Orders)
SELECT * INTO #orders 
FROM WideWorldImporters.Sales.Orders;

--check the output in the Messages tab
SELECT * FROM tempdb.sys.tables;

/*Result:
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'sysmultiobjrefs'. Scan count 4, logical reads 8, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'sysschobjs'. Scan count 1, logical reads 39, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'syssingleobjrefs'. Scan count 5, logical reads 10, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'syspalnames'. Scan count 1, logical reads 2, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'sysidxstats'. Scan count 1, logical reads 7, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'syspalvalues'. Scan count 2, logical reads 4, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
*/
-- a lot of involved database objects for a very simple action with temp tables
-- when you create, manipulate and drop a lot of temporal objects, these writings into system tables
-- could become a bottleneck in the system (metadata latch contention)

--turn the flag MEMORY_OPTIMIZED TEMPDB_METADATA on
ALTER SERVER CONFIGURATION SET MEMORY_OPTIMIZED TEMPDB_METADATA = ON;

-- restart the server (YOU CAN DO THIS ON YOUR MACHINE ONLY!!!)
SHUTDOWN WITH NOWAIT;   
--ensure that this query returns 1
SELECT SERVERPROPERTY('IsTempdbMetadataMemoryOptimized');

--turn on STATISTICS IO in order to see system tables involved in SQL commands
SET NOCOUNT ON;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
--create a temp table (you can take any existing table instead of WideWorldImporters.Sales.Orders)
SELECT * INTO #orders 
FROM WideWorldImporters.Sales.Orders;

--check the output in the Messages tab
SELECT * FROM tempdb.sys.tables;

/*Result:
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'syspalnames'. Scan count 1, logical reads 2, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'syspalvalues'. Scan count 2, logical reads 4, physical reads 1, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
*/
--You can see significnatly less objects - most of them are in-memory objects

-- 2) Limitations

-- Columnstore index creation is not support in tempdb when memory-optimized metadata mode is enabled

CREATE TABLE #t (id INT, c1 NVARCHAR(50));
INSERT INTO #t SELECT object_id, LEFT(name, 50) FROM sys.tables;
CREATE COLUMNSTORE INDEX idx1 ON #t(c1);

-- sp_estimate_data_compression_savings
CREATE TABLE [dbo].[TestCI](
	[TestColumn] [nvarchar](256) NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED COLUMNSTORE INDEX [ClusteredColumnStoreIndex] ON [dbo].[TestCI] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [PRIMARY]
GO
EXEC sp_estimate_data_compression_savings 'dbo', 'TestCI', NULL, NULL, 'ROW' ;  
GO

-- InMemory access to TempDB system views

DROP TABLE IF EXISTS dbo.MemoryOptimizedTable;
CREATE TABLE dbo.MemoryOptimizedTable
(
	id int NOT NULL,
	name nvarchar(50) COLLATE Latin1_General_100_CI_AS NOT NULL,
	PRIMARY KEY NONCLUSTERED HASH (id)
	WITH ( BUCKET_COUNT = 1024)
) WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA )
GO

-- Not working because of TempDB system view
BEGIN TRANSACTION
IF EXISTS(SELECT 1 FROM tempdb.sys.tables WHERE name LIKE N'#x[_]%') DROP TABLE #x;
CREATE TABLE #x (id INT, c1 NVARCHAR(50));
INSERT INTO #x SELECT object_id, LEFT(name, 50) FROM sys.tables;
INSERT INTO dbo.MemoryOptimizedTable SELECT id, c1 FROM #x;
COMMIT

BEGIN TRANSACTION
IF OBJECT_ID('tempdb..#x') IS NOT NULL DROP TABLE #x;
CREATE TABLE #x (id INT, c1 NVARCHAR(50));
INSERT INTO #x SELECT object_id, LEFT(name, 50) FROM sys.tables;
INSERT INTO dbo.MemoryOptimizedTable SELECT id, c1 FROM #x;
COMMIT

-- 3) Stress test

USE TestDb;
GO
--stored proc
CREATE OR ALTER PROCEDURE dbo.P
AS
DECLARE @cnt INT = 0;
WHILE @cnt < 50
BEGIN
	CREATE TABLE #T (id INT); INSERT INTO #T(id) VALUES(1); DROP TABLE #T;
	SET @cnt+=1
END
GO

SELECT SERVERPROPERTY('IsTempdbMetadataMemoryOptimized');
GO

ALTER SERVER CONFIGURATION SET MEMORY_OPTIMIZED TEMPDB_METADATA = ON;
GO
-- Restart server if NOT

-- CD c:\Program Files (x86)\Microsoft Corporation\Database Experimentation Assistant\Dependencies\X64
-- ostress -E -dTestDb -Q"EXEC dbo.P" -MSSQLSERVER -r50 -n100 -q

--check waits
SELECT 
r.wait_time,
r.wait_type, 
r.total_elapsed_time,
r.cpu_time,
st.text,
c.client_net_address,
c.num_reads,
c.num_writes
FROM sys.dm_exec_requests r INNER JOIN sys.dm_exec_connections c
ON (r.connection_id = c.connection_id) OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) st
WHERE 
r.wait_type NOT IN ('SP_SERVER_DIAGNOSTICS_SLEEP','WAITFOR')
AND r.database_id = DB_ID()
ORDER BY 
 r.wait_time DESC
 GO

 -- No waits or rarely, Time 00:00:30.546

ALTER SERVER CONFIGURATION SET MEMORY_OPTIMIZED TEMPDB_METADATA = OFF;
GO

SHUTDOWN WITH NOWAIT;  

-- Repeat
-- ostress -E -dTestDb -Q"EXEC dbo.P" -MSSQLSERVER -r50 -n100 -q

--check waits
SELECT 
r.wait_time,
r.wait_type, 
r.total_elapsed_time,
r.cpu_time,
st.text,
c.client_net_address,
c.num_reads,
c.num_writes
FROM sys.dm_exec_requests r INNER JOIN sys.dm_exec_connections c
ON (r.connection_id = c.connection_id) OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) st
WHERE 
r.wait_type NOT IN ('SP_SERVER_DIAGNOSTICS_SLEEP','WAITFOR')
AND r.database_id = DB_ID()
ORDER BY 
 r.wait_time DESC
 GO

-- Waits are frequent, Time 00:01:18.216
