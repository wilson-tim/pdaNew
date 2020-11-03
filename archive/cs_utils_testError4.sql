/*****************************************************************************
** dbo.cs_utils_testError4
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
IF OBJECT_ID (N'dbo.cs_utils_testError4', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_utils_testError4;
GO
CREATE PROCEDURE dbo.cs_utils_testError4
AS
BEGIN

	SET NOCOUNT ON;

DECLARE @result integer,
	@errortext varchar(500);
/*
	EXECUTE @result = dbo.cs_utils_testError3
	-- PRINT STR(@result);
	IF @result < 0
	BEGIN
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END
*/
	BEGIN TRY
		EXECUTE @result = dbo.cs_utils_testError3
	END TRY
	BEGIN CATCH
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

normalexit:
	RETURN 0

errorexit:
	SET @errortext = '[' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1

END
GO

/*
declare @result integer;
execute @result = dbo.cs_utils_testError4
*/
