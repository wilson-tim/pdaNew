/*****************************************************************************
** dbo.cs_comp_updateRecordGraff
** stored procedure
**
** Description
** Update a customer care record, etc. for service type Graffiti
**
** Parameters
** @xmlCompGraff = XML structure containing comp (GRAFF) record
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
** 16/04/2013  TW  New
** 02/05/2013  TW  Revised - graffiti details update moved to cs_comp_updateRecordGraffDetails
** 07/06/2013  TW  Revised - process changes to item_ref, comp_code and date_due
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_comp_updateRecordGraff', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comp_updateRecordGraff;
GO
CREATE PROCEDURE dbo.cs_comp_updateRecordGraff
	@xmlCompGraff xml OUTPUT,
	@comp_notes varchar(MAX) = NULL OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @result integer
		,@errortext varchar(500)
		,@errornumber varchar(10)
		,@comp_rowcount integer
		,@compgraff_rowcount integer
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

		/* graffiti data */
		,@volume_ref varchar(6)
		,@tag_offensive varchar(1)
		,@tag_visible varchar(1)
		,@tag_recognisable varchar(1)
		,@tag_known_offender varchar(1)
		,@tag_offender_info varchar(80)
		,@tag_repeat_offence varchar(1)
		,@tag_offences_ref varchar(6)
		,@rem_workforce_ref varchar(6)
		,@wo_est_cost decimal(10,2)
		,@refuse_pay varchar(1)
		,@est_duration_date datetime
		,@est_duration_h char(2)
		,@est_duration_m char(2)
		,@po_code varchar(6)
		,@graffiti_level_ref varchar(6)
		,@completion_date datetime
		,@completion_time_h char(2)
		,@completion_time_m char(2)
		,@indemnity_response varchar(1)
		,@indemnity_date datetime
		,@indemnity_time_h char(2)
		,@indemnity_time_m char(2)
		,@cust_responsible varchar(1)
		,@landlord_perm_date datetime
		,@tag varchar(15)
		,@oldtag varchar(15)
		,@graffiti_sqmtr decimal(10,2)
		,@s12_notice_type varchar(1)
		,@s12_notice_date datetime
		,@ertsur varchar(500)
		,@ertmat varchar(500)
		,@ertoff varchar(500)
		,@ertown varchar(500)
		,@ertopp varchar(500)
		,@ertitm varchar(500)
		,@ertact varchar(500)
		,@ertabu varchar(500)
		,@ertmet varchar(500)
		,@ertequ varchar(500);

	SET @errornumber = '20208';
	
	IF OBJECT_ID('tempdb..#tempCompGraff') IS NOT NULL
	BEGIN
		DROP TABLE #tempCompGraff;
	END

	BEGIN TRY
		SELECT
			xmldoc.compgraff.value('complaint_no[1]','integer') AS 'complaint_no'
			,xmldoc.compgraff.value('entered_by[1]','varchar(8)') AS 'entered_by'
			,xmldoc.compgraff.value('site_ref[1]','varchar(16)') AS 'site_ref'
			,xmldoc.compgraff.value('site_name_1[1]','varchar(70)') AS 'site_name_1'
			,xmldoc.compgraff.value('site_distance[1]','decimal(10,2)') AS 'site_distance'
			,xmldoc.compgraff.value('exact_location[1]','varchar(70)') AS 'exact_location'
			,xmldoc.compgraff.value('service_c[1]','varchar(6)') AS 'service_c'
			,xmldoc.compgraff.value('service_c_desc[1]','varchar(40)') AS 'service_c_desc'
			,xmldoc.compgraff.value('item_ref[1]','varchar(12)') AS 'item_ref'
			,xmldoc.compgraff.value('item_desc[1]','varchar(40)') AS 'item_desc'
			,xmldoc.compgraff.value('feature_ref[1]','varchar(12)') AS 'feature_ref'
			,xmldoc.compgraff.value('feature_desc[1]','varchar(40)') AS 'feature_desc'
			,xmldoc.compgraff.value('contract_ref[1]','varchar(12)') AS 'contract_ref'
			,xmldoc.compgraff.value('contract_name[1]','varchar(40)') AS 'contract_name'
			,xmldoc.compgraff.value('comp_code[1]','varchar(6)') AS 'comp_code'
			,xmldoc.compgraff.value('comp_code_desc[1]','varchar(40)') AS 'comp_code_desc'
			,xmldoc.compgraff.value('occur_day[1]','varchar(7)') AS 'occur_day'
			,xmldoc.compgraff.value('round_c[1]','varchar(10)') AS 'round_c'
			,xmldoc.compgraff.value('pa_area[1]','varchar(6)') AS 'pa_area'
			,xmldoc.compgraff.value('action_flag[1]','varchar(1)') AS 'action_flag'
			,xmldoc.compgraff.value('compl_init[1]','varchar(10)') AS 'compl_init'
			,xmldoc.compgraff.value('compl_name[1]','varchar(100)') AS 'compl_name'
			,xmldoc.compgraff.value('compl_surname[1]','varchar(100)') AS 'compl_surname'
			,xmldoc.compgraff.value('compl_build_no[1]','varchar(14)') AS 'compl_build_no'
			,xmldoc.compgraff.value('compl_build_name[1]','varchar(14)') AS 'compl_build_name'
			,xmldoc.compgraff.value('compl_addr2[1]','varchar(100)') AS 'compl_addr2'
			,xmldoc.compgraff.value('compl_addr4[1]','varchar(40)') AS 'compl_addr4'
			,xmldoc.compgraff.value('compl_addr5[1]','varchar(30)') AS 'compl_addr5'
			,xmldoc.compgraff.value('compl_addr6[1]','varchar(30)') AS 'compl_addr6'
			,xmldoc.compgraff.value('compl_postcode[1]','varchar(8)') AS 'compl_postcode'
			,xmldoc.compgraff.value('compl_phone[1]','varchar(20)') AS 'compl_phone'
			,xmldoc.compgraff.value('compl_email[1]','varchar(40)') AS 'compl_email'
			,xmldoc.compgraff.value('compl_business[1]','varchar(100)') AS 'compl_business'
			,xmldoc.compgraff.value('int_ext_flag[1]','varchar(1)') AS 'int_ext_flag'
			,xmldoc.compgraff.value('date_entered[1]','datetime') AS 'date_entered'
			,xmldoc.compgraff.value('ent_time_h[1]','char(2)') AS 'ent_time_h'
			,xmldoc.compgraff.value('ent_time_m[1]','char(2)') AS 'ent_time_m'
			,xmldoc.compgraff.value('dest_ref[1]','integer') AS 'dest_ref'
			,xmldoc.compgraff.value('dest_suffix[1]','varchar(6)') AS 'dest_suffix'
			,xmldoc.compgraff.value('date_due[1]','datetime') AS 'date_due'
			,xmldoc.compgraff.value('date_closed[1]','datetime') AS 'date_closed'
			,xmldoc.compgraff.value('incident_id[1]','varchar(20)') AS 'incident_id'
			,xmldoc.compgraff.value('details_1[1]','varchar(70)') AS 'details_1'
			,xmldoc.compgraff.value('details_2[1]','varchar(70)') AS 'details_2'
			,xmldoc.compgraff.value('details_3[1]','varchar(70)') AS 'details_3'
			,xmldoc.compgraff.value('notice_type[1]','varchar(1)') AS 'notice_type'

			,xmldoc.compgraff.value('volume_ref[1]','varchar(6)') AS 'volume_ref'
			,xmldoc.compgraff.value('tag_offensive[1]','varchar(1)') AS 'tag_offensive'
			,xmldoc.compgraff.value('tag_visible[1]','varchar(1)') AS 'tag_visible'
			,xmldoc.compgraff.value('tag_recognisable[1]','varchar(1)') AS 'tag_recognisable'
			,xmldoc.compgraff.value('tag_known_offender[1]','varchar(1)') AS 'tag_known_offender'
			,xmldoc.compgraff.value('tag_offender_info[1]','varchar(80)') AS 'tag_offender_info'
			,xmldoc.compgraff.value('tag_repeat_offence[1]','varchar(1)') AS 'tag_repeat_offence'
			,xmldoc.compgraff.value('tag_offences_ref[1]','varchar(6)') AS 'tag_offences_ref'
			,xmldoc.compgraff.value('rem_workforce_ref[1]','varchar(6)') AS 'rem_workforce_ref'
			,xmldoc.compgraff.value('wo_est_cost[1]','decimal(10,2)') AS 'wo_est_cost'
			,xmldoc.compgraff.value('po_code[1]','varchar(6)') AS 'po_code'
			,xmldoc.compgraff.value('refuse_pay[1]','varchar(1)') AS 'refuse_pay'
			,xmldoc.compgraff.value('est_duration_date[1]','datetime') AS 'est_duration_date'
			,xmldoc.compgraff.value('est_duration_h[1]','char(2)') AS 'est_duration_h'
			,xmldoc.compgraff.value('est_duration_m[1]','char(2)') AS 'est_duration_m'
			,xmldoc.compgraff.value('graffiti_level_ref[1]','varchar(6)') AS 'graffiti_level_ref'
			,xmldoc.compgraff.value('completion_date[1]','datetime') AS 'completion_date'
			,xmldoc.compgraff.value('completion_time_h[1]','char(2)') AS 'completion_time_h'
			,xmldoc.compgraff.value('completion_time_m[1]','char(2)') AS 'completion_time_m'
			,xmldoc.compgraff.value('indemnity_response[1]','varchar(1)') AS 'indemnity_response'
			,xmldoc.compgraff.value('indemnity_date[1]','datetime') AS 'indemnity_date'
			,xmldoc.compgraff.value('indemnity_time_h[1]','char(2)') AS 'indemnity_time_h'
			,xmldoc.compgraff.value('indemnity_time_m[1]','char(2)') AS 'indemnity_time_m'
			,xmldoc.compgraff.value('cust_responsible[1]','varchar(1)') AS 'cust_responsible'
			,xmldoc.compgraff.value('landlord_perm_date[1]','datetime') AS 'landlord_perm_date'
			,xmldoc.compgraff.value('tag[1]','varchar(15)') AS 'tag'
			,xmldoc.compgraff.value('graffiti_sqmtr[1]','decimal(10,2)') AS 'graffiti_sqmtr'
			,xmldoc.compgraff.value('s12_notice_type[1]','varchar(1)') AS 's12_notice_type'
			,xmldoc.compgraff.value('s12_notice_date[1]','datetime') AS 's12_notice_date'
			,xmldoc.compgraff.value('ERTSUR[1]','varchar(500)') AS 'ERTSUR'
			,xmldoc.compgraff.value('ERTMAT[1]','varchar(500)') AS 'ERTMAT'
			,xmldoc.compgraff.value('ERTOFF[1]','varchar(500)') AS 'ERTOFF'
			,xmldoc.compgraff.value('ERTOWN[1]','varchar(500)') AS 'ERTOWN'
			,xmldoc.compgraff.value('ERTOPP[1]','varchar(500)') AS 'ERTOPP'
			,xmldoc.compgraff.value('ERTITM[1]','varchar(500)') AS 'ERTITM'
			,xmldoc.compgraff.value('ERTACT[1]','varchar(500)') AS 'ERTACT'
			,xmldoc.compgraff.value('ERTABU[1]','varchar(500)') AS 'ERTABU'
			,xmldoc.compgraff.value('ERTMET[1]','varchar(500)') AS 'ERTMET'
			,xmldoc.compgraff.value('ERTEQU[1]','varchar(500)') AS 'ERTEQU'
		INTO #tempCompGraff
		FROM @xmlCompGraff.nodes('/CustCareGrafDTO') AS xmldoc(compgraff);

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

			,@volume_ref = UPPER(LTRIM(RTRIM(volume_ref)))
			,@tag_offensive = UPPER(tag_offensive)
			,@tag_visible = UPPER(tag_visible)
			,@tag_recognisable = UPPER(tag_recognisable)
			,@tag_known_offender = UPPER(tag_known_offender)
			,@tag_offender_info = LTRIM(RTRIM(tag_offender_info))
			,@tag_repeat_offence = UPPER(tag_repeat_offence)
			,@tag_offences_ref = UPPER(LTRIM(RTRIM(tag_offences_ref)))
			,@rem_workforce_ref = UPPER(LTRIM(RTRIM(rem_workforce_ref)))
			,@wo_est_cost = wo_est_cost
			,@refuse_pay = UPPER(refuse_pay)
			,@est_duration_h = STUFF(LTRIM(RTRIM(STR(est_duration_h))), 1, 0, REPLICATE('0', 2 - LEN(LTRIM(RTRIM(STR(est_duration_h))))))
			,@est_duration_m = STUFF(LTRIM(RTRIM(STR(est_duration_m))), 1, 0, REPLICATE('0', 2 - LEN(LTRIM(RTRIM(STR(est_duration_m))))))
			,@graffiti_level_ref = UPPER(LTRIM(RTRIM(graffiti_level_ref)))
			,@completion_date = completion_date
			,@indemnity_response = UPPER(indemnity_response)
			,@indemnity_date = indemnity_date
			,@cust_responsible = UPPER(cust_responsible)
			,@landlord_perm_date = landlord_perm_date
			,@tag = LTRIM(RTRIM(tag))
			,@graffiti_sqmtr = graffiti_sqmtr
			,@s12_notice_type = UPPER(LTRIM(RTRIM(s12_notice_type)))
			,@s12_notice_date = s12_notice_date
			,@ertsur = UPPER(LTRIM(RTRIM(ertsur)))
			,@ertmat = UPPER(LTRIM(RTRIM(ertmat)))
			,@ertoff = UPPER(LTRIM(RTRIM(ertoff)))
			,@ertown = UPPER(LTRIM(RTRIM(ertown)))
			,@ertopp = UPPER(LTRIM(RTRIM(ertopp)))
			,@ertitm = UPPER(LTRIM(RTRIM(ertitm)))
			,@ertact = UPPER(LTRIM(RTRIM(ertact)))
			,@ertabu = UPPER(LTRIM(RTRIM(ertabu)))
			,@ertmet = UPPER(LTRIM(RTRIM(ertmet)))
			,@ertequ = UPPER(LTRIM(RTRIM(ertequ)))
		FROM #tempCompGraff;

		SET @compgraff_rowcount = @@ROWCOUNT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20209';
		SET @errortext = 'Error processing @xmlCompGraff';
		GOTO errorexit;
	END CATCH

	IF @compgraff_rowcount > 1
	BEGIN
		SET @errornumber = '20210';
		SET @errortext = 'Error processing @xmlCompGraff - too many rows';
		GOTO errorexit;
	END
	IF @compgraff_rowcount < 1
	BEGIN
		SET @errornumber = '20211';
		SET @errortext = 'Error processing @xmlCompGraff - no rows found';
		GOTO errorexit;
	END

	SET @entered_by = LTRIM(RTRIM(@entered_by));

	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @errornumber = '20212';
		SET @errortext = 'complaint_no is required';
		GOTO errorexit;
	END
	SELECT @comp_rowcount = COUNT(*)
		FROM comp
		WHERE complaint_no = @complaint_no
	IF @comp_rowcount <> 1
	BEGIN
		SET @errornumber = '20213';
		SET @errortext = LTRIM(RTRIM(STR(@complaint_no))) + ' is not a valid complaint reference';
		GOTO errorexit;
	END

	/* @entered_by validation */
	/* Assuming that @entered_by has already been validated by calling process(es) */
	/* so only a basic test here for non-blank and non-null data being passed */
	IF @entered_by = '' OR @entered_by IS NULL
	BEGIN
		SET @errornumber = '20214';
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
		SET @errornumber = '20268';
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
			SET @errornumber = '20585';
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
		SET @errornumber = '20375';
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
				SET @errornumber = '20215';
				SET @errortext = ERROR_MESSAGE();
				GOTO errorexit;
			END CATCH
		END
		ELSE
		BEGIN
			IF @action_flag <> 'W'
			BEGIN
				BEGIN TRY
					SET @errornumber = '20216';
					SET @errortext = 'Error updating comp record';

					UPDATE comp
						SET action_flag = @action_flag
						WHERE complaint_no = @complaint_no;

					SET @errornumber = '20217';
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
			SET @errornumber = '20218';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH

		SET @comp_notes = dbo.cs_comptext_getNotes(@complaint_no, 0);
	END

	BEGIN TRY
		/* Update #tempCompGraff with actual data ready to return via @xmlCompGraff */
		UPDATE #tempCompGraff
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
			,volume_ref = @volume_ref
			,tag_offensive = @tag_offensive
			,tag_visible = @tag_visible
			,tag_recognisable = @tag_recognisable
			,tag_known_offender = @tag_known_offender
			,tag_offender_info = @tag_offender_info
			,tag_repeat_offence = @tag_repeat_offence
			,tag_offences_ref = @tag_offences_ref
			,rem_workforce_ref = @rem_workforce_ref
			,wo_est_cost = @wo_est_cost
			,po_code = @po_code
			,refuse_pay = @refuse_pay
			,est_duration_date = @est_duration_date
			,est_duration_h = @est_duration_h
			,est_duration_m = @est_duration_m
			,graffiti_level_ref = @graffiti_level_ref
			,completion_date = @completion_date
			,completion_time_h = @completion_time_h
			,completion_time_m = @completion_time_m
			,indemnity_response = @indemnity_response
			,indemnity_date = @indemnity_date
			,indemnity_time_h = @indemnity_time_h
			,indemnity_time_m = @indemnity_time_m
			,cust_responsible = @cust_responsible
			,landlord_perm_date = @landlord_perm_date
			,tag = @tag
			,graffiti_sqmtr = @graffiti_sqmtr
			,s12_notice_type = @s12_notice_type
			,s12_notice_date = @s12_notice_date
			,ertsur = @ertsur
			,ertmat = @ertmat
			,ertoff = @ertoff
			,ertown = @ertown
			,ertopp = @ertopp
			,ertitm = @ertitm
			,ertact = @ertact
			,ertabu = @ertabu
			,ertmet = @ertmet
			,ertequ = @ertequ
	END TRY
	BEGIN CATCH
		SET @errornumber = '20220';
		SET @errortext = 'Error updating #tempCompGraff record';
		GOTO errorexit;
	END CATCH
	BEGIN TRY
		SET @xmlCompGraff = (SELECT * FROM #tempCompGraff FOR XML PATH('CustCareGrafDTO'))
	END TRY
	BEGIN CATCH
		SET @errornumber = '20221';
		SET @errortext = 'Error updating @xmlCompGraff';
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
