/*****************************************************************************
** dbo.cs_comp_getLocalDart
** stored procedure
**
** Description
** Selects a set of current comp records for DART service
** within a given radius of a given location
**
** Parameters
** @easting  = 6 digit decimal easting value, i.e. units of 1 metre
** @northing = 6 digit decimal northing value, i.e. units of 1 metre
** @radius   = distance in metres
**
** Returned
** Result set of DART customer care data
**
** History
** 26/04/2013  TW  New
** 23/05/2013  TW  Additional fly capture columns
** 30/05/2013  TW  Additional column action_flag_desc
** 07/06/2013  TW  Additional column priority_flag
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_comp_getLocalDart', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comp_getLocalDart;
GO
CREATE PROCEDURE dbo.cs_comp_getLocalDart
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
		NULL AS flycap_record,
		NULL AS landtype_ref,
		NULL AS landtype_desc,
		NULL AS dominant_waste_ref,
		NULL AS dominant_waste_desc,
		NULL AS dominant_waste_qty,
		NULL AS load_ref,
		NULL AS load_desc,
		NULL AS load_qty,
		NULL AS load_unit_cost,
		NULL AS load_est_cost,

		comp_dart_header.rep_needle_qty,
		comp_dart_header.rep_crack_pipe_qty,
		comp_dart_header.rep_condom_qty,
		comp_dart_header.col_needle_qty,
		comp_dart_header.col_crack_pipe_qty,
		comp_dart_header.col_condom_qty,
		comp_dart_header.wo_est_cost,
		comp_dart_header.po_code,
		comp_dart_header.completion_date,
		comp_dart_header.completion_time_h,
		comp_dart_header.completion_time_m,
		DATEADD(minute, CAST(ISNULL(comp_dart_header.est_duration_h, 0) AS integer),
			DATEADD(hour,   CAST(ISNULL(comp_dart_header.est_duration_m, 0) AS integer),
			DATEADD(day,    DATEPART(day,   0) - 1, 
			DATEADD(month,  DATEPART(month, 0) - 1, 
			DATEADD(year,   DATEPART(year,  0) - 1900, 0))))) AS est_duration_date,
		comp_dart_header.est_duration_h,
		comp_dart_header.est_duration_m,
		comp_dart_header.refuse_pay,
		dbo.cs_compdartdetail_getLookupCodeList(cs_comp_viewHistory.complaint_no, 'DRTREP') AS DRTREP,
		dbo.cs_compdartdetail_getLookupCodeDescList(cs_comp_viewHistory.complaint_no, 'DRTREP') AS DRTREP_desc,
		dbo.cs_compdartdetail_getLookupCodeList(cs_comp_viewHistory.complaint_no, 'DRTPAR') AS DRTPAR,
		dbo.cs_compdartdetail_getLookupCodeDescList(cs_comp_viewHistory.complaint_no, 'DRTPAR') AS DRTPAR_desc,
		dbo.cs_compdartdetail_getLookupCodeList(cs_comp_viewHistory.complaint_no, 'DRTASW') AS DRTASW,
		dbo.cs_compdartdetail_getLookupCodeDescList(cs_comp_viewHistory.complaint_no, 'DRTASW') AS DRTASW_desc,
		dbo.cs_compdartdetail_getLookupCodeList(cs_comp_viewHistory.complaint_no, 'ABUSE') AS ABUSE,
		dbo.cs_compdartdetail_getLookupCodeDescList(cs_comp_viewHistory.complaint_no, 'ABUSE') AS ABUSE_desc

		FROM cs_comp_viewHistory
		INNER JOIN site_detail
		ON site_detail.site_ref = cs_comp_viewHistory.site_ref
		LEFT OUTER JOIN comp_dart_header
		ON comp_dart_header.complaint_no = cs_comp_viewHistory.complaint_no
		WHERE dbo.cs_utils_getServiceType(cs_comp_viewHistory.service_c) = 'DART'
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
