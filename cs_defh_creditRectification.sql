/*****************************************************************************
** dbo.cs_defh_creditRectification
** stored procedure
**
** Description
** Rectification update - credit the specified rectification
**
** Parameters
** @complaint_no
** @default_no
** @action_flag
** @username
** @deft_time_h (OUTPUT)
** @deft_time_m (OUTPUT)
** @defh_default_status (OUTPUT)
**
** Returned
** Return value of 0 (success), or -1 (failure)
**
** History
** 31/05/2013  TW  New
** 09/07/2013  TW  Bug fix for close condition (2 * @zcount) >= @tcount
**                 instead of @zcount >= (@tcount / 2)
**                 [integers and rounding making division imprecise]
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_defh_creditRectification', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_defh_creditRectification;
GO
CREATE PROCEDURE dbo.cs_defh_creditRectification
	@complaint_no integer
	,@default_no integer
	,@item_ref varchar(12)
	,@feature_ref varchar(12)
	,@action_flag varchar(6)
	,@username varchar(8)
	,@deft_time_h varchar(2) OUTPUT
	,@deft_time_m varchar(2) OUTPUT
	,@defh_default_status varchar(1) OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500)
		,@errornumber varchar(10)
		,@comp_rowcount integer
		,@comp_default_no integer
		,@comp_item_ref varchar(12)
		,@comp_feature_ref varchar(12)
		,@deft_rowcount integer
		,@max_seq_no integer
		,@new_seq_no integer
		,@query_seq_no integer
		,@trans_date datetime
		,@trans_time_h char(2)
		,@trans_time_m char(2)
		,@numberstr integer
		,@default_level integer
		,@default_occ integer
		,@deft_item_ref varchar(12)
		,@deft_priority_flag varchar(1)
		,@deft_feature_ref varchar(12)
		,@deft_notice_type varchar(4)
		,@deft_points decimal(10,2)
		,@deft_value decimal(10,2)
		,@deft_source_flag varchar(1)
		,@deft_source_ref integer
		,@deft_action_flag varchar(1)
		,@next_deft_action_flag varchar(1)
		,@tcount integer
		,@zcount integer
		,@loop_seq_no integer
		,@loop_item_ref varchar(12)
		,@loop_feature_ref varchar(12)
		,@loop_default_level integer
		,@loop_default_occ integer
		,@loop_default_sublevel integer
		;

	SET @errornumber = '20530';

	/* @complaint_no validation */
	IF @complaint_no IS NULL
	BEGIN
		SET @errornumber = '20531';
		SET @errortext = 'complaint_no is required';
		GOTO errorexit;
	END
	SELECT @comp_rowcount = COUNT(*)
		FROM comp
		WHERE complaint_no = @complaint_no;
	IF @comp_rowcount <> 1
	BEGIN
		SET @errornumber = '20532';
		SET @errortext = LTRIM(RTRIM(STR(@complaint_no))) + ' is not a valid complaint reference';
		GOTO errorexit;
	END
	SELECT @comp_default_no = dest_ref
		,@comp_item_ref = item_ref
		,@comp_feature_ref = feature_ref
		FROM comp
		WHERE complaint_no = @complaint_no;

	/* @default_no validation */
	IF @default_no <> @comp_default_no
	BEGIN
		SET @errornumber = '20533';
		SET @errortext = LTRIM(RTRIM(STR(@default_no))) + ' is not a valid cust_def_no';
		GOTO errorexit;
	END

	/* @item_ref validation */
	IF @item_ref = '' OR @item_ref IS NULL
	BEGIN
		SET @errornumber = '20680';
		SET @errortext = 'item_ref is required';
		GOTO errorexit;
	END
	IF @item_ref <> @comp_item_ref
	BEGIN
		SET @errornumber = '20681';
		SET @errortext = LTRIM(RTRIM(STR(@item_ref))) + ' is not a valid item_ref';
		GOTO errorexit;
	END

	/* @feature_ref validation */
	IF @feature_ref = '' OR @feature_ref IS NULL
	BEGIN
		SET @errornumber = '20682';
		SET @errortext = 'feature_ref is required';
		GOTO errorexit;
	END
	IF @feature_ref <> @comp_feature_ref
	BEGIN
		SET @errornumber = '20683';
		SET @errortext = LTRIM(RTRIM(STR(@feature_ref))) + ' is not a valid feature_ref';
		GOTO errorexit;
	END

	/* @action_flag validation */
	IF @action_flag = '' OR @action_flag IS NULL
	BEGIN
		SET @errornumber = '20534';
		SET @errortext = 'action_flag is required';
		GOTO errorexit;
	END

	/* @username validation */
	/* Assuming that @username has already been validated by calling process(es) */
	/* so only a basic test here for non-blank and non-null data being passed */
	IF @username = '' OR @username IS NULL
	BEGIN
		SET @errornumber = '20535';
		SET @errortext = 'username is required';
		GOTO errorexit;
	END

	SELECT @max_seq_no = MAX(seq_no)
		FROM deft
		WHERE default_no = @default_no;

	SET @new_seq_no = @max_seq_no + 1;

	SET @query_seq_no = 0;

	IF @action_flag = 'CR'
	BEGIN
		SET @query_seq_no = @max_seq_no;

		SET @trans_date = GETDATE();

		SET @numberstr = DATENAME(hour, @trans_date);
		SET @trans_time_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

		SET @numberstr = DATENAME(minute, @trans_date);
		SET @trans_time_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

		SET @trans_date = CONVERT(datetime, CONVERT(date, @trans_date));

		SELECT
			@default_level = default_level
			,@default_occ = default_occ
			,@deft_item_ref = item_ref
			,@deft_priority_flag = priority_flag
			,@deft_feature_ref = feature_ref
			,@deft_notice_type = notice_type
			,@deft_points = points
			,@deft_value = value
			,@deft_source_flag = source_flag
			,@deft_source_ref = source_ref
			,@deft_action_flag = action_flag
			FROM deft
			WHERE seq_no = @query_seq_no
				AND default_no = @default_no
				AND feature_ref = @feature_ref
				AND item_ref = @item_ref;

		BEGIN TRY
			UPDATE defh
				SET cum_points = cum_points - @deft_points
					,cum_value = cum_value - @deft_value
				WHERE cust_def_no = @default_no;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20537';
			SET @errortext = 'Error updating defh record';
			GOTO errorexit;
		END CATCH

		BEGIN TRY
			UPDATE defi
				SET cum_points = cum_points - @deft_points
					,cum_value = cum_value - @deft_value
				WHERE default_no = @default_no;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20538';
			SET @errortext = 'Error updating defi record';
			GOTO errorexit;
		END CATCH

		SET @default_level = - @default_level;
		SET @default_occ   = - @default_occ;
		SET @deft_points   = - @deft_points;
		SET @deft_value    = - @deft_value;

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
				,@deft_item_ref
				,@deft_feature_ref
				,@default_level
				,@new_seq_no
				,'Z'
				,@trans_date
				,@deft_notice_type
				,@default_no
				,@deft_priority_flag
				,@deft_points
				,@deft_value
				,@deft_source_flag
				,@deft_source_ref
				,@trans_date
				,@username
				,NULL
				,@trans_time_h
				,@trans_time_m
				,@default_occ
				,NULL
				,NULL
				,NULL
				)
		END TRY
		BEGIN CATCH
			SET @errornumber = '20536';
			SET @errortext = 'Error inserting deft record';
			GOTO errorexit;
		END CATCH

		GOTO check_close;
	END

	IF @action_flag = 'CRA'
	BEGIN
		SET @query_seq_no = 1;

		SET @trans_date = GETDATE();

		SET @numberstr = DATENAME(hour, @trans_date);
		SET @trans_time_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

		SET @numberstr = DATENAME(minute, @trans_date);
		SET @trans_time_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

		SET @trans_date = CONVERT(datetime, CONVERT(date, @trans_date));

		DECLARE csr_deft CURSOR FOR
			SELECT deft.seq_no
				,defi.item_ref
				,defi.feature_ref
				,deft.default_level
				,deft.default_occ
				FROM defh, defi, deft
				WHERE defh.cust_def_no = @default_no
					AND defh.default_status = 'Y'
					AND defi.item_status = 'Y'
					AND deft.default_level > 0
					AND deft.default_occ > 0
					AND defh.cust_def_no = defi.default_no
					AND deft.default_no = defi.default_no
					AND defi.item_ref = deft.item_ref
					AND defi.feature_ref = deft.feature_ref
				ORDER BY defi.item_ref
					,defi.feature_ref
					,deft.default_level
					,deft.default_occ;

			OPEN csr_deft;

			FETCH NEXT FROM csr_deft INTO
				@loop_seq_no
				,@loop_item_ref
				,@loop_feature_ref
				,@loop_default_level
				,@loop_default_occ
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT
					@default_level = default_level
					,@default_occ = default_occ
					,@deft_item_ref = item_ref
					,@deft_priority_flag = priority_flag
					,@deft_feature_ref = feature_ref
					,@deft_notice_type = notice_type
					,@deft_points = points
					,@deft_value = value
					,@deft_source_flag = source_flag
					,@deft_source_ref = source_ref
					,@deft_action_flag = action_flag
					FROM deft
					WHERE default_no = @default_no
						AND seq_no = @loop_seq_no
						AND feature_ref = @loop_feature_ref
						AND item_ref = @loop_item_ref;

				SELECT @deft_rowcount = COUNT(*)
					FROM deft
					WHERE default_no = @default_no
						AND default_level = - @default_level
						AND default_occ = - @default_occ
						AND item_ref = @deft_item_ref
						AND feature_ref = @deft_feature_ref;

				IF @deft_rowcount = 0
				BEGIN
					BEGIN TRY
						UPDATE defh
							SET cum_points = cum_points - @deft_points
								,cum_value = cum_value - @deft_value
							WHERE cust_def_no = @default_no;
					END TRY
					BEGIN CATCH
						SET @errornumber = '20582';
						SET @errortext = 'Error updating defh record';
						GOTO errorexit;
					END CATCH

					BEGIN TRY
						UPDATE defi
							SET cum_points = cum_points - @deft_points
								,cum_value = cum_value - @deft_value
							WHERE default_no = @default_no;
					END TRY
					BEGIN CATCH
						SET @errornumber = '20583';
						SET @errortext = 'Error updating defi record';
						GOTO errorexit;
					END CATCH

				END

				SET @default_level = - @default_level;
				SET @default_occ   = - @default_occ;
				SET @deft_points   = - @deft_points;
				SET @deft_value    = - @deft_value;

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
						,@deft_item_ref
						,@deft_feature_ref
						,@default_level
						,@new_seq_no
						,'Z'
						,@trans_date
						,@deft_notice_type
						,@default_no
						,@deft_priority_flag
						,@deft_points
						,@deft_value
						,@deft_source_flag
						,@deft_source_ref
						,@trans_date
						,@username
						,NULL
						,@trans_time_h
						,@trans_time_m
						,@default_occ
						,NULL
						,NULL
						,NULL
						)
				END TRY
				BEGIN CATCH
					SET @errornumber = '20584';
					SET @errortext = 'Error inserting deft record';
					GOTO errorexit;
				END CATCH

				FETCH NEXT FROM csr_deft INTO
					@loop_seq_no
					,@loop_item_ref
					,@loop_feature_ref
					,@loop_default_level
					,@loop_default_occ
			END

			CLOSE csr_deft;
			DEALLOCATE csr_deft;

		GOTO check_close;
	END

	GOTO normalexit;

