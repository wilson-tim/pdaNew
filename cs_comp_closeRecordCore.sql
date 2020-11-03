/*****************************************************************************
** dbo.cs_comp_closeRecordCore
** stored procedure
**
** Description
** Close a customer care record
**
** Parameters
** @complaint_no = complaint number
** @entered_by   = user login id
** @date_closed  = date closed (optional)
**
** Returned
** @date_closed  = date closed
** @dest_ref     = destination reference
** Return value of 0 (success) or -1 (failure)
**
** History
** 25/02/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_comp_closeRecordCore', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comp_closeRecordCore;
GO
CREATE PROCEDURE dbo.cs_comp_closeRecordCore
	@complaint_no integer,
	@entered_by varchar(8),
	@date_closed datetime = NULL OUTPUT,
	@dest_ref integer = NULL OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@numberstr char(2),
		@time_closed_h char(2),
		@time_closed_m char(2),
		@diry_ref integer,
		@comp_nfa_text varchar(1),
		@full_name varchar(40),
		@seq integer,
		@notes varchar(100),
		@notes1 varchar(60),
		@notes2 varchar(60),
		@comp_record_title varchar(500);

	SET @errornumber = '10700';
	SET @entered_by = LTRIM(RTRIM(@entered_by));

	IF @complaint_no IS NULL
	BEGIN
		SET @errornumber = '10701';
		SET @errortext = 'complaint_no is required';
		GOTO errorexit;
	END

	IF @entered_by = '' OR @entered_by IS NULL
	BEGIN
		SET @errornumber = '10702';
		SET @errortext = 'entered_by is required';
		GOTO errorexit;
	END

	IF @date_closed IS NULL
	BEGIN
		SET @date_closed = GETDATE();
	END

	SET @numberstr = DATENAME(hour, @date_closed);
	SET @time_closed_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @numberstr = DATENAME(minute, @date_closed);
	SET @time_closed_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @date_closed = CONVERT(datetime, CONVERT(date, @date_closed))

	SELECT @diry_ref
		FROM diry
		WHERE source_ref = @complaint_no
			AND source_flag = 'C';
	IF @@ROWCOUNT < 1
	BEGIN
		SET @errornumber = '10703';
		SET @errortext = 'diry record not found';
		GOTO errorexit;
	END

	/* Close the comp record */
	BEGIN TRY
		SET @dest_ref = 0;

		UPDATE comp
		SET action_flag   = 'N',
			date_closed   = @date_closed,
			time_closed_h = @time_closed_h,
			time_closed_m = @time_closed_m,
			dest_ref      = @dest_ref
		WHERE complaint_no  = @complaint_no;

	END TRY
	BEGIN CATCH
		SET @errornumber = '10704';
		SET @errortext = 'Error updating comp record (closure)';
		GOTO errorexit;
	END CATCH

	/* Close the diry record */
	BEGIN TRY
		UPDATE diry
			SET action_flag = 'C',
				dest_flag   = 'C',
				dest_ref    = NULL,
				dest_date   = @date_closed,
				dest_time_h = @time_closed_h,
				dest_time_m = @time_closed_m,
				dest_user   = @entered_by
			WHERE diry_ref = @diry_ref;
	END TRY
	BEGIN CATCH
		SET @errornumber = '10705';
		SET @errortext = 'Error updating comp diry record (closure)';
		GOTO errorexit;
	END CATCH

	/*
	** insp_list table
	*/
	BEGIN TRY
		DELETE FROM insp_list
			WHERE complaint_no = @complaint_no;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20460';
		SET @errortext = 'Error deleting insp_list record';
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

		SET @notes  = @comp_record_title + ' set to NO FURTHER ACTION by ' + @full_name;
		SET @notes1 = LTRIM(RTRIM(SUBSTRING(@notes, 1, 60)));
		SET @notes2 = LTRIM(RTRIM(SUBSTRING(@notes, 61, 60)));

		BEGIN TRY
			SET @errornumber = '10706';
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

			SET @errornumber = '10707';
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

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
