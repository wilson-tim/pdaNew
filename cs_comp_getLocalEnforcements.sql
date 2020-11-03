/*****************************************************************************
** dbo.cs_comp_getLocalEnforcements
** stored procedure
**
** Description
** Selects a set of current Enforcement records
**
** Parameters
** @easting  = 6 digit decimal easting value, i.e. units of 1 metre
** @northing = 6 digit decimal northing value, i.e. units of 1 metre
** @radius   = distance in metres
**
** Returned
** Result set of Enforcement records
**
** History
** 26/02/2013  TW  New
** 29/05/2013  TW  Additional fly capture columns
** 30/05/2013  TW  Additional column action_flag_desc
** 07/06/2013  TW  Additional column priority_flag
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_comp_getLocalEnforcements', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comp_getLocalEnforcements;
GO
CREATE PROCEDURE dbo.cs_comp_getLocalEnforcements
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
		cs_comp_viewHistory.occur_day,
		cs_comp_viewHistory.round_c,
		cs_comp_viewHistory.pa_area,
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
		cs_comp_viewHistory.load_est_cost,

		cs_comp_viewEnfList.law_ref,
		cs_comp_viewEnfList.law_desc,
		cs_comp_viewEnfList.offence_ref,
		cs_comp_viewEnfList.offence_desc,
		cs_comp_viewEnfList.offence_datetime,
		cs_comp_viewEnfList.inv_officer,
		cs_comp_viewEnfList.inv_officer_desc,
		cs_comp_viewEnfList.enf_officer,
		cs_comp_viewEnfList.enf_officer_desc,
		cs_comp_viewEnfList.enf_status,
		cs_comp_viewEnfList.enf_status_desc,
		cs_comp_viewEnfList.suspect_ref,
		cs_comp_viewEnfList.suspect_name,
		cs_comp_viewEnfList.suspect_company,
		cs_comp_viewEnfList.actions,
		cs_comp_viewEnfList.action_seq,
		cs_comp_viewEnfList.action_ref,
		cs_comp_viewEnfList.action_desc,
		cs_comp_viewEnfList.action_notes,
		cs_comp_viewEnfList.car_id,
		cs_comp_viewEnfList.source_ref,
		cs_comp_viewEnfList.inv_period_start,
		cs_comp_viewEnfList.inv_period_finish,
		cs_comp_viewEnfList.agreement_no,
		cs_comp_viewEnfList.agreement_name,
		cs_comp_viewEnfList.site_name,
		cs_comp_viewEnfList.action_datetime,
		cs_comp_viewEnfList.fpcn,
		cs_comp_viewEnfList.do_date,
		cs_comp_viewEnfList.aut_officer,
		cs_comp_viewEnfList.aut_officer_desc,
		cs_comp_viewEnfList.[state],
		action_days_remaining = 
			/* Unexpired delay period? */
			CASE 
				WHEN DATEDIFF(day, CONVERT(datetime, CONVERT(date, GETDATE())), cs_comp_viewEnfList.do_date) > 0 THEN DATEDIFF(day, CONVERT(datetime, CONVERT(date, GETDATE())), cs_comp_viewEnfList.do_date)
				ELSE 0
			END

		FROM cs_comp_viewEnfList, cs_comp_viewHistory
		INNER JOIN site_detail
		ON site_detail.site_ref = cs_comp_viewHistory.site_ref
		WHERE  (cs_comp_viewEnfList.[state] = 'A' OR cs_comp_viewEnfList.[state] = 'P')
			AND (cs_comp_viewEnfList.action_flag = 'N')
			AND cs_comp_viewHistory.complaint_no = cs_comp_viewEnfList.complaint_no
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
		ORDER BY site_distance, cs_comp_viewEnfList.do_date, cs_comp_viewHistory.site_name_1;

END
GO 
