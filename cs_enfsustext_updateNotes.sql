/*****************************************************************************
** dbo.cs_enfsustext_updateNotes
** stored procedure
**
** Description
** Update notes for a specified enforcement suspect
**
** Parameters
** @suspect_ref = suspect reference
** @notes       = notes text
**
** Returned
** Return value of 0 (success) or -1
**
** Notes
** Assuming that new notes text is always appended.
**
** History
** 14/03/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_enfsustext_updateNotes', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_enfsustext_updateNotes;
GO
CREATE PROCEDURE dbo.cs_enfsustext_updateNotes
	@suspect_ref integer,
	@username varchar(8),
	@notes varchar(MAX) = NULL OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@suspect_rowcount integer,
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

	SET @errornumber = '20067';

	SET @username = LTRIM(RTRIM(@username));
	SET @notes    = LTRIM(RTRIM(@notes));

	IF @suspect_ref = 0 OR @suspect_ref IS NULL
	BEGIN
		SET @errornumber = '20068';
		SET @errortext = 'suspect_ref is required';
		GOTO errorexit;
	END
	SELECT @suspect_rowcount = COUNT(*)
		FROM enf_suspect
		WHERE suspect_ref = @suspect_ref
	IF @suspect_rowcount <> 1
	BEGIN
		SET @errornumber = '20487';
		SET @errortext = LTRIM(RTRIM(STR(@suspect_ref))) + ' is not a valid suspect reference';
		GOTO errorexit;
	END

	IF @username = '' OR @username IS NULL
	BEGIN
		SET @errornumber = '20069';
		SET @errortext = 'username is required';
		GOTO errorexit;
	END

	IF @notes = '' OR @notes IS NULL
	BEGIN
		SET @errornumber = '20070';
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

	/* Get the current last sequence number */
	SELECT @textSeq = COUNT(*)
		FROM enf_sus_text
		WHERE suspect_ref = @suspect_ref;

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

			INSERT INTO enf_sus_text
				(
				suspect_ref,
				seq,
				username,
				doa,
				time_entered_h,
				time_entered_m,
				txt
				)
				VALUES
				(
				@suspect_ref,
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
		SET @errornumber = '20071';
		SET @errortext = 'Error inserting enf_sus_text record';
		GOTO errorexit;
	END CATCH

/* Not really an error and no mechanism in place to deal with informative messages
	IF @textSeq > 500
	BEGIN
		SET @errornumber = '20072';
		SET @errortext = 'The maximum 500 lines of text exist, cannot add more';
		GOTO errorexit;
	END
*/

	BEGIN TRY
		/* update enf_suspect text flag to 'Y' */
		UPDATE enf_suspect
			SET text_flag = 'Y'
			WHERE suspect_ref = @suspect_ref;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20073';
		SET @errortext = 'Error updating enf_suspect record (text_flag)';
		GOTO errorexit;
	END CATCH

	SET @notes = dbo.cs_enfsustext_getNotes(@suspect_ref, 0);

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
