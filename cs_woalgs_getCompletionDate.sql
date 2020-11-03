/*****************************************************************************
** dbo.cs_woalgs_getCompletionDate
** user defined function
**
** Description
** Calculate the works order task completion date
**
** Parameters
** @wo_suffix
** @task_ref
** @wo_type_f
** @contract_ref
** @start_date
** @pa_area
**
** Returned
** @completion_date = works order task completion date
**
** Notes
** @dow calculations - cannot use SET DATEFIRST 1 inside a user defined function
** Day delay calculations add working days not calendar days
**
** History
** 06/02/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_woalgs_getCompletionDate', N'FN') IS NOT NULL
    DROP FUNCTION dbo.cs_woalgs_getCompletionDate;
GO
CREATE FUNCTION dbo.cs_woalgs_getCompletionDate
(
	@wo_suffix varchar(6),
	@task_ref varchar(12),
	@wo_type_f varchar(2),
	@contract_ref varchar(12),
	@start_date datetime,
	@pa_area varchar(6)
)
RETURNS datetime
AS
BEGIN

	DECLARE @completion_date datetime,
		@wa_wo_suffix varchar(6),
		@wa_woi_task_ref varchar(12),
		@wa_wo_type_f varchar(2),
		@wa_contract_ref varchar(12),
		@wa_ww_type varchar(2),
		@wa_day_delay integer,
		@wa_use_pa_area char(1),
		@wa_auto_clear char(1),
		@wa_extend_yn char(1),
		@work_week varchar(7),
		@dow integer,
		@day_loop integer,
		@day_delay integer,
		@wp_wo_suffix varchar(6),
		@wp_woi_task_ref varchar(12),
		@wp_wo_type_f varchar(2),
		@wp_contract_ref varchar(12),
		@wp_pa_area varchar(6),
		@wp_occur_day char(7),
		@wp_day_delay integer,
		@wp_ww_type varchar(2),
		@wp_due_date_action char(1),
		@wp_next_date_action char(1),
		@wp_action_time_h char(2),
		@wp_action_time_m char(2),
		@done integer,
		@action_time_h integer,
		@action_time_m integer,
		@time_h integer,
		@time_m integer,
		@datetime datetime,
		@calc_date datetime;

	SET @task_ref = LTRIM(RTRIM(@task_ref));
	SET @wo_type_f = LTRIM(RTRIM(@wo_type_f));
	SET @contract_ref = LTRIM(RTRIM(@contract_ref));
	SET @pa_area = LTRIM(RTRIM(@pa_area));

	IF (LEN(@task_ref) + LEN(@wo_type_f) + LEN(@contract_ref) + LEN(@pa_area)) = 0
	BEGIN
		GOTO normalexit;
	END

	IF @start_date IS NULL
	BEGIN
		SET @start_date = GETDATE();
	END

	SET @completion_date = @start_date;
	SET @calc_date       = @start_date;

	DECLARE csr_wo_algs CURSOR FOR
		SELECT wo_suffix,
			woi_task_ref,
			wo_type_f,
			contract_ref,
			ww_type,
			day_delay,
			use_pa_area,
			auto_clear,
			extend_yn
			FROM wo_algs;

	OPEN csr_wo_algs;

	FETCH NEXT FROM csr_wo_algs INTO
		@wa_wo_suffix,
		@wa_woi_task_ref,
		@wa_wo_type_f,
		@wa_contract_ref,
		@wa_ww_type,
		@wa_day_delay,
		@wa_use_pa_area,
		@wa_auto_clear,
		@wa_extend_yn;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @wa_wo_suffix <> '' AND @wa_wo_suffix IS NOT NULL
		BEGIN
			IF @wa_wo_suffix <> @wo_suffix
			BEGIN
				GOTO continuewhile1;
			END
		END

		IF @wa_woi_task_ref <> '' AND @wa_woi_task_ref IS NOT NULL
		BEGIN
			IF @wa_woi_task_ref <> @task_ref
			BEGIN
				GOTO continuewhile1;
			END
		END

		IF @wa_wo_type_f <> '' AND @wa_wo_type_f IS NOT NULL
		BEGIN
			IF @wa_wo_type_f <> @wo_type_f
			BEGIN
				GOTO continuewhile1;
			END
		END

		IF @wa_contract_ref <> '' AND @wa_contract_ref IS NOT NULL
		BEGIN
			IF @wa_contract_ref <> @contract_ref
			BEGIN
				GOTO continuewhile1;
			END
		END

		/* Found a matching record */
		SET @calc_date = @start_date;

		IF @wa_day_delay > 0
		BEGIN
			IF @work_week = '' OR @work_week IS NULL
			BEGIN
				SELECT @work_week = work_week
					FROM ww
					WHERE ww_type = @wa_ww_type;
			END
			IF @work_week <> '' AND @work_week IS NOT NULL AND @work_week <> 'NNNNNNN'
			BEGIN
				/* Adjust @calc_date by @wa_day_delay working days */
				SET @day_loop = 0;
				SET @day_delay = @wa_day_delay;
				WHILE @day_loop < @day_delay
				BEGIN
					SET @day_loop = @day_loop + 1;
					SET @calc_date = DATEADD(day, 1, @calc_date);

					SET @dow = (DATEPART(weekday, @calc_date) + 6 - 1) % 7 + 1;
					WHILE SUBSTRING(@work_week, @dow, 1) = 'N'
					BEGIN
						SET @calc_date = DATEADD(day, 1, @calc_date);
						SET @dow = (DATEPART(weekday, @calc_date) + 6 - 1) % 7 + 1;
					END
				END
			END
			ELSE
			BEGIN
				SET @calc_date = DATEADD(day, @wa_day_delay, @calc_date);
			END
		END
		ELSE
		BEGIN
			IF @wa_use_pa_area = 'Y'
			BEGIN
				SET @done = 0;

				DECLARE csr_wo_algs_pa_area CURSOR FOR
					SELECT 
						wo_suffix,
						woi_task_ref,
						wo_type_f,
						contract_ref,
						pa_area,
						occur_day,
						day_delay,
						ww_type,
						due_date_action,
						next_date_action,
						action_time_h,
						action_time_m
						FROM wo_algs_pa_area
						WHERE pa_area = @pa_area;

				OPEN csr_wo_algs_pa_area;

				FETCH NEXT FROM csr_wo_algs_pa_area INTO
					@wp_wo_suffix,
					@wp_woi_task_ref,
					@wp_wo_type_f,
					@wp_contract_ref,
					@wp_pa_area,
					@wp_occur_day,
					@wp_day_delay,
					@wp_ww_type,
					@wp_due_date_action,
					@wp_next_date_action,
					@wp_action_time_h,
					@wp_action_time_m;

				WHILE @@FETCH_STATUS = 0 AND @done = 0
				BEGIN
					IF @wa_wo_suffix <> '' AND @wa_wo_suffix IS NOT NULL
					BEGIN
						IF @wp_wo_suffix <> @wa_wo_suffix
						BEGIN
							GOTO continuewhile2;
						END
					END

					IF @wa_woi_task_ref <> '' AND @wa_woi_task_ref IS NOT NULL
					BEGIN
						IF @wp_woi_task_ref <> @wa_woi_task_ref
						BEGIN
							GOTO continuewhile2;
						END
					END

					IF @wa_wo_type_f <> '' AND @wa_wo_type_f IS NOT NULL
					BEGIN
						IF @wp_wo_type_f <> @wa_wo_type_f
						BEGIN
							GOTO continuewhile2;
						END
					END

					IF @wa_contract_ref <> '' AND @wa_contract_ref IS NOT NULL
					BEGIN
						IF @wp_contract_ref <> @wa_contract_ref
						BEGIN
							GOTO continuewhile2;
						END
					END

					/* Found a matching record */
					SET @done = 1;

					IF @action_time_h IS NULL
					BEGIN
						SET @action_time_h = 0;
					END

					IF @action_time_m IS NULL
					BEGIN
						SET @action_time_m = 0;
					END

					IF @wp_occur_day <> '' AND @wp_occur_day IS NULL AND @wp_occur_day <> 'XXXXXXX'
					BEGIN
						IF @wp_day_delay > 0
						BEGIN
							/* Adjust @calc_date by @wp_day_delay working days */
							SET @day_loop = 0;
							SET @day_delay = @wp_day_delay;
							WHILE @day_loop < @day_delay
							BEGIN
								SET @day_loop = @day_loop + 1;
								SET @calc_date = DATEADD(day, 1, @calc_date);

								SET @dow = (DATEPART(weekday, @calc_date) + 6 - 1) % 7 + 1;
								WHILE SUBSTRING(@wp_occur_day, @dow, 1) = 'X'
								BEGIN
									SET @calc_date = DATEADD(day, 1, @calc_date);
									SET @dow = (DATEPART(weekday, @calc_date) + 6 - 1) % 7 + 1;
								END
							END
						END
						ELSE
						BEGIN
							/* Calculate the next occur day */
							WHILE (1 = 1)
							BEGIN
								SET @dow = (DATEPART(weekday, @calc_date) + 6 - 1) % 7 + 1;
								WHILE SUBSTRING(@wp_occur_day, @dow, 1) = 'X'
								BEGIN
									SET @calc_date = DATEADD(day, 1, @calc_date);
									SET @dow = (DATEPART(weekday, @calc_date) + 6 - 1) % 7 + 1;
								END

								IF @wp_due_date_action = 'Y'
									AND @calc_date = @start_date
								BEGIN
									SET @calc_date = DATEADD(day, 1, @calc_date);
									CONTINUE;
								END

								IF @wp_next_date_action = 'Y'
									AND @calc_date = DATEADD(day, 1, @start_date)
									AND LEN(@wp_action_time_h) > 0
									AND LEN(@wp_action_time_m) > 0
								BEGIN
									SET @datetime = GETDATE();
									SET @time_h = DATEPART(hour, @datetime);
									SET @time_m = DATEPART(minute, @datetime);
									IF @time_h IS NULL
									BEGIN
										SET @time_h = 0;
									END
									IF @time_m IS NULL
									BEGIN
										SET @time_m = 0;
									END
									IF @time_h > @wp_action_time_h
									BEGIN
										SET @calc_date = DATEADD(day, 1, @calc_date);
										CONTINUE;
									END
									ELSE
									BEGIN
										IF @time_h = @wp_action_time_h
										BEGIN
											IF @time_m > @wp_action_time_m
											BEGIN
												SET @calc_date = DATEADD(day, 1, @calc_date);
												CONTINUE;
											END
										END
									END
								END

								BREAK;

							END  /* WHILE (1 = 1) */
						END  /* IF @wp_day_delay > 0 */
					END
					ELSE
					BEGIN
						IF @wp_day_delay > 0
						BEGIN
							SELECT @work_week = work_week
								FROM ww
								WHERE ww_type = @wp_ww_type;

							IF @work_week <> '' AND @work_week IS NOT NULL AND @work_week <> 'NNNNNNN'
							BEGIN
								/* Adjust @calc_date by @wp_day_delay working days */
								SET @day_loop = 0;
								SET @day_delay = @wp_day_delay;
								WHILE @day_loop < @day_delay
								BEGIN
									SET @day_loop = @day_loop + 1;
									SET @calc_date = DATEADD(day, 1, @calc_date);

									SET @dow = (DATEPART(weekday, @calc_date) + 6 - 1) % 7 + 1;
									WHILE SUBSTRING(@work_week, @dow, 1) = 'N'
									BEGIN
										SET @calc_date = DATEADD(day, 1, @calc_date);
										SET @dow = (DATEPART(weekday, @calc_date) + 6 - 1) % 7 + 1;
									END
								END
							END
							ELSE
							BEGIN
								SET @calc_date = DATEADD(day, @wp_day_delay, @calc_date);
							END
						END  /* IF @wp_day_delay > 0 */
					END  /* IF @wp_occur_day <> '' AND @wp_occur_day IS NULL AND @wp_occur_day <> 'XXXXXXX' */

