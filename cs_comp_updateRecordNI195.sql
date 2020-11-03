/*****************************************************************************
** dbo.cs_comp_updateRecordNI195
** stored procedure
**
** Description
** Update a customer care record, etc. for service type NI195
**
** Parameters
** @xmlCompCore        = XML structure containing comp record [CustCareCoreDTO]
** @xmlCompNI195Survey = XML structure containing NI195 survey details [NI195SurveyDTO]
**
** Returned
** All passed parameters are INPUT and OUTPUT
** Return value of 0 (success), or -1 (failure)
**
** Notes
** data passed in via XML
** extract data into temporary table
** validate key data
** do stuff
** update data in temporary table
** convert data in temporary table into XML and return to caller
**
** History
** 13/05/2013  TW  New
** 01/07/2013  TW  Processing for fly capture data
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_comp_updateRecordNI195', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comp_updateRecordNI195;
GO
CREATE PROCEDURE dbo.cs_comp_updateRecordNI195
       @xmlCompCore xml OUTPUT,
       @xmlCompNI195Survey xml OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @result integer
		,@errortext varchar(500)
		,@errornumber varchar(10)
		,@comp_rowcount integer
		,@numberstr varchar(2)
		,@rowcount integer

		,@compcore_rowcount integer
		,@compNI195Survey_rowcount integer

		/* core data */
		,@complaint_no integer
		,@entered_by varchar(8)
		,@site_ref varchar(16)
		,@site_name_1 varchar(70)
		,@site_distance decimal(10,2)
		,@exact_location varchar(70)
		,@service_c varchar(6)
		,@service_c_desc varchar(40)
		,@item_ref varchar(12)
		,@item_desc varchar(40)
		,@feature_ref varchar(12)
		,@feature_desc varchar(40)
		,@contract_ref varchar(12)
		,@contract_name varchar(40)
		,@comp_code varchar(6)
		,@comp_code_desc varchar(40)
		,@action_flag varchar(1)
		,@occur_day varchar(7)
		,@occur_week varchar(10)
		,@occur_month varchar(16)
		,@round_c varchar(10)
		,@pa_area varchar(6)
		,@priority_flag varchar(1)
		,@volume decimal(10,2)

		/* customer data */
		,@compl_init varchar(10)
		,@compl_name varchar(100)
		,@compl_surname varchar(100)
		,@compl_build_no varchar(14)
		,@compl_build_name varchar(60)
		,@compl_addr2 varchar(100)
		,@compl_addr4 varchar(40)
		,@compl_addr5 varchar(30)
		,@compl_addr6 varchar(30)
		,@compl_postcode varchar(8)
		,@compl_phone varchar(20)
		,@compl_email varchar(40)
		,@compl_business varchar(100)
		,@int_ext_flag varchar(1)

		/* other core data */
		,@date_entered datetime
		,@ent_time_h char(2)
		,@ent_time_m char(2)
		,@dest_ref integer
		,@dest_suffix varchar(6)
		,@date_due datetime
		,@date_closed datetime
		,@time_closed_h char(2)
		,@time_closed_m char(2)
		,@incident_id varchar(20)
		,@details_1 varchar(70)
		,@details_2 varchar(70)
		,@details_3 varchar(70)
		,@notice_type varchar(1)

		/* survey data */
		,@transect_ref integer
		,@litter_grade varchar(3)
		,@litter_text varchar(300)
		,@litter_comp_code varchar(6)
		,@litter_complaint_no integer
		,@litter_action_flag varchar(1)
		,@detritus_grade varchar(3)
		,@detritus_text varchar(300)
		,@detritus_comp_code varchar(6)
		,@detritus_complaint_no integer
		,@detritus_action_flag varchar(1)
		,@graffiti_grade varchar(3)
		,@graffiti_text varchar(300)
		,@graffiti_comp_code varchar(6)
		,@graffiti_complaint_no integer
		,@graffiti_action_flag varchar(1)
		,@flyposting_grade varchar(3)
		,@flyposting_text varchar(300)
		,@flyposting_comp_code varchar(6)
		,@flyposting_complaint_no integer
		,@flyposting_action_flag varchar(1)
		,@rectificationRequired bit
		,@po_code varchar(6)

		/* rectification data */
		,@rservice_c varchar(6)
		,@ritem_ref varchar(12)
		,@rfeature_ref varchar(12)
		,@rcontract_ref varchar(12)
		,@roccur_day varchar(7)
		,@roccur_week varchar(10)
		,@roccur_month varchar(16)
		,@rround_c varchar(10)
		,@rpa_area varchar(6)
		,@rpriority_flag varchar(1)
		,@rvolume decimal(10,2)
		,@rdate_due datetime
		;

	SET @errornumber = '20461';

	/* Read NI195 customer care record */
	IF OBJECT_ID('tempdb..#tempCompCore') IS NOT NULL
	BEGIN
		DROP TABLE #tempCompCore;
	END

	BEGIN TRY
		SELECT
			xmldoc.compcore.value('complaint_no[1]','integer') AS 'complaint_no'
			,xmldoc.compcore.value('entered_by[1]','varchar(8)') AS 'entered_by'
			,xmldoc.compcore.value('site_ref[1]','varchar(16)') AS 'site_ref'
			,xmldoc.compcore.value('site_name_1[1]','varchar(70)') AS 'site_name_1'
			,xmldoc.compcore.value('site_distance[1]','decimal(10,2)') AS 'site_distance'
			,xmldoc.compcore.value('exact_location[1]','varchar(70)') AS 'exact_location'
			,xmldoc.compcore.value('service_c[1]','varchar(6)') AS 'service_c'
			,xmldoc.compcore.value('service_c_desc[1]','varchar(40)') AS 'service_c_desc'
			,xmldoc.compcore.value('item_ref[1]','varchar(12)') AS 'item_ref'
			,xmldoc.compcore.value('item_desc[1]','varchar(40)') AS 'item_desc'
			,xmldoc.compcore.value('feature_ref[1]','varchar(12)') AS 'feature_ref'
			,xmldoc.compcore.value('feature_desc[1]','varchar(40)') AS 'feature_desc'
			,xmldoc.compcore.value('contract_ref[1]','varchar(12)') AS 'contract_ref'
			,xmldoc.compcore.value('contract_name[1]','varchar(40)') AS 'contract_name'
			,xmldoc.compcore.value('comp_code[1]','varchar(6)') AS 'comp_code'
			,xmldoc.compcore.value('comp_code_desc[1]','varchar(40)') AS 'comp_code_desc'
			,xmldoc.compcore.value('occur_day[1]','varchar(7)') AS 'occur_day'
			,xmldoc.compcore.value('round_c[1]','varchar(10)') AS 'round_c'
			,xmldoc.compcore.value('pa_area[1]','varchar(6)') AS 'pa_area'
			,xmldoc.compcore.value('action_flag[1]','varchar(1)') AS 'action_flag'
			,xmldoc.compcore.value('compl_init[1]','varchar(10)') AS 'compl_init'
			,xmldoc.compcore.value('compl_name[1]','varchar(100)') AS 'compl_name'
			,xmldoc.compcore.value('compl_surname[1]','varchar(100)') AS 'compl_surname'
			,xmldoc.compcore.value('compl_build_no[1]','varchar(14)') AS 'compl_build_no'
			,xmldoc.compcore.value('compl_build_name[1]','varchar(14)') AS 'compl_build_name'
			,xmldoc.compcore.value('compl_addr2[1]','varchar(100)') AS 'compl_addr2'
			,xmldoc.compcore.value('compl_addr4[1]','varchar(40)') AS 'compl_addr4'
			,xmldoc.compcore.value('compl_addr5[1]','varchar(30)') AS 'compl_addr5'
			,xmldoc.compcore.value('compl_addr6[1]','varchar(30)') AS 'compl_addr6'
			,xmldoc.compcore.value('compl_postcode[1]','varchar(8)') AS 'compl_postcode'
			,xmldoc.compcore.value('compl_phone[1]','varchar(20)') AS 'compl_phone'
			,xmldoc.compcore.value('compl_email[1]','varchar(40)') AS 'compl_email'
			,xmldoc.compcore.value('compl_business[1]','varchar(100)') AS 'compl_business'
			,xmldoc.compcore.value('int_ext_flag[1]','varchar(1)') AS 'int_ext_flag'
			,xmldoc.compcore.value('date_entered[1]','datetime') AS 'date_entered'
			,xmldoc.compcore.value('ent_time_h[1]','char(2)') AS 'ent_time_h'
			,xmldoc.compcore.value('ent_time_m[1]','char(2)') AS 'ent_time_m'
			,xmldoc.compcore.value('dest_ref[1]','integer') AS 'dest_ref'
			,xmldoc.compcore.value('dest_suffix[1]','varchar(6)') AS 'dest_suffix'
			,xmldoc.compcore.value('date_due[1]','datetime') AS 'date_due'
			,xmldoc.compcore.value('date_closed[1]','datetime') AS 'date_closed'
			,xmldoc.compcore.value('incident_id[1]','varchar(20)') AS 'incident_id'
			,xmldoc.compcore.value('details_1[1]','varchar(70)') AS 'details_1'
			,xmldoc.compcore.value('details_2[1]','varchar(70)') AS 'details_2'
			,xmldoc.compcore.value('details_3[1]','varchar(70)') AS 'details_3'
			,xmldoc.compcore.value('notice_type[1]','varchar(1)') AS 'notice_type'
		INTO #tempCompCore
		FROM @xmlCompCore.nodes('/CustCareCoreDTO') AS xmldoc(compcore);

		SELECT @complaint_no = complaint_no
			,@entered_by = LTRIM(RTRIM(entered_by))
			,@site_ref = LTRIM(RTRIM(site_ref))
			,@site_name_1 = site_name_1
			,@site_distance = NULL
			,@exact_location = LTRIM(RTRIM(exact_location))
			,@service_c = LTRIM(RTRIM(service_c))
			,@service_c_desc = service_c_desc
			,@item_ref = LTRIM(RTRIM(item_ref))
			,@item_desc = item_desc
			,@feature_ref = LTRIM(RTRIM(feature_ref))
			,@feature_desc = feature_desc
			,@contract_ref = LTRIM(RTRIM(contract_ref))
			,@contract_name = [contract_name]
			,@comp_code = LTRIM(RTRIM(comp_code))
			,@comp_code_desc = comp_code_desc
			,@occur_day = LTRIM(RTRIM(occur_day))
			,@round_c = LTRIM(RTRIM(round_c))
			,@pa_area = LTRIM(RTRIM(pa_area))
			,@action_flag = LTRIM(RTRIM(action_flag))
			,@compl_init = LTRIM(RTRIM(compl_init))
			,@compl_name = LTRIM(RTRIM(compl_name))
			,@compl_surname = LTRIM(RTRIM(compl_surname))
			,@compl_build_no = LTRIM(RTRIM(compl_build_no))
			,@compl_build_name = LTRIM(RTRIM(compl_build_name))
			,@compl_addr2 = LTRIM(RTRIM(compl_addr2))
			,@compl_addr4 = LTRIM(RTRIM(compl_addr4))
			,@compl_addr5 = LTRIM(RTRIM(compl_addr5))
			,@compl_addr6 = LTRIM(RTRIM(compl_addr6))
			,@compl_postcode = LTRIM(RTRIM(compl_postcode))
			,@compl_phone = LTRIM(RTRIM(compl_phone))
			,@compl_email = LTRIM(RTRIM(compl_email))
			,@compl_business = LTRIM(RTRIM(compl_business))
			,@int_ext_flag = int_ext_flag
			,@date_entered = date_entered
			,@ent_time_h = ent_time_h
			,@ent_time_m = ent_time_m
			,@dest_ref = dest_ref
			,@dest_suffix = dest_suffix
			,@date_due = date_due
			,@date_closed = date_closed
			,@incident_id = incident_id
			,@details_1 = LTRIM(RTRIM(details_1))
			,@details_2 = LTRIM(RTRIM(details_2))
			,@details_3 = LTRIM(RTRIM(details_3))
			,@notice_type = notice_type
		FROM #tempCompCore;

		SET @compcore_rowcount = @@ROWCOUNT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20462';
		SET @errortext = 'Error processing @xmlCompCore';
		GOTO errorexit;
	END CATCH

	IF @compCore_rowcount > 1
	BEGIN
		SET @errornumber = '20463';
		SET @errortext = 'Error processing @xmlCompCore - too many rows';
		GOTO errorexit;
	END
	IF @compCore_rowcount < 1
	BEGIN
		SET @errornumber = '20464';
		SET @errortext = 'Error processing @xmlCompCore - no rows found';
		GOTO errorexit;
	END

	/* Read NI195 survey details record */
	IF OBJECT_ID('tempdb..#tempCompNI195Survey') IS NOT NULL
	BEGIN
		DROP TABLE #tempCompNI195Survey;
	END

	BEGIN TRY
		SELECT
            xmldoc.compni195survey.value('transect_ref[1]','integer') AS 'transect_ref'
            ,xmldoc.compni195survey.value('litter_grade[1]','varchar(3)') AS 'litter_grade'
            ,xmldoc.compni195survey.value('litter_text[1]','varchar(300)') AS 'litter_text'
            ,xmldoc.compni195survey.value('litter_comp_code[1]','varchar(6)') AS 'litter_comp_code'
            ,xmldoc.compni195survey.value('litter_complaint_no[1]','integer') AS 'litter_complaint_no'
            ,xmldoc.compni195survey.value('detritus_grade[1]','varchar(3)') AS 'detritus_grade'
            ,xmldoc.compni195survey.value('detritus_text[1]','varchar(300)') AS 'detritus_text'
            ,xmldoc.compni195survey.value('detritus_comp_code[1]','varchar(6)') AS 'detritus_comp_code'
            ,xmldoc.compni195survey.value('detritus_complaint_no[1]','integer') AS 'detritus_complaint_no'
            ,xmldoc.compni195survey.value('graffiti_grade[1]','varchar(3)') AS 'graffiti_grade'
            ,xmldoc.compni195survey.value('graffiti_text[1]','varchar(300)') AS 'graffiti_text'
            ,xmldoc.compni195survey.value('graffiti_comp_code[1]','varchar(6)') AS 'graffiti_comp_code'
            ,xmldoc.compni195survey.value('graffiti_complaint_no[1]','integer') AS 'graffiti_complaint_no'
            ,xmldoc.compni195survey.value('flyposting_grade[1]','varchar(3)') AS 'flyposting_grade'
            ,xmldoc.compni195survey.value('flyposting_text[1]','varchar(300)') AS 'flyposting_text'
            ,xmldoc.compni195survey.value('flyposting_comp_code[1]','varchar(6)') AS 'flyposting_comp_code'
            ,xmldoc.compni195survey.value('flyposting_complaint_no[1]','integer') AS 'flyposting_complaint_no'

		INTO #tempCompNI195Survey
		FROM @xmlCompNI195Survey.nodes('/NI195SurveyDTO') AS xmldoc(compni195survey);

		SELECT @transect_ref = transect_ref
			,@litter_grade = LTRIM(RTRIM(litter_grade))
			,@litter_text = LTRIM(RTRIM(litter_text))
			,@litter_comp_code = LTRIM(RTRIM(litter_comp_code))
			,@detritus_grade = LTRIM(RTRIM(detritus_grade))
			,@detritus_text = LTRIM(RTRIM(detritus_text))
			,@detritus_comp_code = LTRIM(RTRIM(detritus_comp_code))
			,@graffiti_grade = LTRIM(RTRIM(graffiti_grade))
			,@graffiti_text = LTRIM(RTRIM(graffiti_text))
			,@graffiti_comp_code = LTRIM(RTRIM(graffiti_comp_code))
			,@flyposting_grade = LTRIM(RTRIM(flyposting_grade))
			,@flyposting_text = LTRIM(RTRIM(flyposting_text))
			,@flyposting_comp_code = LTRIM(RTRIM(flyposting_comp_code))
		FROM #tempCompNI195Survey;

		SET @compNI195Survey_rowcount = @@ROWCOUNT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20465';
		SET @errortext = 'Error processing @xmlCompNI195Survey';
		GOTO errorexit;
	END CATCH

	IF @compNI195Survey_rowcount > 1
	BEGIN
		SET @errornumber = '20466';
		SET @errortext = 'Error processing @xmlCompNI195Survey - too many rows';
		GOTO errorexit;
	END
	IF @compNI195Survey_rowcount < 1
	BEGIN
		SET @errornumber = '20467';
		SET @errortext = 'Error processing @xmlCompNI195Survey - no rows found';
		GOTO errorexit;
	END

	SET @entered_by = LTRIM(RTRIM(@entered_by));

	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @errornumber = '20468';
		SET @errortext = 'complaint_no is required';
		GOTO errorexit;
	END
	SELECT @comp_rowcount = COUNT(*)
		FROM comp
		WHERE complaint_no = @complaint_no
	IF @comp_rowcount <> 1
	BEGIN
		SET @errornumber = '20469';
		SET @errortext = LTRIM(RTRIM(STR(@complaint_no))) + ' is not a valid complaint reference';
		GOTO errorexit;
	END

	/* @entered_by validation */
	/* Assuming that @entered_by has already been validated by calling process(es) */
	/* so only a basic test here for non-blank and non-null data being passed */
	IF @entered_by = '' OR @entered_by IS NULL
	BEGIN
		SET @errornumber = '20470';
		SET @errortext = 'entered_by is required';
		GOTO errorexit;
	END

	/* @po_code */
	SELECT @po_code = po_code
		FROM pda_user
		WHERE [user_name] = @entered_by;

	SELECT @comp_code = c_field, 
            @comp_code_desc = keydesc
        FROM keys
        WHERE keyname = 'BV199_COMP_CODE';
	IF @comp_code = '' OR @comp_code IS NULL
	BEGIN
		SET @errornumber = '20471';
		SET @errortext = 'comp_code is not defined in system key BV199_COMP_CODE';
		GOTO errorexit;
	END

