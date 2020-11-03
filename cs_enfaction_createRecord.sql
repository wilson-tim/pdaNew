/*****************************************************************************
** dbo.cs_enfaction_createRecord
** stored procedure
**
** Description
** Create a enforcement action record
**
** Parameters
** @xmlEnfAction = XML structure containing enf_action record
** @notes        = notes text
**
** Returned
** All passed parameters are INPUT and OUTPUT
** Return value of new action_seq or -1
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
** 13/03/2013  TW  New
** 19/03/2013  TW  Validations
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_enfaction_createRecord', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_enfaction_createRecord;
GO
CREATE PROCEDURE dbo.cs_enfaction_createRecord
	@xmlEnfAction xml OUTPUT,
	@notes varchar(MAX) OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @result integer
		,@errortext varchar(500)
		,@errornumber varchar(10)
		,@comp_rowcount integer
		,@numberstr varchar(2)
		,@seq integer
		,@enfaction_rowcount integer
		,@valid_action_ref varchar(6)
		,@comp_enf_action_seq integer
		,@delay integer
		,@action_count integer
		,@enf_completed varchar(500)
		,@date_closed datetime
		,@dest_ref integer
		,@valid_enf_status integer
		,@plea_reqd char(1)
		,@judgement_reqd char(1)
		,@penalty_reqd char(1)
		,@reference_reqd char(1)
		,@offence_date datetime
		,@inv_period_start datetime
		,@last_action_date datetime
		,@enf_fpcn_action varchar(500)
		,@reference char(1)
		,@reference_validate char(1)
		,@reference_auto char(1)
		,@reference_format varchar(20)
		,@reference_max integer
		,@valid_fpcn integer

		,@complaint_no integer
		,@action_seq integer
		,@action_ref varchar(6)
		,@action_desc varchar(40)
		,@action_date datetime
		,@action_time_h char(2)
		,@action_time_m char(2)
		,@due_date datetime
		,@paid_date datetime
		,@suspect_ref integer
		,@aut_officer varchar(6)
		,@aut_officer_desc varchar(40)
		,@enf_status varchar(6)
		,@enf_status_desc varchar(40)
		,@plea varchar(1)
		,@plea_desc varchar(40)
		,@judgement varchar(1)
		,@judgement_desc varchar(40)
		,@penalty_ref varchar(6)
		,@penalty_desc varchar(40)
		,@costs decimal(6,2)
		,@fine decimal(6,2)
		,@date_entered datetime
		,@entered_by varchar(8)
		,@ent_time_h char(2)
		,@ent_time_m char(2)
		,@text_flag varchar(1)
		,@fpcn varchar(20)
		,@date_printed datetime
		,@time_printed_h char(2)
		,@time_printed_m char(2)
		,@user_printed varchar(8)
		,@prev_action_date datetime
		,@paid_amount decimal(6,2)

	SET @errornumber = '20043';

	IF OBJECT_ID('tempdb..#tempEnfAction') IS NOT NULL
	BEGIN
		DROP TABLE #tempEnfAction;
	END

	BEGIN TRY
		SELECT
			xmldoc.enfaction.value('complaint_no[1]','integer') AS 'complaint_no'
			,xmldoc.enfaction.value('action_seq[1]','integer') AS 'action_seq'
			,xmldoc.enfaction.value('action_ref[1]','varchar(6)') AS 'action_ref'
			,xmldoc.enfaction.value('action_desc[1]','varchar(40)') AS 'action_desc'
			,xmldoc.enfaction.value('action_date[1]','datetime') AS 'action_date'
			,xmldoc.enfaction.value('action_time_h[1]','char(2)') AS 'action_time_h'
			,xmldoc.enfaction.value('action_time_m[1]','char(2)') AS 'action_time_m'
			,xmldoc.enfaction.value('due_date[1]','datetime') AS 'due_date'
			,xmldoc.enfaction.value('paid_date[1]','datetime') AS 'paid_date'
			,xmldoc.enfaction.value('suspect_ref[1]','integer') AS 'suspect_ref'
			,xmldoc.enfaction.value('aut_officer[1]','varchar(6)') AS 'aut_officer'
			,xmldoc.enfaction.value('aut_officer_desc[1]','varchar(40)') AS 'aut_officer_desc'
			,xmldoc.enfaction.value('enf_status[1]','varchar(6)') AS 'enf_status'
			,xmldoc.enfaction.value('enf_status_desc[1]','varchar(40)') AS 'enf_status_desc'
			,xmldoc.enfaction.value('plea[1]','varchar(6)') AS 'plea'
			,xmldoc.enfaction.value('plea_desc[1]','varchar(40)') AS 'plea_desc'
			,xmldoc.enfaction.value('judgement[1]','varchar(6)') AS 'judgement'
			,xmldoc.enfaction.value('judgement_desc[1]','varchar(40)') AS 'judgement_desc'
			,xmldoc.enfaction.value('penalty_ref[1]','varchar(6)') AS 'penalty_ref'
			,xmldoc.enfaction.value('penalty_desc[1]','varchar(40)') AS 'penalty_desc'
			,xmldoc.enfaction.value('costs[1]','decimal(6,2)') AS 'costs'
			,xmldoc.enfaction.value('fine[1]','decimal(6,2)') AS 'fine'
			,xmldoc.enfaction.value('date_entered[1]','datetime') AS 'date_entered'
			,xmldoc.enfaction.value('entered_by[1]','varchar(8)') AS 'entered_by'
			,xmldoc.enfaction.value('ent_time_h[1]','char(2)') AS 'ent_time_h'
			,xmldoc.enfaction.value('ent_time_m[1]','char(2)') AS 'ent_time_m'
			,xmldoc.enfaction.value('text_flag[1]','varchar(1)') AS 'text_flag'
			,xmldoc.enfaction.value('fpcn[1]','varchar(20)') AS 'fpcn'
			,xmldoc.enfaction.value('date_printed[1]','datetime') AS 'date_printed'
			,xmldoc.enfaction.value('time_printed_h[1]','char(2)') AS 'time_printed_h'
			,xmldoc.enfaction.value('time_printed_m[1]','char(2)') AS 'time_printed_m'
			,xmldoc.enfaction.value('prev_action_date[1]','datetime') AS 'prev_action_date'
			,xmldoc.enfaction.value('paid_amount[1]','decimal(6,2)') AS 'paid_amount'
		INTO #tempEnfAction
		FROM @xmlEnfAction.nodes('/CustCareEnfActionDTO') AS xmldoc(enfaction);

		SELECT @complaint_no = complaint_no
			,@action_seq = action_seq
			,@action_ref = action_ref
			,@action_desc = action_desc
			,@action_date = action_date
			,@action_time_h = action_time_h
			,@action_time_m = action_time_m
			,@due_date = due_date
			,@paid_date = paid_date
			,@suspect_ref = suspect_ref
			,@aut_officer = aut_officer
			,@aut_officer_desc = aut_officer_desc
			,@enf_status = enf_status
			,@enf_status_desc = enf_status_desc
			,@plea = plea
			,@plea_desc = plea_desc
			,@judgement = judgement
			,@judgement_desc = judgement_desc
			,@penalty_ref = penalty_ref
			,@penalty_desc = penalty_desc
			,@costs = costs
			,@fine = fine
			,@date_entered = date_entered
			,@entered_by = entered_by
			,@ent_time_h = ent_time_h
			,@ent_time_m = ent_time_m
			,@text_flag = text_flag
			,@fpcn = fpcn
			,@date_printed = date_printed
			,@time_printed_h = time_printed_h
			,@time_printed_m = time_printed_m
			,@prev_action_date = prev_action_date
			,@paid_amount = paid_amount
			FROM #tempEnfAction;

		SET @enfaction_rowcount = @@ROWCOUNT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20044';
		SET @errortext = 'Error processing @xmlEnfAction';
		GOTO errorexit;
	END CATCH

	IF @enfaction_rowcount > 1
	BEGIN
		SET @errornumber = '20045';
		SET @errortext = 'Error processing @xmlEnfAction - too many rows';
		GOTO errorexit;
	END
	IF @enfaction_rowcount < 1
	BEGIN
		SET @errornumber = '20046';
		SET @errortext = 'Error processing @xmlEnfAction - no rows found';
		GOTO errorexit;
	END

	SET @entered_by = LTRIM(RTRIM(@entered_by));

	/* @complaint_no validation */
	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @errornumber = '20047';
		SET @errortext = 'complaint_no is required';
		GOTO errorexit;
	END
	SELECT @comp_rowcount = COUNT(*)
		FROM comp
		WHERE complaint_no = @complaint_no
	IF @comp_rowcount <> 1
	BEGIN
		SET @errornumber = '20048';
		SET @errortext = LTRIM(RTRIM(STR(@complaint_no))) + ' is not a valid complaint reference';
		GOTO errorexit;
	END

	/* @action_ref validation */
	IF @action_ref = '' OR @action_ref is NULL
	BEGIN
		SET @errornumber = '20049';
		SET @errortext = 'action_ref is required';
		GOTO errorexit;
	END
	ELSE
	BEGIN
		EXECUTE @valid_action_ref = dbo.cs_enfact_validateNextAction
			@complaint_no,
			@action_ref;

		IF @valid_action_ref <> 1
		BEGIN
			SET @errornumber = '20050';
			SET @errortext = @action_ref + ' is not a valid next action';
			GOTO errorexit;
		END
	END

	/* @action_date validation */
	IF @action_date IS NULL
	BEGIN
		SET @errornumber = '20120';
		SET @errortext = 'action_date is required';
		GOTO errorexit;
	END

	SET @numberstr = DATENAME(hour, @action_date);
	SET @action_time_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @numberstr = DATENAME(minute, @action_date);
	SET @action_time_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @action_date = CONVERT(datetime, CONVERT(date, @action_date));
	
	/* @suspect_ref */
	SELECT @suspect_ref = suspect_ref,
		@comp_enf_action_seq = action_seq
		FROM comp_enf
		WHERE complaint_no = @complaint_no;

	/* @prev_action_date */
	IF @comp_enf_action_seq > 0 AND @comp_enf_action_seq IS NOT NULL
	BEGIN
	SELECT @prev_action_date = action_date
		FROM enf_action
		WHERE complaint_no = @complaint_no
			AND action_seq =
				(
					SELECT MAX(action_seq)
						FROM enf_action
						WHERE complaint_no = @complaint_no
				);
	END
	ELSE
	BEGIN
		SET @prev_action_date = NULL;
	END

	/* @aut_officer validation */
	/*
	IF @aut_officer = '' OR @aut_officer IS NULL
	BEGIN
		SET @errornumber = '20121';
		SET @errortext = 'aut_officer is required';
		GOTO errorexit;
	END
	*/
	SET @aut_officer = dbo.cs_pdauser_getEnfOfficerPoCode(@entered_by);
	IF @aut_officer = '' OR @aut_officer is NULL
	BEGIN
		SET @errornumber = '20121';
		SET @errortext = 'aut_officer is required';
		GOTO errorexit;
	END

	/* @enf_status validation */
	IF @enf_status = '' OR @enf_status is NULL
	BEGIN
		SET @errornumber = '20122';
		SET @errortext = 'enf_status is required';
		GOTO errorexit;
	END
	ELSE
	BEGIN
		EXECUTE @valid_enf_status = dbo.cs_allk_validateEnfStatus
			@action_ref,
			@enf_status;

		IF @valid_enf_status <> 1
		BEGIN
			SET @errornumber = '20099';
			SET @errortext = @enf_status + ' is not a valid status';
			GOTO errorexit;
		END
	END

	/* Read action parameters */
	SET @enf_fpcn_action = ',' + LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'ENF_FPCN_ACTION'))) + ',';
	SELECT @delay = [delay],
		@plea_reqd = UPPER(plea),
		@judgement_reqd = UPPER(judgement),
		@penalty_reqd = UPPER(penalty),
		@reference = UPPER(reference),
		@reference_validate = UPPER(reference_validate),
		@reference_auto = UPPER(reference_auto),
		@reference_max = reference_max,
		@reference_reqd =
			CASE
				WHEN (reference = 'N'
					OR (reference_auto = 'Y' AND CHARINDEX(','+@action_ref+',',@enf_fpcn_action,1) > 0)) THEN 'N'
				ELSE 'Y'
			END
		FROM enf_act
		WHERE action_code = @action_ref;

	SET @enf_completed = LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'ENF_COMPLETED')));

	/* @fpcn validation */
	IF (@fpcn = '' OR @fpcn IS NULL) AND @reference_reqd = 'Y'
	BEGIN
		SET @errornumber = '20101';
		SET @errortext   = 'fpcn (document reference) is required';
		GOTO errorexit;
	END
	ELSE
	BEGIN
		IF @reference = 'Y' AND @reference_validate = 'Y'
		BEGIN
			EXECUTE @valid_fpcn = dbo.cs_enfact_validateFpcnRef
				@reference_format,
				@fpcn;

			IF @valid_fpcn <> 1
			BEGIN
				SET @errornumber = '20109';
				SET @errortext = ERROR_MESSAGE();
				GOTO errorexit;
			END
		END
	END

	/* @plea validation */
	IF (@plea = '' OR @plea IS NULL) AND @plea_reqd = 'Y'
	BEGIN
		SET @errornumber = '20102';
		SET @errortext   = 'plea is required';
		GOTO errorexit;
	END
	IF (@plea <> '' AND @plea IS NOT NULL) AND @plea_reqd = 'N'
	BEGIN
		SET @errornumber = '20123';
		SET @errortext   = 'plea is not valid for this action';
		GOTO errorexit;
	END

	/* @judgement validation */
	IF (@judgement = '' OR @judgement IS NULL) AND @judgement_reqd = 'Y'
	BEGIN
		SET @errornumber = '20103';
		SET @errortext   = 'judgement is required';
		GOTO errorexit;
	END
	IF (@judgement <> '' AND @judgement IS NOT NULL) AND @judgement_reqd = 'N'
	BEGIN
		SET @errornumber = '20124';
		SET @errortext   = 'judgement is not valid for this action';
		GOTO errorexit;
	END
	IF @judgement_reqd = 'Y' AND (@enf_status = @enf_completed AND @enf_completed <> '' AND @enf_completed IS NOT NULL)
	BEGIN
		IF (@judgement = '' OR @judgement IS NULL)
		BEGIN
			SET @errornumber = '20125';
			SET @errortext   = 'A judgement is required before closing this action';
			GOTO errorexit;
		END
	END

	/* @penalty validation */
	IF (@penalty_ref = '' OR @penalty_ref IS NULL) AND @penalty_reqd = 'Y'
	BEGIN
		SET @errornumber = '20104';
		SET @errortext   = 'penalty is required';
		GOTO errorexit;
	END
	IF (@penalty_ref <> '' AND @penalty_ref IS NOT NULL) AND @penalty_reqd = 'N'
	BEGIN
		SET @errornumber = '20126';
		SET @errortext   = 'penalty_ref is not valid for this action';
		GOTO errorexit;
	END

	IF @plea_reqd = 'N' AND @judgement_reqd = 'N' AND @penalty_reqd = 'N'
	BEGIN
		IF @costs > 0 AND @costs IS NOT NULL
		BEGIN
			SET @errornumber = '20127';
			SET @errortext   = 'costs is not valid for this action';
			GOTO errorexit;
		END
		IF @fine > 0 AND @fine IS NOT NULL
		BEGIN
			SET @errornumber = '20128';
			SET @errortext   = 'fine is not valid for this action';
			GOTO errorexit;
		END
	END

	/* @action_date validation */
	IF @action_date IS NOT NULL
	BEGIN
		/* Date only tests, ignoring hours and minutes */
		SELECT @offence_date = comp_enf.offence_date,
			@inv_period_start = inv_period_start,
			@last_action_date = enf_action.action_date
			FROM comp_enf
			INNER JOIN enf_action
			ON comp_enf.complaint_no = @complaint_no
				AND enf_action.complaint_no  = comp_enf.complaint_no
				AND enf_action.action_seq = comp_enf.action_seq;
		IF @last_action_date IS NOT NULL
		BEGIN
			IF DATEDIFF(day, @last_action_date, @action_date) < 0
			BEGIN
				SET @errornumber = '20106';
				SET @errortext   = 'action_date must be later than ' + LTRIM(RTRIM(CONVERT(varchar(11), @last_action_date, 113)));
				GOTO errorexit;
			END
		END
		ELSE
		BEGIN
			IF @offence_date IS NOT NULL
			BEGIN
				IF DATEDIFF(day, @offence_date, @action_date) < 0
				BEGIN
					SET @errornumber = '20107';
					SET @errortext   = 'action_date must be later than ' + LTRIM(RTRIM(CONVERT(varchar(11), @offence_date, 113)));
					GOTO errorexit;
				END
			END
			ELSE
			BEGIN
				IF @inv_period_start IS NOT NULL
				BEGIN
					IF DATEDIFF(day, @inv_period_start, @action_date) < 0
					BEGIN
						SET @errornumber = '20108';
						SET @errortext   = 'action_date must be later than ' + LTRIM(RTRIM(CONVERT(varchar(11), @inv_period_start, 113)));
						GOTO errorexit;
					END
				END
			END
		END
	END

	/* @paid_date validation */
	IF @paid_date IS NOT NULL
		AND @action_date IS NOT NULL
			AND DATEDIFF(day, @paid_date, @action_date) > 0
	BEGIN
		SET @errornumber = '20129';
		SET @errortext   = 'Paid date cannot be before the action date';
		GOTO errorexit;
	END

	/* Generate FPCN number if required */
	IF @reference_auto = 'Y' AND (CHARINDEX(','+@action_ref+',',@enf_fpcn_action,1) > 0) AND (@fpcn = '' OR @fpcn IS NULL)
	BEGIN
		BEGIN TRY
			EXECUTE dbo.cs_enfact_generateFpcnRef
				@reference_format,
				@reference_max,
				@fpcn OUTPUT;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20158';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH
	END

	/* @action_seq */
	BEGIN TRY
		EXECUTE @result = dbo.cs_sno_getSerialNumber'enf_action', '', @serial_no = @action_seq OUTPUT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20051';
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

	/* @due_date */
	IF @delay > 0 and @delay IS NOT NULL
	BEGIN
		SET @due_date = DATEADD(day, @delay, CONVERT(datetime, CONVERT(date, GETDATE())));
	END
	ELSE
	BEGIN
		SET @due_date = NULL;
	END

	/* @date_entered */
	SET @date_entered = GETDATE();

	SET @numberstr = DATENAME(hour, @date_entered);
	SET @ent_time_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @numberstr = DATENAME(minute, @date_entered);
	SET @ent_time_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @date_entered = CONVERT(datetime, CONVERT(date, @date_entered));

	/*
	** enf_action table
	*/
	BEGIN TRY
		INSERT INTO enf_action
			(
			action_seq
			,complaint_no
			,action_ref
			,action_date
			,action_time_h
			,action_time_m
			,due_date
			,suspect_ref
			,aut_officer
			,enf_status
			,date_entered
			,entered_by
			,ent_time_h
			,ent_time_m
			,text_flag
			,fpcn,
			prev_action_date
			)
			VALUES
			(
			@action_seq
			,@complaint_no
			,@action_ref
			,@action_date
			,@action_time_h
			,@action_time_m
			,@due_date
			,@suspect_ref
			,@aut_officer
			,@enf_status
			,@date_entered
			,@entered_by
			,@ent_time_h
			,@ent_time_m
			,'N'
			,@fpcn
			,@prev_action_date
			);
	END TRY
	BEGIN CATCH
		SET @errornumber = '20052';
		SET @errortext = 'Error inserting enf_action record';
		GOTO errorexit;
	END CATCH

	/*
	** enf_act_text table
	*/
	IF LEN(@notes) > 0
	BEGIN
		BEGIN TRY
			EXECUTE dbo.cs_enfacttext_updateNotes
				@complaint_no,
				@action_seq,
				@action_ref,
				@action_date,
				@entered_by,
				@notes OUTPUT;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20053';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH
	END

	SELECT @action_count = COUNT(*)
		FROM enf_action
		WHERE complaint_no = @complaint_no;
	BEGIN
		BEGIN TRY
			UPDATE comp_enf
				SET actions = @action_count,
					action_seq = @action_seq,
					enf_status = @enf_status
				WHERE complaint_no = @complaint_no;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20054';
			SET @errortext = 'Error updating comp_enf record';
			GOTO errorexit;
		END CATCH
	END

	/* Close the complaint if the ENF_COMPLETED status has been selected */
	IF @enf_status = @enf_completed AND @enf_completed <> '' AND @enf_completed IS NOT NULL
	BEGIN
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
				SET @errornumber = '20055';
				SET @errortext = ERROR_MESSAGE();
				GOTO errorexit;
			END CATCH
		END
	END

	BEGIN TRY
		/* Update #tempEnfAction with actual data ready to return via @xmlEnfAction */
		UPDATE #tempEnfAction
			SET complaint_no = @complaint_no
				,action_seq = @action_seq
				,action_ref = @action_ref
				,action_desc = @action_desc
				,action_date = @action_date
				,action_time_h = @action_time_h
				,action_time_m = @action_time_m
				,due_date = @due_date
				,paid_date = @paid_date
				,suspect_ref = @suspect_ref
				,aut_officer = @aut_officer
				,aut_officer_desc = @aut_officer_desc
				,enf_status = @enf_status
				,enf_status_desc = @enf_status_desc
				,plea = @plea
				,plea_desc = @plea_desc
				,judgement = @judgement
				,judgement_desc = @judgement_desc
				,penalty_ref = @penalty_ref
				,penalty_desc = @penalty_desc
				,costs = @costs
				,fine = @fine
				,date_entered = @date_entered
				,entered_by = @entered_by
				,ent_time_h = @ent_time_h
				,ent_time_m = @ent_time_m
				,text_flag = @text_flag
				,fpcn = @fpcn
				,date_printed = @date_printed
				,time_printed_h = @time_printed_h
				,time_printed_m = @time_printed_m
				,prev_action_date = @prev_action_date
				,paid_amount = @paid_amount
	END TRY
	BEGIN CATCH
		SET @errornumber = '20056';
		SET @errortext = 'Error updating #tempEnfAction record';
		GOTO errorexit;
	END CATCH
	BEGIN TRY
		SET @xmlEnfAction = (SELECT * FROM #tempEnfAction FOR XML PATH('CustCareEnfActionDTO'))
	END TRY
	BEGIN CATCH
		SET @errornumber = '20057';
		SET @errortext = 'Error updating @xmlEnfAction';
		GOTO errorexit;
	END CATCH

normalexit:
	RETURN @action_seq;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO
