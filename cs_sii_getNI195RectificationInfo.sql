/*****************************************************************************
** dbo.cs_sii_getNI195RectificationInfo
** stored procedure
**
** Description
** [NI195] Get the required information for creating a rectification
**
** Parameters (all compulsory)
** @psite_ref varchar(16) = site reference
** @pcategory varchar(10) = category ('LITTER', 'DETRITUS', 'GRAFFITI', 'FLYPOSTING')
**
** Returned
** Result set of the initial required information for creating a rectification
** Return value of rowcount (success), or -1 (failure)
**
** History
** 13/05/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_sii_getNI195RectificationInfo', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_sii_getNI195RectificationInfo;
GO
CREATE PROCEDURE dbo.cs_sii_getNI195RectificationInfo
	@psite_ref varchar(16),
	@pcategory varchar(10)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@site_ref varchar(16),
		@category varchar(10),
		@keyscategory varchar(10),
		@rowcount integer;

	SET @errornumber = '20449';

	SET @site_ref = LTRIM(RTRIM(@psite_ref));
	SET @category = LTRIM(RTRIM(@pcategory));

	IF @site_ref = '' OR @site_ref IS NULL
	BEGIN
		SET @errornumber = '20450';
		SET @errortext   = 'site_ref is required';
		GOTO errorexit;
	END

	IF @category = '' OR @category IS NULL
	BEGIN
		SET @errornumber = '20451';
		SET @errortext = 'category is required';
		GOTO errorexit;
	END

	SET @keyscategory =
		CASE
			WHEN @category = 'LITTER' THEN 'LITTER'
			WHEN @category = 'DETRITUS' THEN 'DETRIT'
			WHEN @category = 'GRAFFITI' THEN 'GRAFF'
			WHEN @category = 'FLYPOSTING' THEN 'FLYPOS'
			ELSE NULL
		END;

	IF @keyscategory = '' OR @keyscategory IS NULL
	BEGIN
		SET @errornumber = '20452';
		SET @errortext = 'category ''' + @category + ''' is not valid';
		GOTO errorexit;
	END

	SET @rowcount = @@ROWCOUNT;

	SELECT DISTINCT si_i.item_ref,
		joineditem.item_desc,
		si_i.feature_ref, 
		feat.feature_desc,
		si_i.contract_ref,
		(SELECT [contract_name] FROM cont WHERE cont.contract_ref = si_i.contract_ref AND cont.service_c = joineditem.service_c) AS [contract_name],
		joineditem.service_c, 
		(SELECT TOP(1) pda_lookup.service_c_desc FROM pda_lookup WHERE pda_lookup.service_c = joineditem.service_c AND pda_lookup.role_name = 'pda-in') AS service_c_desc,
		(dbo.cs_utils_getServiceType(joineditem.service_c)) AS service_type,
		si_i.occur_day,
		si_i.occur_week,
		si_i.occur_month,
		si_i.round_c,
		si_i.pa_area,
		si_i.priority_flag,
		si_i.volume,
		si_i.date_due,
		joineditem.item_type,
		joineditem.insp_item_flag
		FROM si_i
		INNER JOIN item joineditem
		ON joineditem.item_ref = si_i.item_ref
			AND joineditem.contract_ref = si_i.contract_ref
			AND joineditem.customer_care_yn = 'Y'
		LEFT OUTER JOIN feat
		ON feat.feature_ref = si_i.feature_ref
		WHERE si_i.site_ref = @site_ref
			AND si_i.item_ref IN
				(
				SELECT item_ref
					FROM item
					WHERE bv199_type =
						(
						SELECT c_field
							FROM keys
							WHERE keyname = 'BV199_' + @keyscategory + '_TYPE'
						)
				);

	IF @rowcount > 1
	BEGIN
		SET @errornumber = '20459';
		SET @errortext = 'Multiple item records found, please check site item configuration';
		GOTO errorexit;
	END

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
