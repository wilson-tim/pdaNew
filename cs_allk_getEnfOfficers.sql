/*****************************************************************************
** dbo.cs_allk_getEnfOfficers
** stored procedure
**
** Description
** [Enforcements] Selects a list of officers
**
** Parameters
** None
**
** Returned
** Result set of officer data
** Return value of @@ROWCOUNT or -1
**
** History
** 28/02/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_allk_getEnfOfficers', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_allk_getEnfOfficers;
GO
CREATE PROCEDURE dbo.cs_allk_getEnfOfficers
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer;

	SET @errornumber = '10000';
	SELECT DISTINCT po_code AS code,
		full_name AS [description]
        FROM pda_user
        WHERE po_code IN
			(
			SELECT lookup_code
				FROM allk
				WHERE lookup_func = 'ENFOFF'
					AND status_yn = 'Y'
			)
		ORDER BY full_name;

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
