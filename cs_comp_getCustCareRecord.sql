/*****************************************************************************
** dbo.cs_comp_getCustCareRecord
** stored procedure
**
** Description
** Generic selection of customer care data for a given complaint_no
** (live records only)
**
** Parameters
** @complaint_no = complaint number
**
** Returned
** Result set of customer care data
**
** Notes
**
** History
** 07/06/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_comp_getCustCareRecord', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comp_getCustCareRecord;
GO
CREATE PROCEDURE dbo.cs_comp_getCustCareRecord
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
		WHERE cs_comp_viewHistory.complaint_no = @complaint_no
			AND cs_comp_viewHistory.date_closed IS NULL
		ORDER BY cs_comp_viewHistory.site_name_1;

END
GO
