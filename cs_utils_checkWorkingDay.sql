/*****************************************************************************
** dbo.cs_utils_checkWorkingDay
** stored procedure
**
** Description
** Check the passed date is a working day and adjust if necessary
**
** Parameters
** @datetime      = date to check
** @item_ref      = item reference
** @contract_ref  = contract reference
** @working_week  = working week pattern, e.g. YYNYYNN (representing MTWTFSS)
**                  [optional parameter]
**
** Returned
** @new_datetime  = checked / adjusted date
** Return value of 0 (success) or -1 (failure, with exception text)
**
** Notes
** Based on def_reps.4gl, functions johns_week, check_for_weekends,
**   get_working_week_record, get_occur_day_pos
**
** History
** 30/01/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_utils_checkWorkingDay', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_utils_checkWorkingDay;
GO
CREATE PROCEDURE dbo.cs_utils_checkWorkingDay
	@datetime datetime,
	@item_ref varchar(12),
	@contract_ref varchar(12),
	@working_week char(7),
	@new_datetime datetime = NULL OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	/* Set Monday as weekday 1, i.e. Sunday is weekday 7 */
	SET DATEFIRST 1;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer,
		@dayofweek integer,
		@calendar_date datetime;

	SET @errornumber = '13700';
	SET @item_ref = LTRIM(RTRIM(@item_ref));
	SET @contract_ref = LTRIM(RTRIM(@contract_ref));

	IF @datetime IS NULL
	BEGIN
		SET @errornumber = '13701';
		SET @errortext = 'datetime is required';
		GOTO errorexit;
	END

	IF @item_ref = '' OR @item_ref IS NULL
	BEGIN
		SET @errornumber = '13702';
		SET @errortext = 'item_ref is required';
		GOTO errorexit;
	END

	IF @contract_ref = '' OR @contract_ref IS NULL
	BEGIN
		SET @errornumber = '13703';
		SET @errortext = 'contract_ref is required';
		GOTO errorexit;
	END

check_for_weekends:
get_working_week_record:
	IF @working_week = '' OR @working_week IS NULL
	BEGIN
		SELECT @working_week = work_week
			FROM ww, item, fr_i, pa_i
			WHERE item.item_ref = @item_ref
				AND item.contract_ref = @contract_ref
				AND item.pattern_code = fr_i.freq_ref
				AND fr_i.date_ref = pa_i.pattern_code
				AND pa_i.[start_date] <= @datetime
				AND pa_i.finish_date >= @datetime
				AND ww.ww_type = fr_i.ww_type;
	END

	/* Check that @working_week exists */
	IF @working_week = '' OR @working_week IS NULL
	BEGIN
		SET @errornumber = '13704';
		SET @errortext = 'Unable to locate working week for item ' + @item_ref + ' contract ' + @contract_ref + ' date ' + LTRIM(RTRIM(CONVERT(varchar(10), @datetime, 103)));
		GOTO errorexit;
	END

	/* Check for @working_week having no working days */
	IF @working_week = 'NNNNNNN'
	BEGIN
		SET @errornumber = '13705';
		SET @errortext = 'There are no working days defined in working week NNNNNNN';
		GOTO errorexit;
	END

	/* Check for @working_week having incorrect characters */
	IF LEN(REPLACE(REPLACE(@working_week, 'Y', ''), 'N', '')) <> 0
	BEGIN
		SET @errornumber = '13706';
		SET @errortext = 'Working week ' + @working_week + ' is not valid';
		GOTO errorexit;
	END

	/* Check for @working_week being incorrect length */
	IF LEN(@working_week) <> 7
	BEGIN
		SET @errornumber = '13707';
		SET @errortext = 'Working week ' + @working_week + ' is not valid';
		GOTO errorexit;
	END

johns_week:
	/* Bob says this is named in honour of John Mooteealoo, Islington */
	SET @new_datetime = @datetime;

	WHILE (@working_week <> 'NNNNNNN')
	BEGIN
		SET @dayofweek = DATEPART(weekday, @new_datetime);

		WHILE SUBSTRING(@working_week, @dayofweek, 1) = 'N'
		BEGIN
			SET @new_datetime = DATEADD(day, 1, @new_datetime);
			SET @dayofweek = DATEPART(weekday, @new_datetime);
		END

		/* Is the whiteboard module installed? */
		IF dbo.cs_modulelic_getInstalled('WB') = 1
		BEGIN
			/* Is @new_datetime an exclusion date? */
			SELECT @rowcount = COUNT(*)
				FROM whiteboard_dtl
					WHERE (calendar_date >= DATEADD(day, DATEDIFF(day, 0, @new_datetime), 0)
						AND calendar_date < DATEADD(day, DATEDIFF(day, 0, @new_datetime) + 1, 0))
						AND exclusion_yn = 'Y';

			IF @rowcount > 0
			BEGIN
				SET @new_datetime = DATEADD(day, 1, @new_datetime);
				CONTINUE
			END
		END

		BREAK
	END

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO
