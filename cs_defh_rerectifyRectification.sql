/*****************************************************************************
** dbo.cs_defh_rerectifyRectification
** stored procedure
**
** Description
** Rectification update - re-rectify the specified rectification
**
** Parameters
** @complaint_no
** @default_no
** @site_ref
** @item_ref
** @feature_ref
** @notice_type
** @priority_flag
** @level
** @occ
** @points
** @value
** @rectify_date
** @username
** @defh_default_status (OUTPUT)
**
** Returned
** Return value of 0 (success), or -1 (failure)
**
** History
** 03/06/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_defh_rerectifyRectification', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_defh_rerectifyRectification;
GO
CREATE PROCEDURE dbo.cs_defh_rerectifyRectification
	@complaint_no integer
	,@default_no integer
	,@site_ref varchar(16)
	,@item_ref varchar(12)
	,@feature_ref varchar(12)
	,@contract_ref varchar(12)
	,@notice_type varchar(4)
	,@priority_flag varchar(1)
	,@level integer
	,@occ integer
	,@points decimal(10,2)
	,@value decimal(10,2)
	,@rectify_date datetime
	,@username varchar(8)
	,@defh_default_status varchar(1) OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500)
		,@errornumber varchar(10)
		,@comp_rowcount integer
		,@comp_site_ref varchar(16)
		,@comp_contract_ref varchar(12)
		,@comp_default_no integer
		,@comp_item_ref varchar(12)
		,@comp_feature_ref varchar(12)
		,@deft_notice_type varchar(4)
		,@site_priority_flag varchar(1)
		,@max_seq_no integer
		,@new_seq_no integer
		,@trans_date datetime
		,@trans_time_h char(2)
		,@trans_time_m char(2)
		,@numberstr integer
		,@rect_seq_no integer
		,@rect_key integer
		,@result integer
		,@defi_rectify_date datetime
		,@defi_rectify_time_h char(2)
		,@defi_rectify_time_m char(2)
		,@wbc_one_monetary_def varchar(1)
		,@trans_total decimal(10,2)
		;

	SET @errornumber = '20547';

	/* @complaint_no validation */
	IF @complaint_no IS NULL
	BEGIN
		SET @errornumber = '20548';
		SET @errortext = 'complaint_no is required';
		GOTO errorexit;
	END
	SELECT @comp_rowcount = COUNT(*)
		FROM comp
		WHERE complaint_no = @complaint_no;
	IF @comp_rowcount <> 1
	BEGIN
		SET @errornumber = '20549';
		SET @errortext = LTRIM(RTRIM(STR(@complaint_no))) + ' is not a valid complaint reference';
		GOTO errorexit;
	END
	SELECT @comp_default_no = dest_ref
		,@comp_item_ref = item_ref
		,@comp_feature_ref = feature_ref
		,@comp_site_ref = site_ref
		,@comp_contract_ref = contract_ref
		FROM comp
		WHERE complaint_no = @complaint_no;

	/* @default_no validation */
	IF @default_no <> @comp_default_no
	BEGIN
		SET @errornumber = '20550';
		SET @errortext = LTRIM(RTRIM(STR(@default_no))) + ' is not a valid cust_def_no';
		GOTO errorexit;
	END

	/* @site_ref validation */
	IF @site_ref = '' OR @site_ref IS NULL
	BEGIN
		SET @errornumber = '20686';
		SET @errortext = 'site_ref is required';
		GOTO errorexit;
	END
	IF @item_ref <> @comp_item_ref
	BEGIN
		SET @errornumber = '20687';
		SET @errortext = LTRIM(RTRIM(STR(@item_ref))) + ' is not a valid site_ref';
		GOTO errorexit;
	END

	/* @item_ref validation */
	IF @item_ref = '' OR @item_ref IS NULL
	BEGIN
		SET @errornumber = '20551';
		SET @errortext = 'item_ref is required';
		GOTO errorexit;
	END
	IF @item_ref <> @comp_item_ref
	BEGIN
		SET @errornumber = '20552';
		SET @errortext = LTRIM(RTRIM(STR(@item_ref))) + ' is not a valid item_ref';
		GOTO errorexit;
	END

	/* @feature_ref validation */
	IF @feature_ref = '' OR @feature_ref IS NULL
	BEGIN
		SET @errornumber = '20553';
		SET @errortext = 'feature_ref is required';
		GOTO errorexit;
	END
	IF @feature_ref <> @comp_feature_ref
	BEGIN
		SET @errornumber = '20554';
		SET @errortext = LTRIM(RTRIM(STR(@feature_ref))) + ' is not a valid feature_ref';
		GOTO errorexit;
	END

	/* @contract_ref validation */
	IF @contract_ref = '' OR @contract_ref IS NULL
	BEGIN
		SET @errornumber = '20684';
		SET @errortext = 'contract_ref is required';
		GOTO errorexit;
	END
	IF @contract_ref <> @comp_contract_ref
	BEGIN
		SET @errornumber = '20685';
		SET @errortext = LTRIM(RTRIM(STR(@feature_ref))) + ' is not a valid contract_ref';
		GOTO errorexit;
	END

	/* notice_type validation */
	SELECT @max_seq_no = MAX(seq_no)
		FROM deft
		WHERE default_no = @default_no;
	SELECT @deft_notice_type = notice_type
		FROM deft
		WHERE seq_no = @max_seq_no
			AND default_no = @default_no;
	IF @deft_notice_type <> @notice_type
	BEGIN
		SET @errornumber = '20555';
		SET @errortext = LTRIM(RTRIM(STR(@notice_type))) + ' is not a valid notice_type';
		GOTO errorexit;
	END

	/* @priority_flag validation */
	SELECT @site_priority_flag = priority_flag
		FROM si_i
		WHERE site_ref = @site_ref
			AND item_ref = @item_ref
			AND feature_ref = @feature_ref
			AND contract_ref = @contract_ref;
	IF @@ROWCOUNT < 1
	BEGIN
		/* If no si_i try to get priority flag from item */
		SELECT @priority_flag = priority_f
			FROM item
			WHERE item_ref = @item_ref
				AND contract_ref = @contract_ref;
	END
	IF @site_priority_flag <> @priority_flag
	BEGIN
		SET @errornumber = '20556';
		SET @errortext = LTRIM(RTRIM(STR(@priority_flag))) + ' is not a valid priority_flag';
		GOTO errorexit;
	END

	/* @level validation */
	IF @level IS NULL
	BEGIN
		SET @errornumber = '20557';
		SET @errortext = 'level is required';
		GOTO errorexit;
	END

	/* @occ validation */
	IF @occ IS NULL
	BEGIN
		SET @errornumber = '20558';
		SET @errortext = 'occ is required';
		GOTO errorexit;
	END

	/* @points validation */
	IF @points IS NULL
	BEGIN
		SET @errornumber = '20559';
		SET @errortext = 'points is required';
		GOTO errorexit;
	END

	/* @value validation */
	IF @value IS NULL
	BEGIN
		SET @errornumber = '20560';
		SET @errortext = 'value is required';
		GOTO errorexit;
	END

	/* @rectify_date */
	IF @rectify_date IS NULL
	BEGIN
		SET @errornumber = '20561';
		SET @errortext = 'rectify_date is required';
		GOTO errorexit;
	END

	/* @username validation */
	/* Assuming that @username has already been validated by calling process(es) */
	/* so only a basic test here for non-blank and non-null data being passed */
	IF @username = '' OR @username IS NULL
	BEGIN
		SET @errornumber = '20562';
		SET @errortext = 'username is required';
		GOTO errorexit;
	END

	SET @trans_date = GETDATE();

	SET @numberstr = DATENAME(hour, @trans_date);
	SET @trans_time_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @numberstr = DATENAME(minute, @trans_date);
	SET @trans_time_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @trans_date = CONVERT(datetime, CONVERT(date, @trans_date));

	/* WBCHousing only charges for the first rectification on any given site */
	/* once per day. So we need to check if there are any rectifications     */
	/* that have already been raised on this site that have been charged.    */
	SET @wbc_one_monetary_def = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'WBC_ONE_MONETARY_DEF'))));
	IF @wbc_one_monetary_def = 'Y'
	BEGIN
		SELECT @trans_total = SUM(value)
			FROM deft, defh
			WHERE
				(trans_date >= DATEADD(day, DATEDIFF(day, 0, @trans_date), 0) AND trans_date < DATEADD(day, DATEDIFF(day, 0, @trans_date) + 1, 0))
				AND site_ref = @site_ref
				AND value <> 0
				AND value IS NOT NULL
				AND defh.cust_def_no = deft.default_no;

		/* If the total value of all transactions is greater than zero        */
		/* then there has already been a transaction against this site today. */
		/* So we need to blank the value of this rectification transaction    */
		IF @trans_total > 0
		BEGIN	
			SET @value = 0;
			SET @points = 0;
		END
	END

	/* deft */
	SELECT @max_seq_no = MAX(seq_no)
		FROM deft
		WHERE default_no = @default_no;

	SET @new_seq_no = @max_seq_no + 1;

	BEGIN TRY
		INSERT INTO deft
			(
			default_no
			,item_ref
			,feature_ref
			,default_level
			,seq_no
			,action_flag
			,trans_date
			,notice_type
			,notice_ref
			,priority_flag
			,points
			,value
			,source_flag
			,source_ref
			,credit_date
			,username
			,po_code
			,time_h
			,time_m
			,default_occ
			,default_sublevel
			,user_initials
			,credit_reason
			)
			VALUES
			(
			@default_no
			,@item_ref
			,@feature_ref
			,@level
			,@new_seq_no
			,'R'
			,@trans_date
			,@notice_type
			,@default_no
			,@priority_flag
			,@points
			,@value
			,'D'
			,@default_no
			,NULL
			,@username
			,NULL
			,@trans_time_h
			,@trans_time_m
			,@occ
			,NULL
			,NULL
			,NULL
			);
	END TRY
	BEGIN CATCH
		SET @errornumber = '20563';
		SET @errortext = 'Error inserting deft record';
		GOTO errorexit;
	END CATCH

	/* defi_rect */
	SELECT @rect_seq_no = MAX(seq_no)
		FROM defi_rect
		WHERE default_no = @default_no;

	SET @rect_seq_no = @rect_seq_no + 1;

	BEGIN TRY
		EXECUTE @result = dbo.cs_sno_getSerialNumber 'defi_rect', '', @serial_no = @rect_key OUTPUT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20564';
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

	SET @defi_rectify_date = CONVERT(datetime, CONVERT(date, @rectify_date));

	SET @numberstr = DATENAME(hour, @rectify_date);
	SET @defi_rectify_time_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @numberstr = DATENAME(minute, @rectify_date);
	SET @defi_rectify_time_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	BEGIN TRY
		INSERT INTO defi_rect
			(
			default_no
			,seq_no
			,rect_key
			,item_ref
			,feature_ref
			,rectify_date
			,rectify_time_h
			,rectify_time_m
			)
			VALUES
			(
			@default_no
			,@rect_seq_no
			,@rect_key
			,@item_ref
			,@feature_ref
			,@defi_rectify_date
			,@defi_rectify_time_h
			,@defi_rectify_time_m
			);
	END TRY
	BEGIN CATCH
		SET @errornumber = '20565';
		SET @errortext = 'Error inserting defi_rect record';
		GOTO errorexit;
	END CATCH

	/* def_cont_i */
	BEGIN TRY
		UPDATE def_cont_i
			SET [action] = NULL
				,compl_by = NULL
				,printed = NULL
				,clear_credit = NULL
				,date_actioned = NULL
				,time_actioned_h = NULL
				,time_actioned_m = NULL
				,completion_date = NULL
				,completion_time_h = NULL
				,completion_time_m = NULL
			WHERE cust_def_no = @default_no;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20566';
		SET @errortext = 'Error updating def_cont_i record';
		GOTO errorexit;
	END CATCH

	/* Update the points */
	IF @points <> 0
	BEGIN
		BEGIN TRY
			UPDATE defh
				SET cum_points = cum_points + @points
				WHERE cust_def_no = @default_no;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20567';
			SET @errortext = 'Error updating defh record (points)';
			GOTO errorexit;
		END CATCH

		BEGIN TRY
			UPDATE defi
				SET cum_points = cum_points + @points
				WHERE default_no = @default_no;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20568';
			SET @errortext = 'Error updating defi record (points)';
			GOTO errorexit;
		END CATCH
	END

	/* Update the value */
	IF @value <> 0
	BEGIN
		BEGIN TRY
			UPDATE defh
				SET cum_value = cum_points + @value
				WHERE cust_def_no = @default_no;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20569';
			SET @errortext = 'Error updating defh record (value)';
			GOTO errorexit;
		END CATCH

		BEGIN TRY
			UPDATE defi
				SET cum_value = cum_points + @value
				WHERE default_no = @default_no;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20570';
			SET @errortext = 'Error updating defi record (value)';
			GOTO errorexit;
		END CATCH
	END

	SELECT @defh_default_status = default_status
		FROM defh
		WHERE cust_def_no = @default_no;

	/* Update any active occurrence of the complaint in the insp_list table */
	/* as it has been processed                                             */
	BEGIN TRY
		UPDATE insp_list
			SET [state] = 'P'
			WHERE complaint_no = @complaint_no
				AND [state] = 'A';
	END TRY
	BEGIN CATCH
		SET @errornumber = '20571';
		SET @errortext = 'Error updating insp_list record';
		GOTO errorexit;
	END CATCH

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