/***** Create comp records (start) *****/

	SET @litter_complaint_no = NULL;
	SET @detritus_complaint_no = NULL;
	SET @graffiti_complaint_no = NULL;
	SET @flyposting_complaint_no = NULL;

	SET @litter_comp_code = @comp_code;
	SET @detritus_comp_code = @comp_code;
	SET @graffiti_comp_code = @comp_code;
	SET @flyposting_comp_code = @comp_code;

	/* @site_ref */
	SELECT @site_ref = LTRIM(RTRIM(site_ref))
		FROM comp
		WHERE complaint_no = @complaint_no;

	/* Litter */
	EXECUTE dbo.cs_keys_checkNI195Grade
		'LITTER'
		,@litter_grade
		,@rectificationRequired OUTPUT;

	IF @rectificationRequired = 1
	BEGIN
		SET @litter_action_flag = 'H';
	END
	ELSE
	BEGIN
		SET @litter_action_flag = 'N';
	END

	BEGIN TRY
		SELECT @rservice_c = c_field
			FROM keys
			WHERE keyname = 'BV199_LITTER_SERVICE';

		SELECT TOP(1)
			@ritem_ref = item_ref
			,@rfeature_ref = feature_ref
			,@rcontract_ref = contract_ref
			,@roccur_day = occur_day
			,@roccur_week = occur_week
			,@roccur_month = occur_month
			,@rround_c = round_c
			,@rpa_area = pa_area
			,@rpriority_flag = priority_flag
			,@rvolume = volume
			,@rdate_due = date_due
		FROM
			(
			SELECT DISTINCT item_ref, 
				feature_ref, 
				contract_ref,
				occur_day,
				occur_week,
				occur_month,
				round_c,
				pa_area,
				priority_flag,
				volume,
				date_due
			FROM si_i
			WHERE site_ref = @site_ref
				AND item_ref IN
					(
					SELECT item_ref
					FROM item
					WHERE bv199_type = (SELECT c_field FROM keys WHERE keyname = 'BV199_LITTER_TYPE')
					)
			) AS itemSelection;

		EXECUTE dbo.cs_comp_createRecordCoreNonXml
			@entered_by OUTPUT,
			@site_ref OUTPUT,
			@site_name_1,
			@exact_location OUTPUT,
			@rservice_c OUTPUT,
			@service_c_desc,
			@litter_comp_code OUTPUT,
			@comp_code_desc,
			@ritem_ref OUTPUT,
			@item_desc,
			@rfeature_ref OUTPUT,
			@feature_desc,
			@rcontract_ref OUTPUT,
			@contract_name OUTPUT,
			@litter_action_flag OUTPUT,
			NULL,
			@compl_init OUTPUT,
			@compl_name OUTPUT,
			@compl_surname OUTPUT,
			@compl_build_no OUTPUT,
			@compl_build_name OUTPUT,
			@compl_addr2 OUTPUT,
			@compl_addr4 OUTPUT,
			@compl_addr5 OUTPUT,
			@compl_addr6 OUTPUT,
			@compl_postcode OUTPUT,
			@compl_phone OUTPUT,
			@compl_email OUTPUT,
			@compl_business OUTPUT,
			@int_ext_flag OUTPUT,
			@litter_complaint_no OUTPUT,
			@date_entered OUTPUT,
			@ent_time_h OUTPUT,
			@ent_time_m OUTPUT,
			@dest_ref OUTPUT,
			@dest_suffix OUTPUT,
			@rdate_due OUTPUT,
			@date_closed OUTPUT,
			@incident_id OUTPUT,
			@details_1 OUTPUT,
			@details_2 OUTPUT,
			@details_3 OUTPUT,
			@notice_type OUTPUT
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20472';
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH
	
	/* Detritus */
	EXECUTE dbo.cs_keys_checkNI195Grade
		'DETRITUS'
		,@detritus_grade
		,@rectificationRequired OUTPUT;

	IF @rectificationRequired = 1
	BEGIN
		SET @detritus_action_flag = 'H';
	END
	ELSE
	BEGIN
		SET @detritus_action_flag = 'N';
	END

	BEGIN TRY
		SELECT @rservice_c = c_field
			FROM keys
			WHERE keyname = 'BV199_DETRIT_SERVICE';

		SELECT TOP(1)
			@ritem_ref = item_ref
			,@rfeature_ref = feature_ref
			,@rcontract_ref = contract_ref
			,@roccur_day = occur_day
			,@roccur_week = occur_week
			,@roccur_month = occur_month
			,@rround_c = round_c
			,@rpa_area = pa_area
			,@rpriority_flag = priority_flag
			,@rvolume = volume
			,@rdate_due = date_due
		FROM
			(
			SELECT DISTINCT item_ref, 
				feature_ref, 
				contract_ref,
				occur_day,
				occur_week,
				occur_month,
				round_c,
				pa_area,
				priority_flag,
				volume,
				date_due
			FROM si_i
			WHERE site_ref = @site_ref
				AND item_ref IN
					(
					SELECT item_ref
					FROM item
					WHERE bv199_type = (SELECT c_field FROM keys WHERE keyname = 'BV199_DETRIT_TYPE')
					)
			) AS itemSelection;

		EXECUTE dbo.cs_comp_createRecordCoreNonXml
			@entered_by OUTPUT,
			@site_ref OUTPUT,
			@site_name_1,
			@exact_location OUTPUT,
			@rservice_c OUTPUT,
			@service_c_desc,
			@detritus_comp_code OUTPUT,
			@comp_code_desc,
			@ritem_ref OUTPUT,
			@item_desc,
			@rfeature_ref OUTPUT,
			@feature_desc,
			@rcontract_ref OUTPUT,
			@contract_name OUTPUT,
			@detritus_action_flag OUTPUT,
			NULL,
			@compl_init OUTPUT,
			@compl_name OUTPUT,
			@compl_surname OUTPUT,
			@compl_build_no OUTPUT,
			@compl_build_name OUTPUT,
			@compl_addr2 OUTPUT,
			@compl_addr4 OUTPUT,
			@compl_addr5 OUTPUT,
			@compl_addr6 OUTPUT,
			@compl_postcode OUTPUT,
			@compl_phone OUTPUT,
			@compl_email OUTPUT,
			@compl_business OUTPUT,
			@int_ext_flag OUTPUT,
			@detritus_complaint_no OUTPUT,
			@date_entered OUTPUT,
			@ent_time_h OUTPUT,
			@ent_time_m OUTPUT,
			@dest_ref OUTPUT,
			@dest_suffix OUTPUT,
			@rdate_due OUTPUT,
			@date_closed OUTPUT,
			@incident_id OUTPUT,
			@details_1 OUTPUT,
			@details_2 OUTPUT,
			@details_3 OUTPUT,
			@notice_type OUTPUT
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20473';
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH
	
	/* Graffiti */
	EXECUTE dbo.cs_keys_checkNI195Grade
		'GRAFFITI'
		,@graffiti_grade
		,@rectificationRequired OUTPUT;

	IF @rectificationRequired = 1
	BEGIN
		SET @graffiti_action_flag = 'H';
	END
	ELSE
	BEGIN
		SET @graffiti_action_flag = 'N';
	END

	BEGIN TRY
		SELECT @rservice_c = c_field
			FROM keys
			WHERE keyname = 'BV199_GRAFF_SERVICE';

		SELECT TOP(1)
			@ritem_ref = item_ref
			,@rfeature_ref = feature_ref
			,@rcontract_ref = contract_ref
			,@roccur_day = occur_day
			,@roccur_week = occur_week
			,@roccur_month = occur_month
			,@rround_c = round_c
			,@rpa_area = pa_area
			,@rpriority_flag = priority_flag
			,@rvolume = volume
			,@rdate_due = date_due
		FROM
			(
			SELECT DISTINCT item_ref, 
				feature_ref, 
				contract_ref,
				occur_day,
				occur_week,
				occur_month,
				round_c,
				pa_area,
				priority_flag,
				volume,
				date_due
			FROM si_i
			WHERE site_ref = @site_ref
				AND item_ref IN
					(
					SELECT item_ref
					FROM item
					WHERE bv199_type = (SELECT c_field FROM keys WHERE keyname = 'BV199_GRAFF_TYPE')
					)
			) AS itemSelection;

		EXECUTE dbo.cs_comp_createRecordCoreNonXml
			@entered_by OUTPUT,
			@site_ref OUTPUT,
			@site_name_1,
			@exact_location OUTPUT,
			@rservice_c OUTPUT,
			@service_c_desc,
			@graffiti_comp_code OUTPUT,
			@comp_code_desc,
			@ritem_ref OUTPUT,
			@item_desc,
			@rfeature_ref OUTPUT,
			@feature_desc,
			@rcontract_ref OUTPUT,
			@contract_name OUTPUT,
			@graffiti_action_flag OUTPUT,
			NULL,
			@compl_init OUTPUT,
			@compl_name OUTPUT,
			@compl_surname OUTPUT,
			@compl_build_no OUTPUT,
			@compl_build_name OUTPUT,
			@compl_addr2 OUTPUT,
			@compl_addr4 OUTPUT,
			@compl_addr5 OUTPUT,
			@compl_addr6 OUTPUT,
			@compl_postcode OUTPUT,
			@compl_phone OUTPUT,
			@compl_email OUTPUT,
			@compl_business OUTPUT,
			@int_ext_flag OUTPUT,
			@graffiti_complaint_no OUTPUT,
			@date_entered OUTPUT,
			@ent_time_h OUTPUT,
			@ent_time_m OUTPUT,
			@dest_ref OUTPUT,
			@dest_suffix OUTPUT,
			@rdate_due OUTPUT,
			@date_closed OUTPUT,
			@incident_id OUTPUT,
			@details_1 OUTPUT,
			@details_2 OUTPUT,
			@details_3 OUTPUT,
			@notice_type OUTPUT
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20474';
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

	BEGIN TRY
		INSERT INTO comp_ert_header
			(
			complaint_no
			,po_code
			)
			VALUES
			(
			@complaint_no
			,@po_code
			);
	END TRY
	BEGIN CATCH
		SET @errornumber = '20488';
		SET @errortext = 'Error inserting comp_ert_header record';
		GOTO errorexit;
	END CATCH

	BEGIN TRY
		INSERT INTO comp_ert_hdr_log
			(
			complaint_no
			,po_code
			,log_seq
			,log_username
			,log_date
			,log_time_h
			,log_time_m
			)
			VALUES
			(
			@complaint_no
			,@po_code
			,1
			,@entered_by
			,@date_entered
			,@ent_time_h
			,@ent_time_m
			);
	END TRY
	BEGIN CATCH
		SET @errornumber = '20489';
		SET @errortext = 'Error inserting comp_ert_hdr_log record';
		GOTO errorexit;
	END CATCH
	
	/* Fly posting */
	EXECUTE dbo.cs_keys_checkNI195Grade
		'FLYPOSTING'
		,@flyposting_grade
		,@rectificationRequired OUTPUT;

	IF @rectificationRequired = 1
	BEGIN
		SET @flyposting_action_flag = 'H';
	END
	ELSE
	BEGIN
		SET @flyposting_action_flag = 'N';
	END

	BEGIN TRY
		SELECT @rservice_c = c_field
			FROM keys
			WHERE keyname = 'BV199_FLYPOS_SERVICE';

		SELECT TOP(1)
			@ritem_ref = item_ref
			,@rfeature_ref = feature_ref
			,@rcontract_ref = contract_ref
			,@roccur_day = occur_day
			,@roccur_week = occur_week
			,@roccur_month = occur_month
			,@rround_c = round_c
			,@rpa_area = pa_area
			,@rpriority_flag = priority_flag
			,@rvolume = volume
			,@rdate_due = date_due
		FROM
			(
			SELECT DISTINCT item_ref, 
				feature_ref, 
				contract_ref,
				occur_day,
				occur_week,
				occur_month,
				round_c,
				pa_area,
				priority_flag,
				volume,
				date_due
			FROM si_i
			WHERE site_ref = @site_ref
				AND item_ref IN
					(
					SELECT item_ref
					FROM item
					WHERE bv199_type = (SELECT c_field FROM keys WHERE keyname = 'BV199_FLYPOS_TYPE')
					)
			) AS itemSelection;

		EXECUTE dbo.cs_comp_createRecordCoreNonXml
			@entered_by OUTPUT,
			@site_ref OUTPUT,
			@site_name_1,
			@exact_location OUTPUT,
			@rservice_c OUTPUT,
			@service_c_desc,
			@flyposting_comp_code OUTPUT,
			@comp_code_desc,
			@ritem_ref OUTPUT,
			@item_desc,
			@rfeature_ref OUTPUT,
			@feature_desc,
			@rcontract_ref OUTPUT,
			@contract_name OUTPUT,
			@flyposting_action_flag OUTPUT,
			NULL,
			@compl_init OUTPUT,
			@compl_name OUTPUT,
			@compl_surname OUTPUT,
			@compl_build_no OUTPUT,
			@compl_build_name OUTPUT,
			@compl_addr2 OUTPUT,
			@compl_addr4 OUTPUT,
			@compl_addr5 OUTPUT,
			@compl_addr6 OUTPUT,
			@compl_postcode OUTPUT,
			@compl_phone OUTPUT,
			@compl_email OUTPUT,
			@compl_business OUTPUT,
			@int_ext_flag OUTPUT,
			@flyposting_complaint_no OUTPUT,
			@date_entered OUTPUT,
			@ent_time_h OUTPUT,
			@ent_time_m OUTPUT,
			@dest_ref OUTPUT,
			@dest_suffix OUTPUT,
			@rdate_due OUTPUT,
			@date_closed OUTPUT,
			@incident_id OUTPUT,
			@details_1 OUTPUT,
			@details_2 OUTPUT,
			@details_3 OUTPUT,
			@notice_type OUTPUT
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20475';
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH
	
