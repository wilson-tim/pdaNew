/*****************************************************************************
** dbo.cs_definb_updateNotes
** stored procedure
**
** Description
** Update notes for a specified rectification
**
** Parameters
** @default_no  = rectification cust_def_no
** @item_ref    = item reference
** @feature_ref = feature reference
** @user_name   = user login id
** @contractorFlag = 'Y' if text originates from a third party and should be enclosed with << ... >>
** @notes       = notes text
**
** Returned
** Return value of 0 (success) or -1
**
** Notes
** Assuming that new notes text is always appended.
**
** History
** 05/08/2013  TW  New
** 06/08/2013  TW  Continued development
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_definb_updateNotes', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_definb_updateNotes;
GO
CREATE PROCEDURE dbo.cs_definb_updateNotes
	@pdefault_no integer
	,@pitem_ref varchar(12)
	,@pfeature_ref varchar(12)
	,@puser_name varchar(8)
	,@pcontractorFlag varchar(1) = NULL
	,@pnotes varchar(MAX) = NULL OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE
		@errortext varchar(500)
		,@errornumber varchar(10)
		,@complaint_no integer
		,@user_name varchar(8)
		,@notes varchar(MAX)
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
		,@default_no integer
		,@item_ref varchar(12)
		,@feature_ref varchar(12)
		,@contractorFlag varchar(1)
		,@rowlength integer
		;

	SET @default_no  = @pdefault_no;
	SET @item_ref    = LTRIM(RTRIM(@pitem_ref));
	SET @feature_ref = LTRIM(RTRIM(@pfeature_ref));
	SET @user_name   = LTRIM(RTRIM(@puser_name));
	SET @contractorFlag = LTRIM(RTRIM(@pcontractorFlag));
	SET @notes       = LTRIM(RTRIM(@pnotes));

	IF @default_no = 0 OR @default_no IS NULL
	BEGIN
		SET @errornumber = '20717';
		SET @errortext = 'default_no is required';
		GOTO errorexit;
	END

	IF @item_ref = '' OR @item_ref IS NULL
	BEGIN
		SET @errornumber = '20718';
		SET @errortext = 'item_ref is required';
		GOTO errorexit;
	END

	IF @feature_ref = '' OR @feature_ref IS NULL
	BEGIN
		SET @errornumber = '20719';
		SET @errortext = 'feature_ref is required';
		GOTO errorexit;
	END

	IF @user_name = '' OR @user_name IS NULL
	BEGIN
		SET @errornumber = '20720';
		SET @errortext = 'user_name is required';
		GOTO errorexit;
	END

	IF @notes = '' OR @notes IS NULL
	BEGIN
		SET @errornumber = '20721';
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
		FROM defi_nb
		WHERE default_no = @default_no;

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

	/* Extract rows of data from @notes and create defi_nb records */
	BEGIN TRY
		IF @contractorFlag = 'Y'
		BEGIN
			SET @rowlength = 56;
		END
		ELSE
		BEGIN
			SET @rowlength = 60;
		END

		IF @wordwrap_enabled = 'Y'
		BEGIN
			DECLARE csr_texttable CURSOR FOR
				SELECT linetext
					FROM dbo.cs_utils_wrapText(@notes, @rowlength, @comp_text_blank_line_bit)
					ORDER BY linenum;
		END
		ELSE
		BEGIN
			DECLARE csr_texttable CURSOR FOR
				SELECT linetext
					FROM dbo.cs_utils_splitText(@notes, @rowlength, @comp_text_blank_line_bit)
					ORDER BY linenum;
		END

		OPEN csr_texttable;

		FETCH NEXT FROM csr_texttable INTO
			@textRow;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @textSeq = @textSeq + 1;

			IF (@contractorFlag = 'Y') AND (SUBSTRING(@textRow, 1, 2) <> '!!')
			BEGIN
				SET @textRow = '<<' + @textRow + '>>';
			END

			IF @textSeq > 500
			BEGIN
				GOTO exitfetch;
			END

			INSERT INTO defi_nb
				(
				default_no,
				item_ref,
				feature_ref,
				seq_no,
				username,
				doa,
				time_entered_h,
				time_entered_m,
				txt
				)
				VALUES
				(
				@default_no,
				@item_ref,
				@feature_ref,
				@textSeq,
				@user_name,
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
		SET @errornumber = '20722';
		SET @errortext = 'Error inserting defi_nb record';
		GOTO errorexit;
	END CATCH

/* Not really an error and no mechanism in place to deal with informative messages
	IF @textSeq > 500
	BEGIN
		SET @errornumber = '99999';
		SET @errortext = 'The maximum 500 lines of text exist, cannot add more';
		GOTO errorexit;
	END
*/

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
