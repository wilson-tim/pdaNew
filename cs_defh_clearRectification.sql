/*****************************************************************************
** dbo.cs_defh_clearRectification
** stored procedure
**
** Description
** Rectification update - clear the specified rectification
**
** Parameters
** @complaint_no
** @default_no
** @item_ref
** @feature_ref
** @notice_type
** @priority_flag
** @username
** @defh_default_status (OUTPUT)
**
** Returned
** Return value of 0 (success), or -1 (failure)
**
** History
** 31/05/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_defh_clearRectification', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_defh_clearRectification;
GO
CREATE PROCEDURE dbo.cs_defh_clearRectification
	@complaint_no integer
	,@default_no integer
	,@site_ref varchar(16)
	,@item_ref varchar(12)
	,@feature_ref varchar(12)
	,@contract_ref varchar(12)
	,@notice_type varchar(4)
	,@priority_flag varchar(1)
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
		;

	SET @errornumber = '20513';

	/* @complaint_no validation */
	IF @complaint_no IS NULL
	BEGIN
		SET @errornumber = '20514';
		SET @errortext = 'complaint_no is required';
		GOTO errorexit;
	END
	SELECT @comp_rowcount = COUNT(*)
		FROM comp
		WHERE complaint_no = @complaint_no;
	IF @comp_rowcount <> 1
	BEGIN
		SET @errornumber = '20515';
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
		SET @errornumber = '20516';
		SET @errortext = LTRIM(RTRIM(STR(@default_no))) + ' is not a valid cust_def_no';
		GOTO errorexit;
	END

	/* @site_ref validation */
	IF @site_ref = '' OR @site_ref IS NULL
	BEGIN
		SET @errornumber = '20678';
		SET @errortext = 'site_ref is required';
		GOTO errorexit;
	END
	IF @item_ref <> @comp_item_ref
	BEGIN
		SET @errornumber = '20679';
		SET @errortext = LTRIM(RTRIM(STR(@item_ref))) + ' is not a valid site_ref';
		GOTO errorexit;
	END

	/* @item_ref validation */
	IF @item_ref = '' OR @item_ref IS NULL
	BEGIN
		SET @errornumber = '20517';
		SET @errortext = 'item_ref is required';
		GOTO errorexit;
	END
	IF @item_ref <> @comp_item_ref
	BEGIN
		SET @errornumber = '20518';
		SET @errortext = LTRIM(RTRIM(STR(@item_ref))) + ' is not a valid item_ref';
		GOTO errorexit;
	END

	/* @feature_ref validation */
	IF @feature_ref = '' OR @feature_ref IS NULL
	BEGIN
		SET @errornumber = '20519';
		SET @errortext = 'feature_ref is required';
		GOTO errorexit;
	END
	IF @feature_ref <> @comp_feature_ref
	BEGIN
		SET @errornumber = '20520';
		SET @errortext = LTRIM(RTRIM(STR(@feature_ref))) + ' is not a valid feature_ref';
		GOTO errorexit;
	END

	/* @contract_ref validation */
	IF @contract_ref = '' OR @contract_ref IS NULL
	BEGIN
		SET @errornumber = '20676';
		SET @errortext = 'contract_ref is required';
		GOTO errorexit;
	END
	IF @contract_ref <> @comp_contract_ref
	BEGIN
		SET @errornumber = '20677';
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
		SET @errornumber = '20521';
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
		SET @errornumber = '20522';
		SET @errortext = LTRIM(RTRIM(STR(@priority_flag))) + ' is not a valid priority_flag';
		GOTO errorexit;
	END

	/* @username validation */
	/* Assuming that @username has already been validated by calling process(es) */
	/* so only a basic test here for non-blank and non-null data being passed */
	IF @username = '' OR @username IS NULL
	BEGIN
		SET @errornumber = '20523';
		SET @errortext = 'username is required';
		GOTO errorexit;
	END

	/* deft */
	/* Create a clear trnasaction */
	BEGIN TRY
		SET @new_seq_no = @max_seq_no + 1;

		SET @trans_date = GETDATE();

		SET @numberstr = DATENAME(hour, @trans_date);
		SET @trans_time_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

		SET @numberstr = DATENAME(minute, @trans_date);
		SET @trans_time_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

		SET @trans_date = CONVERT(datetime, CONVERT(date, @trans_date));

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
			,0
			,@new_seq_no
			,'C'
			,@trans_date
			,@notice_type
			,@default_no
			,@priority_flag
			,0.00
			,0.00
			,'D'
			,0
			,NULL
			,@username
			,NULL
			,@trans_time_h
			,@trans_time_m
			,0
			,NULL
			,NULL
			,NULL
			)
	END TRY
	BEGIN CATCH
		SET @errornumber = '20524';
		SET @errortext = 'error inserting deft record';
		GOTO errorexit;
	END CATCH

	/* Close the rectification */

	/* defh */
	BEGIN TRY
		UPDATE defh
			SET clear_flag = 'N'
			,default_status = 'N'
			WHERE cust_def_no = @default_no;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20525';
		SET @errortext = 'error updating defh record';
		GOTO errorexit;
	END CATCH

	SELECT @defh_default_status = default_status
		FROM defh
		WHERE cust_def_no = @default_no;

	/* defi */
	BEGIN TRY
		UPDATE defi
			SET item_status = 'N'
				,clear_date = @trans_date
			WHERE default_no = @default_no;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20526';
		SET @errortext = 'error updating defi record';
		GOTO errorexit;
	END CATCH

	/* diry */
	BEGIN TRY
		UPDATE diry
			SET action_flag = 'C'
				,dest_flag = 'C'
				,dest_date = @trans_date
				,dest_time_h = @trans_time_h
				,dest_time_m = @trans_time_m
				,dest_user = @username
			WHERE source_flag = 'D'
				AND source_ref = @default_no;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20527';
		SET @errortext = 'error updating diry record';
		GOTO errorexit;
	END CATCH

	/* Close the complaint */
	BEGIN TRY
		UPDATE comp
			SET date_closed = @trans_date
				,time_closed_h = @trans_time_h
				,time_closed_m = @trans_time_m
			WHERE complaint_no = @complaint_no;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20528';
		SET @errortext = 'error updating comp record';
		GOTO errorexit;
	END CATCH

	BEGIN TRY
		DELETE FROM insp_list
			WHERE complaint_no = @complaint_no;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20529';
		SET @errortext = 'Error deleting insp_list record';
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
