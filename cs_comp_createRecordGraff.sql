/*****************************************************************************
** dbo.cs_comp_createRecordGraff
** stored procedure
**
** Description
** Create a customer care record for Graffiti service
**
** Parameters
** @xmlCompGraff = XML structure containing comp (Graffiti) record
** @comp_notes   = notes
**
** Returned
** All passed parameters are INPUT and OUTPUT
** Return value of new complaint_no or -1
**
** History
** 12/04/2013  TW  New
** 01/07/2013  TW  Processing for fly capture data
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_comp_createRecordGraff', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comp_createRecordGraff;
GO
CREATE PROCEDURE dbo.cs_comp_createRecordGraff
	@xmlCompGraff xml OUTPUT,
	@comp_notes varchar(MAX) = NULL OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @result integer,
		@errortext varchar(500),
		@errornumber varchar(10),
		@recvd_by varchar(6),
		@location_c varchar(10),
		@build_no varchar(14),
		@build_sub_no varchar(14),
		@build_name varchar(100),
		@build_sub_name varchar(100),
		@long_build_name varchar(250),
		@location_name varchar(100),
		@location_desc varchar(100),
		@townname varchar(30),
		@site_section varchar(70),
		@comp_loc_desc_town char(1),
		@disp_ward_or_area char(1),
		@area_c varchar(6),
		@ward_code varchar(6),
		@area_ward_desc varchar(100),
		@countyname varchar(30),
		@posttown varchar(30),
		@postcode varchar(8),
		@text_flag varchar(1),
		@occur_day varchar(7),
		@round_c varchar(10),
		@pa_area varchar(6),
		@easting decimal(10,2),
		@northing decimal(10,2),
		@easting_end decimal(10,2),
		@northing_end decimal(10,2),
		@customer_no integer,
		@cs_flag char(1),
		@diry_ref integer,
		@full_name varchar(40),
		@comp_to_def char(1),
		@numberstr varchar(2),
		@enforcement_service_c varchar(6),
		@compgraff_rowcount integer,

		/* key data */
		@entered_by varchar(8),
		@site_ref varchar(16),
		@site_name_1 varchar(70),
		@site_distance decimal(10,2),
		@exact_location varchar(70),
		@service_c varchar(6),
		@service_c_desc varchar(40),
		@comp_code varchar(6),
		@comp_code_desc varchar(40),
		@item_ref varchar(12),
		@item_desc varchar(40),
		@feature_ref varchar(12),
		@feature_desc varchar(40),
		@contract_ref varchar(12),
		@contract_name varchar(40),
		@action_flag varchar(2),
		/* customer data */
		@compl_init varchar(10),
		@compl_name varchar(100),
		@compl_surname varchar(100),
		@compl_build_no varchar(14),
		@compl_build_name varchar(60),
		@compl_addr2 varchar(100),
		@compl_addr4 varchar(40),
		@compl_addr5 varchar(30),
		@compl_addr6 varchar(30),
		@compl_postcode varchar(8),
		@compl_phone varchar(20),
		@compl_email varchar(40),
		@compl_business varchar(100),
		@int_ext_flag varchar(1),
		/* other data */
		@complaint_no integer,
		@date_entered datetime,
		@ent_time_h varchar(2),
		@ent_time_m varchar(2),
		@dest_ref integer,
		@dest_suffix varchar(6),
		@date_due datetime,
		@date_closed datetime,
		@incident_id varchar(20),
		@details_1 varchar(70),
		@details_2 varchar(70),
		@details_3 varchar(70),
		@notice_type varchar(1),
		/* graffiti data */
		@volume_ref varchar(6),
		@tag_offensive varchar(1),
		@tag_visible varchar(1),
		@tag_recognisable varchar(1),
		@tag_known_offender varchar(1),
		@tag_offender_info varchar(80),
		@tag_repeat_offence varchar(1),
		@tag_offences_ref varchar(6),
		@rem_workforce_ref varchar(6),
		@wo_est_cost decimal(10,2),
		@refuse_pay varchar(1),
		@est_duration_date datetime,
		@est_duration_h char(2),
		@est_duration_m char(2),
		@po_code varchar(6),
		@graffiti_level_ref varchar(6),
		@completion_date datetime,
		@completion_time_h char(2),
		@completion_time_m char(2),
		@indemnity_response varchar(1),
		@indemnity_date datetime,
		@indemnity_time_h char(2),
		@indemnity_time_m char(2),
		@cust_responsible varchar(1),
		@landlord_perm_date datetime,
		@tag varchar(15),
		@graffiti_sqmtr decimal(10,2),
		@s12_notice_type varchar(1),
		@s12_notice_date datetime,
		@ertsur varchar(500),
		@ertmat varchar(500),
		@ertoff varchar(500),
		@ertown varchar(500),
		@ertopp varchar(500),
		@ertitm varchar(500),
		@ertact varchar(500),
		@ertabu varchar(500),
		@ertmet varchar(500),
		@ertequ varchar(500);

	SET @errornumber = '20182';

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
			,xmldoc.compgraff.value('graffiti_level_ref[1]','varchar(6)') AS 'graffiti_level_ref'
			,xmldoc.compgraff.value('completion_date[1]','datetime') AS 'completion_date'
			,xmldoc.compgraff.value('completion_time_h[1]','char(2)') AS 'completion_time_h'
			,xmldoc.compgraff.value('completion_time_m[1]','char(2)') AS 'completion_time_m'
			,xmldoc.compgraff.value('est_duration_date[1]','datetime') AS 'est_duration_date'
			,xmldoc.compgraff.value('est_duration_h[1]','char(2)') AS 'est_duration_h'
			,xmldoc.compgraff.value('est_duration_m[1]','char(2)') AS 'est_duration_m'
			,xmldoc.compgraff.value('refuse_pay[1]','varchar(1)') AS 'refuse_pay'
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
			,@est_duration_date = est_duration_date
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
		SET @errornumber = '20183';
		SET @errortext = 'Error processing @xmlCompGraff';
		GOTO errorexit;
	END CATCH

	IF @compgraff_rowcount > 1
	BEGIN
		SET @errornumber = '20184';
		SET @errortext = 'Error processing @xmlCompGraff - too many rows';
		GOTO errorexit;
	END
	IF @compgraff_rowcount < 1
	BEGIN
		SET @errornumber = '20185';
		SET @errortext = 'Error processing @xmlCompGraff - no rows found';
		GOTO errorexit;
	END

	SET @comp_notes = LTRIM(RTRIM(@comp_notes));

	/* @entered_by validation */
	/* Assuming that @entered_by has already been validated by calling process(es) */
	/* so only a basic test here for non-blank and non-null data being passed */
	IF @entered_by = '' OR @entered_by IS NULL
	BEGIN
		SET @errornumber = '20186';
		SET @errortext = 'entered_by is required';
		GOTO errorexit;
	END

	/* @service_c validation */
	IF @service_c = '' OR @service_c IS NULL
	BEGIN
		SET @errornumber = '20189';
		SET @errortext = 'service_c is required';
		GOTO errorexit;
	END
	SELECT pda_lookup.service_c_desc
		FROM pda_lookup
		WHERE pda_lookup.role_name = 'pda-in'
		/*
			(
			SELECT keys.c_field
				FROM keys
				WHERE keys.service_c = 'ALL'
					AND keys.keyname = 'PDA_INSPECTOR_ROLE'
			)
		*/
		AND pda_lookup.service_c = @service_c;
	IF @@ROWCOUNT = 0
	BEGIN
		SET @errornumber = '20190';
		SET @errortext = @service_c + ' is not a valid service code';
		GOTO errorexit;
	END

	/* @site_ref validation */
	IF @site_ref = '' OR @site_ref IS NULL
	BEGIN
		SET @errornumber = '20187';
		SET @errortext = 'site_ref is required';
		GOTO errorexit;
	END
	SELECT site_name_1
		FROM site
		WHERE site_ref = @site_ref;
	IF @@ROWCOUNT = 0
	BEGIN
		SET @errornumber = '20188';
		SET @errortext = @site_ref + ' is not a valid site reference';
		GOTO errorexit;
	END

	/* @item_ref validation */
	IF @item_ref = '' OR @item_ref IS NULL
	BEGIN
		SET @errornumber = '20192';
		SET @errortext = 'item_ref is required';
		GOTO errorexit;
	END

	/* @comp_code validation */
	IF @comp_code = '' OR @comp_code IS NULL
	BEGIN
		SET @errornumber = '20191';
		SET @errortext = 'comp_code is required';
		GOTO errorexit;
	END

	/* @contract_ref validation */
	IF @contract_ref = '' OR @contract_ref IS NULL
	BEGIN
		SELECT @contract_ref = contract_ref
			FROM si_i
		WHERE si_i.site_ref = @site_ref
			AND si_i.item_ref = @item_ref;
	END

	/* @po_code */
	SELECT @po_code = po_code
		FROM pda_user
		WHERE [user_name] = @entered_by;

	/* Create comp record */
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
		SET @errornumber = '20265';
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

	/*
	** comp_ert_header table
	*/
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

	IF @indemnity_response = 'Y'
	BEGIN
		SET @numberstr = DATENAME(hour, @indemnity_date);
		SET @indemnity_time_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

		SET @numberstr = DATENAME(minute, @indemnity_date);
		SET @indemnity_time_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

		SET @indemnity_date = CONVERT(datetime, CONVERT(date, @indemnity_date));
	END
	ELSE
	BEGIN
		SET @indemnity_date   = NULL;
		SET @indemnity_time_h = NULL;
		SET @indemnity_time_m = NULL;
	END

	BEGIN TRY
		INSERT INTO comp_ert_header
			(
			complaint_no
			,volume_ref
			,tag_offensive
			,tag_visible
			,tag_recognisable
			,tag_known_offender
			,tag_offender_info
			,tag_repeat_offence
			,tag_offences_ref
			,rem_workforce_ref
			,wo_est_cost
			,refuse_pay
			,est_duration_h
			,est_duration_m
			,po_code
			,graffiti_level_ref
			,completion_date
			,completion_time_h
			,completion_time_m
			,indemnity_response
			,indemnity_date
			,indemnity_time_h
			,indemnity_time_m
			,cust_responsible
			,landlord_perm_date
			)
			VALUES
			(
			@complaint_no
			,@volume_ref
			,@tag_offensive
			,@tag_visible
			,@tag_recognisable
			,@tag_known_offender
			,@tag_offender_info
			,@tag_repeat_offence
			,@tag_offences_ref
			,@rem_workforce_ref
			,@wo_est_cost
			,@refuse_pay
			,@est_duration_h
			,@est_duration_m
			,@po_code
			,@graffiti_level_ref
			,@completion_date
			,@completion_time_h
			,@completion_time_m
			,@indemnity_response
			,@indemnity_date
			,@indemnity_time_h
			,@indemnity_time_m
			,@cust_responsible
			,@landlord_perm_date
			);
	END TRY
	BEGIN CATCH
		SET @errornumber = '20203';
		SET @errortext = 'Error inserting comp_ert_header record';
		GOTO errorexit;
	END CATCH

	/*
	** comp_ert_hdr_log table
	*/
	BEGIN TRY
		INSERT INTO comp_ert_hdr_log
			(
			complaint_no
			,volume_ref
			,tag_offensive
			,tag_visible
			,tag_recognisable
			,tag_known_offender
			,tag_offender_info
			,tag_repeat_offence
			,tag_offences_ref
			,rem_workforce_ref
			,wo_est_cost
			,refuse_pay
			,est_duration_h
			,est_duration_m
			,po_code
			,graffiti_level_ref
			,completion_date
			,completion_time_h
			,completion_time_m
			,indemnity_response
			,indemnity_date
			,indemnity_time_h
			,indemnity_time_m
			,cust_responsible
			,landlord_perm_date
			,log_seq
			,log_username
			,log_date
			,log_time_h
			,log_time_m
			)
			VALUES
			(
			@complaint_no
			,@volume_ref
			,@tag_offensive
			,@tag_visible
			,@tag_recognisable
			,@tag_known_offender
			,@tag_offender_info
			,@tag_repeat_offence
			,@tag_offences_ref
			,@rem_workforce_ref
			,@wo_est_cost
			,@refuse_pay
			,@est_duration_h
			,@est_duration_m
			,@po_code
			,@graffiti_level_ref
			,@completion_date
			,@completion_time_h
			,@completion_time_m
			,@indemnity_response
			,@indemnity_date
			,@indemnity_time_h
			,@indemnity_time_m
			,@cust_responsible
			,@landlord_perm_date
			,1
			,@entered_by
			,@date_entered
			,@ent_time_h
			,@ent_time_m
			);
	END TRY
	BEGIN CATCH
		SET @errornumber = '20204';
		SET @errortext = 'Error inserting comp_ert_hdr_log record';
		GOTO errorexit;
	END CATCH

	/*
	** comp_ert_tags table
	*/
	IF @tag <> '' AND @tag IS NOT NULL
	BEGIN
		BEGIN TRY
			INSERT INTO comp_ert_tags
				(
				complaint_no
				,seq_no
				,username
				,tag
				,doa
				)
				VALUES
				(
				@complaint_no
				,1
				,@entered_by
				,@tag
				,@date_entered
				)
		END TRY
		BEGIN CATCH
			SET @errornumber = '20205';
			SET @errortext = 'Error inserting comp_ert_tags record';
			GOTO errorexit;
		END CATCH
	END

	/* Close the complaint if the No Action flag is set */
	SELECT @enforcement_service_c = LTRIM(RTRIM(c_field))
		FROM keys
		WHERE keyname = 'ENF_SERVICE'
			AND service_c = 'ALL';
	
	IF @action_flag = 'N' AND (@service_c <> ISNULL(@enforcement_service_c, ''))
	BEGIN
		BEGIN TRY
			SET @date_closed = @date_entered;

			EXECUTE dbo.cs_comp_closeRecordCore
				@complaint_no,
				@entered_by,
				@date_closed OUTPUT,
				@dest_ref OUTPUT;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20207';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH
	END

	IF @ertsur <> '' AND @ertsur IS NOT NULL
	BEGIN
		BEGIN TRY
			EXECUTE dbo.cs_compertdetail_createRecord
				@complaint_no,
				'ERTSUR',
				@ertsur,
				@entered_by
		END TRY
		BEGIN CATCH
			SET @errornumber = '20242';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH
	END

	IF @ertmat <> '' AND @ertmat IS NOT NULL
	BEGIN
		BEGIN TRY
			EXECUTE dbo.cs_compertdetail_createRecord
				@complaint_no,
				'ERTMAT',
				@ertmat,
				@entered_by
		END TRY
		BEGIN CATCH
			SET @errornumber = '20243';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH
	END

	IF @ertoff <> '' AND @ertoff IS NOT NULL
	BEGIN
		BEGIN TRY
			EXECUTE dbo.cs_compertdetail_createRecord
				@complaint_no,
				'ERTOFF',
				@ertoff,
				@entered_by
		END TRY
		BEGIN CATCH
			SET @errornumber = '20244';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH
	END

	IF @ertown <> '' AND @ertown IS NOT NULL
	BEGIN
		BEGIN TRY
			EXECUTE dbo.cs_compertdetail_createRecord
				@complaint_no,
				'ERTOWN',
				@ertown,
				@entered_by
		END TRY
		BEGIN CATCH
			SET @errornumber = '20245';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH
	END

	IF @ertopp <> '' AND @ertopp IS NOT NULL
	BEGIN
		BEGIN TRY
			EXECUTE dbo.cs_compertdetail_createRecord
				@complaint_no,
				'ERTOPP',
				@ertopp,
				@entered_by
		END TRY
		BEGIN CATCH
			SET @errornumber = '20246';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH
	END

	IF @ertitm <> '' AND @ertitm IS NOT NULL
	BEGIN
		BEGIN TRY
			EXECUTE dbo.cs_compertdetail_createRecord
				@complaint_no,
				'ERTITM',
				@ertitm,
				@entered_by
		END TRY
		BEGIN CATCH
			SET @errornumber = '20247';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH
	END

	IF @ertact <> '' AND @ertact IS NOT NULL
	BEGIN
		BEGIN TRY
			EXECUTE dbo.cs_compertdetail_createRecord
				@complaint_no,
				'ERTACT',
				@ertact,
				@entered_by
		END TRY
		BEGIN CATCH
			SET @errornumber = '20248';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH
	END

	IF @ertabu <> '' AND @ertabu IS NOT NULL
	BEGIN
		BEGIN TRY
			EXECUTE dbo.cs_compertdetail_createRecord
				@complaint_no,
				'ERTABU',
				@ertabu,
				@entered_by
		END TRY
		BEGIN CATCH
			SET @errornumber = '20249';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH
	END

	IF @ertmet <> '' AND @ertmet IS NOT NULL
	BEGIN
		BEGIN TRY
			EXECUTE dbo.cs_compertdetail_createRecord
				@complaint_no,
				'ERTMET',
				@ertmet,
				@entered_by
		END TRY
		BEGIN CATCH
			SET @errornumber = '20250';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH
	END

	IF @ertequ <> '' AND @ertequ IS NOT NULL
	BEGIN
		BEGIN TRY
			EXECUTE dbo.cs_compertdetail_createRecord
				@complaint_no,
				'ERTEQU',
				@ertequ,
				@entered_by
		END TRY
		BEGIN CATCH
			SET @errornumber = '20251';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH
	END

	BEGIN TRY
		/* Update #tempCompGraff with actual data ready to return via @xmlCompGraff */
		UPDATE #tempCompGraff
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
		SET @errornumber = '20195';
		SET @errortext = 'Error updating #tempCompGraff record';
		GOTO errorexit;
	END CATCH
	BEGIN TRY
		SET @xmlCompGraff = (SELECT * FROM #tempCompGraff FOR XML PATH('CustCareGrafDTO'))
	END TRY
	BEGIN CATCH
		SET @errornumber = '20196';
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
