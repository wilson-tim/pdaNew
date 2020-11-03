/*****************************************************************************
** dbo.cs_comp_createRecordEnf
** stored procedure
**
** Description
** Create a customer care record, etc. for service type ENF Enforcement
**
** Parameters
** @xmlCompEnf = XML structure containing comp (ENF) record
** @comp_notes = notes
**
** Returned
** All passed parameters are INPUT and OUTPUT
** Return value of new complaint_no or -1
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
** 28/02/2013  TW  New
** 03/03/2013  TW  Continued
** 04/03/2013  TW  Continued
** 27/03/2013  TW  Linked enforcement - do not copy customer details from original complaint
** 17/06/2013  TW  Moved comp_destination insert command to avoid duplication
**                 Moved diry and comp_enf_link inserts too
** 01/07/2013  TW  Processing for fly capture data
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_comp_createRecordEnf', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comp_createRecordEnf;
GO
CREATE PROCEDURE dbo.cs_comp_createRecordEnf
	@xmlCompEnf xml OUTPUT,
	@comp_notes varchar(MAX) = NULL OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @result integer
		,@errortext varchar(500)
		,@errornumber varchar(10)
		,@comp_rowcount integer
		,@numberstr varchar(2)
		,@seq integer

		,@compenf_rowcount integer
		,@recvd_by varchar(6)
		,@location_c varchar(10)
		,@build_no varchar(14)
		,@build_sub_no varchar(14)
		,@build_name varchar(100)
		,@build_sub_name varchar(100)
		,@location_name varchar(100)
		,@location_desc varchar(100)
		,@area_ward_desc varchar(100)
		,@townname varchar(30)
		,@countyname varchar(30)
		,@posttown varchar(30)
		,@postcode varchar(8)
		,@easting decimal(10,2)
		,@northing decimal(10,2)
		,@easting_end decimal(10,2)
		,@northing_end decimal(10,2)
		,@comp_customer_no integer
		,@cs_flag char(1)
		,@comp_to_def char(1)
		,@comp_diry_ref integer
		,@diry_ref integer
		,@enf_cost_installed char(1)
		,@enf_cost_admin_code varchar(8)
		,@enf_cost_description varchar(40)
		,@enf_cost_unit_basis decimal(4,2)
		,@enf_cost_unit_price decimal(10,4)
		,@unit_basis decimal(8,2)
		,@unit_price decimal(8,2)
		,@unit_value decimal(12,2)
		,@comp_service_c varchar(6)

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
		,@occur_day varchar(7)
		,@round_c varchar(10)
		,@pa_area varchar(6)
		,@action_flag varchar(1)

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

		/* ENF core data */
		,@law_ref varchar(6)
		,@law_desc varchar(40)
		,@offence_ref varchar(6)
		,@offence_desc varchar(40)
		,@offence_datetime datetime
		,@inv_officer varchar(6)
		,@inv_officer_desc varchar(40)
		,@enf_officer varchar(6)
		,@enf_officer_desc varchar(40)
		,@enf_status varchar(6)
		,@enf_status_desc varchar(40)
		,@suspect_ref integer
		,@suspect_name varchar(60)
		,@suspect_company varchar(50)
		,@actions integer
		,@action_seq integer
		,@action_ref varchar(6)
		,@car_id varchar(12)
		,@source_ref integer
		,@inv_period_start datetime
		,@inv_period_finish datetime
		,@agreement_no integer
		,@agreement_name varchar(60)
		,@site_name varchar(60)
		,@offence_time_h char(2)
		,@offence_time_m char(2)
		,@action_datetime datetime
		,@do_date datetime
		,@aut_officer varchar(6)
		,@aut_officer_desc varchar(40)

		/* ENF action data */
		
		/* ENF evidence data */
		
		/* ENF suspect data */

	SET @errornumber = '11000';

	IF OBJECT_ID('tempdb..#tempCompEnf') IS NOT NULL
	BEGIN
		DROP TABLE #tempCompEnf;
	END

	BEGIN TRY
		SELECT
			xmldoc.compenf.value('complaint_no[1]','integer') AS 'complaint_no'
			,xmldoc.compenf.value('entered_by[1]','varchar(8)') AS 'entered_by'
			,xmldoc.compenf.value('site_ref[1]','varchar(16)') AS 'site_ref'
			,xmldoc.compenf.value('site_name_1[1]','varchar(70)') AS 'site_name_1'
			,xmldoc.compenf.value('site_distance[1]','decimal(10,2)') AS 'site_distance'
			,xmldoc.compenf.value('exact_location[1]','varchar(70)') AS 'exact_location'
			,xmldoc.compenf.value('service_c[1]','varchar(6)') AS 'service_c'
			,xmldoc.compenf.value('service_c_desc[1]','varchar(40)') AS 'service_c_desc'
			,xmldoc.compenf.value('item_ref[1]','varchar(12)') AS 'item_ref'
			,xmldoc.compenf.value('item_desc[1]','varchar(40)') AS 'item_desc'
			,xmldoc.compenf.value('feature_ref[1]','varchar(12)') AS 'feature_ref'
			,xmldoc.compenf.value('feature_desc[1]','varchar(40)') AS 'feature_desc'
			,xmldoc.compenf.value('contract_ref[1]','varchar(12)') AS 'contract_ref'
			,xmldoc.compenf.value('contract_name[1]','varchar(40)') AS 'contract_name'
			,xmldoc.compenf.value('comp_code[1]','varchar(6)') AS 'comp_code'
			,xmldoc.compenf.value('comp_code_desc[1]','varchar(40)') AS 'comp_code_desc'
			,xmldoc.compenf.value('occur_day[1]','varchar(7)') AS 'occur_day'
			,xmldoc.compenf.value('round_c[1]','varchar(10)') AS 'round_c'
			,xmldoc.compenf.value('pa_area[1]','varchar(6)') AS 'pa_area'
			,xmldoc.compenf.value('action_flag[1]','varchar(1)') AS 'action_flag'
			,xmldoc.compenf.value('compl_init[1]','varchar(10)') AS 'compl_init'
			,xmldoc.compenf.value('compl_name[1]','varchar(100)') AS 'compl_name'
			,xmldoc.compenf.value('compl_surname[1]','varchar(100)') AS 'compl_surname'
			,xmldoc.compenf.value('compl_build_no[1]','varchar(14)') AS 'compl_build_no'
			,xmldoc.compenf.value('compl_build_name[1]','varchar(14)') AS 'compl_build_name'
			,xmldoc.compenf.value('compl_addr2[1]','varchar(100)') AS 'compl_addr2'
			,xmldoc.compenf.value('compl_addr4[1]','varchar(40)') AS 'compl_addr4'
			,xmldoc.compenf.value('compl_addr5[1]','varchar(30)') AS 'compl_addr5'
			,xmldoc.compenf.value('compl_addr6[1]','varchar(30)') AS 'compl_addr6'
			,xmldoc.compenf.value('compl_postcode[1]','varchar(8)') AS 'compl_postcode'
			,xmldoc.compenf.value('compl_phone[1]','varchar(20)') AS 'compl_phone'
			,xmldoc.compenf.value('compl_email[1]','varchar(40)') AS 'compl_email'
			,xmldoc.compenf.value('compl_business[1]','varchar(100)') AS 'compl_business'
			,xmldoc.compenf.value('int_ext_flag[1]','varchar(1)') AS 'int_ext_flag'
			,xmldoc.compenf.value('date_entered[1]','datetime') AS 'date_entered'
			,xmldoc.compenf.value('ent_time_h[1]','char(2)') AS 'ent_time_h'
			,xmldoc.compenf.value('ent_time_m[1]','char(2)') AS 'ent_time_m'
			,xmldoc.compenf.value('dest_ref[1]','integer') AS 'dest_ref'
			,xmldoc.compenf.value('dest_suffix[1]','varchar(6)') AS 'dest_suffix'
			,xmldoc.compenf.value('date_due[1]','datetime') AS 'date_due'
			,xmldoc.compenf.value('date_closed[1]','datetime') AS 'date_closed'
			,xmldoc.compenf.value('incident_id[1]','varchar(20)') AS 'incident_id'
			,xmldoc.compenf.value('details_1[1]','varchar(70)') AS 'details_1'
			,xmldoc.compenf.value('details_2[1]','varchar(70)') AS 'details_2'
			,xmldoc.compenf.value('details_3[1]','varchar(70)') AS 'details_3'
			,xmldoc.compenf.value('notice_type[1]','varchar(1)') AS 'notice_type'
			,xmldoc.compenf.value('law_ref[1]','varchar(6)') AS 'law_ref'
			,xmldoc.compenf.value('law_desc[1]','varchar(40)') AS 'law_desc'
			,xmldoc.compenf.value('offence_ref[1]','varchar(6)') AS 'offence_ref'
			,xmldoc.compenf.value('offence_desc[1]','varchar(40)') AS 'offence_desc'
			,xmldoc.compenf.value('offence_datetime[1]','datetime') AS 'offence_datetime'
			,xmldoc.compenf.value('inv_officer[1]','varchar(6)') AS 'inv_officer'
			,xmldoc.compenf.value('inv_officer_desc[1]','varchar(40)') AS 'inv_officer_desc'
			,xmldoc.compenf.value('enf_officer[1]','varchar(6)') AS 'enf_officer'
			,xmldoc.compenf.value('enf_officer_desc[1]','varchar(40)') AS 'enf_officer_desc'
			,xmldoc.compenf.value('enf_status[1]','varchar(6)') AS 'enf_status'
			,xmldoc.compenf.value('enf_status_desc[1]','varchar(40)') AS 'enf_status_desc'
			,xmldoc.compenf.value('suspect_ref[1]','varchar(6)') AS 'suspect_ref'
			,xmldoc.compenf.value('suspect_name[1]','varchar(60)') AS 'suspect_name'
			,xmldoc.compenf.value('suspect_company[1]','varchar(50)') AS 'suspect_company'
			,xmldoc.compenf.value('actions[1]','integer') AS 'actions'
			,xmldoc.compenf.value('action_seq[1]','integer') AS 'action_seq'
			,xmldoc.compenf.value('action_ref[1]','varchar(6)') AS 'action_ref'
			,xmldoc.compenf.value('car_id[1]','varchar(12)') AS 'car_id'
			,xmldoc.compenf.value('source_ref[1]','integer') AS 'source_ref'
			,xmldoc.compenf.value('inv_period_start[1]','datetime') AS 'inv_period_start'
			,xmldoc.compenf.value('inv_period_finish[1]','datetime') AS 'inv_period_finish'
			,xmldoc.compenf.value('agreement_no[1]','integer') AS 'agreement_no'
			,xmldoc.compenf.value('agreement_name[1]','varchar(60)') AS 'agreement_name'
			,xmldoc.compenf.value('site_name[1]','varchar(60)') AS 'site_name'
			,xmldoc.compenf.value('offence_time_h[1]','char(2)') AS 'offence_time_h'
			,xmldoc.compenf.value('offence_time_m[1]','char(2)') AS 'offence_time_m'
			,xmldoc.compenf.value('action_datetime[1]','datetime') AS 'action_datetime'
			,xmldoc.compenf.value('do_date[1]','datetime') AS 'do_date'
			,xmldoc.compenf.value('aut_officer[1]','varchar(6)') AS 'aut_officer'
			,xmldoc.compenf.value('aut_officer_desc[1]','varchar(40)') AS 'aut_officer_desc'
		INTO #tempCompEnf
		FROM @xmlCompEnf.nodes('/CustCareEnfDTO') AS xmldoc(compenf);

		SELECT @complaint_no = complaint_no
			,@entered_by = LTRIM(RTRIM(entered_by))
			,@site_ref = LTRIM(RTRIM(site_ref))
			,@site_name_1 = site_name_1
			,@site_distance = site_distance
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
			,@law_ref = law_ref
			,@law_desc = law_desc
			,@offence_ref= offence_ref
			,@offence_desc= offence_desc
			,@offence_datetime = offence_datetime
			,@inv_officer = inv_officer
			,@inv_officer_desc = inv_officer_desc
			,@enf_officer = enf_officer
			,@enf_officer_desc = enf_officer_desc
			,@enf_status = enf_status
			,@enf_status_desc = enf_status_desc
			,@suspect_ref = suspect_ref
			,@actions = actions
			,@action_seq = action_seq
			,@action_ref = action_ref
			,@car_id = car_id
			,@source_ref = source_ref
			,@inv_period_start = inv_period_start
			,@inv_period_finish = inv_period_finish
			,@agreement_no = agreement_no
			,@agreement_name = agreement_name
			,@site_name = site_name
			,@offence_time_h = offence_time_h
			,@offence_time_m = offence_time_m
			,@action_datetime = action_datetime
			,@do_date = do_date
			,@aut_officer = aut_officer
			,@aut_officer_desc = aut_officer_desc
		FROM #tempCompEnf;

		SET @compenf_rowcount = @@ROWCOUNT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '11001';
		SET @errortext = 'Error processing @xmlCompEnf';
		GOTO errorexit;
	END CATCH

	IF @compenf_rowcount > 1
	BEGIN
		SET @errornumber = '11002';
		SET @errortext = 'Error processing @xmlCompEnf - too many rows';
		GOTO errorexit;
	END
	IF @compenf_rowcount < 1
	BEGIN
		SET @errornumber = '11003';
		SET @errortext = 'Error processing @xmlCompEnf - no rows found';
		GOTO errorexit;
	END

	SET @service_c = LTRIM(RTRIM(@service_c));
	SET @site_ref = LTRIM(RTRIM(@site_ref));
	SET @item_ref = LTRIM(RTRIM(@item_ref));
	SET @feature_ref = LTRIM(RTRIM(@feature_ref));
	SET @contract_ref = LTRIM(RTRIM(@contract_ref));
	SET @comp_code = LTRIM(RTRIM(@comp_code));
	SET @entered_by = LTRIM(RTRIM(@entered_by));
	SET @action_flag = LTRIM(RTRIM(@action_flag));
	SET @comp_notes = LTRIM(RTRIM(@comp_notes));
	SET @exact_location = LTRIM(RTRIM(@exact_location));

	/* @comp_code validation */
	IF @comp_code = '' OR @comp_code IS NULL
	BEGIN
		SELECT @comp_code = c_field, 
               @comp_code_desc = keydesc
          FROM keys
         WHERE keyname = 'ENF_COMP_CODE'
			AND service_c = 'ALL';

		IF @comp_code = '' OR @comp_code IS NULL
		BEGIN
			SET @errornumber = '11004';
			SET @errortext = 'comp_code is not defined in system key ENF_COMP_CODE';
			GOTO errorexit;
		END
	END

	/* @item_ref validation */
	IF @item_ref = '' OR @item_ref IS NULL
	BEGIN
		SELECT @item_ref = c_field,
			@item_desc = keydesc
			FROM keys
			WHERE keyname = 'ENF_ITEM'
				AND service_c = 'ALL';

		IF @item_ref = '' OR @item_ref IS NULL
		BEGIN
			SET @errornumber = '11005';
			SET @errortext = 'item_ref is not defined in system key ENF_ITEM';
			GOTO errorexit;
		END
	END

	/* @service_c validation */
	IF @service_c = '' OR @service_c IS NULL
	BEGIN
		SELECT @service_c = LTRIM(RTRIM(c_field))
          FROM keys
         WHERE keyname = 'ENF_SERVICE'
			AND service_c = 'ALL';

		IF @service_c = '' OR @service_c IS NULL
		BEGIN
			SET @errornumber = '11006';
			SET @errortext = 'service_c is not defined in system key ENF_SERVICE';
			GOTO errorexit;
		END
	END


	/* @contract_ref validation */
	IF @contract_ref = '' OR @contract_ref IS NULL
	BEGIN
		SELECT @contract_ref = contract_ref,
			@contract_name = [contract_name]
			FROM cont
			WHERE service_c = @service_c;

		IF @contract_ref = '' OR @contract_ref IS NULL
		BEGIN
			SET @errornumber = '11007';
			SET @errortext = 'contract_ref is not defined in the cont table for service ' + @service_c;
			GOTO errorexit;
		END
	END

	/* @feature_ref validation */
	IF @feature_ref = '' OR @feature_ref IS NULL
	BEGIN
		SELECT @feature_ref = it_f.feature_ref,
			@feature_desc = feature_desc
			FROM it_f
			INNER JOIN feat
			ON feat.feature_ref=it_f.feature_ref
			WHERE item_ref = @item_ref;

		IF @feature_ref = '' OR @feature_ref IS NULL
		BEGIN
			SET @errornumber = '11008';
			SET @errortext = 'feature_ref is not defined in the it_f table for item_ref ' + @item_ref;
			GOTO errorexit;
		END
	END

	/* @suspect_ref validation */
	IF @suspect_ref = 0 OR @suspect_ref IS NULL
	BEGIN
		SET @errornumber = '20097';
		SET @errortext   = 'suspect_ref is required';
		GOTO errorexit;
	END

	/* @action_flag */
	SET @action_flag = 'N';

	/* @inv_officer */
	SET @inv_officer = dbo.cs_pdauser_getEnfOfficerPoCode(@entered_by);
	IF @inv_officer = '' OR @inv_officer is NULL
	BEGIN
		SET @errornumber = '20133';
		SET @errortext = 'inv_officer is required';
		GOTO errorexit;
	END

	/* @enf_officer */
	SET @enf_officer = dbo.cs_pdauser_getEnfOfficerPoCode(@entered_by);
	IF @enf_officer = '' OR @enf_officer is NULL
	BEGIN
		SET @errornumber = '20134';
		SET @errortext = 'enf_officer is required';
		GOTO errorexit;
	END

	/*
	** Standalone or linked enquiry?
	*/
	IF @source_ref = 0 OR @source_ref IS NULL
	BEGIN
		/* Create a new comp record */

		/* @entered_by validation */
		/* Assuming that @entered_by has already been validated by calling process(es) */
		/* so only a basic test here for non-blank and non-null data being passed */
		IF @entered_by = '' OR @entered_by IS NULL
		BEGIN
			SET @errornumber = '11009';
			SET @errortext = 'entered_by is required';
			GOTO errorexit;
		END

		/* @site_ref validation */
		IF @site_ref = '' OR @site_ref IS NULL
		BEGIN
			SET @errornumber = '11010';
			SET @errortext = 'site_ref is required';
			GOTO errorexit;
		END
		SELECT site_name_1
			FROM site
			WHERE site_ref = @site_ref;
		IF @@ROWCOUNT = 0
		BEGIN
			SET @errornumber = '11011';
			SET @errortext = @site_ref + ' is not a valid site reference';
			GOTO errorexit;
		END

		BEGIN TRY
			EXECUTE dbo.cs_comp_createRecordCoreNonXml
				@entered_by OUTPUT,
				@site_ref OUTPUT,
				@site_name_1,
				@exact_location OUTPUT,
				@service_c OUTPUT,
				@service_c_desc,
				@comp_code OUTPUT,
				@comp_code_desc,
				@item_ref OUTPUT,
				@item_desc,
				@feature_ref OUTPUT,
				@feature_desc,
				@contract_ref OUTPUT,
				@contract_name OUTPUT,
				@action_flag OUTPUT,
				@comp_notes OUTPUT,
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
				@complaint_no OUTPUT,
				@date_entered OUTPUT,
				@ent_time_h OUTPUT,
				@ent_time_m OUTPUT,
				@dest_ref OUTPUT,
				@dest_suffix OUTPUT,
				@date_due OUTPUT,
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
			SET @errornumber = '11012';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH
	END
	ELSE
	BEGIN
		/* Copy linked enquiry record */

		/* Validate @source_ref */
		SELECT @comp_rowcount = COUNT(*)
			FROM comp
			WHERE complaint_no = @source_ref
		IF @comp_rowcount <> 1
		BEGIN
			SET @errornumber = '11013';
			SET @errortext = LTRIM(RTRIM(STR(@source_ref))) + ' is not a valid originating complaint reference';
			GOTO errorexit;
		END

		/* @car_id */
		SELECT @comp_service_c = service_c
			FROM comp
			WHERE complaint_no = @source_ref
		IF (dbo.cs_utils_getServiceType(@comp_service_c) = 'AV')
		BEGIN
			SELECT @car_id = car_id
				FROM comp_av
				WHERE complaint_no = @source_ref;
		END

		SELECT @entered_by = entered_by
			,@recvd_by = recvd_by
			,@site_ref = site_ref
			,@location_c = location_c
			,@build_no = build_no
			,@build_sub_no = build_sub_no
			,@build_name = build_name
			,@build_sub_name = build_sub_name
			,@location_name = location_name
			,@location_desc = location_desc
			,@area_ward_desc = area_ward_desc
			,@townname = townname
			,@countyname = countyname
			,@posttown = posttown
			,@postcode = postcode
			,@exact_location = exact_location
			,@incident_id = incident_id
			,@details_1 = details_1
			,@details_2 = details_2
			,@details_3 = details_3
			,@notice_type = notice_type
			,@occur_day = occur_day
			,@round_c = round_c
			,@pa_area = pa_area
			,@date_closed = date_closed
			,@time_closed_h = time_closed_h
			,@time_closed_m = time_closed_m
			,@dest_ref = dest_ref
			,@dest_suffix = dest_suffix
			,@easting = easting
			,@northing = northing
			,@easting_end = easting_end
			,@northing_end = northing_end
			FROM comp
			WHERE complaint_no = @source_ref;

		BEGIN TRY
			EXECUTE @result = dbo.cs_sno_getSerialNumber 'comp', '', @serial_no = @complaint_no OUTPUT;
		END TRY
		BEGIN CATCH
			SET @errornumber = '11014';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH

		SET @date_entered = GETDATE();

		SET @numberstr = DATENAME(hour, @date_entered);
		SET @ent_time_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

		SET @numberstr = DATENAME(minute, @date_entered);
		SET @ent_time_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

		SET @date_entered = CONVERT(datetime, CONVERT(date, @date_entered));

		/*
		** comp table
		*/
		BEGIN TRY
			INSERT INTO comp
				(
				complaint_no,
				date_entered,
				ent_time_h,
				ent_time_m,
				entered_by,
				recvd_by,
				site_ref,
				location_c,
				build_no,
				build_sub_no,
				build_name,
				build_sub_name,
				location_name,
				location_desc,
				area_ward_desc,
				townname,
				countyname,
				posttown,
				postcode,
				exact_location,
				details_1,
				details_2,
				details_3,
				notice_type,
				service_c,
				comp_code,
				item_ref,
				feature_ref,
				contract_ref,
				occur_day,
				round_c,
				pa_area,
				action_flag,
				dest_ref,
				dest_suffix,
				easting,
				northing,
				easting_end,
				northing_end,
				text_flag
				)
				VALUES
				(
				@complaint_no,
				@date_entered,
				@ent_time_h,
				@ent_time_m,
				@entered_by,
				@recvd_by,
				@site_ref,
				@location_c,
				@build_no,
				@build_sub_no,
				@build_name,
				@build_sub_name,
				@location_name,
				@location_desc,
				@area_ward_desc,
				@townname,
				@countyname,
				@posttown,
				@postcode,
				@exact_location,
				@details_1,
				@details_2,
				@details_3,
				@notice_type,
				@service_c,
				@comp_code,
				@item_ref,
				@feature_ref,
				@contract_ref,
				@occur_day,
				@round_c,
				@pa_area,
				@action_flag,
				@dest_ref,
				@dest_suffix,
				@easting,
				@northing,
				@easting_end,
				@northing_end,
				'N'
				);
		END TRY
		BEGIN CATCH
			SET @errornumber = '11015';
			SET @errortext = 'Error inserting comp record';
			GOTO errorexit;
		END CATCH

		/* Get the linked complaints customer */
