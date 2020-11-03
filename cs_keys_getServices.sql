/*****************************************************************************
** dbo.cs_keys_getServices
** stored procedure
**
** Description
** Selects a list of available services
**
** Parameters
** @user_name = login id
** @service_c = service code (optional)
**
** Returned
** Result set of available services with columns
**   service_c, char(6)
**   service_c_desc, char(40)
**   service_type, char(30)
**   installed = 1 installed, 0 not found/not installed, -1 expired, -2 null/incorrect checksum
**     integer
** ordered by service_c
** Return value of @@ROWCOUNT or -1
**
** Notes
** location_search_type A=all, P=properties, S=streets and street sections
**
** History
** 05/12/2012  TW  New
** 22/01/2013  TW  pda_lookup.role_name = 'pda-in'
** 17/03/2013  TW  Additional column location_search_type
** 21/03/2013  TW  Additional parameter @user_name
** 27/03/2013  TW  Additional parameter @service_c
** 24/07/2013  TW  modulelic.keyname is a char field and should be trimmed
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_keys_getServices', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_keys_getServices;
GO
CREATE PROCEDURE dbo.cs_keys_getServices
	@user_name varchar(8),
	@service_c varchar(6) = NULL
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @rowcount integer,
		@errornumber varchar(10),
		@errortext varchar(500);

	SET @errornumber = '12400';

	SET @user_name = LTRIM(RTRIM(@user_name));
	SET @service_c = LTRIM(RTRIM(@service_c));

	IF @user_name = '' OR @user_name IS NULL
	BEGIN
		SET @errornumber = '20131';
		SET @errortext   = 'user_name is required';
		GOTO errorexit;
	END

	SELECT DISTINCT pda_lookup.service_c,
		pda_lookup.service_c_desc,
		/*	keys2.keyname, */
		ISNULL(LTRIM(RTRIM(modulelic.keyname)), 'CORE') AS service_type,
		dbo.cs_modulelic_getInstalled(LTRIM(RTRIM(modulelic.keyname))) AS installed,
		keys4.c_field AS location_search_type
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
		WHERE pda_lookup.role_name = keys3.c_field
		*/
		INNER JOIN keys keys4
		ON keys4.service_c = pda_lookup.service_c
			AND keys4.keyname = 'HEADER'
		WHERE pda_lookup.role_name = 'pda-in'
			AND (
				(ISNULL(LTRIM(RTRIM(modulelic.keyname)), 'CORE') = 'ENF' AND dbo.cs_pdauser_getEnfOfficerPoCode(@user_name) IS NOT NULL)
				OR
				(ISNULL(LTRIM(RTRIM(modulelic.keyname)), 'CORE') <> 'ENF')
				OR
				(ISNULL(LTRIM(RTRIM(modulelic.keyname)), 'CORE') = '')
				OR
				(modulelic.keyname IS NULL)
				)
			AND (
				(@service_c <> '' AND @service_c IS NOT NULL AND LTRIM(RTRIM(pda_lookup.service_c)) = @service_c)
				OR
				(@service_c = '' OR @service_c IS NULL)
				)
		ORDER BY pda_lookup.service_c;

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO
