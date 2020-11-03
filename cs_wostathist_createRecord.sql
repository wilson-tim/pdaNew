/*****************************************************************************
** dbo.cs_wostathist_createRecord
** stored procedure
**
** Description
** Create a wo_stat_hist record
**
** Parameters
** @wo_ref
** @wo_suffix
** @new_status  = new wo status value
** @username
**
** Returned
** Return value of 0 (success), or -1 (failure)
**
** Notes
**
** History
** 26/06/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_wostathist_createRecord', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_wostathist_createRecord;
GO
CREATE PROCEDURE dbo.cs_wostathist_createRecord
	@pwo_ref integer
	,@pwo_suffix varchar(6)
	,@pnew_status varchar(6)
	,@pusername varchar(8)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @result integer
		,@errortext varchar(500)
		,@errornumber varchar(10)
		,@wo_ref integer
		,@wo_suffix varchar(6)
		,@new_status varchar(6)
		,@username varchar(8)
		,@seq_no integer
		,@numberstr varchar(2)
		,@datestamp_date datetime
		,@datestamp_time_h varchar(2)
		,@datestamp_time_m varchar(2)
		;

	SET @wo_ref     = @pwo_ref;
	SET @wo_suffix  = LTRIM(RTRIM(@pwo_suffix));
	SET @new_status = LTRIM(RTRIM(@pnew_status));
	SET @username   = LTRIM(RTRIM(@pusername));

	/* @wo_ref validation */
	IF @wo_ref = 0 OR @wo_ref IS NULL
	BEGIN
		SET @errornumber = '20620';
		SET @errortext = 'wo_ref is required';
		GOTO errorexit;
	END

	/* @wo_suffix validation */
	IF @wo_suffix = '' OR @wo_suffix IS NULL
	BEGIN
		SET @errornumber = '20621';
		SET @errortext = 'wo_suffix is required';
		GOTO errorexit;
	END

	/* @new_status validation */
	IF @new_status = '' OR @new_status IS NULL
	BEGIN
		SET @errornumber = '20622';
		SET @errortext = 'new_status is required';
		GOTO errorexit;
	END

	/* @username validation */
	/* Assuming that @username has already been validated by calling process(es) */
	/* so only a basic test here for non-blank and non-null data being passed */
	IF @username = '' OR @username IS NULL
	BEGIN
		SET @errornumber = '20623';
		SET @errortext = 'username is required';
		GOTO errorexit;
	END

	SELECT @seq_no = COUNT(*)
		FROM wo_stat_hist
		WHERE wo_ref = @wo_ref
			AND wo_suffix = @wo_suffix;

	IF @seq_no = 0
	BEGIN
		SET @seq_no = 1;
	END
	ELSE
	BEGIN
		SET @seq_no = @seq_no + 1;
	END

	SET @datestamp_date = GETDATE();

	SET @numberstr = DATENAME(hour, @datestamp_date);
	SET @datestamp_time_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @numberstr = DATENAME(minute, @datestamp_date);
	SET @datestamp_time_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @datestamp_date = CONVERT(datetime, CONVERT(date, @datestamp_date));

	BEGIN TRY
		INSERT INTO wo_stat_hist
			(
			wo_ref
			,wo_suffix
			,seq_no
			,wo_h_stat
			,[user_name]
			,change_date
			,change_time_h
			,change_time_m
			)
			VALUES
			(
			@wo_ref
			,@wo_suffix
			,@seq_no
			,@new_status
			,@username
			,@datestamp_date
			,@datestamp_time_h
			,@datestamp_time_m
			);
	END TRY
	BEGIN CATCH
		SET @errornumber = '20624';
		SET @errortext = 'Error inserting wo_stat_hist record';
		GOTO errorexit;
	END CATCH

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO