/*****************************************************************************
** dbo.cs_utils_checkServiceType
** user defined function
**
** Description
** Check service type of a given service
**
** Parameters
** @service_c    = service code to be checked, varchar(6)
** @service_type = service type to check service code against, varchar(30)
**
** Returned
** @result = true or false, integer
**
** History
** 18/12/2012  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_utils_checkServiceType', N'FN') IS NOT NULL
    DROP FUNCTION dbo.cs_utils_checkServiceType;
GO
CREATE FUNCTION dbo.cs_utils_checkServiceType
(
	@service_c varchar(6),
	@service_type varchar(30)
)
RETURNS integer
AS
BEGIN
	
	DECLARE @result integer;

	/* Create temporary table */
	DECLARE @services AS TABLE
		(
			service_c varchar(6),
			service_c_desc varchar(40),
			service_type varchar(30),
			installed integer
		);

	SET @service_c    = RTRIM(LTRIM(@service_c));
	SET @service_type = RTRIM(LTRIM(@service_type));

	/* Cannot call cs_keys_getServices here so reproduce code instead */
	INSERT INTO @services
		SELECT DISTINCT pda_lookup.service_c, pda_lookup.service_c_desc,
		/*	keys2.keyname, */
			ISNULL(modulelic.keyname, 'CORE') AS service_type,
			dbo.cs_modulelic_getInstalled(modulelic.keyname) AS installed
			FROM pda_lookup
			/* Join services with configurable service names */
			LEFT OUTER JOIN keys keys2
			ON pda_lookup.service_c = keys2.c_field
				AND keys2.keyname LIKE '%_SERVICE'
				AND keys2.keyname NOT LIKE 'BV199_%'
				AND keys2.keyname NOT LIKE '% %'
			/* Join services which are specifically licensed / installed */
			LEFT OUTER JOIN modulelic
			ON modulelic.keyname = dbo.cs_utils_getField(keys2.keyname, '_', 1)
			/* Join services available to the current type of mobile user */
			LEFT OUTER JOIN keys keys3
			ON keys3.service_c = 'ALL'
				AND keys3.keyname = 'PDA_INSPECTOR_ROLE'
			WHERE pda_lookup.role_name = keys3.c_field
			ORDER BY pda_lookup.service_c;

	SELECT @result = COUNT(*)
		FROM @services
		WHERE RTRIM(LTRIM(service_c)) = @service_c
			AND RTRIM(LTRIM(service_type)) = @service_type;

	IF @result <> 1
	BEGIN
		SET @result = 0;
	END

	RETURN (@result);

END
GO
