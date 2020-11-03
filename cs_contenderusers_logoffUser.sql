/*****************************************************************************
** dbo.cs_contenderusers_logoffUser
** stored procedure
**
** Description
** Process user log off
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
** 30/05/2013  TW  Delete ALL expired records
** 11/06/2013  TW  Delete all records for user_name, not just oldest non-expired record
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_contenderusers_logoffUser', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_contenderusers_logoffUser;
GO
CREATE PROCEDURE dbo.cs_contenderusers_logoffUser
	@puser_name varchar(8),
	@ptimeout_value integer
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@user_name varchar(8),
		@timeout_value integer,
		@user_id integer;

	SET @errornumber = '20425';

	SET @user_name = LTRIM(RTRIM(@puser_name));
	SET @timeout_value = @ptimeout_value;

	IF @user_name = '' OR @user_name IS NULL
	BEGIN
		SET @errornumber = '20426';
		SET @errortext   = 'user_name is required';
		GOTO errorexit
	END

	IF @timeout_value = 0 OR @timeout_value IS NULL
	BEGIN
		SET @errornumber = '20427';
		SET @errortext   = 'timeout_value is required';
		GOTO errorexit
	END

	/* Delete ALL expired records */
	BEGIN TRY
		DELETE FROM ContenderUsers
			WHERE login_time < DATEADD(minute, -@timeout_value, GETDATE());
	END TRY
	BEGIN CATCH
		SET @errornumber = '20428';
		SET @errortext   = 'Error deleting ContenderUsers record(s)';
		GOTO errorexit
	END CATCH

	/* Delete all records for @user_name */
	BEGIN TRY
		DELETE FROM ContenderUsers
			WHERE [user_name] = @user_name;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20430';
		SET @errortext   = 'Error deleting ContenderUsers record(s)';
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
