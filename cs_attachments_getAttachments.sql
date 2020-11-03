/*****************************************************************************
** dbo.cs_attachments_getAttachments
** stored procedure
**
** Description
** Select a list of attachments records
**
** Parameters
** @type           = attachment type
** @source_no      = source reference
** @username       = user login name [optional]
**
** Returned
** Results set of attachments records
** Return value of 0 (success) or -1 (failure)
**
** History
** 28/02/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_attachments_getAttachments', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_attachments_getAttachments;
GO
CREATE PROCEDURE dbo.cs_attachments_getAttachments
	@type varchar(1),
	@source_no integer,
	@username varchar(20)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer;

	SET @errornumber = '10400';
	SET @type = LTRIM(RTRIM(@type));
	SET @username = LTRIM(RTRIM(@username));

	IF @type = '' OR @type IS NULL
	BEGIN
		SET @errornumber = '10401';
		SET @errortext = 'type is required';
		GOTO errorexit;
	END

	IF @source_no = 0 OR @source_no IS NULL
	BEGIN
		SET @errornumber = '10402';
		SET @errortext = 'source_no is required';
		GOTO errorexit;
	END

	IF @username = '' OR @username IS NULL
	BEGIN
		SELECT attach_no,
			[type],
			source_no,
			username,
			doa,
			comment,
			[file_name],
			orig_file_name
			FROM attachments
			WHERE [type] = @type
				AND source_no = @source_no;
	END
	ELSE
	BEGIN
		SELECT attach_no,
			[type],
			source_no,
			username,
			doa,
			comment,
			[file_name],
			orig_file_name
			FROM attachments
			WHERE [type] = @type
				AND source_no = @source_no
				AND username = @username;
	END

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
	