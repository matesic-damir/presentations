/* Accelerated Database Recovery */
/* Damir Mate�i� - https://blog.matesic.info */
/* ######################################### */

EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'ADR';
GO
USE [master];
GO
DROP DATABASE IF EXISTS [ADR];
GO
CREATE DATABASE [ADR];
GO
ALTER DATABASE [ADR] SET RECOVERY SIMPLE WITH NO_WAIT
GO
USE [ADR];
GO

SELECT * INTO dbo.TestADR 
FROM WideWorldImporters.Sales.Orders;
GO
INSERT INTO dbo.TestADR SELECT * FROM dbo.TestADR;
GO 5
-- 2 355 040 rows

--ensure that the ACCELERATED_DATABASE_RECOVERY feature is turned off
ALTER DATABASE [ADR] SET ACCELERATED_DATABASE_RECOVERY = OFF;
GO

--run the following two lines
BEGIN TRAN
INSERT INTO dbo.TestADR SELECT * FROM dbo.TestADR;
/* Result:
(2355040 rows affected)
it should take about 10 seconds
*/

--now run the ROLLBACK statement
ROLLBACK;
/* Result:
Commands completed successfully.
the ROLLBACK statement took about 2-3 seconds
*/

--now turn the ACCELERATED_DATABASE_RECOVERY flag on
--ansure that no other session in this database is active!!!
ALTER DATABASE [ADR] SET ACCELERATED_DATABASE_RECOVERY = ON;
GO

--run the following two lines
BEGIN TRAN
INSERT INTO dbo.TestADR SELECT * FROM dbo.TestADR;
/* Result:
(2355040 rows affected)
it should take about 20 seconds
*/

--now run the ROLLBACK statement
ROLLBACK;
/* Result:
Commands completed successfully.
the ROLLBACK is instantaneous!!!
*/

--cleanup
--ensure that you rollback all transactions
ROLLBACK;
/* Result:
Msg 3903, Level 16, State 1, Line 60
The ROLLBACK TRANSACTION request has no corresponding BEGIN TRANSACTION.
*/

DROP TABLE IF EXISTS dbo.TestADR;

EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'ADR';
GO
USE [master];
GO
DROP DATABASE IF EXISTS [ADR];
GO