/*****************************************************************************
** dbo.cs_defa_getDefaultCompletionDate
** stored procedure
**
** Description
** Calculate the default completion date/time for a rectification
**
** Parameters
** @cb_time_id    = defp1.cb_time_id
** @item_ref      = item reference
** @contract_ref  = contract reference
** @cdatetime     = completion date
**
** Returned
** @new_cdatetime = completion date
** Return value of 0 (success) or -1 (failure, with exception text)
**
** Notes
** Based on def_reps.4gl
**
** History
** 29/01/2013  TW  New
** 30/01/2013  TW  Completed
** 01/02/2013  TW  Renamed from cs_defa_getCorrectByDates
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_defa_getDefaultCompletionDate', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_defa_getDefaultCompletionDate;
GO
CREATE PROCEDURE cs_defa_getDefaultCompletionDate
	@cb_time_id integer,
	@item_ref varchar(12),
	@contract_ref varchar(12),
	@cdatetime datetime,
	@new_cdatetime datetime = NULL OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@numberstr varchar(2),
		@defp4cb_time_id integer,
		@defp4time_delay decimal(6,2),
		@defp4report_by_hrs1 char(2),
		@defp4report_by_mins1 char(2),
		@defp4report_by_hrs2 char(2),
		@defp4report_by_mins2 char(2),
		@defp4report_by_hrs3 char(2),
		@defp4report_by_mins3 char(2),
		@defp4correct_by_hrs1 char(2),
		@defp4correct_by_mins1 char(2),
		@defp4correct_by_hrs2 char(2),
		@defp4correct_by_mins2 char(2),
		@defp4correct_by_hrs3 char(2),
		@defp4correct_by_mins3 char(2),
		@defp4working_week char(7),
		@defp4clock_start_hrs char(2),
		@defp4clock_start_mins char(2),
		@defp4clock_stop_hrs char(2),
		@defp4clock_stop_mins char(2),
		@defp4cut_off_hrs char(2),
		@defp4cut_off_mins char(2),
		@temp_cdatetime datetime,
		@time_h char(2),
		@time_m char(2),
		@new_time_h char(2),
		@new_time_m char(2),
		@new_time_h_int integer,
		@new_time_m_int integer,
		@time_h_int integer,
		@time_m_int integer,
		@rby_int_hrs1 integer,
		@rby_int_hrs2 integer,
		@rby_int_hrs3 integer,
		@rby_int_mins1 integer,
		@rby_int_mins2 integer,
		@rby_int_mins3 integer,
		@cby_int_hrs1 integer,
		@cby_int_hrs2 integer,
		@cby_int_hrs3 integer,
		@cby_int_mins1 integer,
		@cby_int_mins2 integer,
		@cby_int_mins3 integer,
		@clock_start_hrs integer,
		@clock_start_mins integer,
		@clock_stop_hrs integer,
		@clock_stop_mins integer,
		@cut_off_hrs integer,
		@cut_off_mins integer,
		@end_range_hrs integer,
		@end_range_mins integer,
		@time_delay decimal(6,2),
		@time_delay_char char(7),
		@time_delay_mins char(2),
		@time_delay_mins_int integer,
		@x integer,
		@y integer;

	SET @errornumber = '11900';
	SET @item_ref = LTRIM(RTRIM(@item_ref));
	SET @contract_ref = LTRIM(RTRIM(@contract_ref));

	IF @item_ref = '' OR @item_ref IS NULL
	BEGIN
		SET @errornumber = '11901';
		SET @errortext = 'item_ref is required';
		GOTO errorexit;
	END

	IF @contract_ref = '' OR @contract_ref IS NULL
	BEGIN
		SET @errornumber = '11902';
		SET @errortext = 'contract_ref is required';
		GOTO errorexit;
	END

get_dtl_cb:
	SELECT @defp4cb_time_id = cb_time_id,
		@defp4time_delay = time_delay,
		@defp4report_by_hrs1 = report_by_hrs1,
		@defp4report_by_mins1 = report_by_mins1,
		@defp4report_by_hrs2 = report_by_hrs2,
		@defp4report_by_mins2 = report_by_mins2,
		@defp4report_by_hrs3 = report_by_hrs3,
		@defp4report_by_mins3 = report_by_mins3,
		@defp4correct_by_hrs1 = correct_by_hrs1,
		@defp4correct_by_mins1 = correct_by_mins1,
		@defp4correct_by_hrs2 = correct_by_hrs2,
		@defp4correct_by_mins2 = correct_by_mins2,
		@defp4correct_by_hrs3 = correct_by_hrs3,
		@defp4correct_by_mins3 = correct_by_mins3,
		@defp4working_week = working_week,
		@defp4clock_start_hrs = clock_start_hrs,
		@defp4clock_start_mins = clock_start_mins,
		@defp4clock_stop_hrs = clock_stop_hrs,
		@defp4clock_stop_mins = clock_stop_mins,
		@defp4cut_off_hrs = cut_off_hrs,
		@defp4cut_off_mins = cut_off_mins
		FROM defp4
		WHERE defp4.cb_time_id = @cb_time_id;

get_correct_by_dates:
	SET @new_cdatetime = CONVERT(datetime, CONVERT(date, @cdatetime));
	SET @numberstr = DATENAME(hour, @cdatetime);
	SET @time_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));
	SET @numberstr = DATENAME(minute, @cdatetime);
	SET @time_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));
	SET @new_time_h = @time_h;
	SET @new_time_m = @time_m;
	SET @new_time_h_int = CAST(@time_h AS integer);
	SET @new_time_m_int = CAST(@time_m AS integer);
	SET @time_h_int = CAST(@time_h AS integer);
	SET @time_m_int = CAST(@time_m AS integer);
	SET @rby_int_hrs1 = CAST(@defp4report_by_hrs1 AS integer);
	SET @rby_int_hrs2 = CAST(@defp4report_by_hrs2 AS integer);
	SET @rby_int_hrs3 = CAST(@defp4report_by_hrs3 AS integer);
	SET @rby_int_mins1 = CAST(@defp4report_by_mins1 AS integer);
	SET @rby_int_mins2 = CAST(@defp4report_by_mins2 AS integer);
	SET @rby_int_mins3 = CAST(@defp4report_by_mins3 AS integer);
	SET @cby_int_hrs1 = CAST(@defp4correct_by_hrs1 AS integer);
	SET @cby_int_hrs2 = CAST(@defp4correct_by_hrs2 AS integer);
	SET @cby_int_hrs3 = CAST(@defp4correct_by_hrs3 AS integer);
	SET @cby_int_mins1 = CAST(@defp4correct_by_mins1 AS integer);
	SET @cby_int_mins2 = CAST(@defp4correct_by_mins2 AS integer);
	SET @cby_int_mins3 = CAST(@defp4correct_by_mins3 AS integer);
	SET @clock_start_hrs = CAST(@defp4clock_start_hrs AS integer);
	SET @clock_start_mins = CAST(@defp4clock_start_mins AS integer);
	SET @clock_stop_hrs = CAST(@defp4clock_stop_hrs AS integer);
	SET @clock_stop_mins = CAST(@defp4clock_stop_mins AS integer);
	SET @cut_off_hrs = CAST(@defp4cut_off_hrs AS integer);
	SET @cut_off_mins = CAST(@defp4cut_off_mins AS integer);

	IF @defp4working_week IS NOT NULL
	BEGIN
		/* Check that @new_cdatetime is a valid working day */
		SET @temp_cdatetime = @new_cdatetime;
		EXECUTE dbo.cs_utils_checkWorkingDay
			@temp_cdatetime,
			@item_ref,
			@contract_ref,
			@defp4working_week,
			@new_cdatetime OUTPUT;

		IF DATEDIFF(day, @cdatetime, @new_cdatetime) <> 0
		BEGIN
			IF @clock_start_hrs IS NOT NULL
			BEGIN
				SET @time_h_int = @clock_start_hrs;
				SET @time_m_int = @clock_start_mins;
			END
			ELSE
			BEGIN
				SET @time_h_int = 0;
				SET @time_m_int = 0;
			END
		END
	END

	/*
	** If the time delay is set then use that as an increment to the current date
	** and time, else use the report by, correct by fields
	*/
	IF @defp4time_delay = 0 OR @defp4time_delay IS NULL
	BEGIN
		/* time delay is not set */
		IF @rby_int_hrs1 > @time_h_int
			OR (@rby_int_hrs1 = @time_h_int AND @rby_int_mins1 > @time_m_int)
		BEGIN
			SET @time_h_int = @cby_int_hrs1;
			SET @time_m_int = @cby_int_mins1;
			SET @end_range_hrs = @rby_int_hrs1;
			SET @end_range_mins = @rby_int_mins1;
			GOTO endcase1
		END

		IF  @rby_int_hrs2 > @time_h_int
			OR (@rby_int_hrs2 = @time_h_int AND @rby_int_mins2 > @time_m_int)
		BEGIN
			SET @time_h_int = @cby_int_hrs2;
			SET @time_m_int = @cby_int_mins2;
			SET @end_range_hrs = @rby_int_hrs2;
			SET @end_range_mins = @rby_int_mins2;
			GOTO endcase1
		END

		/* ... otherwise */
		SET @time_h_int = @cby_int_hrs3;
		SET @time_m_int = @cby_int_mins3;
		SET @end_range_hrs = @rby_int_hrs3;
		SET @end_range_mins = @rby_int_mins3;

