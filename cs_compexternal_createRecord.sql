/*****************************************************************************
** dbo.cs_compexternal_createRecord
** stored procedure
**
** Description
** Create comp_external record for specified complaint_no
**
** Parameters
** @complaint_no
**
** Returned
** @seq_no
** Return value of 1 (success) or 0
**
** History
** 22/03/2013  TW  New
** 04/07/2013  TW  Check for existing record first (ensure only one record per complaint_no)
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_compexternal_createRecord', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_compexternal_createRecord;
GO
CREATE PROCEDURE dbo.cs_compexternal_createRecord
	@complaint_no integer,
	@seq_no integer = NULL OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@result integer,
		@rowcount integer;

	SET @errornumber = '20139';

	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @errornumber = '20140';
		SET @errortext   = 'complaint_no is required';
		GOTO errorexit;
	END

	/* Check for existing record */
	SELECT @rowcount = COUNT(*)
		FROM comp_external
		WHERE complaint_no = @complaint_no;

	IF @rowcount = 0
	BEGIN
		BEGIN TRY
			EXECUTE @result = dbo.cs_sno_getSerialNumber 'comp_external', '', @serial_no = @seq_no OUTPUT;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20141';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH

		BEGIN TRY
			INSERT INTO comp_external
				(
				complaint_no,
				seq_no
				)
				VALUES
				(
				@complaint_no,
				@seq_no
				);
		END TRY
		BEGIN CATCH
			SET @errornumber = '20142';
			SET @errortext = 'Error inserting comp_external record';
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
