/*****************************************************************************
** dbo.cs_evidencetext_updateNotes
** stored procedure
**
** Description
** Update notes for a specified enforcements complaint
**
** Parameters
** @complaint_no = complaint number
** @username     = user login id
** @notes        = notes text
**
** Returned
** @notes = concatenated notes data
** Return value of 0 (success) or -1
**
** Notes
** Ignoring system key OVERWRITE_COMP_TEXT
** so assuming that new notes text is always appended.
**
** History
** 14/03/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_evidencetext_updateNotes', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_evidencetext_updateNotes;
GO
CREATE PROCEDURE dbo.cs_evidencetext_updateNotes
	@complaint_no integer,
	@username varchar(8),
	@notes varchar(MAX) = NULL OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@comp_rowcount integer,
		@tempText varchar(MAX),
		@textSeq integer,
		@textPos integer,
		@textRow varchar(60),
		@date_entered datetime,
		@ent_time_h varchar(2),
		@ent_time_m varchar(2),
		@numberstr varchar(2),
		@wordwrap_enabled char(1),
		@comp_text_blank_line char(1),
		@comp_text_blank_line_bit bit;

	SET @errornumber = '20061';

	SET @username = LTRIM(RTRIM(@username));
	SET @notes    = LTRIM(RTRIM(@notes));

	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @errornumber = '20062';
		SET @errortext = 'complaint no is required';
		GOTO errorexit;
	END
	SELECT @comp_rowcount = COUNT(*)
		FROM comp
		WHERE complaint_no = @complaint_no
	IF @comp_rowcount <> 1
	BEGIN
		SET @errornumber = '20486';
		SET @errortext = LTRIM(RTRIM(STR(@complaint_no))) + ' is not a valid complaint reference';
		GOTO errorexit;
	END

	IF @username = '' OR @username IS NULL
	BEGIN
		SET @errornumber = '20063';
		SET @errortext = 'username is required';
		GOTO errorexit;
	END

	IF @notes = '' OR @notes IS NULL
	BEGIN
		SET @errornumber = '20064';
		SET @errortext = 'notes is required';
		GOTO errorexit;
	END

	/* Get date enetered, etc. */
	SET @date_entered = GETDATE();

	SET @numberstr = DATENAME(hour, @date_entered);
	SET @ent_time_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @numberstr = DATENAME(minute, @date_entered);
	SET @ent_time_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @date_entered = CONVERT(datetime, CONVERT(date, @date_entered));

	/* Get the current last sequence number */
	SELECT @textSeq = COUNT(*)
		FROM evidence_text
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
			SET @textSeq = @textSeq + 1;

			IF @textSeq > 500
			BEGIN
				GOTO exitfetch;
			END

			INSERT INTO evidence_text
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

	END TRY
	BEGIN CATCH
		SET @errornumber = '20065';
		SET @errortext = 'Error inserting evidence_text record';
		GOTO errorexit;
	END CATCH

/* Not really an error and no mechanism in place to deal with informative messages
	IF @textSeq > 500
	BEGIN
		SET @errornumber = '20066';
		SET @errortext = 'The maximum 500 lines of text exist, cannot add more';
		GOTO errorexit;
	END
*/

	SET @notes = dbo.cs_evidencetext_getNotes(@complaint_no, 0);

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
