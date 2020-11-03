/*****************************************************************************
** dbo.cs_comptext_updateNotes
** stored procedure
**
** Description
** Update notes for a specified complaint
**
** Parameters
** @complaint_no = complaint number
** @username     = user login id
** @notes        = notes text
**
** Returned
** Return value of 0 (success) or -1
**
** Notes
** Ignoring system key OVERWRITE_COMP_TEXT
** so assuming that new notes text is always appended.
**
** History
** 08/03/2013  TW  New
** 15/07/2013  TW  Check for 'UPD_COMP_DEST_TEXT' system key and additional notes processing
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_comptext_updateNotes', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comptext_updateNotes;
GO
CREATE PROCEDURE dbo.cs_comptext_updateNotes
	@complaint_no integer,
	@username varchar(8),
	@notes varchar(MAX) = NULL OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE
		@errortext varchar(500)
		,@errornumber varchar(10)
		,@comp_rowcount integer
		,@tempText varchar(MAX)
		,@textSeq integer
		,@textPos integer
		,@textRow varchar(60)
		,@date_entered datetime
		,@ent_time_h varchar(2)
		,@ent_time_m varchar(2)
		,@numberstr varchar(2)
		,@wordwrap_enabled char(1)
		,@comp_text_blank_line char(1)
		,@comp_text_blank_line_bit bit
		,@startseq integer
		,@endseq integer
		,@upd_comp_dest_text char(1)
		,@overwrite_comp_text char(1)
		,@action_flag varchar(1)
		,@dest_ref integer
		,@dest_suffix varchar(6)
		,@wo_ref integer
		,@wo_suffix varchar(6)
		,@wohtxt_seq integer
		,@wohtxt_username varchar(8)
		,@wohtxt_doa datetime
		,@wohtxt_time_entered_h char(2)
		,@wohtxt_time_entered_m char(2)
		,@wohtxt_txt varchar(60)
		,@cust_def_no integer
		,@definb_seq integer
		,@definb_username varchar(8)
		,@definb_doa datetime
		,@definb_time_entered_h char(2)
		,@definb_time_entered_m char(2)
		,@definb_txt varchar(60)
		,@item_ref varchar(12)
		,@feature_ref varchar(12)
		,@comp_text_flag char(1)
		;

	SET @errornumber = '20018';

	SET @username = LTRIM(RTRIM(@username));
	SET @notes    = LTRIM(RTRIM(@notes));

	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @errornumber = '20021';
		SET @errortext = 'complaint no is required';
		GOTO errorexit;
	END
	SELECT @comp_rowcount = COUNT(*)
		FROM comp
		WHERE complaint_no = @complaint_no;
	IF @comp_rowcount <> 1
	BEGIN
		SET @errornumber = '20484';
		SET @errortext = LTRIM(RTRIM(STR(@complaint_no))) + ' is not a valid complaint reference';
		GOTO errorexit;
	END

	IF @username = '' OR @username IS NULL
	BEGIN
		SET @errornumber = '20019';
		SET @errortext = 'username is required';
		GOTO errorexit;
	END

	IF @notes = '' OR @notes IS NULL
	BEGIN
		SET @errornumber = '20020';
		SET @errortext = 'notes is required';
		GOTO errorexit;
	END

	/* Get date entered, etc. */
	SET @date_entered = GETDATE();

	SET @numberstr = DATENAME(hour, @date_entered);
	SET @ent_time_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @numberstr = DATENAME(minute, @date_entered);
	SET @ent_time_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @date_entered = CONVERT(datetime, CONVERT(date, @date_entered));

	/* Initially assume that notes are being created (i.e. no current notes records) and not updated */
	SET @upd_comp_dest_text = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'UPD_COMP_DEST_TEXT'))));
	SET @overwrite_comp_text =  UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'OVERWRITE_COMP_TEXT'))));

	/* Get the current last sequence number */
	SELECT @textSeq = COUNT(*)
		FROM comp_text
		WHERE complaint_no = @complaint_no;

	/* Is word wrapping enabled? */
	SET @wordwrap_enabled = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'WORDWRAP_ENABLED'))));

	/* Are blank lines being included? */
	SET @comp_text_blank_line = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'COMP_TEXT_BLANK_LINE'))));
	IF @comp_text_blank_line = 'Y'
	BEGIN
		SET @comp_text_blank_line_bit = 1;
	END
	ELSE
	BEGIN
		SET @comp_text_blank_line_bit = 0;
	END

	SET @comp_text_flag = 'N';

	SET @startseq = 0;
	SET @endseq   = 0;

	/* Extract rows of data from @notes and create comp_text records */
	BEGIN TRY
		IF @wordwrap_enabled = 'Y'
		BEGIN
			DECLARE csr_texttable CURSOR FOR
				SELECT linetext
					FROM dbo.cs_utils_wrapText(@notes, 60, @comp_text_blank_line_bit)
					ORDER BY linenum;
		END
		ELSE
		BEGIN
			DECLARE csr_texttable CURSOR FOR
				SELECT linetext
					FROM dbo.cs_utils_splitText(@notes, 60, @comp_text_blank_line_bit)
					ORDER BY linenum;
		END

		OPEN csr_texttable;

		FETCH NEXT FROM csr_texttable INTO
			@textRow;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @comp_text_flag = 'N'
			BEGIN
				SET @comp_text_flag = 'Y';
			END

			SET @textSeq = @textSeq + 1;

			IF @startseq = 0
			BEGIN
				SET @startseq = @textSeq;
			END

			IF @textSeq > 500
			BEGIN
				GOTO exitfetch;
			END

			INSERT INTO comp_text
				(
				complaint_no,
				seq,
				username,
				doa,
				time_entered_h,
				time_entered_m,
				txt
				)
				VALUES
				(
				@complaint_no,
				@textSeq,
				@username,
				@date_entered,
				@ent_time_h,
				@ent_time_m,
				@textRow
				);

			FETCH NEXT FROM csr_texttable INTO
				@textRow;
		END

