/*****************************************************************************
** dbo.csis_itl_updateRecord
** stored procedure
**
** Description
** Updates the integration transfer log
**
** Parameters
** @complaint_no     = complaint reference
** @contractor_ref   = contractor reference (optional)
** @rejected         = rejected flag (optional)
** @tansfer_datetime = transfer datetime (optional)
** @update_datetime  = update datetime 1 = Yes, 0 = No
**
** Returned
** Return value of 0 (success), or -1 (failure)
**
** History
** 05/08/2013  TW  New
** 07/08/2013  TW  New parameter update_datetime
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.csis_itl_updateRecord', N'P') IS NOT NULL
    DROP PROCEDURE dbo.csis_itl_updateRecord;
GO
CREATE PROCEDURE dbo.csis_itl_updateRecord
	@pcomplaint_no integer
	,@pcontractor_ref varchar(20)
	,@prejected varchar(1)
	,@ptransfer_datetime datetime
	,@pupdate_datetime bit = 1
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500)
		,@errornumber varchar(10)
		,@rowcount integer
		,@complaint_no integer
		,@contractor_ref varchar(20)
		,@rejected varchar(1)
		,@transfer_datetime datetime
		,@update_datetime bit
		;

	SET @complaint_no = @pcomplaint_no;
	SET @contractor_ref = LTRIM(RTRIM(@pcontractor_ref));
	SET @rejected = LTRIM(RTRIM(@prejected));
	SET @transfer_datetime = @ptransfer_datetime;
	SET @update_datetime = @pupdate_datetime;

	/* @complaint_no validation */
	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @errornumber = '20708';
		SET @errortext = 'complaint_no is required';
		GOTO errorexit;
	END
	SELECT @rowcount = COUNT(*)
		FROM comp
		WHERE complaint_no = @complaint_no;
	IF @rowcount <> 1
	BEGIN
		SET @errornumber = '20709';
		SET @errortext = LTRIM(RTRIM(STR(@complaint_no))) + ' is not a valid complaint reference';
		GOTO errorexit;
	END

	/* @transfer_datetime */
	IF @transfer_datetime IS NULL
	BEGIN
		SET @transfer_datetime = GETDATE();
	END

	SELECT @rowcount = COUNT(*)
		FROM integration_transfer_log
		WHERE complaint_no = @complaint_no;

	IF @rowcount = 0
	BEGIN
		/* Create a new record */
		BEGIN TRY
			INSERT INTO integration_transfer_log
				(
				complaint_no
				,contractor_ref
				,rejected
				,transfer_datetime
				)
				VALUES
				(
				@complaint_no
				,@contractor_ref
				,@rejected
				,@transfer_datetime
				);
		END TRY
		BEGIN CATCH
			SET @errornumber = '20710';
			SET @errortext = 'Error inserting integration_transfer_log record';
			GOTO errorexit;
		END CATCH
	END
	ELSE
	BEGIN
		/* Update an existing record */
		BEGIN TRY
			IF @contractor_ref = '' OR @contractor_ref IS NULL
			BEGIN
				SELECT @contractor_ref = contractor_ref
					FROM integration_transfer_log
					WHERE complaint_no = @complaint_no;
			END

			IF @update_datetime = 1
			BEGIN
				UPDATE integration_transfer_log
					SET
					complaint_no = @complaint_no
					,contractor_ref = @contractor_ref
					,rejected = @rejected
					,transfer_datetime = @transfer_datetime
					WHERE complaint_no = @complaint_no;
			END
			ELSE
			BEGIN
				UPDATE integration_transfer_log
					SET
					complaint_no = @complaint_no
					,contractor_ref = @contractor_ref
					,rejected = @rejected
					WHERE complaint_no = @complaint_no;
			END
		END TRY
		BEGIN CATCH
			SET @errornumber = '20711';
			SET @errortext = 'Error updating integration_transfer_log record';
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
