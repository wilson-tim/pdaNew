/*****************************************************************************
** dbo.cs_utils_getServiceType
** user defined function
**
** Description
** Check service type of a given service
**
** Parameters
** @service_c    = service code to be checked, varchar(6)
**
** Returned
** @result = service type code
**
** History
** 07/01/2013  TW  New
** 22/01/2013  TW  pda_lookup.role_name = 'pda-in'
** 10/07/2013  TW  No longer using a temporary table
** 23/07/2013  TW  modulic.keyname is a char field and should be trimmed
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_utils_getServiceType', N'FN') IS NOT NULL
    DROP FUNCTION dbo.cs_utils_getServiceType;
GO
CREATE FUNCTION dbo.cs_utils_getServiceType
(
	@service_c varchar(6)
)
RETURNS varchar(30)
AS
BEGIN
	
	DECLARE @result varchar(30);

	SET @service_c = LTRIM(RTRIM(@service_c));

	/* Cannot call cs_keys_getServices here so reproduce code instead */
	SELECT @result = service_type
		FROM
		(
		SELECT 
			DISTINCT pda_lookup.service_c,
			ISNULL(LTRIM(RTRIM(modulelic.keyname)), 'CORE') AS service_type
			FROM pda_lookup
			/* Join services with configurable service names */
			LEFT OUTER JOIN keys keys2
			ON pda_lookup.service_c = keys2.c_field
				AND keys2.keyname LIKE '%_SERVICE'
				AND keys2.keyname NOT LIKE 'BV199_%'
				AND keys2.keyname NOT LIKE '% %'
			/* Join services which are specifically licensed / installed */
			LEFT OUTER JOIN modulelic
			ON ISNULL(LTRIM(RTRIM(modulelic.keyname)), 'CORE') = dbo.cs_utils_getField(keys2.keyname, '_', 1)
			/* Join services available to the current type of mobile user */
			/*
			LEFT OUTER JOIN keys keys3
			ON keys3.service_c = 'ALL'
				AND keys3.keyname = 'PDA_INSPECTOR_ROLE'
			WHERE pda_lookup.role_name = keys3.c_field;
			*/
			WHERE pda_lookup.role_name = 'pda-in'
		) servicetypes
		WHERE servicetypes.service_c = @service_c;

	SET @result = ISNULL(@result, '');

	RETURN (@result);

END
GO
