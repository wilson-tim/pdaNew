/*****************************************************************************
** dbo.cs_comp_viewEnfList
** view script
**
** Description
** comp view for cs_comp_getEnfList
** Replaces the enf_list table
**
** Parameters
**
** Returned
**
** Notes
** MS SQL Server 2012 has introduced function DATETIMEFROMPARTS which supersedes the
**   the DATEADD based datetime calculations below
**
** History
** 26/02/2013  TW  New
** 07/03/2013  TW  Revised columns
** 22/03/2013  TW  Exclude records without a suspect_ref
** 25/03/2013  TW  Removed join to pda_user/patr_area which was causing a problem
**                 with comp records having NULL pa_area
** 14/05/2013  TW  Relax the requirement for suspect details (per Mark's unit testing)
**
*****************************************************************************/

IF EXISTS
	(
	SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS
		WHERE TABLE_NAME = 'cs_comp_viewEnfList'
	)
	DROP VIEW cs_comp_viewEnfList
GO

CREATE VIEW dbo.cs_comp_viewEnfList
AS

	/* Enforcements With Due Dates */
	SELECT comp.complaint_no AS complaint_no,
		comp.entered_by,
		comp.site_ref,
		RTRIM(LTRIM(RTRIM(ISNULL([site].site_name_1, ''))) + ' ' + LTRIM(RTRIM(ISNULL([site].site_name_2, '')))) AS site_name_1,
		comp.service_c,
		(SELECT service_c_desc FROM pda_lookup WHERE pda_lookup.service_c = comp.service_c AND pda_lookup.comp_code = comp.comp_code AND pda_lookup.role_name = 'pda-in') AS service_c_desc,
		comp.comp_code,
		(SELECT keydesc FROM keys WHERE keyname = 'ENF_COMP_CODE' AND service_c = 'ALL') AS comp_code_desc,
		comp.item_ref,
		(SELECT keydesc FROM keys WHERE keyname = 'ENF_ITEM' AND service_c = 'ALL') AS item_desc,
		comp.feature_ref,
		(SELECT feature_desc FROM it_f INNER JOIN feat ON feat.feature_ref=it_f.feature_ref WHERE item_ref = comp.item_ref) AS feature_desc,
		comp.contract_ref,
		(SELECT cont.[contract_name] FROM cont WHERE cont.contract_ref = comp.contract_ref AND cont.service_c = comp.service_c) AS [contract_name],
		comp.occur_day,
		comp.round_c,
		comp.pa_area,
		comp.action_flag,
		dbo.cs_comptext_getNotes(comp.complaint_no, 0) AS notes,
		NULL AS compl_init,
		NULL AS compl_name,
		NULL AS compl_surname,
		NULL AS compl_build_no,
		NULL AS compl_build_name,
		NULL AS compl_addr2,
		NULL AS compl_addr4,
		NULL AS compl_addr5,
		NULL AS compl_addr6,
		NULL AS compl_postcode,
		NULL AS compl_phone,
		NULL AS compl_email,
		NULL AS compl_business,
		NULL AS int_ext_flag,
		comp.date_entered,
		comp.ent_time_h,
		comp.ent_time_m,
		comp.dest_ref,
		comp.dest_suffix,
		(SELECT date_due FROM diry WHERE source_ref = comp.complaint_no AND source_flag = 'C') AS date_due,
		comp.date_closed,
		comp.incident_id,
		comp.details_1,
		comp.details_2,
		comp.details_3,
		comp.notice_type,
		NULL AS site_distance,

		comp_enf.law_ref AS law_ref,
		(SELECT lookup_text FROM allk WHERE lookup_func = 'ENFLAW' AND lookup_code = law_ref) AS law_desc,
		comp_enf.offence_ref AS offence_ref,
		(SELECT lookup_text FROM allk WHERE lookup_func = 'ENFDET' AND lookup_code = offence_ref) AS offence_desc,
		comp_enf.inv_officer AS inv_officer,
		(SELECT lookup_text FROM allk WHERE lookup_func = 'ENFOFF' AND lookup_code = inv_officer) AS inv_officer_desc,
		comp_enf.enf_officer AS enf_officer,
		(SELECT lookup_text FROM allk WHERE lookup_func = 'ENFOFF' AND lookup_code = enf_officer) AS enf_officer_desc,
		enf_action.enf_status AS enf_status,
		(SELECT lookup_text FROM allk WHERE lookup_func = 'ENFST' AND lookup_code = enf_action.enf_status) AS enf_status_desc,
		comp_enf.suspect_ref AS suspect_ref,
		(SELECT LTRIM(RTRIM(ISNULL(fstname, '') + ' ' + ISNULL(midname, '') + ' ' + ISNULL(surname, ''))) FROM enf_suspect WHERE suspect_ref = comp_enf.suspect_ref) AS suspect_name,
		(SELECT company_name FROM enf_company WHERE company_ref = (SELECT company_ref FROM enf_suspect WHERE suspect_ref = comp_enf.suspect_ref)) AS suspect_company,
		comp_enf.actions AS actions,
		comp_enf.action_seq AS action_seq,
		comp_enf.car_id AS car_id,
		comp_enf.source_ref AS source_ref,
		comp_enf.inv_period_start AS inv_period_start,
		comp_enf.inv_period_finish AS inv_period_finish,
		comp_enf.agreement_no AS agreement_no,
		comp_enf.agreement_name AS agreement_name,
		comp_enf.site_name AS site_name,
		DATEADD(minute, CAST(ISNULL(comp_enf.offence_time_m, 0) AS integer),
			DATEADD(hour,   CAST(ISNULL(comp_enf.offence_time_h, 0) AS integer),
			DATEADD(day,    DATEPART(day,   comp_enf.offence_date) - 1, 
			DATEADD(month,  DATEPART(month, comp_enf.offence_date) - 1, 
			DATEADD(year,   DATEPART(year,  comp_enf.offence_date) - 1900, 0))))) AS offence_datetime,
		enf_action.action_ref AS action_ref,
		(SELECT [description] FROM enf_act WHERE action_code = enf_action.action_ref) as action_desc,
		dbo.cs_enfacttext_getNotes(comp.complaint_no, comp_enf.action_seq, enf_action.action_ref, 0) AS action_notes,
		DATEADD(minute, CAST(ISNULL(enf_action.action_time_m, 0) AS integer),
			DATEADD(hour,   CAST(ISNULL(enf_action.action_time_h, 0) AS integer),
			DATEADD(day,    DATEPART(day,   enf_action.action_date) - 1, 
			DATEADD(month,  DATEPART(month, enf_action.action_date) - 1, 
			DATEADD(year,   DATEPART(year,  enf_action.action_date) - 1900, 0))))) AS action_datetime,
		enf_action.fpcn AS fpcn,
		enf_action.due_date AS do_date,
		enf_action.aut_officer AS aut_officer,
		(SELECT lookup_text FROM allk WHERE lookup_func = 'ENFOFF' AND lookup_code = aut_officer) AS aut_officer_desc,
		'A' AS [state]

		FROM comp, comp_enf, enf_action, [site]
		WHERE comp.action_flag = 'N'
			AND comp.date_closed IS NULL
			AND [site].site_ref = comp.site_ref
			AND enf_action.action_seq = comp_enf.action_seq
			AND enf_action.complaint_no = comp_enf.complaint_no
			AND comp_enf.complaint_no = comp.complaint_no
			/*
			AND (comp_enf.suspect_ref <> 0 AND comp_enf.suspect_ref IS NOT NULL)
			*/

	UNION

	/* Enforcements Without Due Dates */
	SELECT comp.complaint_no AS complaint_no,
		comp.entered_by,
		comp.site_ref,
		RTRIM(LTRIM(RTRIM(ISNULL([site].site_name_1, ''))) + ' ' + LTRIM(RTRIM(ISNULL([site].site_name_2, '')))) AS site_name_1,
		comp.service_c,
		(SELECT service_c_desc FROM pda_lookup WHERE pda_lookup.service_c = comp.service_c AND pda_lookup.comp_code = comp.comp_code AND pda_lookup.role_name = 'pda-in') AS service_c_desc,
		comp.comp_code,
		(SELECT keydesc FROM keys WHERE keyname = 'ENF_COMP_CODE' AND service_c = 'ALL') AS comp_code_desc,
		comp.item_ref,
		(SELECT keydesc FROM keys WHERE keyname = 'ENF_ITEM' AND service_c = 'ALL') AS item_desc,
		comp.feature_ref,
		(SELECT feature_desc FROM it_f INNER JOIN feat ON feat.feature_ref=it_f.feature_ref WHERE item_ref = comp.item_ref) AS feature_desc,
		comp.contract_ref,
		(SELECT cont.[contract_name] FROM cont WHERE cont.contract_ref = comp.contract_ref AND cont.service_c = comp.service_c) AS [contract_name],
		comp.occur_day,
		comp.round_c,
		comp.pa_area,
		comp.action_flag,
		dbo.cs_comptext_getNotes(comp.complaint_no, 0) AS notes,
		NULL AS compl_init,
		NULL AS compl_name,
		NULL AS compl_surname,
		NULL AS compl_build_no,
		NULL AS compl_build_name,
		NULL AS compl_addr2,
		NULL AS compl_addr4,
		NULL AS compl_addr5,
		NULL AS compl_addr6,
		NULL AS compl_postcode,
		NULL AS compl_phone,
		NULL AS compl_email,
		NULL AS compl_business,
		NULL AS int_ext_flag,
		comp.date_entered,
		comp.ent_time_h,
		comp.ent_time_m,
		comp.dest_ref,
		comp.dest_suffix,
		(SELECT date_due FROM diry WHERE source_ref = comp.complaint_no AND source_flag = 'C') AS date_due,
		comp.date_closed,
		comp.incident_id,
		comp.details_1,
		comp.details_2,
		comp.details_3,
		comp.notice_type,
		NULL AS site_distance,

		comp_enf.law_ref AS law_ref,
		(SELECT lookup_text FROM allk WHERE lookup_func = 'ENFLAW' AND lookup_code = law_ref) AS law_desc,
		comp_enf.offence_ref AS offence_ref,
		(SELECT lookup_text FROM allk WHERE lookup_func = 'ENFDET' AND lookup_code = offence_ref) AS offence_desc,
		comp_enf.inv_officer AS inv_officer,
		(SELECT lookup_text FROM allk WHERE lookup_func = 'ENFOFF' AND lookup_code = inv_officer) AS inv_officer_desc,
		comp_enf.enf_officer AS enf_officer,
		(SELECT lookup_text FROM allk WHERE lookup_func = 'ENFOFF' AND lookup_code = enf_officer) AS enf_officer_desc,
		NULL AS enf_status,
		NULL AS enf_status_desc,
		comp_enf.suspect_ref AS suspect_ref,
		(SELECT LTRIM(RTRIM(ISNULL(fstname, '') + ' ' + ISNULL(midname, '') + ' ' + ISNULL(surname, ''))) FROM enf_suspect WHERE suspect_ref = comp_enf.suspect_ref) AS suspect_name,
		(SELECT company_name FROM enf_company WHERE company_ref = (SELECT company_ref FROM enf_suspect WHERE suspect_ref = comp_enf.suspect_ref)) AS suspect_company,
		comp_enf.actions AS actions,
		comp_enf.action_seq AS action_seq,
		comp_enf.car_id AS car_id,
		comp_enf.source_ref AS source_ref,
		comp_enf.inv_period_start AS inv_period_start,
		comp_enf.inv_period_finish AS inv_period_finish,
		comp_enf.agreement_no AS agreement_no,
		comp_enf.agreement_name AS agreement_name,
		comp_enf.site_name AS site_name,
		DATEADD(minute, CAST(ISNULL(comp_enf.offence_time_m, 0) AS integer),
			DATEADD(hour,   CAST(ISNULL(comp_enf.offence_time_h, 0) AS integer),
			DATEADD(day,    DATEPART(day,   comp_enf.offence_date) - 1, 
			DATEADD(month,  DATEPART(month, comp_enf.offence_date) - 1, 
			DATEADD(year,   DATEPART(year,  comp_enf.offence_date) - 1900, 0))))) AS offence_datetime,
		NULL AS action_ref,
		NULL AS action_desc,
		NULL AS action_notes,
		/*
		DATEADD(minute, CAST(ISNULL(comp.ent_time_m, 0) AS integer),
			DATEADD(hour,   CAST(ISNULL(comp.ent_time_h, 0) AS integer),
			DATEADD(day,    DATEPART(day,   comp.date_entered) - 1, 
			DATEADD(month,  DATEPART(month, comp.date_entered) - 1, 
			DATEADD(year,   DATEPART(year,  comp.date_entered) - 1900, 0))))) AS action_datetime,
		*/
		NULL as action_datetime,
		NULL AS fpcn,
		comp.date_entered AS do_date,
		NULL AS aut_officer,
		NULL AS aut_officer_desc,
		'A' AS [state]

		FROM comp, comp_enf, [site]
		WHERE comp.action_flag = 'N'
			AND comp.date_closed IS NULL
			AND [site].site_ref = comp.site_ref
			AND comp_enf.complaint_no = comp.complaint_no
			AND comp_enf.action_seq IS NULL
			/*
			AND (comp_enf.suspect_ref <> 0 AND comp_enf.suspect_ref IS NOT NULL)
			*/

WITH CHECK OPTION;
GO
