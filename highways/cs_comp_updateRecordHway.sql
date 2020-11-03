/*****************************************************************************
** dbo.cs_comp_updateRecordHway
** stored procedure
**
** Description
** Update a customer care record, etc. for service type Highways
**
** Parameters
** @xmlCompHway = XML structure containing comp (Highways) record
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
** 07/10/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_comp_updateRecordHway', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comp_updateRecordHway;
GO
CREATE PROCEDURE dbo.cs_comp_updateRecordHway
	@xmlCompHway xml OUTPUT,
	@comp_notes varchar(MAX) = NULL OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @result integer
		,@errortext varchar(500)
		,@errornumber varchar(10)
		,@comp_rowcount integer
		,@compHway_rowcount integer
		,@old_action_flag varchar(1)
		,@old_item_ref varchar(12)
		,@old_comp_code varchar(6)
		,@numberstr varchar(2)

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

		/* Highways data */
		,@x_value decimal(7,1)
		,@y_value decimal(7,1)
		,@linear_value decimal(10,1)
		,@area_value decimal(10,1)
		,@priority varchar(1)
		,@oldrecordcount integer;

	SET @errornumber = '20783';
	
	IF OBJECT_ID('tempdb..#tempCompHway') IS NOT NULL
	BEGIN
		DROP TABLE #tempCompHway;
	END

	BEGIN TRY
		SELECT
			xmldoc.compHway.value('complaint_no[1]','integer') AS 'complaint_no'
			,xmldoc.compHway.value('entered_by[1]','varchar(8)') AS 'entered_by'
			,xmldoc.compHway.value('site_ref[1]','varchar(16)') AS 'site_ref'
			,xmldoc.compHway.value('site_name_1[1]','varchar(70)') AS 'site_name_1'
			,xmldoc.compHway.value('site_distance[1]','decimal(10,2)') AS 'site_distance'
			,xmldoc.compHway.value('exact_location[1]','varchar(70)') AS 'exact_location'
			,xmldoc.compHway.value('service_c[1]','varchar(6)') AS 'service_c'
			,xmldoc.compHway.value('service_c_desc[1]','varchar(40)') AS 'service_c_desc'
			,xmldoc.compHway.value('item_ref[1]','varchar(12)') AS 'item_ref'
			,xmldoc.compHway.value('item_desc[1]','varchar(40)') AS 'item_desc'
			,xmldoc.compHway.value('feature_ref[1]','varchar(12)') AS 'feature_ref'
			,xmldoc.compHway.value('feature_desc[1]','varchar(40)') AS 'feature_desc'
			,xmldoc.compHway.value('contract_ref[1]','varchar(12)') AS 'contract_ref'
			,xmldoc.compHway.value('contract_name[1]','varchar(40)') AS 'contract_name'
			,xmldoc.compHway.value('comp_code[1]','varchar(6)') AS 'comp_code'
			,xmldoc.compHway.value('comp_code_desc[1]','varchar(40)') AS 'comp_code_desc'
			,xmldoc.compHway.value('occur_day[1]','varchar(7)') AS 'occur_day'
			,xmldoc.compHway.value('round_c[1]','varchar(10)') AS 'round_c'
			,xmldoc.compHway.value('pa_area[1]','varchar(6)') AS 'pa_area'
			,xmldoc.compHway.value('action_flag[1]','varchar(1)') AS 'action_flag'
			,xmldoc.compHway.value('compl_init[1]','varchar(10)') AS 'compl_init'
			,xmldoc.compHway.value('compl_name[1]','varchar(100)') AS 'compl_name'
			,xmldoc.compHway.value('compl_surname[1]','varchar(100)') AS 'compl_surname'
			,xmldoc.compHway.value('compl_build_no[1]','varchar(14)') AS 'compl_build_no'
			,xmldoc.compHway.value('compl_build_name[1]','varchar(14)') AS 'compl_build_name'
			,xmldoc.compHway.value('compl_addr2[1]','varchar(100)') AS 'compl_addr2'
			,xmldoc.compHway.value('compl_addr4[1]','varchar(40)') AS 'compl_addr4'
			,xmldoc.compHway.value('compl_addr5[1]','varchar(30)') AS 'compl_addr5'
			,xmldoc.compHway.value('compl_addr6[1]','varchar(30)') AS 'compl_addr6'
			,xmldoc.compHway.value('compl_postcode[1]','varchar(8)') AS 'compl_postcode'
			,xmldoc.compHway.value('compl_phone[1]','varchar(20)') AS 'compl_phone'
			,xmldoc.compHway.value('compl_email[1]','varchar(40)') AS 'compl_email'
			,xmldoc.compHway.value('compl_business[1]','varchar(100)') AS 'compl_business'
			,xmldoc.compHway.value('int_ext_flag[1]','varchar(1)') AS 'int_ext_flag'
			,xmldoc.compHway.value('date_entered[1]','datetime') AS 'date_entered'
			,xmldoc.compHway.value('ent_time_h[1]','char(2)') AS 'ent_time_h'
			,xmldoc.compHway.value('ent_time_m[1]','char(2)') AS 'ent_time_m'
			,xmldoc.compHway.value('dest_ref[1]','integer') AS 'dest_ref'
			,xmldoc.compHway.value('dest_suffix[1]','varchar(6)') AS 'dest_suffix'
			,xmldoc.compHway.value('date_due[1]','datetime') AS 'date_due'
			,xmldoc.compHway.value('date_closed[1]','datetime') AS 'date_closed'
			,xmldoc.compHway.value('incident_id[1]','varchar(20)') AS 'incident_id'
			,xmldoc.compHway.value('details_1[1]','varchar(70)') AS 'details_1'
			,xmldoc.compHway.value('details_2[1]','varchar(70)') AS 'details_2'
			,xmldoc.compHway.value('details_3[1]','varchar(70)') AS 'details_3'
			,xmldoc.compHway.value('notice_type[1]','varchar(1)') AS 'notice_type'

			,xmldoc.compHway.value('x_value[1]','decimal(7,1)') AS 'x_value'
			,xmldoc.compHway.value('y_value[1]','decimal(7,1)') AS 'y_value'
			,xmldoc.compHway.value('linear_value[1]','decimal(10,1)') AS 'linear_value'
			,xmldoc.compHway.value('area_value[1]','decimal(10,1)') AS 'area_value'
			,xmldoc.compHway.value('priority[1]','varchar(1)') AS 'priority'
		INTO #tempCompHway
		FROM @xmlCompHway.nodes('/CustCareHwayDTO') AS xmldoc(compHway);

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

			,@x_value = x_value
			,@y_value = y_value
			,@linear_value = linear_value
			,@area_value = area_value
			,@priority = [priority]
		FROM #tempCompHway;

		SET @compHway_rowcount = @@ROWCOUNT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20784';
		SET @errortext = 'Error processing @xmlCompHway';
		GOTO errorexit;
	END CATCH

	IF @compHway_rowcount > 1
	BEGIN
		SET @errornumber = '20785';
		SET @errortext = 'Error processing @xmlCompHway - too many rows';
		GOTO errorexit;
	END
	IF @compHway_rowcount < 1
	BEGIN
		SET @errornumber = '20786';
		SET @errortext = 'Error processing @xmlCompHway - no rows found';
		GOTO errorexit;
	END

	SET @entered_by = LTRIM(RTRIM(@entered_by));

	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @errornumber = '20787';
		SET @errortext = 'complaint_no is required';
		GOTO errorexit;
	END
	SELECT @comp_rowcount = COUNT(*)
		FROM comp
		WHERE complaint_no = @complaint_no
	IF @comp_rowcount <> 1
	BEGIN
		SET @errornumber = '20788';
		SET @errortext = LTRIM(RTRIM(STR(@complaint_no))) + ' is not a valid complaint reference';
		GOTO errorexit;
	END

	/* @entered_by validation */
	/* Assuming that @entered_by has already been validated by calling process(es) */
	/* so only a basic test here for non-blank and non-null data being passed */
	IF @entered_by = '' OR @entered_by IS NULL
	BEGIN
		SET @errornumber = '20789';
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
		SET @errornumber = '20790';
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
			SET @errornumber = '20791';
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
		SET @errornumber = '20792';
		SET @errortext = 'Error updating diry record';
		GOTO errorexit;
	END CATCH

	SELECT @oldrecordcount = COUNT(*)
		FROM comp_measurement
		WHERE complaint_no = @complaint_no;

	IF @oldrecordcount = 0
	BEGIN
		BEGIN TRY
			INSERT INTO comp_measurement
				(
				complaint_no,
				x_value,
				y_value,
				z_value,
				linear_value,
				area_value,
				[priority]
				)
				VALUES
				(
				@complaint_no,
				@x_value,
				@y_value,
				0,
				@linear_value,
				@area_value,
				@priority
				);
		END TRY
		BEGIN CATCH
			SET @errornumber = '20799';
			SET @errortext = 'Error inserting comp_measurement record';
			GOTO errorexit;
		END CATCH
	END
	ELSE
	BEGIN
		BEGIN TRY
			UPDATE comp_measurement
				SET x_value = @x_value
					,y_value = @y_value
					,linear_value = @linear_value
					,area_value = @area_value
					,[priority] = @priority
				WHERE complaint_no = @complaint_no;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20800';
			SET @errortext = 'Error updating comp_measurement record';
			GOTO errorexit;
		END CATCH
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
				SET @errornumber = '20793';
				SET @errortext = ERROR_MESSAGE();
				GOTO errorexit;
			END CATCH
		END
		ELSE
		BEGIN
			IF @action_flag <> 'W'
			BEGIN
				BEGIN TRY
					SET @errornumber = '20794';
					SET @errortext = 'Error updating comp record';

					UPDATE comp
						SET action_flag = @action_flag
						WHERE complaint_no = @complaint_no;

					SET @errornumber = '20795';
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
			SET @errornumber = '20796';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH

		SET @comp_notes = dbo.cs_comptext_getNotes(@complaint_no, 0);
	END

	BEGIN TRY
		/* Update #tempCompHway with actual data ready to return via @xmlCompHway */
		UPDATE #tempCompHway
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
			,x_value = @x_value
			,y_value = @y_value
			,linear_value = @linear_value
			,area_value = @area_value
			,[priority] = @priority
	END TRY
	BEGIN CATCH
		SET @errornumber = '20797';
		SET @errortext = 'Error updating #tempCompHway record';
		GOTO errorexit;
	END CATCH
	BEGIN TRY
		SET @xmlCompHway = (SELECT * FROM #tempCompHway FOR XML PATH('CustCareHwayDTO'))
	END TRY
	BEGIN CATCH
		SET @errornumber = '20798';
		SET @errortext = 'Error updating @xmlCompHway';
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