endcase1:

		/*
		** If the new time is less than or equal to the END RANGE (NOT current) time
		** then it must mean tomorrow
		*/
		IF @time_h_int < @end_range_hrs
		BEGIN
			SET @new_cdatetime = DATEADD(day, 1, @new_cdatetime);
		END
		ELSE
		BEGIN
			IF @time_h_int = @end_range_hrs
				AND @time_m_int <= @end_range_mins
			BEGIN
				SET @new_cdatetime = DATEADD(day, 1, @new_cdatetime);
			END
		END

		/* Check that @new_cdatetime is a valid working day */
		SET @temp_cdatetime = @new_cdatetime;
		EXECUTE dbo.cs_utils_checkWorkingDay
			@temp_cdatetime,
			@item_ref,
			@contract_ref,
			@defp4working_week,
			@new_cdatetime OUTPUT;
	END
	ELSE
	BEGIN
		/* time delay is set */
		SET @time_delay = @defp4time_delay;
		SET @time_delay_char = CONVERT(char(7), @time_delay);
		SET @x = LEN(@time_delay_char);
		SET @time_delay_mins = SUBSTRING(@time_delay_char, @x -1, 2);
		SET @time_delay_mins_int = CAST(@time_delay AS integer);

		IF @clock_start_hrs IS NULL
		BEGIN
			WHILE @time_delay - 24 > 0
			BEGIN
				SET @time_delay = @time_delay - 24;
				SET @new_cdatetime = DATEADD(day, 1, @new_cdatetime);

				/* Check that @new_cdatetime is a valid working day */
				SET @temp_cdatetime = @new_cdatetime;
				EXECUTE dbo.cs_utils_checkWorkingDay
					@temp_cdatetime,
					@item_ref,
					@contract_ref,
					@defp4working_week,
					@new_cdatetime OUTPUT;
			END   /* END of WHILE @time_delay - 24 > 0 */

			/* OK, we are now down to less than 24 hours */
			/* We must cater for minutes, as requested by Camden */

			WHILE @time_delay > 0
			BEGIN
				IF @time_delay < 1
				BEGIN
					IF @time_delay = 0.30
					BEGIN
						IF (@time_m_int + 30) < 60
						BEGIN
							SET @time_m_int = @time_m_int + 30;
						END
						ELSE
						BEGIN
							SET @time_h_int = @time_h_int + 1;
							SET @time_m_int = ((@time_m_int + 30) - 60);
						END
					END

					IF @time_delay = 0.15
					BEGIN
						IF (@time_m_int + 15) < 60
						BEGIN
							SET @time_m_int = @time_m_int + 15;
						END
						ELSE
						BEGIN
							SET @time_h_int = @time_h_int + 1;
							SET @time_m_int = ((@time_m_int + 15) - 60);
						END
					END

					SET @time_delay = 0;

					BREAK;
				END
				ELSE
				BEGIN
					SET @time_delay = @time_delay - 1;
					SET @time_h_int = @time_h_int + 1;

					IF @time_h_int >= 24
					BEGIN
						SET @time_h_int = @time_h_int - 24;
						SET @new_cdatetime = DATEADD(day, 1, @new_cdatetime);

						/* Check that @new_cdatetime is a valid working day */
						SET @temp_cdatetime = @new_cdatetime;
						EXECUTE dbo.cs_utils_checkWorkingDay
							@temp_cdatetime,
							@item_ref,
							@contract_ref,
							@defp4working_week,
							@new_cdatetime OUTPUT;
					END
				END
			END   /* END of WHILE @time_delay > 0 */
		END
		ELSE
		BEGIN
			/* Clock Start / Clock Stop code follows */

			SET @time_h_int = @time_h_int + @time_delay;

			SET @time_m_int = @time_m_int + @time_delay_mins_int;

			IF @time_m_int >= 60
			BEGIN
				SET @time_h_int = @time_h_int + 1;
				SET @time_m_int = @time_m_int - 60;
			END

			IF @cut_off_hrs IS NULL
			BEGIN
				WHILE @time_h_int > @clock_stop_hrs
				BEGIN
					SET @new_cdatetime = DATEADD(day, 1, @new_cdatetime);

					/* Check that @new_cdatetime is a valid working day */
					SET @temp_cdatetime = @new_cdatetime;
					EXECUTE dbo.cs_utils_checkWorkingDay
						@temp_cdatetime,
						@item_ref,
						@contract_ref,
						@defp4working_week,
						@new_cdatetime OUTPUT;

					SET @y = @time_h_int - @clock_stop_hrs;
					SET @time_h_int = @clock_start_hrs + @y;

					IF @time_h_int = @clock_stop_hrs
					BEGIN
						IF @time_m_int <= @clock_stop_mins
						BEGIN
							BREAK;
						END
						ELSE
						BEGIN
							SET @new_cdatetime = DATEADD(day, 1, @new_cdatetime);
							SET @time_h_int = @clock_start_hrs;

							/* Check that @new_cdatetime is a valid working day */
							SET @temp_cdatetime = @new_cdatetime;
							EXECUTE dbo.cs_utils_checkWorkingDay
								@temp_cdatetime,
								@item_ref,
								@contract_ref,
								@defp4working_week,
								@new_cdatetime OUTPUT;
						END
					END
				END   /* END of WHILE @time_h_int > @clock_stop_hrs */
			END
			ELSE
			BEGIN
				WHILE (1 = 1)
				BEGIN
					/* Rectify time is in normal working hours */
					IF (@time_h_int < @clock_stop_hrs
						OR (@time_h_int = @clock_stop_hrs AND @time_m_int <= @clock_stop_mins)
						)
					/* The actual time before delay is added */
						AND (@new_time_h_int < @clock_stop_hrs
							OR (@new_time_h_int = @clock_stop_hrs AND @new_time_m_int <= @clock_stop_mins)
							)
					BEGIN
						/* Leave the rectification time */
						BREAK;
					END

					/* Passed clock stop but not reached Shut Off */
					IF (@time_h_int > @clock_stop_hrs
						OR (@time_h_int = @clock_stop_hrs AND @time_m_int > @clock_stop_mins)
						)
						AND (@cut_off_hrs > @time_h_int
							OR (@cut_off_hrs = @time_h_int AND @cut_off_mins > @time_m_int)
							)
					BEGIN
						/* Leave the rectification time */
						BREAK;
					END

					/* Both Clock Stop and Cut Off have been pased */
					IF (@time_h_int > @clock_stop_hrs
						OR (@time_h_int = @clock_stop_hrs AND @time_m_int > @clock_stop_mins)
						)
						AND (@time_h_int > @cut_off_hrs
							OR (@time_h_int = @cut_off_hrs AND @time_m_int > @cut_off_mins)
							)
						AND @cut_off_hrs > @clock_stop_hrs
					BEGIN
						/* Let rectify time equal cut off time */
						SET @time_h_int = @clock_stop_hrs;
						SET @time_m_int = @clock_stop_mins;

						BREAK;
					END

					/* 
					** The Clock Stop has passed but
					** the Cut Off is less than the Clock Stop
					** i.e. Clock Stop in evening Cut Off in morning
					*/
					IF (@time_h_int > @clock_stop_hrs
						OR (@time_h_int = @clock_stop_hrs AND @time_m_int > @clock_stop_mins)
						)
						AND (@cut_off_hrs < @clock_stop_hrs
							OR (@cut_off_hrs = @clock_stop_hrs AND @cut_off_mins < @clock_stop_hrs)
							)
					BEGIN
						SET @time_h_int = @time_h_int - @clock_stop_hrs;
						SET @time_m_int = @time_m_int - @clock_stop_mins;

						IF @time_m_int >= 60
						BEGIN
							SET @time_h_int = @time_h_int + 1;
							SET @time_m_int = @time_m_int - 60;
							GOTO endcase2
						END

						IF @time_m_int < 0
						BEGIN
							SET @time_h_int = @time_h_int - 1;
							SET @time_m_int = 60 - @time_m_int;
							GOTO endcase2
						END

