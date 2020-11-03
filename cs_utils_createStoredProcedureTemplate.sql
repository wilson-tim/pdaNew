/*****************************************************************************
** dbo.cs_utils_createStoredProcedureTemplate
** stored procedure
**
** Description
** Creates a skeleton stored procedure
**
** Parameters
** @procname = stored procedure name
**
** Returned
** Text output of skeleton stored procedure
**
** History
** 07/12/2012  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_utils_createStoredProcedureTemplate', N'P' ) IS NOT NULL
    DROP PROCEDURE dbo.cs_utils_createStoredProcedureTemplate;
GO
CREATE PROCEDURE dbo.cs_utils_createStoredProcedureTemplate
	@procname varchar(40)
AS
BEGIN

	SET NOCOUNT ON;

	PRINT '/*****************************************************************************';
	PRINT '** dbo.' + @procname;
	PRINT '** stored procedure';
	PRINT '**';
	PRINT '** Description';
	PRINT '** <description>';
	PRINT '**';
	PRINT '** Parameters';
	PRINT '** <parameters>';
	PRINT '**';
	PRINT '** Returned';
	PRINT '** <returned>';
	PRINT '**';
	PRINT '** History';
	PRINT '** ' + LTRIM(RTRIM(CONVERT(varchar(10), GETDATE(), 103))) + '  TW  New';
	PRINT '**';
	PRINT '*****************************************************************************/';
	PRINT 'IF OBJECT_ID (N''dbo.' + @procname + ''', N''P'') IS NOT NULL';
	PRINT '    DROP PROCEDURE dbo.' + @procname + ';';
	PRINT 'GO';
	PRINT 'CREATE PROCEDURE dbo.' + @procname;
	PRINT '	@param1 datatype1,';
	PRINT '	@param2 datatype2';
	PRINT 'AS';

	PRINT 'BEGIN';
	PRINT CHAR(13) + CHAR(10);

	PRINT '	SET NOCOUNT ON;'
	PRINT CHAR(13) + CHAR(10);

	PRINT '	DECLARE @errortext varchar(500),'
	PRINT '		@errornumber varchar(10);'
	PRINT CHAR(13) + CHAR(10);

	PRINT '	<statements>;'
	PRINT CHAR(13) + CHAR(10);

	PRINT 'normalexit:'
	PRINT '	RETURN 0;'
	PRINT CHAR(13) + CHAR(10);

	PRINT 'errorexit:'
	PRINT '	SET @errortext = ''['' + @errornumber + '']['' + OBJECT_NAME(@@PROCID) + ''] '' + @errortext;'
	PRINT '	RAISERROR(@errortext, 16, 9);'
	PRINT '	RETURN -1;'
	PRINT CHAR(13) + CHAR(10);

	PRINT 'END';
	PRINT 'GO ';

END
GO

/* execute dbo.cs_utils_createStoredProcedureTemplate cs_utils_test */
