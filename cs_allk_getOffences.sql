/*****************************************************************************
** dbo.cs_allk_getOffences
** stored procedure
**
** Description
** [Enforcements] Selects a list of offences
**
** Parameters
** @law_code = law reference (if known)
**
** Returned
** Result set of offences data
** Return value of @@ROWCOUNT or -1
**
** History
** 28/02/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_allk_getOffences', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_allk_getOffences;
GO
CREATE PROCEDURE dbo.cs_allk_getOffences
	@law_code varchar(6)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer,
		@offence_law_link varchar(1);

	SET @errornumber = '10200';
	SET @offence_law_link = LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'OFFENCE>LAW LINK')));

	IF @offence_law_link = 'Y'
		AND (@law_code <> '' AND @law_code IS NOT NULL)
	BEGIN
		SELECT enf_law_offence.offence_ref AS code,
			enf_offence.offence_desc AS [description]
			FROM enf_law_offence, enf_offence
			WHERE enf_law_offence.law_ref = @law_code
				AND enf_law_offence.offence_ref = enf_offence.offence_ref;
	END
	ELSE
	BEGIN
		SELECT lookup_code AS code,
			lookup_text AS [description]
			FROM allk
			WHERE lookup_func = 'ENFDET'
				AND status_yn = 'Y'
			ORDER BY lookup_text;
	END

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
