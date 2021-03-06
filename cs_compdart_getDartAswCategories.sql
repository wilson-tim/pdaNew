/*****************************************************************************
** dbo.cs_compdart_getDartAswCategories
** stored procedure
**
** Description
** DART lookup - anti-social waste
**
** Parameters
** None
**
** Returned
** DART lookup - anti-social waste
** Return value of @@ROWCOUNT or -1
**
** History
** 26/04/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_compdart_getDartAswCategories', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_compdart_getDartAswCategories;
GO
CREATE PROCEDURE dbo.cs_compdart_getDartAswCategories
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer;

	SELECT lookup_code AS code, 
		lookup_text AS [description]
		FROM allk
		WHERE lookup_func = 'DRTASW'
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
