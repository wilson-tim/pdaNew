/*****************************************************************************
** dbo.cs_compavhist_updateStatus
** stored procedure
**
** Description
** Update abandoned vehicle status
**
** Parameters
** @complaint_no
** @status_ref
** @status_notes
** @entered_by
**
** Returned
** Return value of 0 (success) or -1 (failure)
**
** History
** 24/02/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_compavhist_updateStatus', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_compavhist_updateStatus;
GO
CREATE PROCEDURE dbo.cs_compavhist_updateStatus
	@complaint_no integer,
	@status_ref varchar(6),
	@status_notes varchar(200),
	@entered_by varchar(8)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@date_entered datetime,
		@numberstr varchar(2),
		@ent_time_h varchar(2),
		@ent_time_m varchar(2),
		@open_yn varchar(1),
		@closed_yn varchar(1),
		@delay integer,
		@expiry_date datetime,
		@seq integer,
		@action_flag varchar(1),
		@date_closed datetime,
		@time_closed_h varchar(2),
		@time_closed_m varchar(2),
		@comp_code varchar(6),
		@dest_ref integer,
		@comp_nfa_text varchar(1),
		@full_name varchar(40),
		@notes varchar(100),
		@notes1 varchar(60),
		@notes2 varchar(60),
		@comp_record_title varchar(500);


	SET @errornumber = '10600';
	SET @entered_by = LTRIM(RTRIM(@entered_by));
	SET @status_ref = LTRIM(RTRIM(@status_ref));
	SET @status_notes = LTRIM(RTRIM(@status_notes));

	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @errornumber = '10601';
		SET @errortext = 'complaint_no is required';
		GOTO errorexit;
	END

	/* @complaint_no validation */
	SELECT @action_flag = action_flag,
		@comp_code = comp_code,
		@dest_ref = dest_ref
		FROM comp
		WHERE complaint_no = @complaint_no;
	IF @@ROWCOUNT < 1
	BEGIN
		SET @errornumber = '10602';
		SET @errortext = 'Enquiry ' + LTRIM(RTRIM(STR(@complaint_no))) + ' not found';
		GOTO errorexit;
	END
	IF @action_flag = '' OR @action_flag IS NULL OR @comp_code = '' OR @comp_code IS NULL
	BEGIN
		SET @errornumber = '10603';
		SET @errortext = 'Enquiry ' + LTRIM(RTRIM(STR(@complaint_no))) + ' has missing data';
		GOTO errorexit;
	END

	/* @status_ref validation */
	IF @status_ref = '' OR @status_ref IS NULL
	BEGIN
		SET @errornumber = '10604';
		SET @errortext = 'status_ref is required';
		GOTO errorexit;
	END

	/* @entered_by validation */
	/* Assuming that @entered_by has already been validated by calling process(es) */
	/* so only a basic test here for non-blank and non-null data being passed */
	IF @entered_by = '' OR @entered_by IS NULL
	BEGIN
		SET @errornumber = '10605';
		SET @errortext = 'entered_by is required';
		GOTO errorexit;
	END

	SET @date_entered = GETDATE();

	SET @numberstr = DATENAME(hour, @date_entered);
	SET @ent_time_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @numberstr = DATENAME(minute, @date_entered);
	SET @ent_time_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @date_entered = CONVERT(datetime, CONVERT(date, @date_entered));

	SELECT @open_yn = open_yn,
		@closed_yn = closed_yn,
		@delay = [delay]
		FROM av_status
		WHERE status_ref = @status_ref;

	/* Is there a notice period associated with this status ? */
	IF @delay > 0
	BEGIN
		SET @expiry_date = DATEADD(day, @delay, @date_entered);
	END

	BEGIN TRY
		SELECT @seq = MAX(seq)
			FROM comp_av_hist
			WHERE complaint_no = @complaint_no;

		IF @seq > 0
		BEGIN
			SET @seq = @seq + 1;
		END
		ELSE
		BEGIN
			SET @seq = 1;
		END

		INSERT INTO comp_av_hist
			(
			complaint_no,
			status_ref,
			seq,
			doa,
			toa_h,
			toa_m,
			username,
			status_date,
			status_time_h,
			status_time_m,
			[expiry_date],
			notes      
			)
			VALUES
			(
			@complaint_no,
			@status_ref,
			@seq,
			@date_entered,
			@ent_time_h,
			@ent_time_m,
			@entered_by,
			@date_entered,
			@ent_time_h,
			@ent_time_m,
			@expiry_date,
			@status_notes
			);

		UPDATE comp_av
			SET last_seq = @seq
			WHERE complaint_no = @complaint_no;
	END TRY
	BEGIN CATCH
		SET @errornumber = '10606';
		SET @errortext = 'Error inserting comp_av_hist record';
		GOTO errorexit;
	END CATCH

	IF @closed_yn = 'Y'
	BEGIN
		IF @action_flag <> 'W'
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
				SET @errornumber = '10607';
				SET @errortext = ERROR_MESSAGE();
				GOTO errorexit;
			END CATCH
		END
	END

	IF @open_yn = 'Y'
	BEGIN
		IF @action_flag <> 'W'
		BEGIN
			BEGIN TRY
				SET @date_closed = NULL;
				SET @time_closed_h = NULL;
				SET @time_closed_m = NULL;
				/* Determine the default value of the action flag */
				SELECT @action_flag = LTRIM(RTRIM(action_flag))
					FROM comp_action
					WHERE comp_code = @comp_code;
				IF @action_flag = '' OR @action_flag IS NULL
				BEGIN
					SET @action_flag = 'H';
				END

				SET @errornumber = '10608';
				SET @errortext = 'Error updating comp record (opening)';

				UPDATE comp
					SET date_closed = @date_closed,
						time_closed_h = @time_closed_h,
						time_closed_m = @time_closed_m,
						action_flag = @action_flag,
						dest_ref = @dest_ref
					WHERE complaint_no = @complaint_no;

				SET @errornumber = '10609';
				SET @errortext = 'Error updating comp diry record (opening)';

				UPDATE diry
					SET action_flag = @action_flag,
						dest_flag = 'C',
						dest_date = @date_closed,
						dest_user = @entered_by,
						dest_time_h = @time_closed_h,
						dest_time_m = @time_closed_m
					WHERE source_flag = 'C'
						AND source_ref = @complaint_no;
			END TRY
			BEGIN CATCH
				/* Appropriate error message previously assigned */
				GOTO errorexit;
			END CATCH
			
			/* Update enquiry notes */
			SET @comp_nfa_text = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'COMP_NFA_TEXT'))));
			IF @comp_nfa_text = 'Y'
			BEGIN
				SELECT @full_name = full_name
					FROM pda_user
					WHERE [user_name] = @entered_by;

				IF @@ROWCOUNT <> 1
				BEGIN
					SET @full_name = 'NO NAME';
				END

				SET @full_name = UPPER(LTRIM(RTRIM(@full_name)));

				SET @comp_record_title = LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'COMP_RECORD_TITLE')));

				SELECT @seq = MAX(seq)
					FROM comp_text
					WHERE complaint_no = @complaint_no;

				IF @seq > 0
				BEGIN
					SET @seq = @seq + 1;
				END
				ELSE
				BEGIN
					SET @seq = 1;
				END

				SET @notes  = @comp_record_title + ' has been RE-OPENED by  ' + @full_name;
				SET @notes1 = LTRIM(RTRIM(SUBSTRING(@notes, 1, 60)));
				SET @notes2 = LTRIM(RTRIM(SUBSTRING(@notes, 61, 60)));

				BEGIN TRY
					SET @errornumber = '10610';
					SET @errortext = 'Error inserting comp_text record';

					INSERT INTO comp_text
						(
							complaint_no,
							seq,
							username,
							doa,
							time_entered_h,
							time_entered_m,
							txt,
							customer_no
						)
						VALUES
						(
							@complaint_no,
							@seq,
							@full_name,
							@date_closed,
							@time_closed_h,
							@time_closed_m,
							@notes1,
							NULL
						);

					IF LEN(@notes2) > 0
					BEGIN
						SET @seq = @seq + 1;

						INSERT INTO comp_text
							(
								complaint_no,
								seq,
								username,
								doa,
								time_entered_h,
								time_entered_m,
								txt,
								customer_no
							)
							VALUES
							(
								@complaint_no,
								@seq,
								@full_name,
								@date_closed,
								@time_closed_h,
								@time_closed_m,
								@notes2,
								NULL
							);
					END

					SET @errornumber = '10611';
					SET @errortext = 'Error inserting comp record (after comp_text update)';

					UPDATE comp
						SET text_flag = 'Y'
						WHERE complaint_no = @complaint_no;
				END TRY
				BEGIN CATCH
					/* Appropriate error message previously assigned */
					GOTO errorexit;
				END CATCH
			END
		END
	END

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