continuewhile2:

					FETCH NEXT FROM csr_wo_algs_pa_area INTO
						@wp_wo_suffix,
						@wp_woi_task_ref,
						@wp_wo_type_f,
						@wp_contract_ref,
						@wp_pa_area,
						@wp_occur_day,
						@wp_day_delay,
						@wp_ww_type,
						@wp_due_date_action,
						@wp_next_date_action,
						@wp_action_time_h,
						@wp_action_time_m;
				END  /* WHILE @@FETCH_STATUS = 0 AND @done = 0 (csr_wo_algs_pa_area) */

				CLOSE csr_wo_algs_pa_area;
				DEALLOCATE csr_wo_algs_pa_area;

			END  /* IF @wa_use_pa_area = 'Y' */
		END  /* IF @wa_day_delay > 0 */

continuewhile1:

		IF @calc_date > @completion_date
		BEGIN
			SET @completion_date = @calc_date;
		END

		FETCH NEXT FROM csr_wo_algs INTO
			@wa_wo_suffix,
			@wa_woi_task_ref,
			@wa_wo_type_f,
			@wa_contract_ref,
			@wa_ww_type,
			@wa_day_delay,
			@wa_use_pa_area,
			@wa_auto_clear,
			@wa_extend_yn;
	END  /* WHILE @@FETCH_STATUS = 0 (csr_wo_algs) */

	CLOSE csr_wo_algs;
	DEALLOCATE csr_wo_algs;

normalexit:

	RETURN (@completion_date);

END
GO 
