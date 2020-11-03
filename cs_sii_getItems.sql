/*****************************************************************************
** dbo.cs_sii_getItems
** stored procedure
**
** Description
** Selects a list of available site items
**
** Parameters
** @site_ref  = site reference
** @service_c = service code ('ALL' to return all service codes)
**
** Returned
** Result set of available site items with columns
**   site.item_ref             = item reference, char(12)
**   item.item_desc            = item description, char(40)
**   si_i.feature_ref          = feature ref, char(12)
**   feat.feature_desc         = feature description, char(40)
**   si_i.contract_ref         = contract ref, char(12)
**   cont.contract_name        = contract name, char(40)
**   item.service_c            = service code, char(6)
**   pda_lookup.service_c_desc = service description, char(40)
**   service_type              = service_type, char(30)
**   si_i.occur_day            = occur day mask, char(7)
**   si_i.occur_week           = occur week, char(10)
**   si_i.occur_month          = occur month, char(16)
**   si_i.round_c              = round code, char(10)
**   si_i.pa_area              = patrol area, char(6)
**   si_i.priority_flag        = priority flag, char(1)
**   si_i.volume               = volume, decimal(10,2)
**   si_i.date_due             = date due, date
**   item.item_type            = item type, char(6)
**   item.insp_item_flag       = inspection item flag Y / N, char(1)
** ordered by service_c, item_ref
**
** History
** 10/12/2012  TW  New
** 05/02/2013  TW  Need to pass username
** 04/03/2013  TW  Revised selection following testing
** 07/05/2013  TW  Additional column to return service_type
** 09/05/2013  TW  Revised 'DISTINCT' selection - should be distinct across
**                   item_ref, contract_ref, feature_ref, service_c
**                 Additional columns to return service code description
**                   and contract name
** 20/05/2013  TW  Improved selection process
**                 Correct filtering out of items relating to non-installed services
**                 Parameter @username is now obsolete and has been removed
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_sii_getItems', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_sii_getItems;
GO
CREATE PROCEDURE dbo.cs_sii_getItems
	@site_ref varchar(16),
	@service_c varchar(6)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @rowcount integer,
		@errornumber varchar(10),
		@errortext varchar(500);

	SET @errornumber = '13000';

	SET @site_ref = LTRIM(RTRIM(@site_ref));
	SET @service_c = LTRIM(RTRIM(@service_c));

	IF @site_ref = '' OR @site_ref IS NULL
	BEGIN
		SET @errornumber = '13001';
		SET @errortext = 'site_ref is required';
		GOTO errorexit;
	END

	IF @service_c = '' OR @service_c IS NULL
	BEGIN
		SET @errornumber = '13002';
		SET @errortext = 'service_c is required';
		GOTO errorexit;
	END

	IF @service_c = 'ALL'
	BEGIN
		/* 'ALL' services */
		SELECT item_ref,
			item_desc,
			feature_ref,
			feature_desc,
			contract_ref,
			[contract_name],
			service_c, 
			service_c_desc,
			service_type,
			occur_day,
			occur_week,
			occur_month,
			round_c,
			pa_area,
			priority_flag,
			volume,
			date_due,
			item_type,
			insp_item_flag
		FROM
			(
			SELECT si_i.item_ref,
				item.item_desc,
				si_i.feature_ref,
				feat.feature_desc,
				si_i.contract_ref,
				(SELECT [contract_name] FROM cont WHERE cont.contract_ref = si_i.contract_ref AND cont.service_c = item.service_c) AS [contract_name],
				item.service_c, 
				(SELECT TOP(1) pda_lookup.service_c_desc FROM pda_lookup WHERE pda_lookup.service_c = item.service_c AND pda_lookup.role_name = 'pda-in') AS service_c_desc,
				(dbo.cs_utils_getServiceType(item.service_c)) AS service_type,
				si_i.occur_day,
				si_i.occur_week,
				si_i.occur_month,
				si_i.round_c,
				si_i.pa_area,
				si_i.priority_flag,
				si_i.volume,
				si_i.date_due,
				item.item_type,
				item.insp_item_flag,
				ROW_NUMBER() OVER (PARTITION BY si_i.item_ref, si_i.feature_ref, si_i.contract_ref, item.service_c ORDER BY si_i.date_due DESC) AS rn
				FROM si_i         
				INNER JOIN item
				ON item.item_ref = si_i.item_ref
					AND item.contract_ref = si_i.contract_ref
					AND item.customer_care_yn = 'Y'
					AND dbo.cs_utils_getServiceType(item.service_c) <> 'TRADE'
				LEFT OUTER JOIN feat
				ON feat.feature_ref = si_i.feature_ref
				WHERE si_i.site_ref = @site_ref
			) AS innerselect
		WHERE rn = 1
			/* Filter services which are specifically licensed / installed */
			AND (service_type <> 'CORE' AND service_c IN
					(
					SELECT DISTINCT pda_lookup.service_c
						FROM pda_lookup
						LEFT OUTER JOIN keys keys2
						ON pda_lookup.service_c = keys2.c_field
							AND REVERSE(SUBSTRING(REVERSE(keys2.keyname), 1,  8)) = '_SERVICE'
							AND SUBSTRING(keys2.keyname, 1, 6) <> 'BV199_'
							AND CHARINDEX(keys2.keyname, ' ', 1) = 0
						INNER JOIN keys keys4
						ON keys4.service_c = pda_lookup.service_c
							AND keys4.keyname = 'HEADER'
						INNER JOIN modulelic
						ON ISNULL(LTRIM(RTRIM(modulelic.keyname)), 'CORE') = dbo.cs_utils_getField(keys2.keyname, '_', 1)
							AND dbo.cs_modulelic_getInstalled(LTRIM(RTRIM(modulelic.keyname))) = 1
						WHERE pda_lookup.role_name = 'pda-in'
					)
				)
			OR service_type = 'CORE'
		ORDER BY service_c, item_ref;

		SET @rowcount = @@ROWCOUNT;
	END
	ELSE
	BEGIN
		/* Specific service */
		SELECT item_ref,
			item_desc,
			feature_ref,
			feature_desc,
			contract_ref,
			[contract_name],
			service_c, 
			service_c_desc,
			service_type,
			occur_day,
			occur_week,
			occur_month,
			round_c,
			pa_area,
			priority_flag,
			volume,
			date_due,
			item_type,
			insp_item_flag
		FROM
			(
			SELECT si_i.item_ref,
				item.item_desc,
				si_i.feature_ref,
				feat.feature_desc,
				si_i.contract_ref,
				(SELECT [contract_name] FROM cont WHERE cont.contract_ref = si_i.contract_ref AND cont.service_c = item.service_c) AS [contract_name],
				item.service_c, 
				(SELECT TOP(1) pda_lookup.service_c_desc FROM pda_lookup WHERE pda_lookup.service_c = item.service_c AND pda_lookup.role_name = 'pda-in') AS service_c_desc,
				(dbo.cs_utils_getServiceType(item.service_c)) AS service_type,
				si_i.occur_day,
				si_i.occur_week,
				si_i.occur_month,
				si_i.round_c,
				si_i.pa_area,
				si_i.priority_flag,
				si_i.volume,
				si_i.date_due,
				item.item_type,
				item.insp_item_flag,
				ROW_NUMBER() OVER (PARTITION BY si_i.item_ref, si_i.feature_ref, si_i.contract_ref, item.service_c ORDER BY si_i.date_due DESC) AS rn
				FROM si_i         
				INNER JOIN item
				ON item.item_ref = si_i.item_ref
					AND item.contract_ref = si_i.contract_ref
					AND item.customer_care_yn = 'Y'
					AND item.service_c = @service_c
					AND dbo.cs_utils_getServiceType(item.service_c) <> 'TRADE'
				LEFT OUTER JOIN feat
				ON feat.feature_ref = si_i.feature_ref
				WHERE si_i.site_ref = @site_ref
			) AS innerselect
		WHERE rn = 1
			/* Filter services which are specifically licensed / installed */
			AND (service_type <> 'CORE' AND service_c IN
					(
					SELECT DISTINCT pda_lookup.service_c
						FROM pda_lookup
						LEFT OUTER JOIN keys keys2
						ON pda_lookup.service_c = keys2.c_field
							AND REVERSE(SUBSTRING(REVERSE(keys2.keyname), 1,  8)) = '_SERVICE'
							AND SUBSTRING(keys2.keyname, 1, 6) <> 'BV199_'
							AND CHARINDEX(keys2.keyname, ' ', 1) = 0
						INNER JOIN keys keys4
						ON keys4.service_c = pda_lookup.service_c
							AND keys4.keyname = 'HEADER'
						INNER JOIN modulelic
						ON ISNULL(LTRIM(RTRIM(modulelic.keyname)), 'CORE') = dbo.cs_utils_getField(keys2.keyname, '_', 1)
							AND dbo.cs_modulelic_getInstalled(LTRIM(RTRIM(modulelic.keyname))) = 1
						WHERE pda_lookup.role_name = 'pda-in'
					)
				)
			OR service_type = 'CORE'
		ORDER BY service_c, item_ref;

		SET @rowcount = @@ROWCOUNT;
	END

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
