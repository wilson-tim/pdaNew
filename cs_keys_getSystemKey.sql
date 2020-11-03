/*****************************************************************************
** dbo.cs_keys_getSystemKey
** stored procedure
**
** Description
** Get a system key value for a given key and service
**
** Parameters
** @keyname   = keyname value
** @service_c = service_c value (optional)
**
** Returned
** Result set of system key data
** Return value of @@ROWCOUNT or -1
**
** History
** 17/01/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_keys_getSystemKey', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_keys_getSystemKey;
GO
CREATE PROCEDURE dbo.cs_keys_getSystemKey
	@keyname char(20),
	@service_c char(9) = NULL
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer;

	SET @errornumber = '12500';
	SET @keyname   = LTRIM(RTRIM(@keyname));
	SET @service_c = LTRIM(RTRIM(@service_c));

	/* @keyname validation */
	IF @keyname = '' OR @keyname IS NULL
	BEGIN
		SET @errornumber = '12501';
		SET @errortext = 'keyname is required';
		GOTO errorexit;
	END

	/* @service_c validation */
	IF @service_c = '' OR @service_c IS NULL
	BEGIN
		SET @service_c = 'ALL';
	END
	/*
	IF @service_c <> '' AND @service_c IS NOT NULL AND @service_c <> 'ALL'
	BEGIN
		SELECT pda_lookup.service_c_desc
			FROM pda_lookup
			WHERE pda_lookup.role_name =
				(
				SELECT keys.c_field
					FROM keys
					WHERE keys.service_c = 'ALL'
						AND keys.keyname = 'PDA_INSPECTOR_ROLE'
				)
			AND pda_lookup.service_c = @service_c;

		IF @@ROWCOUNT = 0
		BEGIN
			SET @errornumber = '12502';
			SET @errortext = @service_c + ' is not a valid service code';
			GOTO errorexit;
		END
	END
	*/

	SELECT service_c,
		keyname,
		keydesc,
		c_field,
		n_field,
		d_field
		FROM keys
		WHERE service_c = @service_c
			AND keyname = @keyname;

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
