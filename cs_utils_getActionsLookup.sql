/*****************************************************************************
** dbo.cs_utils_getActionsLookup
** stored procedure
**
** Description
** Display action flag lookup
**
** Parameters
**
** Returned
** Result set of action flags
**   code        = action code, char(1)
**   description = action code description, char(40)
** Return value of @@ROWCOUNT or -1
**
** History
** 28/03/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_utils_getActionsLookup', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_utils_getActionsLookup;
GO
CREATE PROCEDURE dbo.cs_utils_getActionsLookup
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer,
		@def_name_noun varchar(40);

	SET @errornumber = '20176';

	SET @def_name_noun = dbo.cs_keys_getCField('PDAINI', 'DEF_NAME_NOUN');

	SELECT DISTINCT action_flag AS action_code,
		action_desc = 
			CASE
				WHEN action_flag = 'A' THEN 'Auto ' + @def_name_noun
				WHEN action_flag = 'D' THEN @def_name_noun
				WHEN action_flag = 'E' THEN 'Enforcement'
				WHEN action_flag = 'H' THEN 'Hold'
				WHEN action_flag = 'I' THEN 'Inspect'
				WHEN action_flag = 'P' THEN 'Pending'
				WHEN action_flag = 'N' THEN 'No Action'
				WHEN action_flag = 'W' THEN 'Works Order'
				WHEN action_flag = 'X' THEN 'Express Works Order'
			END,
		NULL as default_flag,
		NULL as display_order
		FROM comp
		WHERE date_closed IS NOT NULL
			AND action_flag IN ('A','D','E','H','I','P','N','W', 'X')
		ORDER BY action_flag;

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO
