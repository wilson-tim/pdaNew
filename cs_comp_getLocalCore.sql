/*****************************************************************************
** dbo.cs_comp_getLocalCore
** stored procedure
**
** Description
** Selects a set of current comp records for Core service
** within a given radius of a given location
**
** Parameters
** @easting  = 6 digit decimal easting value, i.e. units of 1 metre
** @northing = 6 digit decimal northing value, i.e. units of 1 metre
** @radius   = distance in metres
**
** Returned
** Result set of Core customer care data
**
** History
** 08/05/2013  TW  New
** 23/05/2013  TW  Additional fly capture columns
** 30/05/2013  TW  Additional column action_flag_desc
** 07/06/2013  TW  Additional column priority_flag
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_comp_getLocalCore', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comp_getLocalCore;
GO
CREATE PROCEDURE dbo.cs_comp_getLocalCore
	@peasting decimal(10,2),
	@pnorthing decimal(10,2),
	@pradius decimal(10,2)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500);

	DECLARE @easting_min decimal(10,2),
			@easting_max decimal(10,2),
			@northing_min decimal(10,2),
			@northing_max decimal(10,2),
			@easting decimal(10,2),
			@northing decimal(10,2),
			@radius decimal(10,2);

	SET @easting = @peasting;
	SET @northing = @pnorthing;
	SET @radius = @pradius;

	SET @easting_min = @easting - @radius;
	SET @easting_max = @easting + @radius;

	SET @northing_min = @northing - @radius;
	SET @northing_max = @northing + @radius;

	SELECT 
		cs_comp_viewHistory.complaint_no,
		cs_comp_viewHistory.entered_by,
		cs_comp_viewHistory.site_ref,
		cs_comp_viewHistory.site_name_1,
		cs_comp_viewHistory.exact_location,
		cs_comp_viewHistory.service_c,
		cs_comp_viewHistory.service_c_desc,
		cs_comp_viewHistory.comp_code,
		cs_comp_viewHistory.comp_code_desc,
		cs_comp_viewHistory.item_ref,
		cs_comp_viewHistory.item_desc,
		cs_comp_viewHistory.priority_flag,
		cs_comp_viewHistory.feature_ref,
		cs_comp_viewHistory.feature_desc,
		cs_comp_viewHistory.contract_ref,
		cs_comp_viewHistory.[contract_name],
		cs_comp_viewHistory.action_flag,
		cs_comp_viewHistory.action_flag_desc,
		dbo.cs_comptext_getNotes(cs_comp_viewHistory.complaint_no, 0) AS notes,
		cs_comp_viewHistory.compl_init,
		cs_comp_viewHistory.compl_name,
		cs_comp_viewHistory.compl_surname,
		cs_comp_viewHistory.compl_build_no,
		cs_comp_viewHistory.compl_build_name,
		cs_comp_viewHistory.compl_addr2,
		cs_comp_viewHistory.compl_addr4,
		cs_comp_viewHistory.compl_addr5,
		cs_comp_viewHistory.compl_addr6,
		cs_comp_viewHistory.compl_postcode,
		cs_comp_viewHistory.compl_phone,
		cs_comp_viewHistory.compl_email,
		cs_comp_viewHistory.compl_business,
		cs_comp_viewHistory.int_ext_flag,
		cs_comp_viewHistory.date_entered,
		cs_comp_viewHistory.ent_time_h,
		cs_comp_viewHistory.ent_time_m,
		cs_comp_viewHistory.dest_ref,
		cs_comp_viewHistory.dest_suffix,
		cs_comp_viewHistory.date_due,
		cs_comp_viewHistory.date_closed,
		cs_comp_viewHistory.incident_id,
		cs_comp_viewHistory.details_1,
		cs_comp_viewHistory.details_2,
		cs_comp_viewHistory.details_3,
		cs_comp_viewHistory.notice_type,
		ISNULL(CAST(SQRT( SQUARE(@easting - site_detail.easting) + SQUARE(@northing - site_detail.northing) ) AS DECIMAL (10,2)), 0) AS site_distance,
		cs_comp_viewHistory.flycap_record,
		cs_comp_viewHistory.landtype_ref,
		cs_comp_viewHistory.landtype_desc,
		cs_comp_viewHistory.dominant_waste_ref,
		cs_comp_viewHistory.dominant_waste_desc,
		cs_comp_viewHistory.dominant_waste_qty,
		cs_comp_viewHistory.load_ref,
		cs_comp_viewHistory.load_desc,
		cs_comp_viewHistory.load_qty,
		cs_comp_viewHistory.load_unit_cost,
		cs_comp_viewHistory.load_est_cost

		FROM cs_comp_viewHistory
		INNER JOIN site_detail
		ON site_detail.site_ref = cs_comp_viewHistory.site_ref
		WHERE dbo.cs_utils_getServiceType(cs_comp_viewHistory.service_c) = 'CORE'
			AND cs_comp_viewHistory.date_closed IS NULL
			AND cs_comp_viewHistory.site_ref IN
				/* Restrict to local site_refs */
				(
				SELECT site_detail.site_ref
					FROM [site]
					INNER JOIN site_detail
					ON site_detail.site_ref = [site].site_ref
					WHERE [site].site_status = 'L'
						AND
						(site_detail.easting BETWEEN @easting_min AND @easting_max
							OR ( (site_detail.easting_end BETWEEN @easting_min AND @easting_max) AND site_detail.easting_end IS NOT NULL ))
						AND (site_detail.northing BETWEEN @northing_min AND @northing_max
							OR ( (site_detail.northing_end BETWEEN @northing_min AND @northing_max) AND site_detail.northing_end IS NOT NULL ))
						AND ((SQRT( ( SQUARE(@easting - site_detail.easting) + SQUARE(@northing - site_detail.northing) ) ) <= @radius AND site_detail.easting IS NOT NULL AND site_detail.northing IS NOT NULL)
							OR ( SQRT( ( SQUARE(@easting - site_detail.easting_end) + SQUARE(@northing - site_detail.northing_end) ) ) <= @radius AND site_detail.easting_end IS NOT NULL AND site_detail.northing_end IS NOT NULL ))
				)
		ORDER BY site_distance, cs_comp_viewHistory.site_name_1;

END
GO 
