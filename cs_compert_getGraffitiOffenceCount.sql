/*****************************************************************************
** dbo.cs_compert_getGraffitiOffenceCount
** stored procedure
**
** Description
** Graffiti lookup - how many times has offence been committed
**
** Parameters
** None
**
** Returned
** Graffiti lookup - how many times has offence been committed
** Return value of @@ROWCOUNT or -1
**
** History
** 15/04/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_compert_getGraffitiOffenceCount', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_compert_getGraffitiOffenceCount;
GO
CREATE PROCEDURE dbo.cs_compert_getGraffitiOffenceCount
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer;

	SELECT lookup_code AS code, 
		lookup_text AS [description]
		FROM allk
		WHERE lookup_func = 'ERTNOO'
			AND status_yn = 'Y'
		ORDER BY lookup_code;

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
