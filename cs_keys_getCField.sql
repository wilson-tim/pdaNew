/*****************************************************************************
** dbo.cs_keys_getCField
** user defined function
**
** Description
** Get a system key value for a given service and key
**
** Parameters
** @service_c = service_c value (optional)
** @keyname   = keyname value
**
** Returned
** @c_field = system key value, char(500)
**
** History
** 07/12/2012  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_keys_getCField', N'FN') IS NOT NULL
    DROP FUNCTION dbo.cs_keys_getCField;
GO
CREATE FUNCTION dbo.cs_keys_getCField
(
	@service_c char(9) = NULL,
	@keyname char(20)
)
RETURNS char(500)
AS
BEGIN

	DECLARE @c_field char(500),
		@rowcount integer;

	SET @service_c = LTRIM(RTRIM(@service_c));
	SET @keyname   = LTRIM(RTRIM(@keyname));

	IF @keyname IS NULL OR @keyname = ''
	BEGIN

		SET @c_field = '';

	END
	ELSE
	BEGIN

		IF @service_c = '' OR @service_c IS NULL
		BEGIN

			SELECT @c_field = c_field
				FROM keys
				WHERE keyname = @keyname;

			SET @rowcount = @@ROWCOUNT;

		END
		ELSE
		BEGIN

			SELECT @c_field = c_field
				FROM keys
				WHERE service_c = @service_c
					AND keyname = @keyname;

			SET @rowcount = @@ROWCOUNT;

		END

		IF @rowcount <> 1
		BEGIN

			SET @c_field = '';

		END

	END

	RETURN (@c_field);

END
GO 
