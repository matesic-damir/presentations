/* OPTIMIZE_FOR_SEQUENTIAL_KEY */
/* Damir Matešiæ - https://blog.matesic.info */
/* ######################################### */

/* RML Utilities for SQL Server (x64) : https://www.microsoft.com/en-us/download/details.aspx?id=4511 */

EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'OptSeqKey'
GO
USE [master];
GO
DROP DATABASE IF EXISTS [OptSeqKey];
GO
CREATE DATABASE [OptSeqKey];
GO
USE [OptSeqKey];
GO 

DBCC FREEPROCCACHE

/*******************************************************************************
	create sample tables and  procedures
*******************************************************************************/
DROP TABLE IF EXISTS dbo.T1;
GO
CREATE TABLE dbo.T1(
	id BIGINT IDENTITY(1,1) NOT NULL,
	c1 SMALLINT NOT NULL,
	c2 BIGINT NOT NULL,
	c3 BIGINT NULL,
	c4 NVARCHAR(128) NOT NULL,
	c6 INT NOT NULL,
	c7 INT NOT NULL,
	c8 NVARCHAR(256) NULL,
	c10 NVARCHAR(50) NOT NULL,
	c11 VARCHAR(128) NOT NULL,
 CONSTRAINT PK_T1 PRIMARY KEY CLUSTERED (
	id ASC
)WITH (OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)  
)  
GO
DROP TABLE IF EXISTS dbo.T2;
GO
CREATE TABLE dbo.T2(
	id BIGINT IDENTITY(1,1) NOT NULL,
	c1 SMALLINT NOT NULL,
	c2 BIGINT NOT NULL,
	c3 BIGINT NULL,
	c4 NVARCHAR(128) NOT NULL,
	c6 INT NOT NULL,
	c7 INT NOT NULL,
	c8 NVARCHAR(256) NULL,
	c10 NVARCHAR(50) NOT NULL,
	c11 VARCHAR(128) NOT NULL,
 CONSTRAINT PK_T2 PRIMARY KEY CLUSTERED (
	id ASC
)WITH (OPTIMIZE_FOR_SEQUENTIAL_KEY = ON)  
)  
GO
--INSERT into a normal table
CREATE OR ALTER PROCEDURE dbo.InsertT1
AS
INSERT INTO dbo.T1 ( c1, c2, c3, c4, c6, c7, c8, c10, c11)
VALUES(2,56789,45454545,N'vfrtoglstenoPritzexYswc',3,3,N'wqew.jdkwqjfkewjkejr.ewewewew.DataAccess.tttwewesS.V2.ewwewew.ewew.ppewpeipw', N'kkk',N'xxxxxxxIdId: 2480918');
GO
--INSERT into an ooptimized table
CREATE OR ALTER PROCEDURE dbo.InsertT2
AS
INSERT INTO dbo.T2 ( c1, c2, c3, c4, c6, c7, c8, c10, c11)
VALUES(2,56789,45454545,N'vfrtoglstenoPritzexYswc',3,3,N'wqew.jdkwqjfkewjkejr.ewewewew.DataAccess.tttwewesS.V2.ewwewew.ewew.ppewpeipw', N'kkk',N'xxxxxxxIdId: 2480918');
GO

--call the InsertT1 Sp 50 times
CREATE OR ALTER PROCEDURE dbo.P1
AS
DECLARE @cnt INT = 0;
WHILE @cnt < 50
BEGIN
	EXEC dbo.InsertT1;
	SET @cnt+=1
END
GO

--call the InsertT2 Sp 50 times
CREATE OR ALTER PROCEDURE dbo.P2
AS
DECLARE @cnt INT = 0;
WHILE @cnt < 50
BEGIN
	EXEC dbo.InsertT2;
	SET @cnt+=1
END
GO

--turn on Query Store
ALTER DATABASE OptSeqKey SET QUERY_STORE =ON (INTERVAL_LENGTH_MINUTES = 5) ;
GO

-- stress test
-- CD "CD c:\Program Files (x86)\Microsoft Corporation\Database Experimentation Assistant\Dependencies\X64"
-- ostress.exe -E -dOptSeqKey -Q"EXEC dbo.P1" -MSSQLServer -r25 -n200 -q //////--11 sec, avg duration 9ms, avg wait time 8ms
-- ostress.exe -E -dOptSeqKey -Q"EXEC dbo.P2" -MSSQLServer -r25 -n200 -q //////--7 sec, avg duration 5ms, avg wait time 0,15ms

-- see avg duration
SELECT plan_id, runtime_stats_interval_id, count_executions, CAST(avg_duration AS INT) avg_duration
FROM sys.query_store_runtime_stats ORDER BY runtime_stats_interval_id, plan_id;

-- see Query Store "Query Wait Statistics"