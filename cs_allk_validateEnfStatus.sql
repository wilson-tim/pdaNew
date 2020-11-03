/*****************************************************************************
** dbo.cs_allk_validateEnfStatus
** stored procedure
**
** Description
** Validate enforcement action status
**
** Parameters
** @action_code = action code (required)
** @enf_status  = status code (required)
**
** Returned
** Return value of 1 (if successful), or 0
**
** History
** 19/03/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_allk_validateEnfStatus', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_allk_validateEnfStatus;
GO
CREATE PROCEDURE dbo.cs_allk_validateEnfStatus
	@action_code varchar(6),
	@enf_status varchar(6)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer;

	SET @errornumber = '20100';

	SET @action_code = LTRIM(RTRIM(@action_code));
	SET @enf_status = LTRIM(RTRIM(@enf_status));

	SELECT @rowcount = COUNT(*)
		FROM enfact_status_link,allk
		WHERE enfact_status_link.action_code = @action_code
			AND enfact_status_link.status_code = @enf_status
			AND enfact_status_link.status_code = allk.lookup_code
			AND allk.lookup_func = 'ENFST';

normalexit:
	IF @rowcount = 1
	BEGIN
		RETURN 1;
	END
	ELSE
	BEGIN
		RETURN 0;
	END

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
