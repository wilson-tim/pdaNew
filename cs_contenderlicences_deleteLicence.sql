/*****************************************************************************
** dbo.cs_contenderlicences_deleteLicence
** stored procedure
**
** Description
** Delete a ContenderLicences record
**
** Parameters
** @pmodule varchar(12)       required
** @puser_type varchar(12)    required
**
** Returned
** Return value of 0 (success) or -1 (failure)
**
** History
** 10/05/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_contenderlicences_deleteLicence', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_contenderlicences_deleteLicence;
GO
CREATE PROCEDURE dbo.cs_contenderlicences_deleteLicence
	@pmodule varchar(12),
	@puser_type varchar(12)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer,
		@module varchar(12),
		@user_type varchar(12),
		@token varchar(32);

	SET @errornumber = '20416';

	SET @module = LTRIM(RTRIM(@pmodule));
	SET @user_type = LTRIM(RTRIM(@puser_type));

	IF @module = '' OR @module IS NULL
	BEGIN
		SET @errornumber = '20417';
		SET @errortext   = 'module is required';
		GOTO errorexit
	END

	IF @user_type = '' OR @user_type IS NULL
	BEGIN
		SET @errornumber = '20418';
		SET @errortext   = 'user_type is required';
		GOTO errorexit
	END

	BEGIN TRY
		DELETE FROM ContenderLicences
			WHERE module = @module
				AND user_type = @user_type;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20419';
		SET @errortext   = 'Error deleting ContenderLicences record';
		GOTO errorexit
	END CATCH

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
