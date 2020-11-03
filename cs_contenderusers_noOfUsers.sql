/*****************************************************************************
** dbo.cs_contenderusers_noOfUsers
** stored procedure
**
** Description
** Determine the number of users' unexpired records
**
** Parameters
** @ptimeout_value integer  required
**
** Returned
** @user_count integer
** Return value of 0 (success) or -1 (failure)
**
** Notes
** Multiple logins are permitted so this simply determines the count of unexpired records
**
** History
** 10/05/2013  TW  New
** 11/06/2013  TW  Processing for additional column user_type
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_contenderusers_noOfUsers', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_contenderusers_noOfUsers;
GO
CREATE PROCEDURE dbo.cs_contenderusers_noOfUsers
	@puser_type varchar(12),
	@ptimeout_value integer,
	@user_count integer = 0 OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@timeout_value integer,
		@user_type varchar(12),
		@user_id integer;

	SET @errornumber = '20431';

	SET @user_type = LTRIM(RTRIM(@puser_type));
	SET @timeout_value = @ptimeout_value;

	IF @user_type = '' OR @user_type IS NULL
	BEGIN
		SET @errornumber = '20595';
		SET @errortext   = 'user_type is required';
		GOTO errorexit
	END

	IF @timeout_value = 0 OR @timeout_value IS NULL
	BEGIN
		SET @errornumber = '20432';
		SET @errortext   = 'timeout_value is required';
		GOTO errorexit
	END

	SELECT @user_count = COUNT(*)
		FROM ContenderUsers
		WHERE user_type = @user_type
			AND login_time >= DATEADD(minute, -@timeout_value, GETDATE());

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
