/*****************************************************************************
** dbo.cs_utils_createBuildFileList
** stored procedure
**
** Description
** Create build file list text file
**
** Parameters
** @filepath = filepath of build file list text file
**
** Returned
** Creates external build file list text file
**
** History
** 24/02/2013  TW  New
**
*****************************************************************************/
IF (OBJECT_ID('dbo.cs_utils_createBuildFileList') IS NOT NULL)
    DROP PROCEDURE dbo.cs_utils_createBuildFileList
GO
CREATE PROCEDURE dbo.cs_utils_createBuildFileList
	@filepath varchar(500)
AS
BEGIN
	DECLARE @sqlcmd varchar(1000);

/* To enable xp_cmdshell
	EXEC master.dbo.sp_configure 'show advanced options', 1
	RECONFIGURE
	EXEC master.dbo.sp_configure 'xp_cmdshell', 1
	RECONFIGURE
*/

	EXECUTE dbo.cs_utils_refreshAllObjects;

	SET @sqlcmd = 'BCP "EXECUTE welshdata.dbo.cs_utils_getDependencyOrder" queryout "' + @filepath + '" -T -c';

	EXECUTE xp_cmdshell @sqlcmd;
END
GO
