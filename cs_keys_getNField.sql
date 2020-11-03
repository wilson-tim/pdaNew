/*****************************************************************************
** dbo.cs_keys_getNField
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
** 28/01/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_keys_getNField', N'FN') IS NOT NULL
    DROP FUNCTION dbo.cs_keys_getNField;
GO
CREATE FUNCTION dbo.cs_keys_getNField
(
	@service_c char(9) = NULL,
	@keyname char(20)
)
RETURNS decimal(16,2)
AS
BEGIN

	DECLARE @n_field decimal(16,2),
		@rowcount integer;

	SET @service_c = LTRIM(RTRIM(@service_c));
	SET @keyname   = LTRIM(RTRIM(@keyname));

	IF @keyname IS NULL OR @keyname = ''
	BEGIN

		SET @n_field = NULL;

	END
	ELSE
	BEGIN

		IF @service_c = '' OR @service_c IS NULL
		BEGIN

			SELECT @n_field = n_field
				FROM keys
				WHERE keyname = @keyname;

			SET @rowcount = @@ROWCOUNT;

		END
		ELSE
		BEGIN

			SELECT @n_field = n_field
				FROM keys
				WHERE service_c = @service_c
					AND keyname = @keyname;

			SET @rowcount = @@ROWCOUNT;

		END

		IF @rowcount <> 1
		BEGIN

			SET @n_field = NULL;

		END

	END

	RETURN (@n_field);

END
GO 