endcase2:

						SET @time_h_int = @time_h_int + @clock_start_hrs;
						SET @time_m_int = @time_m_int + @clock_start_mins;

						SET @new_cdatetime = DATEADD(day, 1, @new_cdatetime);

						/* Check that @new_cdatetime is a valid working day */
						SET @temp_cdatetime = @new_cdatetime;
						EXECUTE dbo.cs_utils_checkWorkingDay
							@temp_cdatetime,
							@item_ref,
							@contract_ref,
							@defp4working_week,
							@new_cdatetime OUTPUT;

						/* The Cut Off is greater than the new rectify time */
						IF @time_h_int < @cut_off_hrs
						BEGIN
							BREAK;
						END

						/* The rectify time has exceed the Cut Off */
						IF @time_h_int > @cut_off_hrs
							OR (@time_h_int = @cut_off_hrs AND @time_m_int > @cut_off_mins)
						BEGIN
							SET @time_h_int = @cut_off_hrs;
							SET @time_m_int = @cut_off_mins;

							BREAK;
						END
					END

				END   /* END of WHILE (1 = 1) */
			END   /* END of IF @cut_off_hrs IS NULL */
		END   /* END of IF @clock_start_hrs IS NULL */
	END   /* END of IF @defp4time_delay = 0 OR @defp4time_delay IS NULL */

	/* Assemble final @new_cdatetime */
	/* MS SQL Server 2012 has introduced function DATETIMEFROMPARTS which supersedes this */
	SET @new_cdatetime = 
		DATEADD(minute, ISNULL(@time_m_int, 0),
			DATEADD(hour,   ISNULL(@time_h_int, 0),
			DATEADD(day,    DATEPART(day,   ISNULL(@new_cdatetime, GETDATE())) - 1, 
			DATEADD(month,  DATEPART(month, ISNULL(@new_cdatetime, GETDATE())) - 1, 
			DATEADD(year,   DATEPART(year,  ISNULL(@new_cdatetime, GETDATE())) - 1900, 0)))));

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
