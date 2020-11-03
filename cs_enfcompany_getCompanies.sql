/*****************************************************************************
** dbo.cs_enfcompany_getCompanies
** stored procedure
**
** Description
** [Enforcements] Selects a list of companies
**
** Parameters
** None
**
** Returned
** Result set of company data
** Return value of @@ROWCOUNT or -1
**
** History
** 15/03/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_enfcompany_getCompanies', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_enfcompany_getCompanies;
GO
CREATE PROCEDURE dbo.cs_enfcompany_getCompanies
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer;

	SET @errornumber = '10000';

	SELECT company_ref AS code,
		company_name AS [description]
		FROM enf_company
		WHERE company_name <> ''
			AND company_name IS NOT NULL
		ORDER BY company_name;

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
