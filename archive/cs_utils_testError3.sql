/*****************************************************************************
** dbo.cs_utils_testError3
** stored procedure
**
** Description
** <description>
**
** Parameters
** <parameters>
**
** Returned
** <returned>
**
** History
** 20/12/2012  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_utils_testError3', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_utils_testError3;
GO
CREATE PROCEDURE dbo.cs_utils_testError3
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500);

	BEGIN TRY
	   SELECT convert(smallint, '2003121')
	END TRY
	BEGIN CATCH
		--PRINT 'errno: ' + ltrim(str(error_number()))
		--PRINT 'errmsg: ' + error_message()
		--RAISERROR('[cs_utils_testError3] Something really bad has happened', 16, 9);
		--RETURN -1;
		SET @errortext = 'Conversion error';
		SET @errortext = @errortext + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH
/*
	SELECT convert(smallint, '2003121')
	IF @@ERROR <> 0
	BEGIN
		--PRINT 'errno: ' + ltrim(str(error_number()))
		--PRINT 'errmsg: ' + error_message()
		RAISERROR('[cs_utils_testError3] Something really bad has happened', 16, 9);
		RETURN -1;
	END
*/
errorexit:

	SET @errortext = '[' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 

/*
declare @result integer;
execute @result = dbo.cs_utils_testError3
*/
