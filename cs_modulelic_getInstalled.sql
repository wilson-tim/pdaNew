/*****************************************************************************
** dbo.cs_modulelic_getInstalled
** user defined function
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
**
** History
** 05/12/2012  TW  New
** 24/07/2013  TW  modulelic.keyname is a char field and should be trimmed
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_modulelic_getInstalled', N'FN') IS NOT NULL
    DROP FUNCTION dbo.cs_modulelic_getInstalled;
GO
CREATE FUNCTION dbo.cs_modulelic_getInstalled
(
	@keyname varchar(500)
)
RETURNS integer
AS
BEGIN
	DECLARE @installed integer,
			@exp_date datetime,
			@checkkey integer,
			@calccheckkey integer;

	SET @keyname = LTRIM(RTRIM(@keyname));

	/* if @keyname is NULL then this is a CORE item and is installed */
	SET @installed = 1;

	IF @keyname <> '' AND @keyname IS NOT NULL
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

	RETURN (@installed);
END
GO
