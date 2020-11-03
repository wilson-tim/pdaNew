/*****************************************************************************
** dbo.cs_attachments_createRecord
** stored procedure
**
** Description
** Create an attachments record
**
** Parameters
** @attach_no      = attachment number
** @type           = attachment type
** @source_no      = source reference
** @username       = user login name
** @doa            = date of attachment
** @comment        = comment [optional]
** @file_name      = destination filename
** @orig_file_name = original filename
**
** Returned
** Return value of 0 (success) or -1 (failure)
**
** History
** 28/02/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_attachments_createRecord', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_attachments_createRecord;
GO
CREATE PROCEDURE dbo.cs_attachments_createRecord
	@attach_no integer,
	@type varchar(1),
	@source_no integer,
	@username varchar(20),
	@doa datetime,
	@comment varchar(40),
	@file_name varchar(200),
	@orig_file_name varchar(200)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errornumber varchar(10),
			@errortext varchar(500);

	SET @errornumber = '10300';
	IF @attach_no = 0 OR @attach_no IS NULL
	BEGIN
		SET @errortext = 'attach_no is required';
		SET @errornumber = '10301';
		GOTO errorexit;
	END

	IF @type = '' OR @type IS NULL
	BEGIN
		SET @errortext = 'type is required';
		SET @errornumber = '10302';
		GOTO errorexit;
	END

	IF @source_no = 0 OR @source_no IS NULL
	BEGIN
		SET @errortext = 'source_no is required';
		SET @errornumber = '10303';
		GOTO errorexit;
	END

	IF @username = '' OR @username IS NULL
	BEGIN
		SET @errortext = 'username is required';
		SET @errornumber = '10304';
		GOTO errorexit;
	END

	IF @doa IS NULL
	BEGIN
		SET @errortext = 'date of attachment is required';
		SET @errornumber = '10305';
		GOTO errorexit;
	END

	IF @file_name = '' OR @file_name IS NULL
	BEGIN
		SET @errortext = 'filename is required';
		SET @errornumber = '10306';
		GOTO errorexit;
	END

	IF @orig_file_name = '' OR @orig_file_name IS NULL
	BEGIN
		SET @errortext = 'original filename is required';
		SET @errornumber = '10307';
		GOTO errorexit;
	END

	INSERT INTO attachments
		(
			attach_no,
			[type],
			source_no,
			username,
			doa,
			comment,
			[file_name],
			orig_file_name
		)
		VALUES
		(
			@attach_no,
			@type,
			@source_no,
			@username,
			@doa,
			@comment,
			@file_name,
			@orig_file_name
		)

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
