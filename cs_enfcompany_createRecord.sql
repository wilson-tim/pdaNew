/*****************************************************************************
** dbo.cs_enfcompany_createRecord
** stored procedure
**
** Description
** Create an enforcement company record
**
** Parameters
** @company_ref  = company reference (generated and returned by this SP)
** @company_name = company_name (required)
**
** Returned
** All passed parameters are INPUT and OUTPUT
** Return value of new company_ref or -1
**
** Notes
**
** History
** 14/03/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_enfcompany_createRecord', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_enfcompany_createRecord;
GO
CREATE PROCEDURE dbo.cs_enfcompany_createRecord
	@company_ref integer OUTPUT,
	@company_name varchar(50) = NULL
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @result integer
		,@errortext varchar(500)
		,@errornumber varchar(10);

	SET @errornumber = '20074';

	SET @company_name = UPPER(LTRIM(RTRIM(@company_name)));

	IF @company_name = '' OR @company_name IS NULL
	BEGIN
		SET @errornumber = '20075';
		SET @errortext = 'company_name is required';
		GOTO errorexit;
	END

	/* @company_ref */
	BEGIN TRY
		EXECUTE @result = dbo.cs_sno_getSerialNumber 'enf_company', '', @serial_no = @company_ref OUTPUT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20076';
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

	/*
	** enf_company table
	*/
	BEGIN TRY
		INSERT INTO enf_company
			(
			company_ref
			,company_name
			)
			VALUES
			(
			@company_ref
			,@company_name
			);
	END TRY
	BEGIN CATCH
		SET @errornumber = '20077';
		SET @errortext = 'Error inserting enf_company record';
		GOTO errorexit;
	END CATCH

normalexit:
	RETURN @company_ref;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO
