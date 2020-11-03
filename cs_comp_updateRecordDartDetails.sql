/*****************************************************************************
** dbo.cs_comp_updateRecordDartDetails
** stored procedure
**
** Description
** Update a customer care record, etc. for service type DART
**
** Parameters
** @xmlCompDart = XML structure containing comp (DART) record
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
** 02/05/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_comp_updateRecordDartDetails', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comp_updateRecordDartDetails;
GO
CREATE PROCEDURE dbo.cs_comp_updateRecordDartDetails
	@xmlCompDart xml OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @result integer
		,@errortext varchar(500)
		,@errornumber varchar(10)
		,@comp_rowcount integer
		,@numberstr varchar(2)
		,@log_seq integer
		,@compdart_rowcount integer
		,@oldrecordcount integer

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

		/* DART data */
		,@rep_needle_qty integer
		,@rep_crack_pipe_qty integer
		,@rep_condom_qty integer
		,@col_needle_qty integer
		,@col_crack_pipe_qty integer
		,@col_condom_qty integer
		,@wo_est_cost decimal(10,2)
		,@po_code varchar(6)
		,@completion_date datetime
		,@completion_time_h char(2)
		,@completion_time_m char(2)
		,@est_duration_date datetime
		,@est_duration_h char(2)
		,@est_duration_m char(2)
		,@refuse_pay varchar(1)
		,@drtrep varchar(500)
		,@drtpar varchar(500)
		,@drtasw varchar(500)
		,@abuse varchar(500);

	SET @errornumber = '20358';
	
	IF OBJECT_ID('tempdb..#tempCompDart') IS NOT NULL
	BEGIN
		DROP TABLE #tempCompDart;
	END

	BEGIN TRY
		SELECT
			xmldoc.compdart.value('complaint_no[1]','integer') AS 'complaint_no'
			,xmldoc.compdart.value('entered_by[1]','varchar(8)') AS 'entered_by'
			,xmldoc.compdart.value('site_ref[1]','varchar(16)') AS 'site_ref'
			,xmldoc.compdart.value('site_name_1[1]','varchar(70)') AS 'site_name_1'
			,xmldoc.compdart.value('site_distance[1]','decimal(10,2)') AS 'site_distance'
			,xmldoc.compdart.value('exact_location[1]','varchar(70)') AS 'exact_location'
			,xmldoc.compdart.value('service_c[1]','varchar(6)') AS 'service_c'
			,xmldoc.compdart.value('service_c_desc[1]','varchar(40)') AS 'service_c_desc'
			,xmldoc.compdart.value('item_ref[1]','varchar(12)') AS 'item_ref'
			,xmldoc.compdart.value('item_desc[1]','varchar(40)') AS 'item_desc'
			,xmldoc.compdart.value('feature_ref[1]','varchar(12)') AS 'feature_ref'
			,xmldoc.compdart.value('feature_desc[1]','varchar(40)') AS 'feature_desc'
			,xmldoc.compdart.value('contract_ref[1]','varchar(12)') AS 'contract_ref'
			,xmldoc.compdart.value('contract_name[1]','varchar(40)') AS 'contract_name'
			,xmldoc.compdart.value('comp_code[1]','varchar(6)') AS 'comp_code'
			,xmldoc.compdart.value('comp_code_desc[1]','varchar(40)') AS 'comp_code_desc'
			,xmldoc.compdart.value('occur_day[1]','varchar(7)') AS 'occur_day'
			,xmldoc.compdart.value('round_c[1]','varchar(10)') AS 'round_c'
			,xmldoc.compdart.value('pa_area[1]','varchar(6)') AS 'pa_area'
			,xmldoc.compdart.value('action_flag[1]','varchar(1)') AS 'action_flag'
			,xmldoc.compdart.value('compl_init[1]','varchar(10)') AS 'compl_init'
			,xmldoc.compdart.value('compl_name[1]','varchar(100)') AS 'compl_name'
			,xmldoc.compdart.value('compl_surname[1]','varchar(100)') AS 'compl_surname'
			,xmldoc.compdart.value('compl_build_no[1]','varchar(14)') AS 'compl_build_no'
			,xmldoc.compdart.value('compl_build_name[1]','varchar(14)') AS 'compl_build_name'
			,xmldoc.compdart.value('compl_addr2[1]','varchar(100)') AS 'compl_addr2'
			,xmldoc.compdart.value('compl_addr4[1]','varchar(40)') AS 'compl_addr4'
			,xmldoc.compdart.value('compl_addr5[1]','varchar(30)') AS 'compl_addr5'
			,xmldoc.compdart.value('compl_addr6[1]','varchar(30)') AS 'compl_addr6'
			,xmldoc.compdart.value('compl_postcode[1]','varchar(8)') AS 'compl_postcode'
			,xmldoc.compdart.value('compl_phone[1]','varchar(20)') AS 'compl_phone'
			,xmldoc.compdart.value('compl_email[1]','varchar(40)') AS 'compl_email'
			,xmldoc.compdart.value('compl_business[1]','varchar(100)') AS 'compl_business'
			,xmldoc.compdart.value('int_ext_flag[1]','varchar(1)') AS 'int_ext_flag'
			,xmldoc.compdart.value('date_entered[1]','datetime') AS 'date_entered'
			,xmldoc.compdart.value('ent_time_h[1]','char(2)') AS 'ent_time_h'
			,xmldoc.compdart.value('ent_time_m[1]','char(2)') AS 'ent_time_m'
			,xmldoc.compdart.value('dest_ref[1]','integer') AS 'dest_ref'
			,xmldoc.compdart.value('dest_suffix[1]','varchar(6)') AS 'dest_suffix'
			,xmldoc.compdart.value('date_due[1]','datetime') AS 'date_due'
			,xmldoc.compdart.value('date_closed[1]','datetime') AS 'date_closed'
			,xmldoc.compdart.value('incident_id[1]','varchar(20)') AS 'incident_id'
			,xmldoc.compdart.value('details_1[1]','varchar(70)') AS 'details_1'
			,xmldoc.compdart.value('details_2[1]','varchar(70)') AS 'details_2'
			,xmldoc.compdart.value('details_3[1]','varchar(70)') AS 'details_3'
			,xmldoc.compdart.value('notice_type[1]','varchar(1)') AS 'notice_type'

			,xmldoc.compdart.value('rep_needle_qty[1]','integer') AS 'rep_needle_qty'
			,xmldoc.compdart.value('rep_crack_pipe_qty[1]','integer') AS 'rep_crack_pipe_qty'
			,xmldoc.compdart.value('rep_condom_qty[1]','integer') AS 'rep_condom_qty'
			,xmldoc.compdart.value('col_needle_qty[1]','integer') AS 'col_needle_qty'
			,xmldoc.compdart.value('col_crack_pipe_qty[1]','integer') AS 'col_crack_pipe_qty'
			,xmldoc.compdart.value('col_condom_qty[1]','integer') AS 'col_condom_qty'
			,xmldoc.compdart.value('wo_est_cost[1]','decimal(10,2)') AS 'wo_est_cost'
			,xmldoc.compdart.value('po_code[1]','varchar(6)') AS 'po_code'
			,xmldoc.compdart.value('completion_date[1]','datetime') AS 'completion_date'
			,xmldoc.compdart.value('completion_time_h[1]','char(2)') AS 'completion_time_h'
			,xmldoc.compdart.value('completion_time_m[1]','char(2)') AS 'completion_time_m'
			,xmldoc.compdart.value('est_duration_date[1]','datetime') AS 'est_duration_date'
			,xmldoc.compdart.value('est_duration_h[1]','char(2)') AS 'est_duration_h'
			,xmldoc.compdart.value('est_duration_m[1]','char(2)') AS 'est_duration_m'
			,xmldoc.compdart.value('refuse_pay[1]','varchar(1)') AS 'refuse_pay'
			,xmldoc.compdart.value('DRTREP[1]','varchar(500)') AS 'DRTREP'
			,xmldoc.compdart.value('DRTPAR[1]','varchar(500)') AS 'DRTPAR'
			,xmldoc.compdart.value('DRTASW[1]','varchar(500)') AS 'DRTASW'
			,xmldoc.compdart.value('ABUSE[1]','varchar(500)') AS 'ABUSE'
		INTO #tempCompDart
		FROM @xmlCompDart.nodes('/CustCareDartDTO') AS xmldoc(compdart);

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

			,@rep_needle_qty = rep_needle_qty
			,@rep_crack_pipe_qty = rep_crack_pipe_qty
			,@rep_condom_qty = rep_condom_qty
			,@col_needle_qty = col_needle_qty
			,@col_crack_pipe_qty = col_crack_pipe_qty
			,@col_condom_qty = col_condom_qty
			,@wo_est_cost = wo_est_cost
			,@refuse_pay = UPPER(refuse_pay)
			,@est_duration_date = est_duration_date
			,@est_duration_h = STUFF(LTRIM(RTRIM(STR(est_duration_h))), 1, 0, REPLICATE('0', 2 - LEN(LTRIM(RTRIM(STR(est_duration_h))))))
			,@est_duration_m = STUFF(LTRIM(RTRIM(STR(est_duration_m))), 1, 0, REPLICATE('0', 2 - LEN(LTRIM(RTRIM(STR(est_duration_m))))))
			,@completion_date = completion_date
			,@drtrep = UPPER(LTRIM(RTRIM(drtrep)))
			,@drtpar = UPPER(LTRIM(RTRIM(drtpar)))
			,@drtasw = UPPER(LTRIM(RTRIM(drtasw)))
			,@abuse = UPPER(LTRIM(RTRIM(abuse)))
		FROM #tempCompDart;

		SET @compdart_rowcount = @@ROWCOUNT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20359';
		SET @errortext = 'Error processing @xmlCompDart';
		GOTO errorexit;
	END CATCH

	IF @compdart_rowcount > 1
	BEGIN
		SET @errornumber = '20360';
		SET @errortext = 'Error processing @xmlCompDart - too many rows';
		GOTO errorexit;
	END
	IF @compdart_rowcount < 1
	BEGIN
		SET @errornumber = '20361';
		SET @errortext = 'Error processing @xmlCompDart - no rows found';
		GOTO errorexit;
	END

	SET @entered_by = LTRIM(RTRIM(@entered_by));

	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @errornumber = '20362';
		SET @errortext = 'complaint_no is required';
		GOTO errorexit;
	END
	SELECT @comp_rowcount = COUNT(*)
		FROM comp
		WHERE complaint_no = @complaint_no
	IF @comp_rowcount <> 1
	BEGIN
		SET @errornumber = '20363';
		SET @errortext = LTRIM(RTRIM(STR(@complaint_no))) + ' is not a valid complaint reference';
		GOTO errorexit;
	END

	/* @entered_by validation */
	/* Assuming that @entered_by has already been validated by calling process(es) */
	/* so only a basic test here for non-blank and non-null data being passed */
	IF @entered_by = '' OR @entered_by IS NULL
	BEGIN
		SET @errornumber = '20364';
		SET @errortext = 'entered_by is required';
		GOTO errorexit;
	END

	/* @po_code */
	SELECT @po_code = po_code
		FROM pda_user
		WHERE [user_name] = @entered_by;

	/* comp_dart_header table */
	IF @completion_date IS NOT NULL
	BEGIN
		SET @numberstr = DATENAME(hour, @completion_date);
		SET @completion_time_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

		SET @numberstr = DATENAME(minute, @completion_date);
		SET @completion_time_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

		SET @completion_date = CONVERT(datetime, CONVERT(date, @completion_date));
	END
	ELSE
	BEGIN
		SET @completion_date   = NULL;
		SET @completion_time_h = NULL;
		SET @completion_time_m = NULL;
	END

	IF @est_duration_date IS NOT NULL
	BEGIN
		SET @numberstr = DATENAME(hour, @est_duration_date);
		SET @est_duration_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

		SET @numberstr = DATENAME(minute, @est_duration_date);
		SET @est_duration_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

		SET @est_duration_date = CONVERT(datetime, CONVERT(date, @est_duration_date));
	END
	ELSE
	BEGIN
		SET @est_duration_date   = NULL;
		SET @est_duration_h = NULL;
		SET @est_duration_m = NULL;
	END

	SELECT @oldrecordcount = COUNT(*)
		FROM comp_dart_header
		WHERE complaint_no = @complaint_no;

	IF @oldrecordcount = 0
	BEGIN
		BEGIN TRY
			INSERT INTO comp_dart_header
				(
				complaint_no
				,rep_needle_qty
				,rep_crack_pipe_qty
				,rep_condom_qty
				,col_needle_qty
				,col_crack_pipe_qty
				,col_condom_qty
				,wo_est_cost
				,refuse_pay
				,est_duration_h
				,est_duration_m
				,po_code
				,completion_date
				,completion_time_h
				,completion_time_m
				)
				VALUES
				(
				@complaint_no
				,@rep_needle_qty
				,@rep_crack_pipe_qty
				,@rep_condom_qty
				,@col_needle_qty
				,@col_crack_pipe_qty
				,@col_condom_qty
				,@wo_est_cost
				,@refuse_pay
				,@est_duration_h
				,@est_duration_m
				,@po_code
				,@completion_date
				,@completion_time_h
				,@completion_time_m
				);
		END TRY
		BEGIN CATCH
			SET @errornumber = '20365';
			SET @errortext = 'Error inserting comp_dart_header record';
			GOTO errorexit;
		END CATCH
	END
	ELSE
	BEGIN
		BEGIN TRY
			UPDATE comp_dart_header
				SET complaint_no = @complaint_no
					,rep_needle_qty = @rep_needle_qty
					,rep_crack_pipe_qty = @rep_crack_pipe_qty
					,rep_condom_qty = @rep_condom_qty
					,col_needle_qty = @col_needle_qty
					,col_crack_pipe_qty = @col_crack_pipe_qty
					,col_condom_qty = @col_condom_qty
					,wo_est_cost = @wo_est_cost
					,refuse_pay = @refuse_pay
					,est_duration_h = @est_duration_h
					,est_duration_m = @est_duration_m
					,po_code = @po_code
					,completion_date = @completion_date
					,completion_time_h = @completion_time_h
					,completion_time_m = @completion_time_m
				WHERE complaint_no = @complaint_no;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20366';
			SET @errortext = 'Error updating comp_dart_header record';
			GOTO errorexit;
		END CATCH
	END

	/*
	** comp_dart_hdr_log table
	*/
	IF @date_entered IS NULL
	BEGIN
		SET @date_entered = GETDATE();

		SET @numberstr = DATENAME(hour, @date_entered);
		SET @ent_time_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

		SET @numberstr = DATENAME(minute, @date_entered);
		SET @ent_time_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

		SET @date_entered = CONVERT(datetime, CONVERT(date, @date_entered));
	END

	SELECT @log_seq = COUNT(*)
		FROM comp_dart_hdr_log
		WHERE complaint_no = @complaint_no;

	SET @log_seq = @log_seq + 1;

	BEGIN TRY
		INSERT INTO comp_dart_hdr_log
			(
			complaint_no
			,rep_needle_qty
			,rep_crack_pipe_qty
			,rep_condom_qty
			,col_needle_qty
			,col_crack_pipe_qty
			,col_condom_qty
			,wo_est_cost
			,refuse_pay
			,est_duration_h
			,est_duration_m
			,po_code
			,completion_date
			,completion_time_h
			,completion_time_m
			,log_seq
			,log_username
			,log_date
			,log_time_h
			,log_time_m
			)
			VALUES
			(
			@complaint_no
			,@rep_needle_qty
			,@rep_crack_pipe_qty
			,@rep_condom_qty
			,@col_needle_qty
			,@col_crack_pipe_qty
			,@col_condom_qty
			,@wo_est_cost
			,@refuse_pay
			,@est_duration_h
			,@est_duration_m
			,@po_code
			,@completion_date
			,@completion_time_h
			,@completion_time_m
			,@log_seq
			,@entered_by
			,@date_entered
			,@ent_time_h
			,@ent_time_m
			);
	END TRY
	BEGIN CATCH
		SET @errornumber = '20367';
		SET @errortext = 'Error inserting comp_dart_hdr_log record';
		GOTO errorexit;
	END CATCH

	BEGIN TRY
		EXECUTE dbo.cs_compdartdetail_updateRecord
			@complaint_no,
			'DRTREP',
			@drtrep,
			@entered_by
	END TRY
	BEGIN CATCH
		SET @errornumber = '20368';
		SET @errortext   = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

	BEGIN TRY
		EXECUTE dbo.cs_compdartdetail_updateRecord
			@complaint_no,
			'DRTPAR',
			@drtpar,
			@entered_by
	END TRY
	BEGIN CATCH
		SET @errornumber = '20369';
		SET @errortext   = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

	BEGIN TRY
		EXECUTE dbo.cs_compdartdetail_updateRecord
			@complaint_no,
			'DRTASW',
			@drtasw,
			@entered_by
	END TRY
	BEGIN CATCH
		SET @errornumber = '20370';
		SET @errortext   = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

	BEGIN TRY
		EXECUTE dbo.cs_compdartdetail_updateRecord
			@complaint_no,
			'ABUSE',
			@abuse,
			@entered_by
	END TRY
	BEGIN CATCH
		SET @errornumber = '20371';
		SET @errortext   = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

	BEGIN TRY
		/* Update #tempCompDart with actual data ready to return via @xmlCompDart */
		UPDATE #tempCompDart
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
			,rep_needle_qty = @rep_needle_qty
			,rep_crack_pipe_qty = @rep_crack_pipe_qty
			,rep_condom_qty = @rep_condom_qty
			,col_needle_qty = @col_needle_qty
			,col_crack_pipe_qty = @col_crack_pipe_qty
			,col_condom_qty = @col_condom_qty
			,wo_est_cost = @wo_est_cost
			,po_code = @po_code
			,refuse_pay = @refuse_pay
			,est_duration_date = @est_duration_date
			,est_duration_h = @est_duration_h
			,est_duration_m = @est_duration_m
			,completion_date = @completion_date
			,completion_time_h = @completion_time_h
			,completion_time_m = @completion_time_m
			,drtrep = @drtrep
			,drtpar = @drtpar
			,drtasw = @drtasw
			,abuse = @abuse
	END TRY
	BEGIN CATCH
		SET @errornumber = '20372';
		SET @errortext = 'Error updating #tempCompDart record';
		GOTO errorexit;
	END CATCH
	BEGIN TRY
		SET @xmlCompDart = (SELECT * FROM #tempCompDart FOR XML PATH('CustCareDartDTO'))
	END TRY
	BEGIN CATCH
		SET @errornumber = '20373';
		SET @errortext = 'Error updating @xmlCompDart';
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
