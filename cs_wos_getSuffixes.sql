/*****************************************************************************
** dbo.cs_wos_getSuffixes
** stored procedure
**
** Description
** Selects a set of wo_s records for a given contract ref
**
** Parameters
** @contract_ref = contract ref
**
** Returned
** Result set of works order suffix data
** Return value of @@ROWCOUNT or -1
**
** Notes
** Ignoring defects and trees for the time being
**
** History
** 02/01/2013  TW  New
** 16/01/2013  TW  Additionally return wo_type_desc
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_wos_getSuffixes', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_wos_getSuffixes;
GO
CREATE PROCEDURE dbo.cs_wos_getSuffixes
	@contract_ref varchar(12)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer;

	SET @errornumber = '14000';
	SET @contract_ref = LTRIM(RTRIM(@contract_ref));

	IF @contract_ref = '' OR @contract_ref IS NULL
	BEGIN
		SET @errornumber = '14001';
		SET @errortext = 'contract_ref is required';
		GOTO errorexit;
	END

	SELECT wo_s.wo_suffix,
		wo_s.contract_ref,
		wo_s.wo_type_f,
		wo_type.wo_type_desc
		FROM wo_s
		LEFT OUTER JOIN wo_type
		ON wo_type.wo_type_f = wo_s.wo_type_f
			AND wo_type.contract_ref = wo_s.contract_ref
		WHERE wo_s.contract_ref = @contract_ref
		ORDER BY wo_s.wo_suffix;

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
