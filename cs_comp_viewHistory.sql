/*****************************************************************************
** dbo.cs_comp_viewHistory
** view script
**
** Description
** comp view for cs_comp_getHistory
**
** Parameters
**
** Returned
**
** History
** 14/01/2013  TW  New
** 05/02/2013  TW  Do not return customer data for the time being (could be multiple customers)
** 23/05/2013  TW  Additional fly capture columns
** 30/05/2013  TW  Additional column action_flag_desc
** 07/06/2013  TW  Additional column priority_flag
** 09/07/2013  TW  Replace function call to ...getFaultCodesTable with ...getFaultCodeDesc
** 16/07/2013  TW  Correction for date_due
**
*****************************************************************************/

IF EXISTS
	(
	SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS
		WHERE TABLE_NAME = 'cs_comp_viewHistory'
	)
	DROP VIEW cs_comp_viewHistory
GO

CREATE VIEW dbo.cs_comp_viewHistory
AS
	SELECT comp.complaint_no,
		comp.entered_by,
		comp.site_ref,
		RTRIM(LTRIM(RTRIM(ISNULL([site].site_name_1, ''))) + ' ' + LTRIM(RTRIM(ISNULL([site].site_name_2, '')))) AS site_name_1,
		comp.exact_location,
		comp.service_c,
		pda_lookup.service_c_desc,
		comp.comp_code,
		(dbo.cs_pdalookup_getFaultCodeDesc(comp.comp_code, comp.service_c, comp.item_ref, NULL)) AS comp_code_desc,
		comp.item_ref,
		item.item_desc,
		(SELECT si_i.priority_flag FROM si_i WHERE si_i.site_ref = comp.site_ref AND si_i.item_ref = comp.item_ref AND si_i.contract_ref = comp.contract_ref) AS priority_flag,
		comp.feature_ref,
		feat.feature_desc,
		comp.contract_ref,
		cont.[contract_name],
		comp.occur_day,
		comp.round_c,
		comp.pa_area,
		comp.action_flag,
		action_flag_desc = 
			CASE
				WHEN comp.action_flag = 'A' THEN 'Auto ' + dbo.cs_keys_getCField('PDAINI', 'DEF_NAME_NOUN')
				WHEN comp.action_flag = 'D' THEN dbo.cs_keys_getCField('PDAINI', 'DEF_NAME_NOUN')
				WHEN comp.action_flag = 'E' THEN 'Enforcement'
				WHEN comp.action_flag = 'H' THEN 'Hold'
				WHEN comp.action_flag = 'I' THEN 'Inspect'
				WHEN comp.action_flag = 'P' THEN 'Pending'
				WHEN comp.action_flag = 'N' THEN 'No Action'
				WHEN comp.action_flag = 'W' THEN 'Works Order'
				WHEN comp.action_flag = 'X' THEN 'Express Works Order'
			END,
		dbo.cs_comptext_getNotes(comp.complaint_no, 0) AS notes,
		customer.compl_init,
		customer.compl_name,
		customer.compl_surname,
		customer.compl_build_no,
		customer.compl_build_name,
		customer.compl_addr2,
		customer.compl_addr4,
		customer.compl_addr5,
		customer.compl_addr6,
		customer.compl_postcode,
		customer.compl_phone,
		customer.compl_email,
		customer.compl_business,
		customer.int_ext_flag,
		comp.date_entered,
		comp.ent_time_h,
		comp.ent_time_m,
		comp.dest_ref,
		comp.dest_suffix,
		date_due =
			CASE
				WHEN (comp.action_flag = 'D') THEN defi_rect.rectify_date
				WHEN (comp.action_flag = 'I') THEN diry.date_due
				WHEN (comp.action_flag = 'W') THEN wo_h.wo_date_due
				ELSE date_entered
			END,
		comp.date_closed,
		comp.incident_id,
		comp.details_1,
		comp.details_2,
		comp.details_3,
		comp.notice_type,
		NULL AS site_distance,
		flycap_record =
			CASE
				WHEN (
					dbo.cs_modulelic_getInstalled('FC') = 1
					AND EXISTS
					(SELECT 1 FROM allk
						WHERE lookup_func = 'FCCOMP'
							AND lookup_code = comp.comp_code)
					) THEN 1
				ELSE 0
			END,
		comp_flycap.landtype_ref,
		(SELECT lookup_text FROM allk WHERE lookup_code = comp_flycap.landtype_ref AND lookup_func = 'FCLAND') AS landtype_desc,
		comp_flycap.dominant_waste_ref,
		(SELECT lookup_text FROM allk WHERE lookup_code = comp_flycap.dominant_waste_ref AND lookup_func = 'FCWSTE') AS dominant_waste_desc,
		comp_flycap.dominant_waste_qty,
		comp_flycap.load_ref,
		(SELECT load_desc FROM fly_loads WHERE load_ref = comp_flycap.load_ref) AS load_desc,
		load_qty,
		load_unit_cost,
		load_est_cost
	FROM comp
	LEFT OUTER JOIN [site]
	ON site.site_ref = comp.site_ref
	LEFT OUTER JOIN pda_lookup
	ON pda_lookup.service_c = comp.service_c
		AND pda_lookup.comp_code = comp.comp_code
		AND pda_lookup.role_name = 'pda-in'
	LEFT OUTER JOIN item
	ON item.item_ref = comp.item_ref
		AND item.contract_ref = comp.contract_ref
		AND item.customer_care_yn = 'Y'
	LEFT OUTER JOIN feat
	ON feat.feature_ref = comp.feature_ref
	LEFT OUTER JOIN cont
	ON cont.contract_ref = comp.contract_ref
		AND cont.service_c = comp.service_c
	LEFT OUTER JOIN customer
	ON customer.customer_no =
		(
		SELECT customer_no
			FROM
			(
			SELECT customer_no,
				ROW_NUMBER() OVER (PARTITION BY complaint_no ORDER BY seq_no DESC) AS rn
				FROM comp_clink
				WHERE complaint_no = comp.complaint_no
			) AS innerselect
			WHERE rn = 1
		)
	LEFT OUTER JOIN diry
	ON diry.source_ref = comp.complaint_no
		AND diry.source_flag = 'C'
	LEFT OUTER JOIN wo_h
	ON wo_ref = comp.dest_ref
		AND wo_suffix = comp.dest_suffix
		AND comp.action_flag = 'W'
	LEFT OUTER JOIN defi_rect
	ON default_no = comp.dest_ref
		AND comp.action_flag = 'D'
		AND seq_no = (SELECT MAX(seq_no) FROM defi_rect WHERE default_no = comp.dest_ref)
	LEFT OUTER JOIN comp_flycap
		ON comp_flycap.complaint_no = comp.complaint_no
WITH CHECK OPTION;
GO
