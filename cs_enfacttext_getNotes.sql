/*****************************************************************************
** dbo.cs_enfacttext_getNotes
** user defined function
**
** Description
** Get concatenated enforcement action notes data for a specified enforcement action
**   and optionally up to a specified length
**
** Parameters
** @complaint_no = complaint number
** @action_seq   = action sequence number
** @action_ref   = action code
** @action_date  = action date
** @noteslen     = length required
**
** Returned
** @result = concatenated notes data
**
** History
** 13/03/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_enfacttext_getNotes', N'FN') IS NOT NULL
    DROP FUNCTION dbo.cs_enfacttext_getNotes;
GO
CREATE FUNCTION dbo.cs_enfacttext_getNotes
(
	@complaint_no integer,
	@action_seq integer,
	@action_ref varchar(6),
/*	@action_date datetime, */
	@noteslen integer
)
RETURNS varchar(MAX)
AS
BEGIN

	DECLARE @result varchar(MAX),
		@username varchar(20),
		@doa datetime,
		@notes varchar(100),
		@old_username varchar(20),
		@doa_text varchar(10),
		@old_doa_text varchar(10);

	SET @result = '';

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
			FROM enf_act_text
			WHERE complaint_no = @complaint_no
				AND action_seq = @action_seq
				AND action_ref = @action_ref
/*				AND action_date = @action_date */
			ORDER BY seq;

	OPEN csr_notes;

	FETCH NEXT FROM csr_notes INTO
		@username,
		@doa,
		@notes;

	WHILE @@FETCH_STATUS = 0
		AND LEN(@result) < @noteslen
	BEGIN
		SET @doa_text = LTRIM(RTRIM(CONVERT(varchar(10), @doa, 103)))
		IF @old_username <> @username
			OR @old_doa_text <> @doa_text
		BEGIN
			SET @old_username = @username;
			SET @old_doa_text = @doa_text;
			SET @notes = '|@|@|' + @username + '|@|@|' + @doa_text + '|@|@|' + @notes;
		END

		IF LEN(@result) = 0
		BEGIN
			SET @result = RTRIM(@notes);
		END
		ELSE
		BEGIN
			SET @result = @result + CHAR(13) + CHAR(10) + RTRIM(@notes);
		END

		FETCH NEXT FROM csr_notes INTO
			@username,
			@doa,
			@notes;
	END

	SET @result = SUBSTRING(@result, 1, @noteslen);

	CLOSE csr_notes
	DEALLOCATE csr_notes

	RETURN (@result);

END
GO 
