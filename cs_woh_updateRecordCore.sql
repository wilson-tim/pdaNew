/*****************************************************************************
** dbo.cs_woh_updateRecordCore
** stored procedure
**
** Description
** Update a works order
**
** Parameters
** @complaint_no = customer care reference
** @new_status = new wo status value
** @username   = login id
**
** Returned
** Return value of 0 (success), or -1 (failure)
**
** Notes
**
** History
** 26/06/2013  TW  New
** 04/07/2013  TW  New parameter @complaint_no in place of @wo_ref and @wo_suffix
** 05/07/2013  TW  Bug fixes
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_woh_updateRecordCore', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_woh_updateRecordCore;
GO
CREATE PROCEDURE dbo.cs_woh_updateRecordCore
	@pcomplaint_no integer
	,@pnew_status varchar(6)
	,@pusername varchar(8)
	,@wo_ref integer OUTPUT
	,@wo_suffix varchar(6) OUTPUT
	,@wo_key integer OUTPUT
	,@wo_h_stat varchar(3) OUTPUT
	,@wo_act_value decimal(13,4) OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @result integer
		,@errortext varchar(500)
		,@errornumber varchar(10)
		,@status_updated bit
		,@new_status varchar(6)
		,@old_status varchar(6)
		,@username varchar(8)
		,@wo_oldstat_cancel varchar(1)
		,@wo_stat_clear varchar(1)
		,@wo_stat_issue varchar(1)
		,@wo_stat_cancel varchar(1)
		,@wo_stat_authorise varchar(1)
		,@wo_stat_last_wo varchar(40)
		,@wo_stat_last_comp varchar(40)
		,@wo_stat_close_comp varchar(1)
		,@stat_count integer
		,@remote_access varchar(40)
		,@compl_by varchar(12)
		,@comp_rowcount integer
		,@datestamp_date datetime
		,@datestamp_time_h varchar(2)
		,@datestamp_time_m varchar(2)
		,@numberstr varchar(2)
		,@wo_date_compl datetime
		,@tmp_date_compl datetime
		,@wo_paycl_dte datetime
		,@complaint_no integer
		,@wo_closed bit
		,@comp_closed bit
		;

	SET @complaint_no = @pcomplaint_no;
	SET @new_status = LTRIM(RTRIM(@pnew_status));
	SET @username   = LTRIM(RTRIM(@pusername));

	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @errornumber = '20670';
		SET @errortext   = 'complaint_no is required';
		GOTO errorexit;
	END
	SELECT @comp_rowcount = COUNT(*)
		FROM comp
		WHERE complaint_no = @complaint_no
	IF @comp_rowcount <> 1
	BEGIN
		SET @errornumber = '20671';
		SET @errortext = LTRIM(RTRIM(STR(@complaint_no))) + ' is not a valid complaint reference';
		GOTO errorexit;
	END

	/* @new_status validation */
	IF @new_status = '' OR @new_status IS NULL
	BEGIN
		SET @errornumber = '20627';
		SET @errortext   = 'new_status is required';
		GOTO errorexit;
	END

	/* @username validation */
	/* Assuming that @username has already been validated by calling process(es) */
	/* so only a basic test here for non-blank and non-null data being passed */
	IF @username = '' OR @username IS NULL
	BEGIN
		SET @errornumber = '20628';
		SET @errortext   = 'username is required';
		GOTO errorexit;
	END

	/* Get @wo_ref and @wo_suffix */
	SELECT @wo_ref = dest_ref
		,@wo_suffix = dest_suffix
		FROM comp
		WHERE complaint_no = @complaint_no
			AND action_flag = 'W';
	IF @wo_ref = 0 OR @wo_ref IS NULL
		OR @wo_suffix = '' OR @wo_suffix IS NULL
	BEGIN
		SET @errornumber = '20672';
		SET @errortext = LTRIM(RTRIM(STR(@complaint_no))) + ' is not a valid complaint reference';
		GOTO errorexit;
	END

	/* Get wo_key and wo completion date */
	SELECT @wo_key = wo_key
		,@wo_date_compl = wo_date_compl
		,@wo_paycl_dte = wo_paycl_dte
		,@old_status = wo_h_stat
		FROM wo_h
		WHERE wo_ref = @wo_ref
			AND wo_suffix = @wo_suffix;

	/* Get attributes of new status */
	SELECT
		@wo_stat_clear = [clear]
		,@wo_stat_issue = issue
		,@wo_stat_cancel = cancel
		,@wo_stat_authorise = authorise
		,@wo_stat_close_comp = close_comp
		FROM wo_stat
		WHERE wo_h_stat = @new_status;

	/* Get attributes of old status */
	SELECT
		@wo_oldstat_cancel = cancel
		FROM wo_stat
		WHERE wo_h_stat = @old_status;

	/* Get date time data */
	SET @datestamp_date = GETDATE();

	SET @numberstr = DATENAME(hour, @datestamp_date);
	SET @datestamp_time_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @numberstr = DATENAME(minute, @datestamp_date);
	SET @datestamp_time_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @datestamp_date = CONVERT(datetime, CONVERT(date, @datestamp_date));

	/* Is remote access installed? */
	SET @remote_access = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'REMOTE_ACCESS'))));

	/*
	SELECT @complaint_no = complaint_no
		FROM comp
		WHERE dest_ref = @wo_ref
			AND dest_suffix = @wo_suffix
			AND action_flag = 'W';
	*/

	SET @wo_closed = 0;
	SET @comp_closed = 0;

	/*****************************************************************************
	** Cleared
	*****************************************************************************/
	IF @wo_stat_clear = 'Y'
	BEGIN
		/* wo_h table */
		BEGIN TRY
			UPDATE wo_h
				SET wo_h_stat     = @new_status,
					wo_date_compl = @datestamp_date
				WHERE wo_key = @wo_key;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20629';
			SET @errortext   = 'Error updating wo_h record; unable to clear works order';
			GOTO errorexit;
		END CATCH

		/* diry table */
		BEGIN TRY
			UPDATE diry
				SET dest_flag   = SUBSTRING(@new_status, 1, 1),
					dest_ref    = NULL,
					dest_date   = @datestamp_date,
					dest_time_h = @datestamp_time_h,
					dest_time_m = @datestamp_time_m,
					dest_user	= @username
				WHERE source_flag = 'W'
					AND source_ref = @wo_key;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20630';
			SET @errortext   = 'Error updating diry record';
			GOTO errorexit;
		END CATCH

		/* Close the complaint? */
		IF @wo_stat_close_comp = 'Y'
		BEGIN
			BEGIN TRY
				UPDATE comp
					SET date_closed   = @datestamp_date,
						time_closed_h = @datestamp_time_h,
						time_closed_m = @datestamp_time_m
					WHERE dest_ref = @wo_ref
						AND dest_suffix = @wo_suffix
						AND action_flag = 'W';
			END TRY
			BEGIN CATCH
				SET @errornumber = '20631';
				SET @errortext   = 'Error updating comp record';
				GOTO errorexit;
			END CATCH

			SET @comp_closed = 1;

			/* See putils.4gl function close_complaint() */
			/* No TRADE service so no works order invoicing here */
		END

		/* wo_cont_h table */
		IF @remote_access = 'Y'
		BEGIN
			SELECT @compl_by = compl_by
				FROM wo_cont_h
				WHERE wo_ref = @wo_ref
					AND wo_suffix = @wo_suffix;

			IF @compl_by = '' OR @compl_by IS NULL
			BEGIN
				BEGIN TRY
					UPDATE wo_cont_h
						SET	compl_by = @username
						WHERE wo_ref = @wo_ref
							AND	wo_suffix = @wo_suffix;
				END TRY
				BEGIN CATCH
					SET @errornumber = '20632';
					SET @errortext   = 'Error updating wo_cont_h record';
					GOTO errorexit;
				END CATCH
			END
		END

		SET @status_updated = 1;
		SET @wo_closed = 1;

		/* wo_stat_hist table */
		BEGIN TRY
			EXECUTE dbo.cs_wostathist_createRecord
				@wo_ref
				,@wo_suffix
				,@new_status
				,@username;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20633';
			SET @errortext   = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH
	END
  
	/*****************************************************************************
	** Issued
	*****************************************************************************/
	IF @wo_stat_issue = 'Y'
	BEGIN
		/* wo_h table */
		BEGIN TRY
			UPDATE wo_h
				SET wo_h_stat     = @new_status,
					wo_date_compl = NULL
				WHERE wo_key = @wo_key;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20634';
			SET @errortext   = 'Error updating wo_h record; unable to issue works order';
			GOTO errorexit;
		END CATCH

		/* wo_cont_h table */
		IF @remote_access = 'Y'
		BEGIN
			BEGIN TRY
				UPDATE wo_cont_h
					SET	compl_by          = NULL,
						cont_canc         = NULL,
						completion_date   = NULL,
						completion_time_h = NULL,
						completion_time_m = NULL
					WHERE wo_ref = @wo_ref
						AND wo_suffix = @wo_suffix;
		END TRY
			BEGIN CATCH
				SET @errornumber = '20635';
				SET @errortext   = 'Error updating wo_cont_h record';
				GOTO errorexit;
			END CATCH
		END

		SET @status_updated = 1;

		/* wo_stat_hist table */
		BEGIN TRY
			EXECUTE dbo.cs_wostathist_createRecord
				@wo_ref
				,@wo_suffix
				,@new_status
				,@username;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20636';
			SET @errortext   = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH
	END
  
	/*****************************************************************************
	** Cancelled
	*****************************************************************************/
	IF @wo_stat_cancel = 'Y'
	BEGIN
		IF @wo_paycl_dte IS NOT NULL
		BEGIN
			SET @errornumber = '20637';
			SET @errortext   = 'This works order has already been cleared for payment; unable to cancel works order';
			GOTO errorexit;
		END

		IF @wo_oldstat_cancel = 'Y'
		BEGIN
			SET @errornumber = '20638';
			SET @errortext   = 'This works order has already been cancelled; unable to cancel works order';
			GOTO errorexit;
		END

		/* wo_h table */
		BEGIN TRY
			IF @wo_date_compl IS NULL
			BEGIN
				UPDATE wo_h
					SET wo_h_stat      = @new_status
						,wo_date_compl = @datestamp_date
					WHERE wo_key = @wo_key;
			END
			ELSE
			BEGIN
				UPDATE wo_h
					SET wo_h_stat = @new_status
					WHERE wo_key = @wo_key;
			END
		END TRY
		BEGIN CATCH
			SET @errornumber = '20639';
			SET @errortext   = 'Error updating wo_h record; unable to cancel works order';
			GOTO errorexit;
		END CATCH

		/* diry table */
		BEGIN TRY
			UPDATE diry
				SET dest_flag    = SUBSTRING(@new_status, 1, 1)
					,dest_date   = @datestamp_date
					,dest_time_h = @datestamp_time_h
					,dest_time_m = @datestamp_time_m
					,date_done   = @datestamp_date
					,done_time_h = @datestamp_time_h
					,done_time_m = @datestamp_time_m
				WHERE source_flag = 'W'
					AND source_ref = @wo_key;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20640';
			SET @errortext   = 'Error updating diry record';
			GOTO errorexit;
		END CATCH

		/* Close the complaint? */
		IF @wo_stat_close_comp = 'Y'
		BEGIN
			BEGIN TRY
				UPDATE comp
					SET date_closed   = @datestamp_date,
						time_closed_h = @datestamp_time_h,
						time_closed_m = @datestamp_time_m
					WHERE dest_ref = @wo_ref
						AND dest_suffix = @wo_suffix
						AND action_flag = 'W';
			END TRY
			BEGIN CATCH
				SET @errornumber = '20641';
				SET @errortext   = 'Error updating comp record';
				GOTO errorexit;
			END CATCH

			SET @comp_closed = 1;

			/* See putils.4gl function close_complaint() */
			/* No TRADE service so no works order invoicing here */
		END

		/* wo_cont_h table */
		IF @remote_access = 'Y'
		BEGIN
			SELECT @compl_by = compl_by
				FROM wo_cont_h
				WHERE wo_ref = @wo_ref
					AND wo_suffix = @wo_suffix;

			IF @compl_by = '' OR @compl_by IS NULL
			BEGIN
				BEGIN TRY
					UPDATE wo_cont_h
						SET compl_by = @username
						WHERE wo_ref = @wo_ref
							AND wo_suffix = @wo_suffix;
				END TRY
				BEGIN CATCH
					SET @errornumber = '20642';
					SET @errortext   = 'Error updating wo_cont_h record';
					GOTO errorexit;
				END CATCH
			END
		END

		SET @status_updated = 1;
		SET @wo_closed = 1;

		/* wo_stat_hist table */
		BEGIN TRY
			EXECUTE dbo.cs_wostathist_createRecord
				@wo_ref
				,@wo_suffix
				,@new_status
				,@username;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20644';
			SET @errortext   = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH

		/* Works order creation logic will have created a wo_cont_h record so cancel it here */
		BEGIN TRY
			UPDATE wo_cont_h
				SET cont_canc = 'Y'
				WHERE wo_ref = @wo_ref
					AND wo_suffix = @wo_suffix;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20643';
			SET @errortext   = 'Error updating wo_cont_h record (cont_canc flag)';
			GOTO errorexit;
		END CATCH
	END

	/*****************************************************************************
	** Authorised
	*****************************************************************************/
	IF @wo_stat_authorise = 'Y'
	BEGIN
		SET @tmp_date_compl = @wo_date_compl;

		IF @tmp_date_compl IS NULL
		BEGIN
			SET @tmp_date_compl = @datestamp_date;
		END

		/* wo_h table */
		BEGIN TRY
			UPDATE wo_h
			SET wo_h_stat     = @new_status,
				wo_payment_f  = 'C',
				wo_paycl_dte  = @datestamp_date,
				wo_date_compl = @tmp_date_compl
			WHERE wo_key = @wo_key;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20645';
			SET @errortext   = 'Error updating wo_h record; unable to authorise works order';
			GOTO errorexit;
		END CATCH

		/* Close the complaint? */
		IF @wo_stat_close_comp = 'Y'
		BEGIN
			BEGIN TRY
				UPDATE comp
					SET date_closed   = @datestamp_date,
						time_closed_h = @datestamp_time_h,
						time_closed_m = @datestamp_time_m
					WHERE dest_ref = @wo_ref
						AND dest_suffix = @wo_suffix
						AND action_flag = 'W';
			END TRY
			BEGIN CATCH
				SET @errornumber = '20646';
				SET @errortext   = 'Error updating comp record';
				GOTO errorexit;
			END CATCH

			SET @comp_closed = 1;

			/* See putils.4gl function close_complaint() */
			/* No TRADE service so no works order invoicing here */
		END

		/* wo_cont_h table */
		IF @remote_access = 'Y'
		BEGIN
			SELECT @compl_by = compl_by
				FROM wo_cont_h
				WHERE wo_ref = @wo_ref
					AND wo_suffix = @wo_suffix;

			IF @compl_by = '' OR @compl_by IS NULL
			BEGIN
				BEGIN TRY
					UPDATE wo_cont_h
						SET compl_by = @username
						WHERE wo_ref = @wo_ref
							AND wo_suffix = @wo_suffix;
				END TRY
				BEGIN CATCH
					SET @errornumber = '20647';
					SET @errortext   = 'Error updating wo_cont_h record';
					GOTO errorexit;
				END CATCH
			END
		END

		SET @status_updated = 1;
		SET @wo_closed = 1;

		/* wo_stat_hist table */
		BEGIN TRY
			EXECUTE dbo.cs_wostathist_createRecord
				@wo_ref
				,@wo_suffix
				,@new_status
				,@username;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20648';
			SET @errortext   = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH
	END

	/*****************************************************************************
	** Last works order - close works order?
	*****************************************************************************/
	SET @wo_stat_last_wo = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'WO_STAT_LAST_WO'))));

	IF @wo_stat_last_wo = 'Y'
	BEGIN
		/* Is there a next status after this status? */
		SELECT @stat_count = COUNT(*)
			FROM wo_next_stat
			WHERE wo_h_stat = @new_status;

		IF @stat_count = 0
		BEGIN
			SET @tmp_date_compl = @wo_date_compl;

			IF @tmp_date_compl IS NULL
			BEGIN
				SET @tmp_date_compl = @datestamp_date;
			END

			/* wo_h table */
			BEGIN TRY
				UPDATE wo_h
				SET wo_h_stat     = @new_status,
					wo_payment_f  = 'C',
					wo_paycl_dte  = @datestamp_date,
					wo_date_compl = @tmp_date_compl
				WHERE wo_key = @wo_key;
			END TRY
			BEGIN CATCH
				SET @errornumber = '20649';
				SET @errortext   = 'Error updating wo_h record';
				GOTO errorexit;
			END CATCH
			
			/* wo_cont_h table */
			IF @remote_access = 'Y'
			BEGIN
				SELECT @compl_by = compl_by
					FROM wo_cont_h
					WHERE wo_ref = @wo_ref
						AND wo_suffix = @wo_suffix;

				IF @compl_by = '' OR @compl_by IS NULL
				BEGIN
					BEGIN TRY
						UPDATE wo_cont_h
							SET compl_by = @username
							WHERE wo_ref = @wo_ref
								AND wo_suffix = @wo_suffix;
					END TRY
					BEGIN CATCH
						SET @errornumber = '20650';
						SET @errortext   = 'Error updating wo_cont_h record';
						GOTO errorexit;
					END CATCH
				END
			END

			SET @status_updated = 1;

			/* wo_stat_hist table */
			BEGIN TRY
				EXECUTE dbo.cs_wostathist_createRecord
					@wo_ref
					,@wo_suffix
					,@new_status
					,@username;
			END TRY
			BEGIN CATCH
				SET @errornumber = '20651';
				SET @errortext   = ERROR_MESSAGE();
				GOTO errorexit;
			END CATCH
		END
	END

	/*****************************************************************************
	** Last works order - close complaint?
	*****************************************************************************/
	SET @wo_stat_last_comp = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'WO_STAT_LAST_COMP'))));

	IF @wo_stat_last_comp = 'Y'
	BEGIN
		/* Is there a next status after this status? */
		SELECT @stat_count = COUNT(*)
			FROM wo_next_stat
			WHERE wo_h_stat = @new_status;

		IF @stat_count = 0
		BEGIN
			SET @tmp_date_compl = @wo_date_compl;
			
			IF @tmp_date_compl IS NULL
			BEGIN
				SET @tmp_date_compl = @datestamp_date;
			END

			/* wo_h table */
			BEGIN TRY
				UPDATE wo_h
				SET wo_h_stat     = @new_status,
					wo_payment_f  = 'C',
					wo_paycl_dte  = @datestamp_date,
					wo_date_compl = @tmp_date_compl
				WHERE wo_key = @wo_key;
			END TRY
			BEGIN CATCH
				SET @errornumber = '20652';
				SET @errortext   = 'Error updating wo_h record';
				GOTO errorexit;
			END CATCH
			
			/* Close the complaint? */
			IF @wo_stat_close_comp = 'Y'
			BEGIN
				BEGIN TRY
					UPDATE comp
						SET date_closed = @datestamp_date,
							time_closed_h = @datestamp_time_h,
							time_closed_m = @datestamp_time_m
						WHERE dest_ref = @wo_ref
							AND dest_suffix = @wo_suffix
							AND action_flag = 'W';
				END TRY
				BEGIN CATCH
					SET @errornumber = '20653';
					SET @errortext   = 'Error updating comp record';
					GOTO errorexit;
				END CATCH

				SET @comp_closed = 1;

				/* See putils.4gl function close_complaint() */
				/* No TRADE service so no works order invoicing here */
			END

			/* wo_cont_h table */
			IF @remote_access = 'Y'
			BEGIN
				SELECT @compl_by = compl_by
					FROM wo_cont_h
					WHERE wo_ref = @wo_ref
						AND wo_suffix = @wo_suffix;

				IF @compl_by = '' OR @compl_by IS NULL
				BEGIN
					BEGIN TRY
						UPDATE wo_cont_h
							SET compl_by = @username
							WHERE wo_ref = @wo_ref
								AND wo_suffix = @wo_suffix;
					END TRY
					BEGIN CATCH
						SET @errornumber = '20654';
						SET @errortext   = 'Error updating wo_cont_h record';
						GOTO errorexit;
					END CATCH
				END
			END

			SET @status_updated = 1;

			/* wo_stat_hist table */
			BEGIN TRY
				EXECUTE dbo.cs_wostathist_createRecord
					@wo_ref
					,@wo_suffix
					,@new_status
					,@username;
			END TRY
			BEGIN CATCH
				SET @errornumber = '20655';
				SET @errortext   = ERROR_MESSAGE();
				GOTO errorexit;
			END CATCH
		END
	END

	IF @status_updated = 1
	BEGIN
		/* wo_h table */
		/* This is per the original source code but it appears to be duplication */
		BEGIN TRY
			UPDATE wo_h
				SET wo_h_stat = @new_status
				WHERE wo_ref = @wo_ref
					AND wo_suffix = @wo_suffix;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20656';
			SET @errortext   = 'Error updating wo_h record; unable to update works order status';
			GOTO errorexit;
		END CATCH
	END
	ELSE
	BEGIN
		/* Processing for all other statuses */
		/* wo_h table */
		BEGIN TRY
			UPDATE wo_h
				SET wo_h_stat = @new_status
				WHERE wo_ref = @wo_ref
					AND wo_suffix = @wo_suffix;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20657';
			SET @errortext   = 'Error updating wo_h record; unable to update works order status (other status)';
			GOTO errorexit;
		END CATCH

		/* wo_stat_hist table */
		BEGIN TRY
			EXECUTE dbo.cs_wostathist_createRecord
				@wo_ref
				,@wo_suffix
				,@new_status
				,@username;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20658';
			SET @errortext   = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH
	END

	IF @wo_closed = 1
	BEGIN
		/* Delete any active occurrence of the complaint in the con_sum_list table */
		BEGIN TRY
			DELETE FROM con_sum_list
				WHERE complaint_no = @complaint_no;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20661';
			SET @errortext = 'Error deleting con_sum_list record';
			GOTO errorexit;
		END CATCH
	END
	ELSE
	BEGIN
		/* Update any active occurrence of the complaint in the con_sum_list table */
		BEGIN TRY
			UPDATE con_sum_list
				SET [state] = 'P'
				WHERE complaint_no = @complaint_no;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20660';
			SET @errortext = 'Error updating con_sum_list record';
			GOTO errorexit;
		END CATCH
	END

	IF @comp_closed = 1
	BEGIN
		/* Delete any active occurrence of the complaint in the insp_list table */
		/* as it has been closed                                                */
		BEGIN TRY
			DELETE FROM insp_list
				WHERE complaint_no = @complaint_no;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20662';
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
			SET @errornumber = '20663';
			SET @errortext = 'Error updating insp_list record';
			GOTO errorexit;
		END CATCH
	END

	SELECT 
		@wo_key = wo_key
		,@wo_h_stat = wo_h_stat
		,@wo_act_value = wo_act_value
		FROM wo_h
		WHERE wo_ref = @wo_ref
			AND wo_suffix = @wo_suffix;
normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO
