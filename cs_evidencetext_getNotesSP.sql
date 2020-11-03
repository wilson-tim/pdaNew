/*****************************************************************************
** dbo.cs_evidencetext_getNotesSP
** stored procedure
**
** Description
** Get concatenated enforcements evidence notes data for a given complaint_no
**   and optionally up to a specified length
**
** Parameters
** @complaint_no = complaint number
** @noteslen     = length required (defaults to 30000)
**
** Returned
** @notes = concatenated notes data
**
** History
** 26/03/2013  TW  SP version of cs_evidencetext_getNotes
** 02/04/2013  TW  Include datestamp
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_evidencetext_getNotesSP', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_evidencetext_getNotesSP;
GO
CREATE PROCEDURE dbo.cs_evidencetext_getNotesSP
	@pcomplaint_no integer,
	@pnoteslen integer,
	@notes varchar(MAX) OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
			@errornumber varchar(10),
			@complaint_no integer,
			@noteslen integer,
			@notestext varchar(100),
			@username varchar(20),
			@doa datetime,
			@old_username varchar(20),
			@doa_text varchar(10),
			@old_doa_text varchar(10);

	SET @errornumber = '20161';

	SET @complaint_no = @pcomplaint_no;
	SET @noteslen = @pnoteslen;
	SET @notes = '';

	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @errornumber = '20162';
		SET @errortext   = 'complaint_no is required';
		GOTO errorexit;
	END

	IF @noteslen = 0 OR @noteslen IS NULL OR @noteslen > 30000
	BEGIN
		SET @noteslen = 30000;
	END

	SET @old_username = '';
	SET @old_doa_text = '';

	DECLARE csr_notes CURSOR FOR
		SELECT username,
			doa,
			txt
			FROM evidence_text
			WHERE complaint_no = @complaint_no
			ORDER BY seq;

	OPEN csr_notes;

	FETCH NEXT FROM csr_notes INTO
		@username,
		@doa,
		@notestext;

	WHILE @@FETCH_STATUS = 0
		AND LEN(@notes) < @noteslen
	BEGIN
		SET @doa_text = LTRIM(RTRIM(CONVERT(varchar(10), @doa, 103)))
		IF @old_username <> @username
			OR @old_doa_text <> @doa_text
		BEGIN
			SET @old_username = @username;
			SET @old_doa_text = @doa_text;
			SET @notestext = '|@|@|' + @username + '|@|@|' + @doa_text + '|@|@|' + @notestext;
		END

		IF LEN(@notes) = 0
		BEGIN
			SET @notes = RTRIM(@notestext);
		END
		ELSE
		BEGIN
			SET @notes = @notes + CHAR(13) + CHAR(10) + RTRIM(@notestext);
		END

		FETCH NEXT FROM csr_notes INTO
			@username,
			@doa,
			@notestext;
	END

	SET @notes = SUBSTRING(@notes, 1, @noteslen);

	CLOSE csr_notes
	DEALLOCATE csr_notes

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
