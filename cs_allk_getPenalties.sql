/*****************************************************************************
** dbo.cs_allk_getPenalties
** stored procedure
**
** Description
** [Enforcements] Selects a list of penalties
**
** Parameters
** None
**
** Returned
** Result set of penalties data
** Return value of @@ROWCOUNT or -1
**
** History
** 12/03/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_allk_getPenalties', N'P') IS NOT NULL
    DROP PROCEDURE cs_allk_getPenalties;
GO
CREATE PROCEDURE cs_allk_getPenalties
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer;

	SET @errornumber = '20031';

	SELECT lookup_code AS code,
		lookup_text AS [description]
		FROM allk
		WHERE lookup_func = 'ENFPEN'
			AND status_yn = 'Y';

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
