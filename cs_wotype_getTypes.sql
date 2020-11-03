/*****************************************************************************
** dbo.cs_wotype_getTypes
** stored procedure
**
** Description
** Selects a set of wo_type records for a given contract ref
**
** Parameters
** @contract_ref = contract ref
**
** Returned
** Result set of works order type data
** Return value of @@ROWCOUNT or -1
**
** History
** 15/01/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_wotype_getTypes', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_wotype_getTypes;
GO
CREATE PROCEDURE dbo.cs_wotype_getTypes
	@contract_ref varchar(12)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer;

	SET @errornumber = '14100';
	SET @contract_ref = LTRIM(RTRIM(@contract_ref));

	IF @contract_ref = '' OR @contract_ref IS NULL
	BEGIN
		SET @errornumber = '14101';
		SET @errortext = 'contract_ref is required';
		GOTO errorexit;
	END

	SELECT wo_type_f,
		wo_type_desc,
		contract_ref,
		wo_type_group
		FROM wo_type
		WHERE contract_ref = @contract_ref
		ORDER BY wo_type_f;

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
