/*****************************************************************************
** dbo.cs_allk_getLaws
** stored procedure
**
** Description
** [Enforcements] Selects a list of laws
**
** Parameters
** None
**
** Returned
** Result set of laws data
** Return value of @@ROWCOUNT or -1
**
** History
** 28/02/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_allk_getLaws', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_allk_getLaws;
GO
CREATE PROCEDURE dbo.cs_allk_getLaws
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer;

	SET @errornumber = '10100';
	SELECT lookup_code AS code,
		lookup_text AS [description]
		FROM allk
		WHERE lookup_func = 'ENFLAW'
			AND status_yn = 'Y'
		ORDER BY lookup_text;

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
