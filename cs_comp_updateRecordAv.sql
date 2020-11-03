/*****************************************************************************
** dbo.cs_comp_updateRecordAv
** stored procedure
**
** Description
** Update a customer care record, etc. for service type AV Abandoned Vehicles
**
** Parameters
** @xmlCompAV = XML structure containing comp (AV) record (complaint_no + changed data only)
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
** 24/02/2013  TW  New
** 17/07/2013  TW  Remove call to cs_customer_updateRecord
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_comp_updateRecordAv', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comp_updateRecordAv;
GO
CREATE PROCEDURE dbo.cs_comp_updateRecordAv
	@xmlCompAv xml OUTPUT,
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

		,@compav_rowcount integer

		,@old_action_flag varchar(1)
		,@old_date_stickered datetime
		,@old_status_ref varchar(6)
		,@valid_status_ref smallint

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
		,@round_c varchar(10)
		,@pa_area varchar(6)

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

		/* AV core data */
		,@generated_no varchar(20)
		,@car_id varchar(12)
		,@make_ref integer
		,@make_desc varchar(20)
		,@model_ref integer
		,@model_desc varchar(20)
		,@colour_ref integer
		,@colour_desc varchar(15)
		,@date_stickered datetime
		,@time_stickered_h char(2)
		,@time_stickered_m char(2)
		,@vehicle_class char(1)
		,@officer_id integer
		,@road_fund_flag varchar(1)
		,@road_fund_valid datetime
		,@last_seq integer
		,@date_police_email datetime
		,@date_fire_email datetime
		,@date_housing_email datetime
		,@dho_rep integer
		,@dho_cc_building varchar(20)
		,@how_long_there varchar(10)
		,@vin varchar(30)

		/* AV status data */
		,@status_ref varchar(6)
		,@status_description varchar(40)
		,@status_notes varchar(200)
		,@status_days_remaining integer
		,@keeper_required integer
		,@open_yn char(1)
		,@closed_yn char(1)
		,@delay integer
		,@expiry_date datetime
		
	SET @errornumber = '11500';
	
	IF OBJECT_ID('tempdb..#tempCompAv') IS NOT NULL
	BEGIN
		DROP TABLE #tempCompAv;
	END

	BEGIN TRY
		SELECT
			xmldoc.compav.value('complaint_no[1]','integer') AS 'complaint_no'
			,xmldoc.compav.value('entered_by[1]','varchar(8)') AS 'entered_by'
			,xmldoc.compav.value('site_ref[1]','varchar(16)') AS 'site_ref'
			,xmldoc.compav.value('site_name_1[1]','varchar(70)') AS 'site_name_1'
			,xmldoc.compav.value('site_distance[1]','decimal(10,2)') AS 'site_distance'
			,xmldoc.compav.value('exact_location[1]','varchar(70)') AS 'exact_location'
			,xmldoc.compav.value('service_c[1]','varchar(6)') AS 'service_c'
			,xmldoc.compav.value('service_c_desc[1]','varchar(40)') AS 'service_c_desc'
			,xmldoc.compav.value('item_ref[1]','varchar(12)') AS 'item_ref'
			,xmldoc.compav.value('item_desc[1]','varchar(40)') AS 'item_desc'
			,xmldoc.compav.value('feature_ref[1]','varchar(12)') AS 'feature_ref'
			,xmldoc.compav.value('feature_desc[1]','varchar(40)') AS 'feature_desc'
			,xmldoc.compav.value('contract_ref[1]','varchar(12)') AS 'contract_ref'
			,xmldoc.compav.value('contract_name[1]','varchar(40)') AS 'contract_name'
			,xmldoc.compav.value('comp_code[1]','varchar(6)') AS 'comp_code'
			,xmldoc.compav.value('comp_code_desc[1]','varchar(40)') AS 'comp_code_desc'
			,xmldoc.compav.value('occur_day[1]','varchar(7)') AS 'occur_day'
			,xmldoc.compav.value('round_c[1]','varchar(10)') AS 'round_c'
			,xmldoc.compav.value('pa_area[1]','varchar(6)') AS 'pa_area'
			,xmldoc.compav.value('action_flag[1]','varchar(1)') AS 'action_flag'
			,xmldoc.compav.value('compl_init[1]','varchar(10)') AS 'compl_init'
			,xmldoc.compav.value('compl_name[1]','varchar(100)') AS 'compl_name'
			,xmldoc.compav.value('compl_surname[1]','varchar(100)') AS 'compl_surname'
			,xmldoc.compav.value('compl_build_no[1]','varchar(14)') AS 'compl_build_no'
			,xmldoc.compav.value('compl_build_name[1]','varchar(14)') AS 'compl_build_name'
			,xmldoc.compav.value('compl_addr2[1]','varchar(100)') AS 'compl_addr2'
			,xmldoc.compav.value('compl_addr4[1]','varchar(40)') AS 'compl_addr4'
			,xmldoc.compav.value('compl_addr5[1]','varchar(30)') AS 'compl_addr5'
			,xmldoc.compav.value('compl_addr6[1]','varchar(30)') AS 'compl_addr6'
			,xmldoc.compav.value('compl_postcode[1]','varchar(8)') AS 'compl_postcode'
			,xmldoc.compav.value('compl_phone[1]','varchar(20)') AS 'compl_phone'
			,xmldoc.compav.value('compl_email[1]','varchar(40)') AS 'compl_email'
			,xmldoc.compav.value('compl_business[1]','varchar(100)') AS 'compl_business'
			,xmldoc.compav.value('int_ext_flag[1]','varchar(1)') AS 'int_ext_flag'
			,xmldoc.compav.value('date_entered[1]','datetime') AS 'date_entered'
			,xmldoc.compav.value('ent_time_h[1]','char(2)') AS 'ent_time_h'
			,xmldoc.compav.value('ent_time_m[1]','char(2)') AS 'ent_time_m'
			,xmldoc.compav.value('dest_ref[1]','integer') AS 'dest_ref'
			,xmldoc.compav.value('dest_suffix[1]','varchar(6)') AS 'dest_suffix'
			,xmldoc.compav.value('date_due[1]','datetime') AS 'date_due'
			,xmldoc.compav.value('date_closed[1]','datetime') AS 'date_closed'
			,xmldoc.compav.value('incident_id[1]','varchar(20)') AS 'incident_id'
			,xmldoc.compav.value('details_1[1]','varchar(70)') AS 'details_1'
			,xmldoc.compav.value('details_2[1]','varchar(70)') AS 'details_2'
			,xmldoc.compav.value('details_3[1]','varchar(70)') AS 'details_3'
			,xmldoc.compav.value('notice_type[1]','varchar(1)') AS 'notice_type'
			,xmldoc.compav.value('generated_no[1]','varchar(20)') AS 'generated_no'
			,xmldoc.compav.value('car_id[1]','varchar(12)') AS 'car_id'
			,xmldoc.compav.value('make_ref[1]','integer') AS 'make_ref'
			,xmldoc.compav.value('make_desc[1]','varchar(20)') AS 'make_desc'
			,xmldoc.compav.value('model_ref[1]','integer') AS 'model_ref'
			,xmldoc.compav.value('model_desc[1]','varchar(20)') AS 'model_desc'
			,xmldoc.compav.value('colour_ref[1]','integer') AS 'colour_ref'
			,xmldoc.compav.value('colour_desc[1]','varchar(15)') AS 'colour_desc'
			,xmldoc.compav.value('date_stickered[1]','datetime') AS 'date_stickered'
			,xmldoc.compav.value('time_stickered_h[1]','char(2)') AS 'time_stickered_h'
			,xmldoc.compav.value('time_stickered_m[1]','char(2)') AS 'time_stickered_m'
			,xmldoc.compav.value('vehicle_class[1]','varchar(1)') AS 'vehicle_class'
			,xmldoc.compav.value('officer_id[1]','integer') AS 'officer_id'
			,xmldoc.compav.value('road_fund_flag[1]','varchar(1)') AS 'road_fund_flag'
			,xmldoc.compav.value('road_fund_valid[1]','datetime') AS 'road_fund_valid'
			,xmldoc.compav.value('last_seq[1]','integer') AS 'last_seq'
			,xmldoc.compav.value('date_police_email[1]','datetime') AS 'date_police_email'
			,xmldoc.compav.value('date_fire_email[1]','datetime') AS 'date_fire_email'
			,xmldoc.compav.value('date_housing_email[1]','datetime') AS 'date_housing_email'
			,xmldoc.compav.value('dho_rep[1]','integer') AS 'dho_rep'
			,xmldoc.compav.value('dho_cc_building[1]','varchar(20)') AS 'dho_cc_building'
			,xmldoc.compav.value('how_long_there[1]','varchar(10)') AS 'how_long_there'
			,xmldoc.compav.value('vin[1]','varchar(30)') AS 'vin'
			,xmldoc.compav.value('status_ref[1]','varchar(6)') AS 'status_ref'
			,xmldoc.compav.value('status_description[1]','varchar(6)') AS 'status_description'
			,xmldoc.compav.value('status_notes[1]','varchar(200)') AS 'status_notes'
			,xmldoc.compav.value('status_days_remaining[1]','integer') AS 'status_days_remaining'
			,xmldoc.compav.value('keeper_required[1]','integer') AS 'keeper_required'
		INTO #tempCompAv
		FROM @xmlCompAv.nodes('/CustCareAVDTO') AS xmldoc(compav);

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
			,@action_flag = action_flag
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
			,@generated_no = generated_no
			,@car_id = car_id
			,@make_ref = make_ref
			,@make_desc = make_desc
			,@model_ref = model_ref
			,@model_desc = model_desc
			,@colour_ref = colour_ref
			,@colour_desc = colour_desc
			,@date_stickered = date_stickered
			,@time_stickered_h = time_stickered_h
			,@time_stickered_m = time_stickered_m
			,@vehicle_class = vehicle_class
			,@officer_id = officer_id
			,@road_fund_flag = road_fund_flag
			,@road_fund_valid = road_fund_valid
			,@last_seq = last_seq
			,@date_police_email = date_police_email
			,@date_fire_email = date_fire_email
			,@date_housing_email = date_housing_email
			,@dho_rep = dho_rep
			,@dho_cc_building = dho_cc_building
			,@how_long_there = how_long_there
			,@vin = vin
			,@status_ref = status_ref
			,@status_description = status_description
			,@status_notes = LTRIM(RTRIM(status_notes))
			,@status_days_remaining = status_days_remaining
			,@keeper_required = keeper_required
		FROM #tempCompAv;

		SET @compav_rowcount = @@ROWCOUNT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '11501';
		SET @errortext = 'Error processing @xmlCompAv';
		GOTO errorexit;
	END CATCH

	IF @compav_rowcount > 1
	BEGIN
		SET @errornumber = '11502';
		SET @errortext = 'Error processing @xmlCompAv - too many rows';
		GOTO errorexit;
	END
	IF @compav_rowcount < 1
	BEGIN
		SET @errornumber = '11503';
		SET @errortext = 'Error processing @xmlCompAv - no rows found';
		GOTO errorexit;
	END

	SET @entered_by = LTRIM(RTRIM(@entered_by));

	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @errornumber = '11504';
		SET @errortext = 'complaint_no is required';
		GOTO errorexit;
	END
	SELECT @comp_rowcount = COUNT(*)
		FROM comp
		WHERE complaint_no = @complaint_no
	IF @comp_rowcount <> 1
	BEGIN
		SET @errornumber = '11505';
		SET @errortext = LTRIM(RTRIM(STR(@complaint_no))) + ' is not a valid complaint reference';
		GOTO errorexit;
	END

	/* @entered_by validation */
	/* Assuming that @entered_by has already been validated by calling process(es) */
	/* so only a basic test here for non-blank and non-null data being passed */
	IF @entered_by = '' OR @entered_by IS NULL
	BEGIN
		SET @errornumber = '11506';
		SET @errortext = 'entered_by is required';
		GOTO errorexit;
	END

	SELECT @old_action_flag = action_flag
		FROM comp
		WHERE complaint_no = @complaint_no;
	IF @@ROWCOUNT < 1
	BEGIN
		SET @errornumber = '11507';
		SET @errortext = 'Enquiry (comp) ' + LTRIM(RTRIM(STR(@complaint_no))) + ' not found';
		GOTO errorexit;
	END

	SELECT @old_date_stickered = date_stickered
		FROM comp_av
		WHERE complaint_no = @complaint_no;
	IF @@ROWCOUNT < 1
	BEGIN
		SET @errornumber = '11508';
		SET @errortext = 'Enquiry (comp_av) ' + LTRIM(RTRIM(STR(@complaint_no))) + ' not found';
		GOTO errorexit;
	END

	/* date_stickered has been input */
	IF @old_date_stickered IS NULL AND @date_stickered IS NOT NULL
	BEGIN
		SET @numberstr = DATENAME(hour, @date_stickered);
		SET @time_stickered_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

		SET @numberstr = DATENAME(minute, @date_stickered);
		SET @time_stickered_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

		SET @date_stickered = CONVERT(datetime, CONVERT(date, @date_stickered));

		BEGIN TRY
			UPDATE comp_av
				SET date_stickered = @date_stickered,
					time_stickered_h = @time_stickered_h,
					time_stickered_m = @time_stickered_m
				WHERE complaint_no = @complaint_no
		END TRY
		BEGIN CATCH
			SET @errornumber = '11509';
			SET @errortext = 'Error inserting comp_av record';
			GOTO errorexit;
		END CATCH
	END

	/* status update */
	IF @status_ref <> '' AND @status_ref IS NOT NULL
	BEGIN
		/* @status_ref validation */
		EXECUTE @valid_status_ref = dbo.cs_avstatus_validateNextStatus @complaint_no, @status_ref
		IF @valid_status_ref <> 1
		BEGIN
			SET @errornumber = '11510';
			SET @errortext = @status_ref + ' is not a valid next status';
			GOTO errorexit;
		END

		BEGIN TRY
			EXECUTE dbo.cs_compavhist_updateStatus
				@complaint_no,
				@status_ref,
				@status_notes,
				@entered_by;
		END TRY
		BEGIN CATCH
			SET @errornumber = '11511';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH
	END

	/*
	** diry table
	*/
	SET @date_entered = GETDATE();

	SET @numberstr = DATENAME(hour, @date_entered);
	SET @ent_time_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @numberstr = DATENAME(minute, @date_entered);
	SET @ent_time_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @date_entered = CONVERT(datetime, CONVERT(date, @date_entered));

	IF @date_due IS NULL
	BEGIN
		SET @date_due = @date_entered;
	END
	ELSE
	BEGIN
		SET @date_due = CONVERT(datetime, CONVERT(date, @date_due));
	END

	SELECT @site_ref = LTRIM(RTRIM(site_ref)),
		@item_ref = LTRIM(RTRIM(item_ref)),
		@contract_ref = LTRIM(RTRIM(contract_ref)),
		@feature_ref = LTRIM(RTRIM(feature_ref))
		FROM comp
		WHERE complaint_no = @complaint_no;

	SET @pa_area = dbo.cs_site_getPaArea(@site_ref, @service_c);

	BEGIN TRY
		UPDATE diry
			SET site_ref = @site_ref,
				item_ref = @item_ref,
				contract_ref = @contract_ref,
				inspect_ref = NULL,
				inspect_seq = NULL,
				feature_ref = @feature_ref,
				date_due = @date_due,
				pa_area = @pa_area,
				action_flag = @action_flag
			WHERE source_ref = @complaint_no
				AND source_flag = 'C';
	END TRY
	BEGIN CATCH
		SET @errornumber = '20378';
		SET @errortext = 'Error updating diry record';
		GOTO errorexit;
	END CATCH

	/* action_flag has changed */
	IF @action_flag <> @old_action_flag AND @action_flag <> '' AND @action_flag IS NOT NULL
	BEGIN
		IF @action_flag = 'N'
		BEGIN
			BEGIN TRY
				SET @date_closed = GETDATE();

				EXECUTE dbo.cs_comp_closeRecordCore
					@complaint_no,
					@entered_by,
					@date_closed OUTPUT,
					@dest_ref OUTPUT;
			END TRY
			BEGIN CATCH
				SET @errornumber = '11512';
				SET @errortext = ERROR_MESSAGE();
				GOTO errorexit;
			END CATCH
		END
		ELSE
		BEGIN
			IF @action_flag <> 'W'
			BEGIN
				BEGIN TRY
					SET @errornumber = '11513';
					SET @errortext = 'Error updating comp record';

					UPDATE comp
						SET action_flag = @action_flag
						WHERE complaint_no = @complaint_no;

					SET @errornumber = '11514';
					SET @errortext = 'Error updating comp diry record';

					UPDATE diry
						SET action_flag = @action_flag
						WHERE source_ref = @complaint_no
							AND source_flag = 'C';
				END TRY
				BEGIN CATCH
					/* Appropriate error message previously assigned */
					GOTO errorexit;
				END CATCH
			END
		END
	END

	/* New notes */
	IF LEN(@comp_notes) > 0
	BEGIN
		BEGIN TRY
			EXECUTE dbo.cs_comptext_updateNotes
				@complaint_no,
				@entered_by,
				@comp_notes;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20024';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH

		SET @comp_notes = dbo.cs_comptext_getNotes(@complaint_no, 0);
	END

	BEGIN TRY
		/* Update #tempCompAv with actual data ready to return via @xmlCompAv */
		UPDATE #tempCompAv
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
			,generated_no = @generated_no
			,car_id = @car_id
			,make_ref = @make_ref
			,make_desc = @make_desc
			,model_ref = @model_ref
			,model_desc = @model_desc
			,colour_ref = @colour_ref
			,colour_desc = @colour_desc
			,date_stickered = @date_stickered
			,time_stickered_h = @time_stickered_h
			,time_stickered_m = @time_stickered_m
			,vehicle_class = @vehicle_class
			,officer_id = @officer_id
			,road_fund_flag = @road_fund_flag
			,road_fund_valid = @road_fund_valid
			,last_seq = @last_seq
			,date_police_email = @date_police_email
			,date_fire_email = @date_fire_email
			,date_housing_email = @date_housing_email
			,dho_rep = @dho_rep
			,dho_cc_building = @dho_cc_building
			,how_long_there = @how_long_there
			,vin = @vin
			,status_ref = @status_ref
			,status_description = @status_description
			,status_notes = @status_notes
			,status_days_remaining = @status_days_remaining
			,keeper_required = @keeper_required;
	END TRY
	BEGIN CATCH
		SET @errornumber = '11515';
		SET @errortext = 'Error updating #tempCompAv record';
		GOTO errorexit;
	END CATCH
	BEGIN TRY
		SET @xmlCompAv = (SELECT * FROM #tempCompAv FOR XML PATH('CustCareAVDTO'))
	END TRY
	BEGIN CATCH
		SET @errornumber = '11516';
		SET @errortext = 'Error updating @xmlCompAv';
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
