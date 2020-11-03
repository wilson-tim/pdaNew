/*****************************************************************************
** dbo.cs_pdacoverlist_getOfficers
** stored procedure
**
** Description
** Selects all mobile officers and details of their availability and cover arrangements
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
IF OBJECT_ID (N'dbo.cs_pdacoverlist_getOfficers', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_pdacoverlist_getOfficers;
GO
CREATE PROCEDURE dbo.cs_pdacoverlist_getOfficers
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer;

	SELECT pda_cover_list.[user_name]
		,pda_user.full_name
		,available = 
			CASE
				WHEN pda_cover_list.[absent] = 'N' AND pda_cover_list.covered_by = pda_cover_list.[user_name] THEN 1
				ELSE 0
			END
		,cover_user_name = 
			CASE
				WHEN pda_cover_list.[absent] = 'N' AND pda_cover_list.covered_by = pda_cover_list.[user_name] THEN NULL
				ELSE pda_cover_list.covered_by
			END
		,cover_full_name = 
			CASE
				WHEN pda_cover_list.[absent] = 'N' AND pda_cover_list.covered_by = pda_cover_list.[user_name] THEN NULL
				ELSE cover.full_name
			END
		FROM pda_cover_list
		INNER JOIN pda_user
		ON pda_user.[user_name] = pda_cover_list.[user_name]
		LEFT OUTER JOIN pda_user cover
		ON cover.[user_name] = pda_cover_list.covered_by
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
