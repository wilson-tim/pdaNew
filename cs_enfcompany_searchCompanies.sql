/*****************************************************************************
** dbo.cs_enfcompany_searchCompanies
** stored procedure
**
** Description
** Selects a set of enforcements company records using company name search data
**
** Parameters
** @company_name = company_name search data
**
** Returned
** Result set of enforcements company data
**
** Notes
**
** History
** 15/03/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_enfcompany_searchCompanies', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_enfcompany_searchCompanies;
GO
CREATE PROCEDURE dbo.cs_enfcompany_searchCompanies
	@company_name varchar(50) = NULL
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10);

	SET @errornumber = '20078';

	SET @company_name = LTRIM(RTRIM(@company_name));

	IF @company_name = '' OR @company_name IS NULL
	BEGIN
		SET @errornumber = '20079';
		SET @errortext = 'No search parameters were passed';
		GOTO errorexit;
	END

	BEGIN TRY
		SELECT company_ref AS code,
			company_name AS [description]
			FROM enf_company
			WHERE company_name LIKE @company_name + '%';
	END TRY
	BEGIN CATCH
		SET @errornumber = '20080';
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
