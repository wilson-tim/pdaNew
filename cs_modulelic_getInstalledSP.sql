/*****************************************************************************
** dbo.cs_modulelic_getInstalledSP
** stored procedure
**
** Description
** Calculates the installation status of a given modulelic keyname
**
** Parameters
** @keyname   = modulelic keyname
**
** Returned
** @installed =  1 installed
**               0 not found/not installed
**              -1 expired
**              -2 null/incorrect checksum
**    integer
** Return value of 0 (success), or -1 (failure)
**
** History
** 27/02/2013  TW  New
** 24/07/2013  TW  modulelic.keyname is a char field and should be trimmed
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_modulelic_getInstalledSP', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_modulelic_getInstalledSP;
GO
CREATE PROCEDURE dbo.cs_modulelic_getInstalledSP
	@keyname varchar(500),
	@installed integer = 0 OUTPUT
AS
BEGIN
	DECLARE @exp_date datetime,
			@checkkey integer,
			@calccheckkey integer,
			@errornumber varchar(10),
			@errortext varchar(500);

	SET @errornumber = '12700';
	SET NOCOUNT ON;

	SET @keyname = LTRIM(RTRIM(@keyname));

	IF @keyname = '' OR @keyname IS NULL
	BEGIN
		SET @errornumber = '12701';
		SET @errortext = 'keyname is required';
		GOTO errorexit;
	END

	SET @installed = 1;

	IF @keyname = 'CORE'
	BEGIN
		GOTO normalexit;
	END

	IF @keyname <> '' AND @keyname IS NOT NULL AND @keyname <> 'CORE'
	BEGIN

		SELECT @exp_date = exp_date
			,@checkkey = checkkey
			FROM modulelic
			WHERE LTRIM(RTRIM(keyname)) = @keyname;

		IF @@ROWCOUNT < 1
		BEGIN
			/* Module not found */
			SET @installed = 0;
		END

		IF @installed = 1
		BEGIN
			/* Module not installed */
			IF @exp_date IS NULL
			BEGIN
				SET @installed = 0;
			END
		END

		IF @installed = 1
		BEGIN
			/* Module has expired */
			IF @exp_date < GETDATE()
			BEGIN
				SET @installed = -1;
			END
		END

		IF @installed = 1
		BEGIN
			/* Module failed checksum */
			IF @checkkey IS NULL
			BEGIN
				SET @installed = -2;
			END
		END

		IF @installed = 1
		BEGIN
			/* Module failed checksum */
			SET @calccheckkey = dbo.cs_modulelic_getCheckKey(@keyname, @exp_date);
			IF (@calccheckkey = -1) OR (@calccheckkey <> @checkkey)
			BEGIN
				SET @installed = -2;
			END
		END

	END

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO
