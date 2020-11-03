/*****************************************************************************
** dbo.cs_contenderusers_logonUser
** stored procedure
**
** Description
** Process user log on
**
** Parameters
** @puser_name varchar(8)   required
** @ptimeout_value integer  required
**
** Returned
** Return value of 0 (success) or -1 (failure)
**
** History
** 10/05/2013  TW  New
** 30/05/2013  TW  Delete ALL expired records, delete all records for @user_name
** 11/06/2013  TW  Processing for additional column user_type
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_contenderusers_logonUser', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_contenderusers_logonUser;
GO
CREATE PROCEDURE dbo.cs_contenderusers_logonUser
	@puser_type varchar(12),
	@puser_name varchar(8),
	@ptimeout_value integer
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@user_type varchar(12),
		@user_name varchar(8),
		@timeout_value integer,
		@user_id integer,
		@result integer;

	SET @errornumber = '20420';

	SET @user_type = LTRIM(RTRIM(@puser_type));
	SET @user_name = LTRIM(RTRIM(@puser_name));
	SET @timeout_value = @ptimeout_value;

	IF @user_type = '' OR @user_type IS NULL
	BEGIN
		SET @errornumber = '20619';
		SET @errortext   = 'user_type is required';
		GOTO errorexit
	END

	IF @user_name = '' OR @user_name IS NULL
	BEGIN
		SET @errornumber = '20421';
		SET @errortext   = 'user_name is required';
		GOTO errorexit
	END

	IF @timeout_value = 0 OR @timeout_value IS NULL
	BEGIN
		SET @errornumber = '20422';
		SET @errortext   = 'timeout_value is required';
		GOTO errorexit
	END

	/* Delete ALL expired records */
	BEGIN TRY
		DELETE FROM ContenderUsers
			WHERE login_time < DATEADD(minute, -@timeout_value, GETDATE());
	END TRY
	BEGIN CATCH
		SET @errornumber = '20423';
		SET @errortext   = 'Error deleting ContenderUsers record(s)';
		GOTO errorexit
	END CATCH

	/* Delete all records for @user_type and @user_name */
	BEGIN TRY
		DELETE FROM ContenderUsers
			WHERE [user_type] = @user_type
				AND [user_name] = @user_name;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20493';
		SET @errortext   = 'Error deleting ContenderUsers record(s) for user_name ' + @user_name;
		GOTO errorexit
	END CATCH

	/* Insert new record */
	BEGIN TRY
		EXECUTE @result = dbo.cs_sno_getSerialNumber 'ContenderUsers', '', @serial_no = @user_id OUTPUT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20429';
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

	BEGIN TRY
		INSERT INTO ContenderUsers
			(
			[user_id],
			[user_type],
			[user_name],
			login_time
			)
			VALUES
			(
			@user_id,
			@user_type,
			@user_name,
			GETDATE()
			)
	END TRY
	BEGIN CATCH
		SET @errornumber = '20424';
		SET @errortext   = 'Error inserting ContenderUsers record';
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
