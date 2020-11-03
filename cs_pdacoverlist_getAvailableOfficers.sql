/*****************************************************************************
** dbo.cs_pdacoverlist_getAvailableOfficers
** stored procedure
**
** Description
** Selects all available mobile officers
**
** Parameters
** None
**
** Returned
** Result set of officer data
** Return value of @@ROWCOUNT or -1
**
** History
** 12/07/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_pdacoverlist_getAvailableOfficers', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_pdacoverlist_getAvailableOfficers;
GO
CREATE PROCEDURE dbo.cs_pdacoverlist_getAvailableOfficers
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer;

	SELECT pda_cover_list.[user_name]
		,pda_user.full_name
		FROM pda_cover_list
		INNER JOIN pda_user
		ON pda_user.[user_name] = pda_cover_list.[user_name]
		WHERE pda_cover_list.[absent] = 'N'
			AND pda_cover_list.[user_name] = pda_cover_list.covered_by
		ORDER BY pda_user.full_name;

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO

