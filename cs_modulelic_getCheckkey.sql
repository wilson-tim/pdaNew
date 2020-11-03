/*****************************************************************************
** dbo.cs_modulelic_getCheckkey
** user defined function
**
** Description
** Calculate the checkkey value for a given modulelic keyname and expiry date
**
** Parameters
** @keyname  = module keyname
** @expdate  = expiry date
**
** Returned
** @checkkey = calculated checksum value, integer
**
** History
** 05/12/2012  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_modulelic_getCheckkey', N'FN') IS NOT NULL
    DROP FUNCTION dbo.cs_modulelic_getCheckkey;
GO
CREATE FUNCTION dbo.cs_modulelic_getCheckkey
(
	@keyname varchar(30),
	@expdate datetime
)
RETURNS integer
AS
BEGIN
	DECLARE @checkkey integer,
	        @loopvar  integer,
	        @sitekey  varchar(500),
			@asciino  integer;

	SET @keyname = LTRIM(RTRIM(@keyname));

	IF @keyname = '' OR @keyname IS NULL
	BEGIN
		RETURN(-1);
	END

	IF @expdate IS NULL
	BEGIN
		/* Expiry date is required for checkkey calculation */
		RETURN(-1);
	END
	ELSE
	BEGIN
		/* Number of days after 31/12/1899 (Informix date) */
		SET @checkkey = DATEDIFF(day, CAST('1899-12-31' AS DATETIME), @expdate);
	END

	/* Site identifier */
	SET @sitekey = LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'SITE_IDENT')));

	/* Shift site identifier */
	SET @loopvar = 0;
	WHILE @loopvar < LEN(@sitekey)
	BEGIN
		SET @loopvar = @loopvar + 1;
		SET @asciino = ASCII(SUBSTRING(@sitekey, @loopvar, 1));
		SET @checkkey = (@checkkey + (@asciino * @loopvar)) % 100000;
	END

	/* Shift module keyname */
	SET @loopvar = 0;
	WHILE @loopvar < LEN(@keyname)
	BEGIN
		SET @loopvar = @loopvar + 1;
		SET @asciino = ASCII(SUBSTRING(@keyname, @loopvar, 1));
		SET @checkkey = (@checkkey + (@asciino * @loopvar)) % 100000;
	END

	RETURN(@checkkey);
END
GO
