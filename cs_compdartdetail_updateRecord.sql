/*****************************************************************************
** dbo.cs_compdartdetail_updateRecord
** stored procedure
**
** Description
** Update comp_dart_detail records for specified lookup_func
**   using specified old and new '|' delimited lookup_code lists
**
** Parameters
** @pcomplaint_no     = complaint number
** @plookup_func      = lookup function
** @pold_lookup_code_list = '|' delimited old list of lookup codes
** @pnew_lookup_code_list = '|' delimited new list of lookup codes
** @pentered_by       = user login id
**
** Returned
** 0 = success, -1 = failure
**
** History
** 30/04/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_compdartdetail_updateRecord', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_compdartdetail_updateRecord;
GO
CREATE PROCEDURE dbo.cs_compdartdetail_updateRecord
	@pcomplaint_no integer,
	@plookup_func varchar(6),
	@plookup_code_list varchar(500) = '',
	@pentered_by varchar(8)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@complaint_no integer,
		@lookup_func varchar(6),
		@lookup_code_list varchar(500),
		@old_lookup_code_list varchar(500),
		@new_lookup_code_list varchar(500),
		@codecount integer,
		@loopvar integer,
		@lookup_code varchar(8),
		@entered_by varchar(8),
		@next_seq integer,
		@date_entered datetime,
		@time_entered_h varchar(2),
		@time_entered_m varchar(2),
		@numberstr varchar(2),
		@log_seq integer,
		@rowcount integer;

	SET @errornumber = '20235';

	SET @complaint_no     = @pcomplaint_no;
	SET @lookup_func      = LTRIM(RTRIM(@plookup_func));
	SET @lookup_code_list = LTRIM(RTRIM(@plookup_code_list));
	SET @entered_by       = LTRIM(RTRIM(@pentered_by));

	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @errornumber = '20236';
		SET @errortext   = 'complaint_no is required';
		GOTO errorexit;
	END

	IF @lookup_func = '' OR @lookup_func IS NULL
	BEGIN
		SET @errornumber = '20237';
		SET @errortext   = 'lookup_func is required';
		GOTO errorexit;
	END

	IF @entered_by = '' OR @entered_by IS NULL
	BEGIN
		SET @errornumber = '20238';
		SET @errortext   = 'entered_by is required';
		GOTO errorexit;
	END

	/* More efficient to delete all comp_dart_detail records */
	/* and insert new data, than work out specifically      */
	/* what has been deleted / added                        */

	BEGIN TRY
		DELETE FROM comp_dart_detail
			WHERE complaint_no = @complaint_no
				AND lookup_func = @lookup_func;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20262';
		SET @errortext   = 'Error deleting comp_dart_detail records';
		GOTO errorexit;
	END CATCH

	IF LEN(@lookup_code_list) > 0
	BEGIN

		SET @date_entered = GETDATE();

		SET @numberstr = DATENAME(hour, @date_entered);
		SET @time_entered_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

		SET @numberstr = DATENAME(minute, @date_entered);
		SET @time_entered_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

		SET @date_entered = CONVERT(datetime, CONVERT(date, @date_entered));

		SELECT @log_seq = COUNT(*)
			FROM comp_dart_dtl_log
			WHERE complaint_no = @complaint_no;

		SET @log_seq = @log_seq + 1;
	
		SET @codecount = LEN(@lookup_code_list) - LEN(REPLACE(@lookup_code_list, '|', '')) + 1;

		SET @loopvar = 1;

		WHILE @loopvar <= @codecount
		BEGIN
			SET @lookup_code = dbo.cs_utils_getField(@lookup_code_list, '|', @loopvar);

			IF @lookup_code <> '' AND @lookup_code IS NOT NULL
			BEGIN
				/* Validation */
				SELECT @rowcount = COUNT(*)
					FROM allk
					WHERE lookup_func = @lookup_func
						AND lookup_code = @lookup_code
						AND status_yn = 'Y';
				IF @rowcount = 0
				BEGIN
					SET @errornumber = '20330';
					SET @errortext = @lookup_code + ' is not a valid code for category ' + @lookup_func;
					GOTO errorexit;
				END

				BEGIN TRY
					INSERT INTO comp_dart_detail
						(
						complaint_no
						,lookup_func
						,lookup_code
						)
						VALUES
						(
						@complaint_no
						,@lookup_func
						,@lookup_code
						)
				END TRY
				BEGIN CATCH
					SET @errornumber = '20239';
					SET @errortext = 'Error inserting comp_dart_detail record';
					GOTO errorexit;
				END CATCH

				BEGIN TRY
					INSERT INTO comp_dart_dtl_log
						(
						complaint_no,
						lookup_func,
						lookup_code,
						log_seq,
						log_username,
						log_date,
						log_time_h,
						log_time_m
						)
						VALUES
						(
						@complaint_no
						,@lookup_func
						,@lookup_code
						,@log_seq
						,@entered_by
						,@date_entered
						,@time_entered_h
						,@time_entered_m
						)
				END TRY
				BEGIN CATCH
					SET @errornumber = '20240';
					SET @errortext = 'Error inserting comp_dart_dtl_log record';
					GOTO errorexit;
				END CATCH

				SET @log_seq = @log_seq + 1;
			END

			SET @loopvar = @loopvar + 1;
		END
	END

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