/***** Create comp records (end)   *****/
	/*
	** comp table
	*/
	SET @date_closed = GETDATE();

	SET @numberstr = DATENAME(hour, @date_closed);
	SET @time_closed_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @numberstr = DATENAME(minute, @date_closed);
	SET @time_closed_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @date_closed = CONVERT(datetime, CONVERT(date, @date_closed))

	BEGIN TRY
		UPDATE comp
			SET action_flag = 'N'
				,comp_code = @comp_code
				,date_closed = @date_closed
				,time_closed_h = @time_closed_h
				,time_closed_m = @time_closed_m
				,exact_location = (SELECT SUBSTRING(LTRIM(RTRIM([description])), 1, 70) FROM bv_transect WHERE transect_ref = @transect_ref)
			WHERE complaint_no = @complaint_no;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20476';
		SET @errortext = 'Error updating comp record';
		GOTO errorexit;
	END CATCH

	/*
	** diry table
	*/
	SELECT @po_code = LTRIM(RTRIM(po_code))
		FROM pda_user
		WHERE [user_name] = @entered_by;

	BEGIN TRY
		UPDATE diry
			SET action_flag = 'C'
				,dest_flag = 'C'
				,date_done = @date_closed
				,done_time_h = @time_closed_h
				,done_time_m = @time_closed_m
				,po_code = @po_code
			WHERE source_ref = @complaint_no;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20477';
		SET @errortext = 'Error updating diry record';
		GOTO errorexit;
	END CATCH

	/*
	** insp_list table
	*/
	BEGIN TRY
		DELETE FROM insp_list
			WHERE complaint_no = @complaint_no;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20478';
		SET @errortext = 'Error deleting insp_list record';
		GOTO errorexit;
	END CATCH

	/*
	** comp_bv199 table
	*/
	SELECT @rowcount = COUNT(*)
		FROM comp_bv199
		WHERE complaint_no = @complaint_no;

	IF @rowcount = 0
	BEGIN
		BEGIN TRY
			INSERT INTO comp_bv199
				(
				complaint_no
				,transect_ref
				,litter_grade
				,litter_text
				,detritus_grade
				,detritus_text
				,graffiti_grade
				,graffiti_text
				,flyposting_grade
				,flyposting_text
				)
				VALUES
				(
				@complaint_no
				,@transect_ref
				,@litter_grade
				,@litter_text
				,@detritus_grade
				,@detritus_text
				,@graffiti_grade
				,@graffiti_text
				,@flyposting_grade
				,@flyposting_text
				)
		END TRY
		BEGIN CATCH
			SET @errornumber = '20479';
			SET @errortext   = 'Error inserting comp_bv199 record';
			GOTO errorexit;
		END CATCH
	END

	BEGIN TRY
		/* Update #tempCompCore with actual data ready to return via @xmlCompCore */
		UPDATE #tempCompCore
			SET complaint_no = @complaint_no
			,entered_by = @entered_by
			,site_ref = @site_ref
			,site_name_1 = @site_name_1
			,site_distance = @site_distance
			,service_c = @service_c
			,service_c_desc = @service_c_desc
			,item_ref = @item_ref
			,item_desc = @item_desc
			,feature_ref = @feature_ref
			,feature_desc = @feature_desc
			,contract_ref = @contract_ref
			,[contract_name] = @contract_name
			,comp_code = @comp_code
			,comp_code_desc = @comp_code_desc
			,action_flag = @action_flag
			,compl_init = @compl_init
			,compl_name = @compl_name
			,compl_surname = @compl_surname
			,compl_build_no = @compl_build_no
			,compl_build_name = @compl_build_name
			,compl_addr2 = @compl_addr2
			,compl_addr4 = @compl_addr4
			,compl_addr5 = @compl_addr5
			,compl_addr6 = @compl_addr6
			,compl_postcode = @compl_postcode
			,compl_phone = @compl_phone
			,compl_email = @compl_email
			,compl_business = @compl_business
			,int_ext_flag = @int_ext_flag
			,date_entered = @date_entered
			,ent_time_h = @ent_time_h
			,ent_time_m = @ent_time_m
			,dest_ref = @dest_ref
			,dest_suffix = @dest_suffix
			,date_due = @date_due
			,date_closed = @date_closed
			,incident_id = @incident_id
			,details_1 = @details_1
			,details_2 = @details_2
			,details_3 = @details_3
			,notice_type = @notice_type
	END TRY
	BEGIN CATCH
		SET @errornumber = '20480';
		SET @errortext = 'Error updating #tempCompCore record';
		GOTO errorexit;
	END CATCH
	BEGIN TRY
		SET @xmlcompcore = (SELECT * FROM #tempCompCore FOR XML PATH('CustCareCoreDTO'))
	END TRY
	BEGIN CATCH
		SET @errornumber = '20481';
		SET @errortext = 'Error updating @xmlCompCore';
		GOTO errorexit;
	END CATCH

	BEGIN TRY
		/* Update #tempCompNI195Survey with new complaint_no's ready to return via @xmlCompNI195Survey */
		UPDATE #tempCompNI195Survey
			SET litter_complaint_no = @litter_complaint_no
				,detritus_complaint_no = @detritus_complaint_no
				,graffiti_complaint_no = @graffiti_complaint_no
				,flyposting_complaint_no = @flyposting_complaint_no
	END TRY
	BEGIN CATCH
		SET @errornumber = '20482';
		SET @errortext = 'Error updating #tempCompNI195Survey record';
		GOTO errorexit;
	END CATCH
	BEGIN TRY
		SET @xmlCompNI195Survey = (SELECT * FROM #tempCompNI195Survey FOR XML PATH('NI195SurveyDTO'))
	END TRY
	BEGIN CATCH
		SET @errornumber = '20483';
		SET @errortext = 'Error updating @xmlCompNI195Survey';
		GOTO errorexit;
	END CATCH

normalexit:
	RETURN @complaint_no;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO
