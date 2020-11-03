/*****************************************************************************
** dbo.cs_comp_getGraffitiDetails
** stored procedure
**
** Description
** Selects Graffiti customer care data for a given complaint_no
**
** Parameters
** @complaint_no = complaint number
**
** Returned
** Result set of Graffiti customer care data
**
** Notes
**
** History
** 03/04/2013  TW  New
** 23/05/2013  TW  Additional fly capture columns
** 30/05/2013  TW  Additional column action_flag_desc
** 07/06/2013  TW  Additional column priority_flag
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_comp_getGraffitiDetails', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comp_getGraffitiDetails;
GO
CREATE PROCEDURE dbo.cs_comp_getGraffitiDetails
	@pcomplaint_no integer
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@complaint_no integer;

	SET @complaint_no = @pcomplaint_no;

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

		comp_ert.graffiti_sqmtr,
		comp_ert.s12_notice_type,
		s12_notice_type_desc =
			CASE
				WHEN comp_ert.s12_notice_type = 'R' THEN 'Residential'
				WHEN comp_ert.s12_notice_type = 'C' THEN 'Commercial'
				ELSE NULL
			END,
		comp_ert.s12_notice_date,

		comp_ert_header.volume_ref,
		(SELECT lookup_text FROM allk WHERE lookup_code = comp_ert_header.volume_ref AND lookup_func = 'ERTVOL' AND status_yn = 'Y') AS volume_ref_desc,
		comp_ert_header.tag_offensive,
		comp_ert_header.tag_visible,
		comp_ert_header.tag_recognisable,
		comp_ert_header.tag_known_offender,
		comp_ert_header.tag_offender_info,
		comp_ert_header.tag_repeat_offence,
		comp_ert_header.tag_offences_ref,
		(SELECT lookup_text FROM allk WHERE lookup_code = comp_ert_header.tag_offences_ref AND lookup_func = 'ERTNOO' AND status_yn = 'Y') AS tag_offences_ref_desc,
		comp_ert_header.rem_workforce_ref,
		(SELECT lookup_text FROM allk WHERE lookup_code = comp_ert_header.rem_workforce_ref AND lookup_func = 'ERTWOR' AND status_yn = 'Y') AS workforce_ref_desc,
		comp_ert_header.wo_est_cost,
		comp_ert_header.po_code,
		comp_ert_header.graffiti_level_ref,
		(SELECT lookup_text FROM allk WHERE lookup_code = comp_ert_header.graffiti_level_ref AND lookup_func = 'ERTLEV' AND status_yn = 'Y') AS graffiti_level_ref_desc,
		comp_ert_header.completion_date,
		comp_ert_header.completion_time_h,
		comp_ert_header.completion_time_m,
		DATEADD(minute, CAST(ISNULL(comp_ert_header.est_duration_h, 0) AS integer),
			DATEADD(hour,   CAST(ISNULL(comp_ert_header.est_duration_m, 0) AS integer),
			DATEADD(day,    DATEPART(day,   0) - 1, 
			DATEADD(month,  DATEPART(month, 0) - 1, 
			DATEADD(year,   DATEPART(year,  0) - 1900, 0))))) AS est_duration_date,
		comp_ert_header.est_duration_h,
		comp_ert_header.est_duration_m,
		comp_ert_header.refuse_pay,
		comp_ert_header.indemnity_response,
		comp_ert_header.indemnity_date,
		comp_ert_header.indemnity_time_h,
		comp_ert_header.indemnity_time_m,
		comp_ert_header.cust_responsible,
		comp_ert_header.landlord_perm_date,

		comp_ert_tags.tag,

		dbo.cs_compertdetail_getLookupCodeList(cs_comp_viewHistory.complaint_no, 'ERTSUR') AS ERTSUR,
		dbo.cs_compertdetail_getLookupCodeDescList(cs_comp_viewHistory.complaint_no, 'ERTSUR') AS ERTSUR_desc,
		dbo.cs_compertdetail_getLookupCodeList(cs_comp_viewHistory.complaint_no, 'ERTMAT') AS ERTMAT,
		dbo.cs_compertdetail_getLookupCodeDescList(cs_comp_viewHistory.complaint_no, 'ERTMAT') AS ERTMAT_desc,
		dbo.cs_compertdetail_getLookupCodeList(cs_comp_viewHistory.complaint_no, 'ERTOFF') AS ERTOFF,
		dbo.cs_compertdetail_getLookupCodeDescList(cs_comp_viewHistory.complaint_no, 'ERTOFF') AS ERTOFF_desc,
		dbo.cs_compertdetail_getLookupCodeList(cs_comp_viewHistory.complaint_no, 'ERTOWN') AS ERTOWN,
		dbo.cs_compertdetail_getLookupCodeDescList(cs_comp_viewHistory.complaint_no, 'ERTOWN') AS ERTOWN_desc,
		dbo.cs_compertdetail_getLookupCodeList(cs_comp_viewHistory.complaint_no, 'ERTOPP') AS ERTOPP,
		dbo.cs_compertdetail_getLookupCodeDescList(cs_comp_viewHistory.complaint_no, 'ERTOPP') AS ERTOPP_desc,
		dbo.cs_compertdetail_getLookupCodeList(cs_comp_viewHistory.complaint_no, 'ERTITM') AS ERTITM,
		dbo.cs_compertdetail_getLookupCodeDescList(cs_comp_viewHistory.complaint_no, 'ERTITM') AS ERTITM_desc,
		dbo.cs_compertdetail_getLookupCodeList(cs_comp_viewHistory.complaint_no, 'ERTACT') AS ERTACT,
		dbo.cs_compertdetail_getLookupCodeDescList(cs_comp_viewHistory.complaint_no, 'ERTACT') AS ERTACT_desc,
		dbo.cs_compertdetail_getLookupCodeList(cs_comp_viewHistory.complaint_no, 'ERTABU') AS ERTABU,
		dbo.cs_compertdetail_getLookupCodeDescList(cs_comp_viewHistory.complaint_no, 'ERTABU') AS ERTABU_desc,
		dbo.cs_compertdetail_getLookupCodeList(cs_comp_viewHistory.complaint_no, 'ERTMET') AS ERTMET,
		dbo.cs_compertdetail_getLookupCodeDescList(cs_comp_viewHistory.complaint_no, 'ERTMET') AS ERTMET_desc,
		dbo.cs_compertdetail_getLookupCodeList(cs_comp_viewHistory.complaint_no, 'ERTEQU') AS ERTEQU,
		dbo.cs_compertdetail_getLookupCodeDescList(cs_comp_viewHistory.complaint_no, 'ERTEQU') AS ERTEQU_desc

		FROM cs_comp_viewHistory
		LEFT OUTER JOIN comp_ert
		ON comp_ert.complaint_no = cs_comp_viewHistory.complaint_no
		LEFT OUTER JOIN comp_ert_header
		ON comp_ert_header.complaint_no = cs_comp_viewHistory.complaint_no
		LEFT OUTER JOIN comp_ert_tags
		ON comp_ert_tags.complaint_no = cs_comp_viewHistory.complaint_no
		WHERE cs_comp_viewHistory.complaint_no = @complaint_no
			AND cs_comp_viewHistory.service_c = (SELECT c_field FROM keys WHERE keyname = 'ERT_SERVICE' AND service_c = 'ALL')
			AND cs_comp_viewHistory.date_closed IS NULL
		ORDER BY cs_comp_viewHistory.site_name_1;

END
GO