/* 27/03/2013  TW  Linked enforcement - do not copy customer details from original complaint
		SELECT @comp_customer_no = customer_no
			FROM comp_clink
			WHERE complaint_no = @source_ref;

		SET @cs_flag = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'CS_FLAG'))));

		BEGIN TRY
			INSERT INTO comp_clink
				(
				complaint_no,
				customer_no,
				username,
				seq_no,
				date_added,
				time_added_h,
				time_added_m,
				cust_satisfaction
				)
				VALUES
				(
				@complaint_no,
				@comp_customer_no,
				@entered_by,
				1,
				@date_entered,
				@ent_time_h,
				@ent_time_m,
				@cs_flag
				);
		END TRY
		BEGIN CATCH
			SET @errornumber = '11016';
			SET @errortext = 'Error inserting comp_clink record';
			GOTO errorexit;
		END CATCH
*/

		/*
		** comp_destination table
		*/
		BEGIN TRY
			INSERT INTO comp_destination
				(
				complaint_no
				)
				VALUES
				(
				@complaint_no
				);
		END TRY
		BEGIN CATCH
			SET @errornumber = '11021';
			SET @errortext = 'Error inserting comp_destination record';
			GOTO errorexit;
		END CATCH

		IF LEN(@comp_notes) > 0
		BEGIN
			BEGIN TRY
				EXECUTE dbo.cs_comptext_updateNotes
					@complaint_no,
					@entered_by,
					@comp_notes OUTPUT;
			END TRY
			BEGIN CATCH
				SET @errornumber = '20023';
				SET @errortext = ERROR_MESSAGE();
				GOTO errorexit;
			END CATCH
		END

		/*
		** diry table (linked enquiry)
		*/
		SELECT @comp_diry_ref = diry_ref
			FROM diry
			WHERE source_flag = 'C'
				AND source_ref = @source_ref;

		BEGIN TRY
			EXECUTE @result = dbo.cs_sno_getSerialNumber 'diry', '', @serial_no = @diry_ref OUTPUT;
		END TRY
		BEGIN CATCH
			SET @errornumber = '11022';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH
		BEGIN TRY
			INSERT INTO diry
				(
				diry_ref,
				prev_record,
				source_flag,
				source_ref,
				source_date,
				source_time_h,
				source_time_m,
				source_user,
				site_ref,
				item_ref,
				contract_ref,
				inspect_ref,
				inspect_seq,
				feature_ref,
				pa_area,
				action_flag,
				dest_flag,
				dest_date,
				dest_time_h,
				dest_time_m,
				dest_user
				)
				VALUES
				(
				@diry_ref,
				@comp_diry_ref,
				'C',
				@complaint_no,
				@date_entered,
				@ent_time_h,
				@ent_time_m,
				@entered_by,
				@site_ref,
				@item_ref,
				@contract_ref,
				NULL,
				NULL,
				@feature_ref,
				@pa_area,
				'C',
				'C',
				@date_entered,
				@ent_time_h,
				@ent_time_m,
				@entered_by
				);
		END TRY
		BEGIN CATCH
			SET @errornumber = '11023';
			SET @errortext = 'Error inserting diry record';
			GOTO errorexit;
		END CATCH

		/*
		** comp_enf_link table (linked enquiry)
		*/
		BEGIN TRY
			INSERT INTO comp_enf_link
				(
				enf_complaint_no,
				source_complaint
				)
				VALUES
				(
				@complaint_no,
				@source_ref
				);
		END TRY
		BEGIN CATCH
			SET @errornumber = '11020';
			SET @errortext = 'Error inserting comp_enf_link record';
			GOTO errorexit;
		END CATCH
	END

	/*
	** enf_suspect table
	*/
	BEGIN TRY
		UPDATE enf_suspect
			SET orig_compl_no = @complaint_no
			WHERE suspect_ref = @suspect_ref
			AND (orig_compl_no = 0 OR orig_compl_no IS NULL);
	END TRY
	BEGIN CATCH
		SET @errornumber = '20105';
		SET @errortext = 'Error updating enf_suspect (orig_compl_no)';
		GOTO errorexit;
	END CATCH

	/*
	** comp_enf table
	*/
	SET @enf_status = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'ENF_INITIAL_STATUS'))));

	SET @numberstr = DATENAME(hour, @offence_datetime);
	SET @offence_time_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @numberstr = DATENAME(minute, @offence_datetime);
	SET @offence_time_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @offence_datetime = CONVERT(datetime, CONVERT(date, @offence_datetime));

	BEGIN TRY
		INSERT INTO comp_enf
			(
			complaint_no,
			law_ref,
			offence_ref,
			offence_date,
			offence_time_h,
			offence_time_m,
			inv_officer,
			enf_officer,
			enf_status,
			suspect_ref,
			actions,
			car_id,
			source_ref,
			inv_period_start,
			inv_period_finish
			)
			VALUES
			(
			@complaint_no,
			@law_ref,
			@offence_ref,
			@offence_datetime,
			@offence_time_h,
			@offence_time_h,
			@inv_officer,
			@enf_officer,
			@enf_status,
			@suspect_ref,
			0,
			@car_id,
			@source_ref,
			@inv_period_start,
			@inv_period_finish
			);
	END TRY
	BEGIN CATCH
		SET @errornumber = '11019';
		SET @errortext = 'Error inserting comp_enf record';
		GOTO errorexit;
	END CATCH

	/*
	** enf_cost_trans table
	*/
	SET @enf_cost_installed = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'ENF_COST_INSTALLED'))));

	IF @enf_cost_installed = 'Y'
	BEGIN
		SET @enf_cost_admin_code = LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'ENF_COST_ADMIN_CODE')));

		SELECT @enf_cost_description = [description],
			@enf_cost_unit_basis = unit_basis,
			@enf_cost_unit_price = unit_price
		FROM enf_cost_rates
		WHERE rate_code = @enf_cost_admin_code;

		SET @unit_basis = @enf_cost_unit_basis;
		SET @unit_price = @enf_cost_unit_price;
		SET @unit_value = @unit_basis * @unit_price;

		BEGIN TRY
			INSERT INTO enf_cost_trans
				(
				complaint_no,
				sequence,
				rate_code,
				qty,
				unit_price,
				value,
				[text],
				action_code,
				username,
				cost_date,
				cost_time_h,
				cost_time_m
				)
				VALUES
				(
				@complaint_no,
				1,
				@enf_cost_admin_code,
				@unit_basis,
				@unit_price,
				@unit_value,
				@enf_cost_description,
				NULL,
				@entered_by,
				@date_entered,
				@ent_time_h,
				@ent_time_m
				)
		END TRY
		BEGIN CATCH
			SET @errornumber = '11024';
			SET @errortext = 'Error inserting enf_cost_trans record';
			GOTO errorexit;
		END CATCH
	END

	BEGIN TRY
		/* Update #tempCompEnf with actual data ready to return via @xmlCompEnf */
		UPDATE #tempCompEnf
			SET complaint_no = @complaint_no
			,entered_by = @entered_by
			,site_ref = @site_ref
			,site_name_1 = @site_name_1
			,site_distance = @site_distance
			,exact_location = @exact_location
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
			,occur_day = @occur_day
			,round_c = @round_c
			,pa_area = @pa_area
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
			,law_ref = @law_ref
			,law_desc = @law_desc
			,offence_ref= @offence_ref
			,offence_desc= @offence_desc
			,offence_datetime = @offence_datetime
			,inv_officer = @inv_officer
			,inv_officer_desc = @inv_officer_desc
			,enf_officer = @enf_officer
			,enf_officer_desc = @enf_officer_desc
			,enf_status = @enf_status
			,enf_status_desc = @enf_status_desc
			,suspect_ref = @suspect_ref
			,actions = @actions
			,action_seq = @action_seq
			,action_ref = @action_ref
			,car_id = @car_id
			,source_ref = @source_ref
			,inv_period_start = @inv_period_start
			,inv_period_finish = @inv_period_finish
			,agreement_no = @agreement_no
			,agreement_name = @agreement_name
			,site_name = @site_name
			,offence_time_h = @offence_time_h
			,offence_time_m = @offence_time_m
			,action_datetime = @action_datetime
			,do_date = @do_date
			,aut_officer = @aut_officer
	END TRY
	BEGIN CATCH
		SET @errornumber = '11025';
		SET @errortext = 'Error updating #tempCompEnf record';
		GOTO errorexit;
	END CATCH
	BEGIN TRY
		SET @xmlCompEnf = (SELECT * FROM #tempCompEnf FOR XML PATH('CustCareEnfDTO'))
	END TRY
	BEGIN CATCH
		SET @errornumber = '11026';
		SET @errortext = 'Error updating @xmlCompEnf';
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
