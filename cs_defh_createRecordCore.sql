/*****************************************************************************
** dbo.cs_defh_createRecordCore
** stored procedure
**
** Description
** Create a rectification
**
** Parameters
** @xmlDefhDefi   = XML structure containing combined defh and defi records
**                  [input and output parameter]
** @complaint_no  = complaint number
** @level         = rectification level (cs_defa_getDefaultPointsValue)
** @occ           = occurrence number (cs_defa_getDefaultPointsValue)
** @points        = points
** @value         = value
** @rectify_date  = completion date
** @username      = user name
**
** Returned
** Return value of new default_no or -1
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
** 01/02/2013  TW  New
** 04/02/2013  TW  Continued development
** 08/05/2013  TW  Assign @defh_default_reason = @defi_default_reason
**                 Bug fix for last resort assignment of @defi_next_date
** 17/05/2013  TW  Bug fix for defh,cust_def_no - correction for an historical issue 
** 28/06/2013  TW  Missing insp_list delete
** 15/07/2013  TW  Check for 'COMP_TEXT TO DEFS' system key and notes copying
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_defh_createRecordCore', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_defh_createRecordCore;
GO
CREATE PROCEDURE dbo.cs_defh_createRecordCore
	@xmlDefhDefi xml OUTPUT,
	@complaint_no integer,
	@level integer,
	@occ integer,
	@points decimal(10,2),
	@value decimal(10,2),
	@rectify_date datetime,
	@username varchar(8)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @result integer
		,@errortext varchar(500)
		,@errornumber varchar(10)
		,@comp_rowcount integer
		,@temprowcount integer
		,@defh_default_no integer
		,@defh_cust_def_no integer
		,@defh_start_date datetime
		,@defh_start_time_h char(2)
		,@defh_start_time_m char(2)
		,@defh_site_ref varchar(16)
		,@defh_contract_ref varchar(12)
		,@defh_cum_points decimal(10,2)
		,@defh_cum_value decimal(10,2)
		,@defh_liquidate_ref varchar(12)
		,@defh_default_status char(1)
		,@defh_default_reason varchar(6)
		,@defh_clear_flag char(1)
		,@defh_blank1 varchar(1)
		,@defh_blank2 varchar(1)
		,@defi_default_no integer
		,@defi_item_ref varchar(12)
		,@defi_feature_ref varchar(12)
		,@defi_volume decimal(10,2)
		,@defi_default_reason varchar(6)
		,@defi_text_flag char(1)
		,@defi_cum_points decimal(10,2)
		,@defi_cum_value decimal(10,2)
		,@defi_next_action char(1)
		,@defi_next_date datetime
		,@defi_item_status char(1)
		,@defi_clear_date datetime
		,@defi_default_algorithm varchar(12)
		,@defi_blank1 varchar(1)
		,@defi_blank2 varchar(1)
		,@deft_priority_flag char(1)
		,@deft_notice_type varchar(4)
		,@deft_value decimal(10,2)
		,@numberstr integer
		,@what_next_action char(1)
		,@def_check_whole_vol char(1)
		,@sii_volume decimal(10,2)
		,@sum_defi_volume decimal(10,2)
		,@deft_rectify_date datetime
		,@deft_rectify_time_h char(2)
		,@deft_rectify_time_m char(2)
		,@comp_diry_ref integer
		,@def_diry_ref integer
		,@pa_area varchar(6)
		,@rect_key integer
		,@service_c varchar(6)
		/* Notes variables */
		,@definb_seq integer
		,@definb_username varchar(8)
		,@definb_doa datetime
		,@definb_time_entered_h char(2)
		,@definb_time_entered_m char(2)
		,@definb_txt varchar(60)
		;

	SET @errornumber = '12300';
	IF OBJECT_ID('tempdb..#tempDefhDefi') IS NOT NULL
	BEGIN
		DROP TABLE  #tempDefhDefi;
	END

	BEGIN TRY
		SELECT
			xmldoc.defhdefi.value('defh_default_no[1]','integer') AS 'defh_default_no'
			,xmldoc.defhdefi.value('defh_cust_def_no[1]','integer') AS 'defh_cust_def_no'
			,xmldoc.defhdefi.value('defh_start_date[1]','datetime') AS 'defh_start_date'
			,xmldoc.defhdefi.value('defh_start_time_h[1]','char(2)') AS 'defh_start_time_h'
			,xmldoc.defhdefi.value('defh_start_time_m[1]','char(2)') AS 'defh_start_time_m'
			,xmldoc.defhdefi.value('defh_site_ref[1]','varchar(16)') AS 'defh_site_ref'
			,xmldoc.defhdefi.value('defh_contract_ref[1]','varchar(12)') AS 'defh_contract_ref'
			,xmldoc.defhdefi.value('defh_cum_points[1]','decimal(10,2)') AS 'defh_cum_points'
			,xmldoc.defhdefi.value('defh_cum_value[1]','decimal(10,2)') AS 'defh_cum_value'
			,xmldoc.defhdefi.value('defh_liquidate_ref[1]','varchar(12)') AS 'defh_liquidate_ref'
			,xmldoc.defhdefi.value('defh_default_status[1]','char(1)') AS 'defh_default_status'
			,xmldoc.defhdefi.value('defh_default_reason[1]','varchar(6)') AS 'defh_default_reason'
			,xmldoc.defhdefi.value('defh_clear_flag[1]','char(1)') AS 'defh_clear_flag'
			,xmldoc.defhdefi.value('defh_blank1[1]','varchar(1)') AS 'defh_blank1'
			,xmldoc.defhdefi.value('defh_blank2[1]','varchar(1)') AS 'defh_blank2'
			,xmldoc.defhdefi.value('defi_default_no[1]','integer') AS 'defi_default_no'
			,xmldoc.defhdefi.value('defi_item_ref[1]','varchar(12)') AS 'defi_item_ref'
			,xmldoc.defhdefi.value('defi_feature_ref[1]','varchar(12)') AS 'defi_feature_ref'
			,xmldoc.defhdefi.value('defi_volume[1]','decimal(10,2)') AS 'defi_volume'
			,xmldoc.defhdefi.value('defi_default_reason[1]','varchar(6)') AS 'defi_default_reason'
			,xmldoc.defhdefi.value('defi_text_flag[1]','char(1)') AS 'defi_text_flag'
			,xmldoc.defhdefi.value('defi_cum_points[1]','decimal(10,2)') AS 'defi_cum_points'
			,xmldoc.defhdefi.value('defi_cum_value[1]','decimal(10,2)') AS 'defi_cum_value'
			,xmldoc.defhdefi.value('defi_next_action[1]','char(1)') AS 'defi_next_action'
			,xmldoc.defhdefi.value('defi_next_date[1]','datetime') AS 'defi_next_date'
			,xmldoc.defhdefi.value('defi_item_status[1]','char(1)') AS 'defi_item_status'
			,xmldoc.defhdefi.value('defi_clear_date[1]','datetime') AS 'defi_clear_date'
			,xmldoc.defhdefi.value('defi_default_algorithm[1]','varchar(12)') AS 'defi_default_algorithm'
			,xmldoc.defhdefi.value('defi_blank1[1]','varchar(1)') AS 'defi_blank1'
			,xmldoc.defhdefi.value('defi_blank2[1]','varchar(1)') AS 'defi_blank2'
		INTO #tempDefhDefi
		FROM @xmlDefhDefi.nodes('/RectificationCoreDTO') AS xmldoc(defhdefi);

		SELECT @defh_default_no = defh_default_no
			,@defh_cust_def_no = defh_cust_def_no
			,@defh_start_date = defh_start_date
			,@defh_start_time_h = defh_start_time_h
			,@defh_start_time_m = defh_start_time_m
			,@defh_site_ref = defh_site_ref
			,@defh_contract_ref = defh_contract_ref
			,@defh_cum_points = defh_cum_points
			,@defh_cum_value = defh_cum_value
			,@defh_liquidate_ref = defh_liquidate_ref
			,@defh_default_status = defh_default_status
			,@defh_default_reason = defh_default_reason
			,@defh_clear_flag = defh_clear_flag
			,@defh_blank1 = defh_blank1
			,@defh_blank2 = defh_blank2
			,@defi_default_no = defi_default_no
			,@defi_item_ref = defi_item_ref
			,@defi_feature_ref = defi_feature_ref
			,@defi_volume = defi_volume
			,@defi_default_reason = defi_default_reason
			,@defi_text_flag = defi_text_flag
			,@defi_cum_points = defi_cum_points
			,@defi_cum_value = defi_cum_value
			,@defi_next_action = defi_next_action
			,@defi_next_date = defi_next_date
			,@defi_item_status = defi_item_status
			,@defi_clear_date = defi_clear_date
			,@defi_default_algorithm = defi_default_algorithm
			,@defi_blank1 = defi_blank1
			,@defi_blank2 = defi_blank2
		FROM #tempDefhDefi;

		SET @temprowcount = @@ROWCOUNT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '12301';
		SET @errortext = 'Error processing @xmlDefhDefi';
		GOTO errorexit;
	END CATCH

	IF @temprowcount > 1
	BEGIN
		SET @errornumber = '12302';
		SET @errortext = 'Error processing @xmlDefhDefi - too many rows';
		GOTO errorexit;
	END
	IF @temprowcount < 1
	BEGIN
		SET @errornumber = '12303';
		SET @errortext = 'Error processing @xmlDefhDefi - no rows found';
		GOTO errorexit;
	END

	SET @username = LTRIM(RTRIM(@username));

	/* @complaint_no validation */
	IF @complaint_no IS NULL
	BEGIN
		SET @errornumber = '12304';
		SET @errortext = 'complaint_no is required';
		GOTO errorexit;
	END
	SELECT @comp_rowcount = COUNT(*)
		FROM comp
		WHERE complaint_no = @complaint_no
	IF @comp_rowcount <> 1
	BEGIN
		SET @errornumber = '12305';
		SET @errortext = LTRIM(RTRIM(STR(@complaint_no))) + ' is not a valid complaint reference';
		GOTO errorexit;
	END
	SELECT @defh_site_ref = LTRIM(RTRIM(site_ref))
		,@defi_item_ref = LTRIM(RTRIM(item_ref))
		,@defi_feature_ref = LTRIM(RTRIM(feature_ref))
		,@defh_contract_ref = LTRIM(RTRIM(contract_ref))
		,@service_c = LTRIM(RTRIM(service_c))
		FROM comp
		WHERE complaint_no = @complaint_no;

	/* @level validation */
	IF @level IS NULL
	BEGIN
		SET @errornumber = '12306';
		SET @errortext = 'level is required';
		GOTO errorexit;
	END

	/* @occ validation */
	IF @occ IS NULL
	BEGIN
		SET @errornumber = '12307';
		SET @errortext = 'occ is required';
		GOTO errorexit;
	END

	/* @points validation */
	IF @points IS NULL
	BEGIN
		SET @errornumber = '12308';
		SET @errortext = 'points is required';
		GOTO errorexit;
	END

	/* @value validation */
	IF @value IS NULL
	BEGIN
		SET @errornumber = '12309';
		SET @errortext = 'value is required';
		GOTO errorexit;
	END

	/* @username validation */
	/* Assuming that @username has already been validated by calling process(es) */
	/* so only a basic test here for non-blank and non-null data being passed */
	IF @username = '' OR @username IS NULL
	BEGIN
		SET @errornumber = '12310';
		SET @errortext = 'username is required';
		GOTO errorexit;
	END

	/* @defh_contract_ref validation */
	IF @defh_contract_ref IS NULL
	BEGIN
		SET @errornumber = '12311';
		SET @errortext = 'contract_ref is required';
		GOTO errorexit;
	END

	/* @defh_site_ref validation */
	IF @defh_site_ref IS NULL
	BEGIN
		SET @errornumber = '12312';
		SET @errortext = 'site_ref is required';
		GOTO errorexit;
	END

	/* @defi_item_ref validation */
	IF @defi_item_ref IS NULL
	BEGIN
		SET @errornumber = '12313';
		SET @errortext = 'item_ref is required';
		GOTO errorexit;
	END

	/* @defi_feature_ref validation */
	IF @defi_feature_ref = '' OR @defi_feature_ref IS NULL
	BEGIN
		SELECT @defi_feature_ref = it_f.feature_ref
			FROM it_f
			INNER JOIN feat
			ON feat.feature_ref=it_f.feature_ref
			WHERE item_ref = @defi_feature_ref;

		IF @defi_feature_ref = '' OR @defi_feature_ref IS NULL
		BEGIN
			SET @errornumber = '20688';
			SET @errortext = 'feature_ref is not defined in the it_f table for item_ref ' + @defi_item_ref;
			GOTO errorexit;
		END
	END
	/*
	IF @defi_feature_ref IS NULL
	BEGIN
		SET @errornumber = '12314';
		SET @errortext = 'feature_ref is required';
		GOTO errorexit;
	END
	*/

	/* @defi_default_reason validation */
	IF @defi_default_reason IS NULL
	BEGIN
		SET @errornumber = '12315';
		SET @errortext = 'default_reason is required';
		GOTO errorexit;
	END

	/* @deft_priority_flag */
	SELECT @deft_priority_flag = priority_flag
		FROM si_i
		WHERE site_ref = @defh_site_ref
			AND item_ref = @defi_item_ref
			AND feature_ref = @defi_feature_ref
			AND contract_ref = @defh_contract_ref;

	IF @@ROWCOUNT < 1
	BEGIN
		/* If no si_i try to get priority flag from item */
		SELECT @deft_priority_flag = priority_f
			FROM item
			WHERE item_ref = @defi_item_ref
				AND contract_ref = @defh_contract_ref;
	END

	/* @deft_notice_type */
	SELECT @deft_notice_type = lookup_num
		FROM allk
		WHERE lookup_func = 'DEFRN'
			AND lookup_code = @defi_default_reason
			AND status_yn = 'Y';

	/* @defi_next_date */
	IF @defi_next_date IS NULL OR @defi_next_date <= GETDATE()
	BEGIN
		SELECT @defi_next_date = date_due
		FROM si_i
			WHERE item_ref = @defi_item_ref
				AND site_ref = @defh_site_ref
				AND contract_ref = @defh_contract_ref
				AND feature_ref = @defi_feature_ref;

		/* Bob says that if next date is still NULL at this point then it should stay NULL */

		/* However, Contender back office says...
		IF @defi_next_date IS NULL
		BEGIN
			SET @defi_next_date = GETDATE();
		END
		*/
	END

	BEGIN TRY
		EXECUTE @result = dbo.cs_sno_getSerialNumber 'defh', '', @serial_no = @defh_default_no OUTPUT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '12316';
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

	BEGIN TRY
		EXECUTE @result = dbo.cs_sno_getSerialNumber 'DEFREF', '', @serial_no = @defh_cust_def_no OUTPUT;
		/* Correction for an historical issue, see DEFS\add_def.4gl and addDefaultFunc.jsp */
		SET @defh_cust_def_no = @defh_cust_def_no + 1;
	END TRY
	BEGIN CATCH
		SET @errornumber = '12317';
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

	SET @defh_start_date = GETDATE();

	SET @numberstr = DATENAME(hour, @defh_start_date);
	SET @defh_start_time_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @numberstr = DATENAME(minute, @defh_start_date);
	SET @defh_start_time_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @defh_start_date = CONVERT(datetime, CONVERT(date, @defh_start_date));

	SET @defh_liquidate_ref = NULL;

	SET @defh_default_status = 'Y';

	SET @defh_default_reason = @defi_default_reason;

	SET @defh_clear_flag = NULL;

	SET @defi_default_no = @defh_cust_def_no;

	SET @defh_default_status = 'Y';
	SET @defh_clear_flag = NULL;

	SET @defi_text_flag = 'N';
	SET @defi_item_status = 'Y';
	SET @defi_clear_date = NULL;

	SET @what_next_action = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'WHAT_NEXT_ACTION'))));
	IF @what_next_action = 'Y'
	BEGIN
		SET @defi_next_action = 'I';
	END
	ELSE
	BEGIN
		SET @defi_next_action = 'N';
	END

	IF @points IS NULL
	BEGIN
		SET @points = 0;
	END
	SET @defh_cum_points = @points;
	SET @defi_cum_points = @points;

	IF @value IS NULL
	BEGIN
		SET @value = 0;
	END
	SET @defh_cum_value = @value;
	SET @defi_cum_value = @value;

	IF @level = 0 AND @occ = 0
	BEGIN
		SET @defi_item_status = 'N';
		SET @defi_clear_date = GETDATE();
	END
	ELSE
	BEGIN
		SET @defi_item_status = 'Y';
		SET @defi_clear_date = NULL;
	END

	SET @def_check_whole_vol = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'DEF_CHECK_WHOLE_VOL'))));
	IF @def_check_whole_vol = 'Y'
	BEGIN
		IF @defi_volume <> 0 AND @defi_volume IS NOT NULL
		BEGIN
			SELECT @sii_volume = volume
				FROM si_i
				WHERE site_ref = @defh_site_ref
					AND item_ref = @defi_item_ref
					AND feature_ref = @defi_feature_ref
					AND contract_ref = @defh_contract_ref;

			IF @@ROWCOUNT <> 1
			BEGIN
				SET @sii_volume = NULL;
			END

			IF @defi_volume > @sii_volume
			BEGIN
				SET @errornumber = '12318';
				SET @errortext = 'The volume entered exceeds the site item volume';
				GOTO errorexit;
			END

			SELECT @sum_defi_volume = SUM(defi.volume)
				FROM defi, defh
				WHERE item_ref = @defi_item_ref
					AND site_ref = @defh_site_ref
					AND contract_ref = @defh_contract_ref
					AND defi.feature_ref = @defi_feature_ref
					AND defi.default_no = defh.cust_def_no
					AND defi.item_status = 'Y';

			IF @sum_defi_volume <> 0 AND @sum_defi_volume IS NOT NULL
			BEGIN
				SET @sum_defi_volume = @sum_defi_volume + @defi_volume;

				IF @sum_defi_volume > @sii_volume
				BEGIN
					SET @errornumber = '12319';
					SET @errortext = 'The whole volume has been rectified for the selected site item';
					GOTO errorexit;
				END
			END
		END
	END

	SET @deft_rectify_date = CONVERT(datetime, CONVERT(date, @rectify_date));

	SET @numberstr = DATENAME(hour, @rectify_date);
	SET @deft_rectify_time_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @numberstr = DATENAME(minute, @rectify_date);
	SET @deft_rectify_time_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	/*
	** defh table
	*/
	BEGIN TRY
		INSERT INTO defh
			(
			default_no,
			cust_def_no,
			[start_date],
			start_time_h,
			start_time_m,
			site_ref,
			contract_ref,
			cum_points,
			cum_value,
			default_status,
			clear_flag,
			default_reason
			)
			VALUES
			(
			@defh_default_no,
			@defh_cust_def_no,
			@defh_start_date,
			@defh_start_time_h,
			@defh_start_time_m,
			@defh_site_ref,
			@defh_contract_ref,
			@defh_cum_points,
			@defh_cum_value,
			@defh_default_status,
			@defh_clear_flag,
			@defh_default_reason
			);
	END TRY
	BEGIN CATCH
		SET @errornumber = '12320';
		SET @errortext = 'Error inserting defh record';
		GOTO errorexit;
	END CATCH

	/*
	** defi table
	*/
	BEGIN TRY
		INSERT INTO defi
			(
			default_no,
			item_ref,
			feature_ref,
			volume,
			default_reason,
			text_flag,
			cum_points,
			cum_value,
			next_action,
			next_date,
			item_status,
			clear_date,
			default_algorithm
			)
			VALUES
			(
			@defi_default_no,
			@defi_item_ref,
			@defi_feature_ref,
			@defi_volume,
			@defi_default_reason,
			@defi_text_flag,
			@defi_cum_points,
			@defi_cum_value,
			@defi_next_action,
			@defi_next_date,
			@defi_item_status,
			@defi_clear_date,
			@defi_default_algorithm
			);
	END TRY
	BEGIN CATCH
		SET @errornumber = '12321';
		SET @errortext = 'Error inserting defi record';
		GOTO errorexit;
	END CATCH

	/*
	** def_cont_i table
	*/
	BEGIN TRY
		INSERT INTO def_cont_i
			(
			cust_def_no,
			item_ref,
			feature_ref
			)
			VALUES
			(
			@defh_cust_def_no,
			@defi_item_ref,
			@defi_feature_ref
			);
	END TRY
	BEGIN CATCH
		SET @errornumber = '12322';
		SET @errortext = 'Error inserting def_cont_i record';
		GOTO errorexit;
	END CATCH

	/*
	** deft table
	*/
	BEGIN TRY
		INSERT INTO deft
			(
			default_no,
			item_ref,
			feature_ref,
			default_level,
			seq_no,
			action_flag,
			trans_date,
			notice_type,
			notice_ref,
			priority_flag,
			points,
			value,
			source_flag,
			source_ref,
			username,
			po_code,
			time_h,
			time_m,
			default_occ,
			default_sublevel
			)
			VALUES
			(
			@defh_cust_def_no,
			@defi_item_ref,
			@defi_feature_ref,
			@level,
			1,
			'D',
			@defh_start_date,
			@deft_notice_type,
			@defh_cust_def_no,
			@deft_priority_flag,
			@points,
			@value,
			'C',
			@complaint_no,
			@username,
			NULL,
			@defh_start_time_h,
			@defh_start_time_m,
			@occ,
			NULL
			);
	END TRY
	BEGIN CATCH
		SET @errornumber = '12323';
		SET @errortext = 'Error inserting deft record';
		GOTO errorexit;
	END CATCH

	/*
	** defi_rect table
	*/
	BEGIN TRY
		EXECUTE @result = dbo.cs_sno_getSerialNumber 'defi_rect', '', @serial_no = @rect_key OUTPUT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '12324';
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

	BEGIN TRY
		INSERT INTO defi_rect
			(
			rect_key,
			default_no,
			seq_no,
			item_ref,
			feature_ref,
			rectify_date,
			rectify_time_h,
			rectify_time_m
			)
			VALUES
			(
			@rect_key,
			@defh_cust_def_no,
			1,
			@defi_item_ref,
			@defi_feature_ref,
			@deft_rectify_date,
			@deft_rectify_time_h,
			@deft_rectify_time_m
			);
	END TRY
	BEGIN CATCH
		SET @errornumber = '12325';
		SET @errortext = 'Error inserting defi_rect record';
		GOTO errorexit;
	END CATCH

	/*
	** diry table
	*/
	SELECT @pa_area = LTRIM(RTRIM(pa_area))
		FROM comp
		WHERE complaint_no = @complaint_no;

	SELECT @comp_diry_ref = diry_ref
		FROM diry
		WHERE source_flag = 'C'
			AND source_ref = @complaint_no;

	BEGIN TRY
		EXECUTE @result = dbo.cs_sno_getSerialNumber 'diry', '', @serial_no = @def_diry_ref OUTPUT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '12326';
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
			@def_diry_ref,
			NULL,
			'D',
			@complaint_no,
			@defh_start_date,
			@defh_start_time_h,
			@defh_start_time_m,
			@username,
			@defh_site_ref,
			@defi_item_ref,
			@defh_contract_ref,
			NULL,
			NULL,
			@defi_feature_ref,
			@defi_next_date,
			@pa_area,
			@defi_next_action,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL
			);
	END TRY
	BEGIN CATCH
		SET @errornumber = '12327';
		SET @errortext = 'Error inserting diry record';
		GOTO errorexit;
	END CATCH

	BEGIN TRY
		/* Update the comp table destination details */
		/* and amend the action flag to 'D' */
		SET @errornumber = '12328';
		SET @errortext = 'Error updating comp record';
		UPDATE comp
			SET dest_ref = @defh_cust_def_no,
				action_flag = 'D'
			WHERE complaint_no = @complaint_no;
    
		/* Update the complaint diry records next_record and dest_ref fields with the */
		/* rectification records info. This completes the complaint record. */
		SET @errornumber = '12329';
		SET @errortext = 'Error updating comp diry record';
		UPDATE diry
			SET next_record = @def_diry_ref,
				dest_ref = @defh_cust_def_no,
				action_flag = 'D',
				dest_flag = 'D',
				dest_date = @defh_start_date,
				dest_time_h = @defh_start_time_h,
				dest_time_m = @defh_start_time_m,
				dest_user = @username,
				date_due = @defh_start_date
			WHERE diry_ref = @comp_diry_ref;

		/* Delete any occurrence of the complaint from the inspection */
		/* list table, as it has been changed. */
		SET @errornumber = '20659';
		SET @errortext = 'Error deleting insp_list record';
		DELETE FROM insp_list
			WHERE complaint_no = @complaint_no;
	END TRY
	BEGIN CATCH
		/* Appropriate error message previously assigned */
		GOTO errorexit;
	END CATCH

	/* Check whether to copy comp text to rectification text */
	IF UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField(@service_c, 'COMP_TEXT TO DEFS')))) = 'Y'
	BEGIN
		DECLARE csr_notes CURSOR FOR
			SELECT seq
				,username
				,doa
				,time_entered_h
				,time_entered_m
				,txt
				FROM comp_text
				WHERE complaint_no = @complaint_no
				ORDER BY seq;

		OPEN csr_notes;

		FETCH NEXT FROM csr_notes INTO
			@definb_seq
			,@definb_username
			,@definb_doa
			,@definb_time_entered_h
			,@definb_time_entered_m
			,@definb_txt;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @defi_text_flag = 'N'
			BEGIN
				SET @defi_text_flag = 'Y';
			END

			BEGIN TRY
				INSERT INTO defi_nb
					(
					default_no
					,item_ref
					,feature_ref
					,seq_no
					,username
					,doa
					,time_entered_h
					,time_entered_m
					,txt
					)
					VALUES
					(
					@defi_default_no
					,@defi_item_ref
					,@defi_feature_ref
					,@definb_seq
					,@definb_username
					,@definb_doa
					,@definb_time_entered_h
					,@definb_time_entered_m
					,@definb_txt
					);
			END TRY
			BEGIN CATCH
				SET @errornumber = '20695';
				SET @errortext = 'Error inserting defi_nb record';
				GOTO errorexit;
			END CATCH

			FETCH NEXT FROM csr_notes INTO
				@definb_seq
				,@definb_username
				,@definb_doa
				,@definb_time_entered_h
				,@definb_time_entered_m
				,@definb_txt;
		END

		CLOSE csr_notes
		DEALLOCATE csr_notes

		/* Update defi.text_flag if notes have been copied */
		IF @defi_text_flag = 'Y'
		BEGIN
			BEGIN TRY
				UPDATE defi
					SET text_flag = @defi_text_flag
					WHERE default_no = @defi_default_no;
			END TRY
			BEGIN CATCH
				SET @errornumber = '20697';
				SET @errortext = 'Error updating defi record (text_flag)';
				GOTO errorexit;
			END CATCH
		END
	END
  
	BEGIN TRY
		/* Update #tempDefhDefi with actual data ready to return via @xmlDefhDefi */
		UPDATE #tempDefhDefi
			SET defh_default_no = @defh_default_no
				,defh_cust_def_no = @defh_cust_def_no
				,defh_start_date = @defh_start_date
				,defh_start_time_h = @defh_start_time_h
				,defh_start_time_m = @defh_start_time_m
				,defh_site_ref = @defh_site_ref
				,defh_contract_ref = @defh_contract_ref
				,defh_cum_points = @defh_cum_points
				,defh_cum_value = @defh_cum_value
				,defh_liquidate_ref = @defh_liquidate_ref
				,defh_default_status = @defh_default_status
				,defh_default_reason = @defh_default_reason
				,defh_clear_flag = @defh_clear_flag
				,defh_blank1 = @defh_blank1
				,defh_blank2 = @defh_blank2
				,defi_default_no = @defi_default_no
				,defi_item_ref = @defi_item_ref
				,defi_feature_ref = @defi_feature_ref
				,defi_volume = @defi_volume
				,defi_default_reason = @defi_default_reason
				,defi_text_flag = @defi_text_flag
				,defi_cum_points = @defi_cum_points
				,defi_cum_value = @defi_cum_value
				,defi_next_action = @defi_next_action
				,defi_next_date = @defi_next_date
				,defi_item_status = @defi_item_status
				,defi_clear_date = @defi_clear_date
				,defi_default_algorithm = @defi_default_algorithm
				,defi_blank1 = @defi_blank1
				,defi_blank2 = @defi_blank2;
	END TRY
	BEGIN CATCH
		SET @errornumber = '12330';
		SET @errortext = 'Error updating #tempDefhDefi record';
		GOTO errorexit;
	END CATCH
	BEGIN TRY
		SET @xmlDefhDefi = (SELECT * FROM #tempDefhDefi FOR XML PATH('RectificationCoreDTO'));
	END TRY
	BEGIN CATCH
		SET @errornumber = '12331';
		SET @errortext = 'Error updating @xmlDefhDefi';
		GOTO errorexit;
	END CATCH

normalexit:
	RETURN @defh_default_no;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO
