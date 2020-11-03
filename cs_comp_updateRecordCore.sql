/*****************************************************************************
** dbo.cs_comp_updateRecordCore
** stored procedure
**
** Description
** Update a customer care record, etc. for service type CORE
**
** Parameters
** @xmlCompCore = XML structure containing comp (CORE) record
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
** 03/05/2013  TW  New
** 07/05/2013  TW  Continued development
** 21/06/2013  TW  Added processing for fly capture data
**                 Added processing for change of item code, fault code, inspection date
** 02/07/2013  TW  Delay assignment of action flags D and W
** 11/07/2013  TW  Customer update
** 17/07/2013  TW  Remove call to cs_customer_updateRecord
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_comp_updateRecordCore', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comp_updateRecordCore;
GO
CREATE PROCEDURE dbo.cs_comp_updateRecordCore
	@xmlCompCore xml OUTPUT,
	@comp_notes varchar(MAX) = NULL OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @result integer
		,@errortext varchar(500)
		,@errornumber varchar(10)
		,@comp_rowcount integer
		,@numberstr varchar(2)
		,@flycap_rowcount integer

		,@compcore_rowcount integer

		,@old_action_flag varchar(1)
		,@old_item_ref varchar(12)
		,@old_comp_code varchar(6)

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

		/* fly capture data */
		,@landtype_ref varchar(6)
		,@dominant_waste_ref varchar(6)
		,@dominant_waste_qty integer
		,@load_ref varchar(2)
		,@load_unit_cost decimal(7,2)
		,@load_qty integer
		,@load_est_cost decimal(7,2)

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
		,@notice_type varchar(1);

	SET @errornumber = '20383';
	
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
			,xmldoc.compcore.value('landtype_ref[1]','varchar(6)') AS 'landtype_ref'
			,xmldoc.compcore.value('dominant_waste_ref[1]','varchar(6)') AS 'dominant_waste_ref'
			,xmldoc.compcore.value('dominant_waste_qty[1]','integer') AS 'dominant_waste_qty'
			,xmldoc.compcore.value('load_ref[1]','varchar(2)') AS 'load_ref'
			,xmldoc.compcore.value('load_unit_cost[1]','decimal(7,2)') AS 'load_unit_cost'
			,xmldoc.compcore.value('load_qty[1]','integer') AS 'load_qty'
			,xmldoc.compcore.value('load_est_cost[1]','decimal(7,2)') AS 'load_est_cost'
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
			,@landtype_ref = landtype_ref
			,@dominant_waste_ref = dominant_waste_ref
			,@dominant_waste_qty = dominant_waste_qty
			,@load_ref = load_ref
			,@load_unit_cost = load_unit_cost
			,@load_qty = load_qty
			,@load_est_cost = load_est_cost
		FROM #tempCompCore;

		SET @compcore_rowcount = @@ROWCOUNT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20384';
		SET @errortext = 'Error processing @xmlCompCore';
		GOTO errorexit;
	END CATCH

	IF @compCore_rowcount > 1
	BEGIN
		SET @errornumber = '20385';
		SET @errortext = 'Error processing @xmlCompCore - too many rows';
		GOTO errorexit;
	END
	IF @compCore_rowcount < 1
	BEGIN
		SET @errornumber = '20386';
		SET @errortext = 'Error processing @xmlCompCore - no rows found';
		GOTO errorexit;
	END

	SET @entered_by = LTRIM(RTRIM(@entered_by));

	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @errornumber = '20387';
		SET @errortext = 'complaint_no is required';
		GOTO errorexit;
	END
	SELECT @comp_rowcount = COUNT(*)
		FROM comp
		WHERE complaint_no = @complaint_no
	IF @comp_rowcount <> 1
	BEGIN
		SET @errornumber = '20388';
		SET @errortext = LTRIM(RTRIM(STR(@complaint_no))) + ' is not a valid complaint reference';
		GOTO errorexit;
	END

	/* @entered_by validation */
	/* Assuming that @entered_by has already been validated by calling process(es) */
	/* so only a basic test here for non-blank and non-null data being passed */
	IF @entered_by = '' OR @entered_by IS NULL
	BEGIN
		SET @errornumber = '20389';
		SET @errortext = 'entered_by is required';
		GOTO errorexit;
	END

	/* Check the action flag, etc. */
	SELECT @old_action_flag = action_flag
		,@old_item_ref = item_ref
		,@old_comp_code = comp_code
		FROM comp
		WHERE complaint_no = @complaint_no;
	IF @@ROWCOUNT < 1
	BEGIN
		SET @errornumber = '20615';
		SET @errortext = 'Enquiry (comp) ' + LTRIM(RTRIM(STR(@complaint_no))) + ' not found';
		GOTO errorexit;
	END

	/* item_ref, comp_code */
	/* Must update comp before the diry update */
	IF ((@item_ref <> '' AND @item_ref IS NOT NULL)
		AND (@old_item_ref <> @item_ref))
		OR ((@comp_code <> '' AND @comp_code IS NOT NULL)
		AND (@old_comp_code <> @comp_code))
	BEGIN
		BEGIN TRY
			UPDATE comp
				SET item_ref = @item_ref
					,comp_code = @comp_code
				WHERE complaint_no = @complaint_no;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20616';
			SET @errortext = 'Error updating comp record (item_ref and or comp_code change)';
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

	SELECT @pa_area = pa_area
		FROM si_i
		WHERE site_ref = @site_ref
			AND item_ref = @item_ref
			AND feature_ref = @feature_ref
			AND contract_ref = @contract_ref;

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
		SET @errornumber = '20390';
		SET @errortext = 'Error updating diry record';
		GOTO errorexit;
	END CATCH

	/*
	** comp_flycap
	*/
	IF @landtype_ref <> '' AND @landtype_ref IS NOT NULL
	BEGIN
		SELECT @load_unit_cost = unit_cost
			FROM fly_loads
			WHERE load_ref = @load_ref;

		SET @load_est_cost = @load_qty * @load_unit_cost;

		SELECT @flycap_rowcount = COUNT(*)
			FROM comp_flycap
			WHERE complaint_no = @complaint_no;

		IF @flycap_rowcount = 0
		BEGIN
			BEGIN TRY
				INSERT INTO comp_flycap
					(
					complaint_no
					,landtype_ref
					,dominant_waste_ref
					,dominant_waste_qty
					,load_ref
					,load_unit_cost
					,load_qty
					,load_est_cost
					)
					VALUES
					(
					@complaint_no
					,@landtype_ref
					,@dominant_waste_ref
					,@dominant_waste_qty
					,@load_ref
					,@load_unit_cost
					,@load_qty
					,@load_est_cost
					);
			END TRY
			BEGIN CATCH
				SET @errornumber = '20617';
				SET @errortext = 'Error inserting comp_flycap record';
				GOTO errorexit;
			END CATCH
		END
		ELSE
		BEGIN
			BEGIN TRY
				UPDATE comp_flycap
					SET landtype_ref = @landtype_ref
					,dominant_waste_ref = @dominant_waste_ref
					,dominant_waste_qty = @dominant_waste_qty
					,load_ref = @load_ref
					,load_unit_cost = @load_unit_cost
					,load_qty = @load_qty
					,load_est_cost = @load_est_cost
					WHERE complaint_no = @complaint_no;
			END TRY
			BEGIN CATCH
				SET @errornumber = '20618';
				SET @errortext = 'Error updating comp_flycap record';
				GOTO errorexit;
			END CATCH
		END
	END

	/* Check the action flag */
	SELECT @old_action_flag = action_flag
		FROM comp
		WHERE complaint_no = @complaint_no;
	IF @@ROWCOUNT < 1
	BEGIN
		SET @errornumber = '20391';
		SET @errortext = 'Enquiry (comp) ' + LTRIM(RTRIM(STR(@complaint_no))) + ' not found';
		GOTO errorexit;
	END

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
				SET @errornumber = '20392';
				SET @errortext = ERROR_MESSAGE();
				GOTO errorexit;
			END CATCH
		END
		ELSE
		BEGIN
			/* cs_defh_createRecordCore will update the action flag to 'D' */
			/* cs_woh_createRecordCore will update the action flag to 'W'  */
			/* These will be called directly by the business logic         */
			IF @action_flag <> 'A' AND @action_flag <> 'D' AND @action_flag <> 'W' AND @action_flag <> 'X'
			BEGIN
				BEGIN TRY
					SET @errornumber = '20393';
					SET @errortext = 'Error updating comp record';

					UPDATE comp
						SET action_flag = @action_flag
						WHERE complaint_no = @complaint_no;

					SET @errornumber = '20394';
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
			SET @errornumber = '20395';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH

		SET @comp_notes = dbo.cs_comptext_getNotes(@complaint_no, 0);
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
			,landtype_ref = @landtype_ref
			,dominant_waste_ref = @dominant_waste_ref
			,dominant_waste_qty = @dominant_waste_qty
			,load_ref = @load_ref
			,load_unit_cost = @load_unit_cost
			,load_qty = @load_qty
			,load_est_cost = @load_est_cost
	END TRY
	BEGIN CATCH
		SET @errornumber = '20396';
		SET @errortext = 'Error updating #tempCompCore record';
		GOTO errorexit;
	END CATCH
	BEGIN TRY
		SET @xmlcompcore = (SELECT * FROM #tempCompCore FOR XML PATH('CustCareCoreDTO'))
	END TRY
	BEGIN CATCH
		SET @errornumber = '20397';
		SET @errortext = 'Error updating @xmlCompCore';
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
