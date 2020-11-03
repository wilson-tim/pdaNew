/*****************************************************************************
** dbo.cs_comp_getMyDart
** stored procedure
**
** Description
** Selects a set of current comp records for DART service and a given officer
**
** Parameters
** @username = user name
**
** Returned
** Result set of DART customer care data
**
** Notes
**
** History
** 26/04/2013  TW  New
** 23/05/2013  TW  Additional fly capture columns
** 30/05/2013  TW  Additional column action_flag_desc
** 07/06/2013  TW  Additional column priority_flag
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_comp_getMyDart', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comp_getMyDart;
GO
CREATE PROCEDURE dbo.cs_comp_getMyDart
	@pusername varchar(8) = NULL
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@username varchar(8);

	SET @username = LTRIM(RTRIM(@pusername));

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
		NULL AS site_distance,
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
		INNER JOIN pda_user
		ON pda_user.[user_name] = @username
		INNER JOIN patr_area
		ON patr_area.po_code = pda_user.po_code
		LEFT OUTER JOIN comp_dart_header
		ON comp_dart_header.complaint_no = cs_comp_viewHistory.complaint_no
		WHERE cs_comp_viewHistory.service_c = (SELECT c_field FROM keys WHERE keyname = 'DART_SERVICE' AND service_c = 'ALL')
			AND cs_comp_viewHistory.pa_area = patr_area.area_c
			AND cs_comp_viewHistory.date_closed IS NULL
			AND (
				cs_comp_viewHistory.entered_by = @username
				OR
				cs_comp_viewHistory.entered_by IN
					(
					SELECT [user_name] 
						FROM pda_cover_list
						WHERE covered_by = @username
					)
				)
		ORDER BY cs_comp_viewHistory.site_name_1;

END
GO 
