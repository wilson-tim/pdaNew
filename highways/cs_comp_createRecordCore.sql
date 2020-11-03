/*****************************************************************************
** dbo.cs_comp_createRecordCore
** stored procedure
**
** Description
** Create a customer care record
**
** Parameters
** @xmlCompCore = XML structure containing comp (CORE) record
** @comp_notes  = notes
**
** Returned
** All passed parameters are INPUT and OUTPUT
** Return value of new complaint_no or -1
**
** History
** 18/12/2012  TW  New
** 28/12/2012  TW  Added comp_text processing
** 22/01/2013  TW  pda_lookup.role_name = 'pda-in'
** 21/02/2013  TW  Commented out some validations to suit abandoned vehicles
** 10/04/2013  TW  Replaced all parameters (except notes text) with an XML parameter
** 11/07/2013  TW  Double check for @feature_ref
** 17/07/2013  TW  Remove call to cs_customer_updateRecord
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_comp_createRecordCore', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comp_createRecordCore;
GO
CREATE PROCEDURE dbo.cs_comp_createRecordCore
	@xmlCompCore xml OUTPUT,
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
		@compcore_rowcount integer,

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
		@notice_type varchar(1)
		/* fly capture */
		,@flycap_rowcount integer
		,@landtype_ref varchar(6)
		,@dominant_waste_ref varchar(6)
		,@dominant_waste_qty integer
		,@load_ref varchar(2)
		,@load_unit_cost decimal(7,2)
		,@load_qty integer
		,@load_est_cost decimal(7,2)
		;

	SET @errornumber = '10900';

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
		SET @errornumber = '20177';
		SET @errortext = 'Error processing @xmlCompCore';
		GOTO errorexit;
	END CATCH

	IF @compcore_rowcount > 1
	BEGIN
		SET @errornumber = '20178';
		SET @errortext = 'Error processing @xmlCompCore - too many rows';
		GOTO errorexit;
	END
	IF @compcore_rowcount < 1
	BEGIN
		SET @errornumber = '20179';
		SET @errortext = 'Error processing @xmlCompCore - no rows found';
		GOTO errorexit;
	END

	SET @entered_by = LTRIM(RTRIM(@entered_by));
	SET @site_ref = LTRIM(RTRIM(@site_ref));
	SET @exact_location = LTRIM(RTRIM(@exact_location));
	SET @service_c = LTRIM(RTRIM(@service_c));
	SET @comp_code = LTRIM(RTRIM(@comp_code));
	SET @item_ref = LTRIM(RTRIM(@item_ref));
	SET @feature_ref = LTRIM(RTRIM(@feature_ref));
	SET @contract_ref = LTRIM(RTRIM(@contract_ref));
	SET @action_flag = LTRIM(RTRIM(@action_flag));
	SET @comp_notes = LTRIM(RTRIM(@comp_notes));

	/* @entered_by validation */
	/* Assuming that @entered_by has already been validated by calling process(es) */
	/* so only a basic test here for non-blank and non-null data being passed */
	IF @entered_by = '' OR @entered_by IS NULL
	BEGIN
		SET @errornumber = '10901';
		SET @errortext = 'entered_by is required';
		GOTO errorexit;
	END

	/* @site_ref validation */
	IF @site_ref = '' OR @site_ref IS NULL
	BEGIN
		SET @errornumber = '10902';
		SET @errortext = 'site_ref is required';
		GOTO errorexit;
	END
	SELECT site_name_1
		FROM site
		WHERE site_ref = @site_ref;
	IF @@ROWCOUNT = 0
	BEGIN
		SET @errornumber = '10903';
		SET @errortext = @site_ref + ' is not a valid site reference';
		GOTO errorexit;
	END

	/* @service_c validation */
	IF @service_c = '' OR @service_c IS NULL
	BEGIN
		SET @errornumber = '10904';
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
		AND LTRIM(RTRIM(pda_lookup.service_c)) = @service_c;
	IF @@ROWCOUNT = 0
	BEGIN
		SET @errornumber = '10905';
		SET @errortext = @service_c + ' is not a valid service code';
		GOTO errorexit;
	END

	/* @comp_code validation */
	IF @comp_code = '' OR @comp_code IS NULL
	BEGIN
		SET @errornumber = '10906';
		SET @errortext = 'comp_code is required';
		GOTO errorexit;
	END
	/*
	SELECT pda_lookup.comp_code_desc
		FROM it_c, pda_lookup, allk
		WHERE pda_lookup.comp_code = it_c.comp_code
			AND allk.lookup_func = 'COMPLA'
			AND allk.status_yn = 'Y'
			AND allk.lookup_code = pda_lookup.comp_code
			AND pda_lookup.comp_code = @comp_code;
	IF @@ROWCOUNT = 0
	BEGIN
		SET @errornumber = '10907';
		SET @errortext = @comp_code + ' is not a valid fault code';
		GOTO errorexit;
	END
	*/

	/* @item_ref validation */
	IF @item_ref = '' OR @item_ref IS NULL
	BEGIN
		SET @errornumber = '10908';
		SET @errortext = 'item_ref is required';
		GOTO errorexit;
	END
	/*
	SELECT DISTINCT item.item_desc
		FROM si_i
		INNER JOIN item
		ON item.item_ref = si_i.item_ref
			AND item.customer_care_yn = 'Y'
			AND item.service_c = @service_c
		WHERE si_i.site_ref = @site_ref
			AND si_i.item_ref = @item_ref;
	IF @@ROWCOUNT = 0
	BEGIN
		SET @errornumber = '10909';
		SET @errortext = @item_ref + ' is not a valid item reference';
		GOTO errorexit;
	END
	*/

	/* @contract_ref validation */
	IF @contract_ref = '' OR @contract_ref IS NULL
	BEGIN
		SELECT @contract_ref = contract_ref
			FROM si_i
		WHERE si_i.site_ref = @site_ref
			AND si_i.item_ref = @item_ref;
	END

	/* @feature_ref validation */
	/*
	IF @feature_ref <> '' AND @feature_ref IS NOT NULL
	BEGIN
		SELECT feature_ref
			FROM si_i
			WHERE item_ref = @item_ref
		IF @@ROWCOUNT = 0
		BEGIN
			SET @errornumber = '10910';
			SET @errortext = @feature_ref + ' is not a valid feature reference';
			GOTO errorexit;
		END
	END
	*/
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
			SET @errornumber = '20674';
			SET @errortext = 'feature_ref is not defined in the it_f table for item_ref ' + @item_ref;
			GOTO errorexit;
		END
	END

	/* @date_due validation */
	IF @date_due IS NOT NULL
	BEGIN
		IF @date_due < GETDATE()
			OR @date_due > DATEADD(MONTH, 1, GETDATE())
		BEGIN
			SET @errornumber = '10911';
			SET @errortext = LTRIM(RTRIM(CONVERT(varchar(10), @date_due, 103))) + ' is not a valid inspection date';
			GOTO errorexit;
		END
	END

	/*
	** comp table
	*/
	BEGIN TRY
		EXECUTE @result = dbo.cs_sno_getSerialNumber 'comp', '', @serial_no = @complaint_no OUTPUT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '10912';
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

	SET @date_entered = GETDATE();

	SET @numberstr = DATENAME(hour, @date_entered);
	SET @ent_time_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @numberstr = DATENAME(minute, @date_entered);
	SET @ent_time_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @date_entered = CONVERT(datetime, CONVERT(date, @date_entered));

	SET @recvd_by = LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'HAND_HELD_REC_BY')));

	IF @date_due IS NULL
	BEGIN
		SET @date_due = @date_entered;
	END
	ELSE
	BEGIN
		SET @date_due = CONVERT(datetime, CONVERT(date, @date_due));
	END

	SELECT @location_c  = LTRIM(RTRIM([site].location_c)),
		@build_no       = LTRIM(RTRIM([site].build_no)),
		@build_sub_no   = LTRIM(RTRIM([site].build_sub_no)),
		@build_name     = LTRIM(RTRIM([site].build_name)),
		@build_sub_name = LTRIM(RTRIM([site].build_sub_name)),
		@townname       = LTRIM(RTRIM([site].townname)),
		@site_section   = LTRIM(RTRIM([site].site_section)),
		@area_c         = LTRIM(RTRIM([site].area_c)),
		@ward_code      = LTRIM(RTRIM([site].ward_code)),
		@postcode       = LTRIM(RTRIM([site].postcode))
		FROM [site]
		WHERE [site].site_ref = @site_ref;

	SELECT @countyname  = LTRIM(RTRIM(site_detail.countyname)),
		@posttown       = LTRIM(RTRIM(site_detail.townname)),
		@easting        = site_detail.easting,
		@northing       = site_detail.northing,
		@easting_end    = site_detail.easting_end,
		@northing_end   = site_detail.northing_end
		FROM site_detail
		WHERE site_detail.site_ref = @site_ref;

	/* Set up the build_name (long_build_name) in the form "build_sub_no, build_sub_name, build_name" */
	IF @build_sub_no <> '' AND @build_sub_no IS NOT NULL
	BEGIN
		SET @long_build_name = @build_sub_no;
	END
	IF @build_sub_name <> '' AND @build_sub_name IS NOT NULL
	BEGIN
		IF @long_build_name <> '' AND @long_build_name IS NOT NULL
		BEGIN
			SET @long_build_name = @long_build_name + ', ' + @build_sub_name;
		END
		ELSE
		BEGIN
			SET @long_build_name = @build_sub_name;
		END
	END
	IF @build_name <> '' AND @build_name IS NOT NULL
	BEGIN
		IF @long_build_name <> '' AND @long_build_name IS NOT NULL
		BEGIN
			SET @long_build_name = @long_build_name + ', ' + @build_name;
		END
		ELSE
		BEGIN
			SET @long_build_name = @build_name;
		END
	END
	/* Truncate to actual column width */
	SET @long_build_name = LEFT(@long_build_name, 100);

	SELECT @location_name = location_name
		FROM locn
		WHERE location_c = @location_c;

	SET @comp_loc_desc_town = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'COMP_LOC_DESC_TOWN'))));
	IF @comp_loc_desc_town = 'Y'
	BEGIN
		SET @location_desc = @townname;
	END
	ELSE
	BEGIN
		SET @location_desc = @site_section;
	END

	SET @area_ward_desc = NULL;
	SET @disp_ward_or_area = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'DISP_WARD_OR_AREA'))));
	IF @disp_ward_or_area = 'Y'
		AND @area_c <> ''
		AND @area_c IS NOT NULL
	BEGIN
		SELECT @area_ward_desc = LTRIM(RTRIM(area_name))
			FROM area
			WHERE area_c = @area_c;
	END
	IF @disp_ward_or_area = 'N'
		AND @ward_code <> ''
		AND @ward_code IS NOT NULL
	BEGIN
		SELECT @area_ward_desc = LTRIM(RTRIM(ward_name))
			FROM ward
			WHERE ward_code = @ward_code;
	END

	SET @incident_id = NULL;

	SET @details_1 = NULL;

	SET @details_2 = NULL;

	SET @details_3 = NULL;

	SET @notice_type = 'N';

	SET @text_flag = 'N';

	SELECT @occur_day = occur_day,
		@round_c      = LTRIM(RTRIM(round_c))
		FROM si_i
		WHERE site_ref = @site_ref
			AND item_ref = @item_ref
			AND feature_ref = @feature_ref
			AND contract_ref = @contract_ref;

	/* Bulky Waste / Scheduled Collections do not have site items so do not have patrol areas */
	IF dbo.cs_utils_getServiceType(@service_c) IN ('AV', 'ENF', 'ENFTR', 'SL')
	BEGIN
		SET @pa_area = dbo.cs_site_getPaArea(@site_ref, @service_c);
	END
	ELSE
	BEGIN
		SELECT @pa_area = pa_area
			FROM si_i
			WHERE site_ref = @site_ref
				AND item_ref = @item_ref
				AND feature_ref = @feature_ref
				AND contract_ref = @contract_ref;
	END

	SET @dest_ref = NULL;

	SET @dest_suffix = NULL;

	IF @action_flag = '' OR @action_flag IS NULL
	BEGIN
		SET @action_flag = 'H';
	END

	/* cs_woh_createRecordCore will update the action flag to 'W' */
	/* This will be called directly by the business logic */
	IF @action_flag = 'W' OR @action_flag = 'X'
	BEGIN
		SET @action_flag = 'H';
	END

	/* cs_defh_createRecordCore will update the action flag to 'D' */
	/* This will be called directly by the business logic */
	IF @action_flag = 'A' OR @action_flag = 'D'
	BEGIN
		SET @action_flag = 'H';
	END

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
			@long_build_name,
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
		SET @errornumber = '10913';
		SET @errortext = 'Error inserting comp record';
		GOTO errorexit;
	END CATCH

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
		SET @errornumber = '10916';
		SET @errortext = 'Error inserting comp_destination record';
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
				SET @errornumber = '20666';
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
				SET @errornumber = '20667';
				SET @errortext = 'Error updating comp_flycap record';
				GOTO errorexit;
			END CATCH
		END
	END

	/*
	** diry table
	*/
	BEGIN TRY
		EXECUTE @result = dbo.cs_sno_getSerialNumber 'diry', '', @serial_no = @diry_ref OUTPUT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '10918';
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
			date_due,
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
			NULL,
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
			@date_due,
			@pa_area,
			@action_flag,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL
			);
	END TRY
	BEGIN CATCH
		SET @errornumber = '10919';
		SET @errortext = 'Error inserting diry record';
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
			SET @errornumber = '20022';
			SET @errortext = ERROR_MESSAGE();
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
			SET @errornumber = '10920';
			SET @errortext = ERROR_MESSAGE();
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
			,landtype_ref = @landtype_ref
			,dominant_waste_ref = @dominant_waste_ref
			,dominant_waste_qty = @dominant_waste_qty
			,load_ref = @load_ref
			,load_unit_cost = @load_unit_cost
			,load_qty = @load_qty
			,load_est_cost = @load_est_cost
	END TRY
	BEGIN CATCH
		SET @errornumber = '20180';
		SET @errortext = 'Error updating #tempCompCore record';
		GOTO errorexit;
	END CATCH
	BEGIN TRY
		SET @xmlCompCore = (SELECT * FROM #tempCompCore FOR XML PATH('CustCareCoreDTO'))
	END TRY
	BEGIN CATCH
		SET @errornumber = '20181';
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
