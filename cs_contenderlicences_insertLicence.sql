/*****************************************************************************
** dbo.cs_contenderlicences_insertLicence
** stored procedure
**
** Description
** Create a ContenderLicences record
**
** Parameters
** @pmodule varchar(12)       required
** @puser_type varchar(12)    required
** @pdescription varchar(200)
** @pexpiry_date datetime
** @pmax_users integer
** @ptoken varchar(32)        required
** @plicence varbinary(1000)  required
**
** Returned
** Return value of 0 (success) or -1 (failure)
**
** History
** 10/05/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_contenderlicences_insertLicence', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_contenderlicences_insertLicence;
GO
CREATE PROCEDURE dbo.cs_contenderlicences_insertLicence
	@pmodule varchar(12),
	@puser_type varchar(12),
	@pdescription varchar(200),
	@pexpiry_date datetime,
	@pmax_users integer,
	@ptoken varchar(32),
	@plicence varbinary(1000)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer,
		@module varchar(12),
		@user_type varchar(12),
		@description varchar(200),
		@expiry_date datetime,
		@max_users integer,
		@token varchar(32),
		@licence varbinary(1000);

	SET @errornumber = '20404';

	SET @module = LTRIM(RTRIM(@pmodule));
	SET @user_type = LTRIM(RTRIM(@puser_type));
	SET @description = LTRIM(RTRIM(@pdescription));
	SET @expiry_date = @pexpiry_date;
	SET @max_users = @pmax_users;
	SET @token = LTRIM(RTRIM(@ptoken));
	SET @licence = @plicence;

	IF @module = '' OR @module IS NULL
	BEGIN
		SET @errornumber = '20405';
		SET @errortext   = 'module is required';
		GOTO errorexit
	END

	IF @user_type = '' OR @user_type IS NULL
	BEGIN
		SET @errornumber = '20406';
		SET @errortext   = 'user_type is required';
		GOTO errorexit
	END

	IF @token = '' OR @token IS NULL
	BEGIN
		SET @errornumber = '20407';
		SET @errortext   = 'token is required';
		GOTO errorexit
	END

	IF LTRIM(RTRIM(CAST(@licence AS varchar(MAX)))) = '' OR @licence IS NULL
	BEGIN
		SET @errornumber = '20408';
		SET @errortext   = 'licence is required';
		GOTO errorexit
	END

	BEGIN TRY
		INSERT INTO ContenderLicences
			(
			module,
			user_type,
			[description],
			[expiry_date],
			max_users,
			token,
			licence
			)
			VALUES
			(
			@module,
			@user_type,
			@description,
			@expiry_date,
			@max_users,
			@token,
			@licence
			);
	END TRY
	BEGIN CATCH
		SET @errornumber = '20409';
		SET @errortext   = 'Error inserting ContenderLicences record';
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
