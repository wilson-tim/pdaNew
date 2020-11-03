/*****************************************************************************
** dbo.cs_contenderlicences_getLicence
** stored procedure
**
** Description
** Select a ContenderLicences record for a specified module and either user_type or token
**
** Parameters
** @pmodule      required
** @puser_type } either / or required
** @ptoken     }
**
** Returned
** Result set of ContenderLicences data
** Return value of @@ROWCOUNT or -1
**
** History
** 10/05/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_contenderlicences_getLicence', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_contenderlicences_getLicence;
GO
CREATE PROCEDURE dbo.cs_contenderlicences_getLicence
	@pmodule varchar(12),
	@puser_type varchar(12),
	@ptoken varchar(32)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer,
		@module varchar(12),
		@user_type varchar(12),
		@token varchar(32);

	SET @errornumber = '20401';

	SET @module = LTRIM(RTRIM(@pmodule));
	SET @user_type = LTRIM(RTRIM(@puser_type));
	SET @token = LTRIM(RTRIM(@ptoken));

	IF @module = '' OR @module IS NULL
	BEGIN
		SET @errornumber = '20402';
		SET @errortext   = 'module is required';
		GOTO errorexit
	END

	IF (@user_type = '' OR @user_type IS NULL)
		AND (@token = '' OR @token IS NULL)
	BEGIN
		SET @errornumber = '20403';
		SET @errortext   = 'either user_type or token is required';
		GOTO errorexit
	END

	SELECT module,
		user_type,
		[description],
		[expiry_date],
		max_users,
		token,
		licence
		FROM ContenderLicences
		WHERE module = @module
			AND
				(
				user_type = @user_type
				OR
				token = @token
				);

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