exitfetch:
		CLOSE csr_texttable;
		DEALLOCATE csr_texttable;

		IF @endseq = 0
		BEGIN
			IF @textSeq > 500
			BEGIN
				SET @endseq = 500;
			END
			ELSE
			BEGIN
				SET @endseq = @textSeq;
			END
		END

	END TRY
	BEGIN CATCH
		SET @errornumber = '10921';
		SET @errortext = 'Error inserting comp_text record';
		GOTO errorexit;
	END CATCH

/* Not really an error and no mechanism in place to deal with informative messages
	IF @textSeq > 500
	BEGIN
		SET @errornumber = '20025';
		SET @errortext = 'The maximum 500 lines of text exist, cannot add more';
		GOTO errorexit;
	END
*/

	/* Update comp.text_flag */
	IF @comp_text_flag = 'Y'
	BEGIN
		BEGIN TRY
			/* update comp text flag to 'Y' */
			UPDATE comp
				SET text_flag = 'Y'
				WHERE complaint_no = @complaint_no
		END TRY
		BEGIN CATCH
			SET @errornumber = '10922';
			SET @errortext = 'Error updating comp record (text_flag)';
			GOTO errorexit;
		END CATCH
	END

	SET @notes = dbo.cs_comptext_getNotes(@complaint_no, 0);

	/* Check for additional notes processing options */
	/* See also cs_defh_createRecordCore and cs_woh_createRecordCore */
	SELECT @action_flag = LTRIM(RTRIM(action_flag))
		,@dest_ref = dest_ref
		,@dest_suffix = LTRIM(RTRIM(dest_suffix))
		,@item_ref = LTRIM(RTRIM(item_ref))
		,@feature_ref = LTRIM(RTRIM(feature_ref))
		FROM comp
		WHERE complaint_no = @complaint_no;

	/* Proceed only if the works order or rectification has been created */
	IF (
		(@action_flag = 'D')
			AND (@dest_ref <> 0 AND @dest_ref IS NOT NULL)
			AND EXISTS
				(SELECT default_no FROM defh WHERE cust_def_no = @dest_ref)
		)
		OR
		(
		(@action_flag = 'W')
			AND (@dest_ref <> 0 AND @dest_ref IS NOT NULL AND @dest_suffix <> '' AND @dest_suffix IS NOT NULL)
			AND EXISTS
				(SELECT wo_key FROM wo_h WHERE wo_ref = @dest_ref AND wo_suffix = @dest_suffix)
		)
	BEGIN
		/* Works Orders */
		IF @action_flag = 'W'
		BEGIN
			SET @wo_ref = @dest_ref;
			SET @wo_suffix = @dest_suffix;

			IF @overwrite_comp_text = 'Y'
			BEGIN
				/* Overwriting */
				BEGIN TRY
					/* Delete all existing notes */
					DELETE FROM wo_h_txt
						WHERE wo_ref = @wo_ref
							AND wo_suffix = @wo_suffix;

					/* Copy comp text */
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
						@wohtxt_seq
						,@wohtxt_username
						,@wohtxt_doa
						,@wohtxt_time_entered_h
						,@wohtxt_time_entered_m
						,@wohtxt_txt;

					WHILE @@FETCH_STATUS = 0
					BEGIN
						INSERT INTO wo_h_txt
							(
							wo_ref
							,wo_suffix
							,seq
							,username
							,doa
							,time_entered_h
							,time_entered_m
							,txt
							)
							VALUES
							(
							@wo_ref
							,@wo_suffix
							,@wohtxt_seq
							,@wohtxt_username
							,@wohtxt_doa
							,@wohtxt_time_entered_h
							,@wohtxt_time_entered_m
							,@wohtxt_txt
							);

						FETCH NEXT FROM csr_notes INTO
							@wohtxt_seq
							,@wohtxt_username
							,@wohtxt_doa
							,@wohtxt_time_entered_h
							,@wohtxt_time_entered_m
							,@wohtxt_txt;
					END

					CLOSE csr_notes
					DEALLOCATE csr_notes
				END TRY
				BEGIN CATCH
					SET @errornumber = '20698';
					SET @errortext = 'Error overwriting wo_h_txt record';
					GOTO errorexit;
				END CATCH
			END
			ELSE
			BEGIN
				/* Appending*/
				BEGIN TRY
					/* Determine the starting sequence number */
					SELECT @wohtxt_seq = COUNT(*)
						FROM wo_h_txt
						WHERE wo_ref = @wo_ref
							AND wo_suffix = @wo_suffix;
					
					SET @wohtxt_seq = @wohtxt_seq + 1;

					/* Append new comp text */
					DECLARE csr_notes CURSOR FOR
						SELECT
							username
							,doa
							,time_entered_h
							,time_entered_m
							,txt
							FROM comp_text
							WHERE complaint_no = @complaint_no
								AND seq >= @startseq
								AND seq <= @endseq
								/* Will not return rows if @startseq > @endseq */
							ORDER BY seq;

					OPEN csr_notes;

					FETCH NEXT FROM csr_notes INTO
						@wohtxt_username
						,@wohtxt_doa
						,@wohtxt_time_entered_h
						,@wohtxt_time_entered_m
						,@wohtxt_txt;

					WHILE @@FETCH_STATUS = 0
					BEGIN
						INSERT INTO wo_h_txt
							(
							wo_ref
							,wo_suffix
							,seq
							,username
							,doa
							,time_entered_h
							,time_entered_m
							,txt
							)
							VALUES
							(
							@wo_ref
							,@wo_suffix
							,@wohtxt_seq
							,@wohtxt_username
							,@wohtxt_doa
							,@wohtxt_time_entered_h
							,@wohtxt_time_entered_m
							,@wohtxt_txt
							);

						SET @wohtxt_seq = @wohtxt_seq + 1;

						FETCH NEXT FROM csr_notes INTO
							@wohtxt_username
							,@wohtxt_doa
							,@wohtxt_time_entered_h
							,@wohtxt_time_entered_m
							,@wohtxt_txt;
					END

					CLOSE csr_notes
					DEALLOCATE csr_notes
				END TRY
				BEGIN CATCH
					SET @errornumber = '20699';
					SET @errortext = 'Error appending wo_h_txt record';
					GOTO errorexit;
				END CATCH
			END
		END

		/* Rectifications */
		IF @action_flag = 'D'
		BEGIN
			SET @cust_def_no = @dest_ref;

			IF @overwrite_comp_text = 'Y'
			BEGIN
				/* Overwriting */
				BEGIN TRY
					/* Delete all existing notes */
					DELETE FROM defi_nb
						WHERE default_no = @cust_def_no;

					/* Copy comp text */
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
							@cust_def_no
							,@item_ref
							,@feature_ref
							,@definb_seq
							,@definb_username
							,@definb_doa
							,@definb_time_entered_h
							,@definb_time_entered_m
							,@definb_txt
							);

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
				END TRY
				BEGIN CATCH
					SET @errornumber = '20700';
					SET @errortext = 'Error overwriting defi_nb record';
					GOTO errorexit;
				END CATCH
			END
			ELSE
			BEGIN
				/* Appending*/
				BEGIN TRY
					/* Determine the starting sequence number */
					SELECT @definb_seq = COUNT(*)
						FROM defi_nb
						WHERE default_no = @cust_def_no;
					
					SET @definb_seq = @definb_seq + 1;

					/* Append new comp text */
					DECLARE csr_notes CURSOR FOR
						SELECT
							username
							,doa
							,time_entered_h
							,time_entered_m
							,txt
							FROM comp_text
							WHERE complaint_no = @complaint_no
								AND seq >= @startseq
								AND seq <= @endseq
								/* Will not return rows if @startseq > @endseq */
							ORDER BY seq;

					OPEN csr_notes;

					FETCH NEXT FROM csr_notes INTO
						@definb_username
						,@definb_doa
						,@definb_time_entered_h
						,@definb_time_entered_m
						,@definb_txt;

					WHILE @@FETCH_STATUS = 0
					BEGIN
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
							@cust_def_no
							,@item_ref
							,@feature_ref
							,@definb_seq
							,@definb_username
							,@definb_doa
							,@definb_time_entered_h
							,@definb_time_entered_m
							,@definb_txt
							);

						SET @definb_seq = @definb_seq + 1;

						FETCH NEXT FROM csr_notes INTO
							@definb_username
							,@definb_doa
							,@definb_time_entered_h
							,@definb_time_entered_m
							,@definb_txt;
					END

					CLOSE csr_notes
					DEALLOCATE csr_notes
				END TRY
				BEGIN CATCH
					SET @errornumber = '20701';
					SET @errortext = 'Error appending defi_nb record';
					GOTO errorexit;
				END CATCH
			END

			/* Update defi.text_flag */
			IF @comp_text_flag = 'Y'
			BEGIN
				BEGIN TRY
					UPDATE defi
						SET text_flag = 'Y'
						WHERE default_no = @cust_def_no;
				END TRY
				BEGIN CATCH
					SET @errornumber = '20702';
					SET @errortext = 'Error updating defi record (text_flag)';
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
