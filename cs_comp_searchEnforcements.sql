/*****************************************************************************
** dbo.cs_comp_searchEnforcements
** stored procedure
**
** Description
** Selects a set of current Enforcement records using law and offence
** search data
**
** Parameters
** @law_ref     = law code
** @offence_ref = offence code
**
** Returned
** Result set of Enforcement records
**
** Notes
**
** History
** 26/02/2013  TW  New
** 29/05/2013  TW  Additional fly capture columns
** 30/05/2013  TW  Additional column action_flag_desc
** 07/06/2013  TW  Additional column priority_flag
** 11/06/2013  TW  Use aliases to reduce query length
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_comp_searchEnforcements', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comp_searchEnforcements;
GO
CREATE PROCEDURE dbo.cs_comp_searchEnforcements
	@plaw_ref varchar(6) = NULL,
	@poffence_ref varchar(6) = NULL
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@query varchar(4000),
		@law_ref varchar(6),
		@offence_ref varchar(6);

	SET @errornumber = '11200';

	SET @law_ref = LTRIM(RTRIM(@plaw_ref));
	SET @offence_ref = LTRIM(RTRIM(@poffence_ref));

	IF (@law_ref = '' OR @law_ref IS NULL) AND (@offence_ref = '' OR @offence_ref IS NULL)
	BEGIN
		SET @errornumber = '11201';
		SET @errortext = 'No search parameters were passed';
		GOTO errorexit;
	END

	SET @query = 

	'SELECT
		cvh.complaint_no,
		cvh.entered_by,
		cvh.site_ref,
		cvh.site_name_1,
		cvh.exact_location,
		cvh.service_c,
		cvh.service_c_desc,
		cvh.comp_code,
		cvh.comp_code_desc,
		cvh.item_ref,
		cvh.item_desc,
		cvh.priority_flag,
		cvh.feature_ref,
		cvh.feature_desc,
		cvh.contract_ref,
		cvh.[contract_name],
		cvh.occur_day,
		cvh.round_c,
		cvh.pa_area,
		cvh.action_flag,
		cvh.action_flag_desc,
		dbo.cs_comptext_getNotes(cvh.complaint_no, 0) AS notes,
		cvh.compl_init,
		cvh.compl_name,
		cvh.compl_surname,
		cvh.compl_build_no,
		cvh.compl_build_name,
		cvh.compl_addr2,
		cvh.compl_addr4,
		cvh.compl_addr5,
		cvh.compl_addr6,
		cvh.compl_postcode,
		cvh.compl_phone,
		cvh.compl_email,
		cvh.compl_business,
		cvh.int_ext_flag,
		cvh.date_entered,
		cvh.ent_time_h,
		cvh.ent_time_m,
		cvh.dest_ref,
		cvh.dest_suffix,
		cvh.date_due,
		cvh.date_closed,
		cvh.incident_id,
		cvh.details_1,
		cvh.details_2,
		cvh.details_3,
		cvh.notice_type,
		NULL AS site_distance,
		cvh.flycap_record,
		cvh.landtype_ref,
		cvh.landtype_desc,
		cvh.dominant_waste_ref,
		cvh.dominant_waste_desc,
		cvh.dominant_waste_qty,
		cvh.load_ref,
		cvh.load_desc,
		cvh.load_qty,
		cvh.load_unit_cost,
		cvh.load_est_cost,

		cve.law_ref,
		cve.law_desc,
		cve.offence_ref,
		cve.offence_desc,
		cve.offence_datetime,
		cve.inv_officer,
		cve.inv_officer_desc,
		cve.enf_officer,
		cve.enf_officer_desc,
		cve.enf_status,
		cve.enf_status_desc,
		cve.suspect_ref,
		cve.suspect_name,
		cve.suspect_company,
		cve.actions,
		cve.action_seq,
		cve.action_ref,
		cve.action_desc,
		cve.action_notes,
		cve.car_id,
		cve.source_ref,
		cve.inv_period_start,
		cve.inv_period_finish,
		cve.agreement_no,
		cve.agreement_name,
		cve.site_name,
		cve.action_datetime,
		cve.fpcn,
		cve.do_date,
		cve.aut_officer,
		cve.aut_officer_desc,
		cve.[state],
		action_days_remaining = 
			/* Unexpired delay period? */
			CASE 
				WHEN DATEDIFF(day, CONVERT(datetime, CONVERT(date, GETDATE())), cve.do_date) > 0 THEN DATEDIFF(day, CONVERT(datetime, CONVERT(date, GETDATE())), cve.do_date)
				ELSE 0
			END

		FROM cs_comp_viewEnfList cve, cs_comp_viewHistory cvh
		WHERE  (cve.[state] = ''A'' OR cve.[state] = ''P'')
			AND (cve.action_flag = ''N'')
			AND cvh.complaint_no = cve.complaint_no';

	IF @law_ref <> '' AND @law_ref IS NOT NULL
	BEGIN
		SET @query = @query +
			' AND law_ref = ''' + @law_ref + '''';
	END

	IF @offence_ref <> '' AND @offence_ref IS NOT NULL
	BEGIN
		SET @query = @query +
			' AND offence_ref = ''' + @offence_ref + '''';
	END

	SET @query = @query +
		' ORDER BY cve.do_date, cvh.site_name_1;';

	BEGIN TRY
		EXECUTE (@query);
	END TRY
	BEGIN CATCH
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
