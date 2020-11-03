/*****************************************************************************
** dbo.cs_allk_getEnfStatuses
** stored procedure
**
** Description
** [Enforcements] Selects a list of enforcement statuses for the specified
** enforcement action code
**
** Parameters
** @action_code = action code
**
** Returned
** Result set of enforcement status data
** Return value of @@ROWCOUNT or -1
**
** History
** 12/03/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_allk_getEnfStatuses', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_allk_getEnfStatuses;
GO
CREATE PROCEDURE dbo.cs_allk_getEnfStatuses
	@action_code varchar(6)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer;

	SET @errornumber = '20059';

	SET @action_code = LTRIM(RTRIM(@action_code));

	IF @action_code = '' OR @action_code IS NULL
	BEGIN
		SET @errornumber = '20060';
		SET @errortext = 'action_code is required';
		GOTO errorexit;
	END

	SELECT enfact_status_link.status_code AS code,
		allk.lookup_text AS [description],
		will_close =
			CASE
				WHEN (status_code = LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'ENF_COMPLETED'))) AND status_code <> '' AND status_code IS NOT NULL) THEN 1
				ELSE 0
			END
		FROM enfact_status_link,allk
		WHERE enfact_status_link.action_code = @action_code
			AND enfact_status_link.status_code = allk.lookup_code
			AND allk.lookup_func = 'ENFST';

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
