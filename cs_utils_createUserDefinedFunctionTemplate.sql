/*****************************************************************************
** dbo.cs_utils_createUserDefinedFunctionTemplate
** user defined function
**
** Description
** Creates a skeleton user defined function
**
** Parameters
** @funcname = user defined function name
**
** Returned
** Text output of skeleton user defined function
**
** History
** 07/12/2012  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_utils_createUserDefinedFunctionTemplate', N'P' ) IS NOT NULL
    DROP PROCEDURE dbo.cs_utils_createUserDefinedFunctionTemplate;
GO
CREATE PROCEDURE dbo.cs_utils_createUserDefinedFunctionTemplate
	@funcname varchar(40)
AS
BEGIN

	SET NOCOUNT ON;

	PRINT '/*****************************************************************************';
	PRINT '** dbo.' + @funcname;
	PRINT '** user defined function';
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
	PRINT 'IF OBJECT_ID (N''dbo.' + @funcname + ''', N''FN'') IS NOT NULL';
	PRINT '    DROP FUNCTION dbo.' + @funcname + ';';
	PRINT 'GO';
	PRINT 'CREATE FUNCTION dbo.' + @funcname;
	PRINT '(';
	PRINT '	@param1 datatype1,';
	PRINT '	@param2 datatype2';
	PRINT ')';
	PRINT 'RETURNS datatype3';
	PRINT 'AS';

	PRINT 'BEGIN';
	PRINT CHAR(13) + CHAR(10);

	PRINT '	DECLARE @result datatype3;'
	PRINT CHAR(13) + CHAR(10);

	PRINT '	<statements>;'
	PRINT CHAR(13) + CHAR(10);

	PRINT '	RETURN (@result);'
	PRINT CHAR(13) + CHAR(10);

	PRINT 'END';
	PRINT 'GO ';

END
GO

/* execute dbo.cs_utils_createUserDefinedFunctionTemplate cs_utils_test */
