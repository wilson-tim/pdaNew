/*****************************************************************************
** dbo.cs_allk_getJudgements
** stored procedure
**
** Description
** [Enforcements] Selects a list of judgements
**
** Parameters
** None
**
** Returned
** Result set of judgements data
** Return value of @@ROWCOUNT or -1
**
** History
** 12/03/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_allk_getJudgements', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_allk_getJudgements;
GO
CREATE PROCEDURE dbo.cs_allk_getJudgements
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer;

	SET @errornumber = '20030';

	SELECT lookup_code AS code,
		lookup_text AS [description]
		FROM allk
		WHERE lookup_func = 'ENFPJ'
			AND status_yn = 'Y'
			AND lookup_code in ('G','N');

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
