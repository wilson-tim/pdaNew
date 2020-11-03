/*****************************************************************************
** dbo.cs_pdauser_checkUserLogin
** stored procedure
**
** Description
** Validate user login credentials
**
** Parameters
** @user_name - user name
** @user_pass - user password hashed and hexed
**
** Returned
** @result - 1 for success, 0 for failure, -1 for an error state (smallint)
**
** History
** 08/01/2013  TW  New
** 02/07/2013  TW  Additionally check that the user logging in is not absent
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_pdauser_checkUserLogin', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_pdauser_checkUserLogin;
GO
CREATE PROCEDURE dbo.cs_pdauser_checkUserLogin
	@user_name varchar(15),
	@user_pass varchar(32)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @result smallint,
		@errornumber varchar(10),
		@errortext varchar(500);

	SET @errornumber = '12900';
	SET @result = 0;

	SET @user_name = LTRIM(RTRIM(@user_name));
	SET @user_pass = LTRIM(RTRIM(@user_pass));

	IF @user_name = '' OR @user_name IS NULL
	BEGIN
		SET @errornumber = '12901';
		SET @errortext = 'user_name is required';
		GOTO errorexit;
	END

	IF @user_pass = '' OR @user_pass IS NULL
	BEGIN
		SET @errornumber = '12902';
		SET @errortext = 'user_pass is required';
		GOTO errorexit;
	END

	SELECT @result = COUNT(*)
		FROM pda_user, pda_cover_list
		WHERE pda_user.[user_name] = @user_name
			AND pda_user.user_pass = @user_pass
			AND pda_cover_list.[user_name] = pda_user.[user_name]
			AND pda_cover_list.[absent] = 'N';

	IF @result <> 1
	BEGIN
		SET @result = 0;
	END
	
normalexit:
	RETURN @result;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