check_close:
	
	SET @deft_time_h = @trans_time_h;
	SET @deft_time_m = @trans_time_m;
	SELECT @defh_default_status = default_status
		FROM defh
		WHERE cust_def_no = @default_no;

	SELECT @tcount = COUNT(*)
		FROM deft
		WHERE default_no = @default_no;

	SELECT @zcount = COUNT(*)
		FROM deft
		WHERE default_no = @default_no
			AND action_flag = 'Z';

	/* Close the rectification? */
	IF (2 * @zcount) >= @tcount
	BEGIN
		/* defi */
		BEGIN TRY
			UPDATE defi
				SET item_status = 'N'
					,clear_date = @trans_date
				WHERE default_no = @default_no;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20542';
			SET @errortext = 'error updating defi record';
			GOTO errorexit;
		END CATCH

		/* defh */
		BEGIN TRY
			UPDATE defh
				SET default_status = 'N'
				WHERE cust_def_no = @default_no;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20541';
			SET @errortext = 'error updating defh record';
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
			SET @errornumber = '20543';
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
			SET @errornumber = '20544';
			SET @errortext = 'error updating comp record';
			GOTO errorexit;
		END CATCH

		/* Delete any occurrence of the complaint from the insp_list table */
		/* as it has been closed                                           */
		BEGIN TRY
			DELETE FROM insp_list
				WHERE complaint_no = @complaint_no;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20545';
			SET @errortext = 'Error deleting insp_list record';
			GOTO errorexit;
		END CATCH
	END
	ELSE
	BEGIN
		/* Update any active occurrence of the complaint in the insp_list table */
		/* as it has been processed                                             */
		BEGIN TRY
			UPDATE insp_list
				SET [state] = 'P'
				WHERE complaint_no = @complaint_no
					AND [state] = 'A';
		END TRY
		BEGIN CATCH
			SET @errornumber = '20546';
			SET @errortext = 'Error updating insp_list record';
			GOTO errorexit;
		END CATCH
	END

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
