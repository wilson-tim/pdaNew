/*****************************************************************************
** dbo.cs_task_getTasks
** stored procedure
**
** Description
** Selects a set of task records for a given contract ref, contract cycle and
**   works order type. There may be more than one ta_r record for a given task
**   within these criteria, e.g. due to price changes during a cycle, so must
**   ensure that the 'current' ta_r record is selected in each case, i.e. ta_r.[start_date]
**   is less than or equal to the current date
**
** Parameters
** @contract_ref = contract ref
** @cycle_no     = contract cycle no
** @wo_suffix    = works order suffix
** @wo_type_f    = works order type (required if works order task groups are in use)
** @pa_area      = patrol area (required if wo_algs_pa_area table is in use)
**
** Returned
** Result set of task data
** Return value of @@ROWCOUNT or -1
**
** Notes
** Ignoring defects for the time being
**
** @contract_ref and @cycle_no are returned by cs_cont_getContracts.sql
**
** @wo_suffix is returned by cs_wos_getSuffixes.sql
**
** @wo_type_f is returned by either cs_wos_getSuffixes.sql
**   or cs_wotype_getTypes.sql
**
** @wo_type_f is needed if works order task groups are in use
**   (system key LINK_TASK_TO_WO_TYPE = 'Y')
**
** @pa_area is needed if wo_algs_pa_area table is in use
**
** History
** 02/01/2013  TW  New
** 15/01/2013  TW  Additionally pass wo_type_f
** 08/02/2013  TW  Additionally pass pa_area for task completion date calculation
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_task_getTasks', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_task_getTasks;
GO
CREATE PROCEDURE dbo.cs_task_getTasks
	@contract_ref varchar(12),
	@cycle_no integer,
	@wo_suffix varchar(6),
	@wo_type_f varchar(2) = NULL,
	@pa_area varchar(6) = NULL
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @rowcount integer,
		@link_task varchar(1),
		@wo_group_flag bit,
		@wo_type_group varchar(6),
		@errortext varchar(500),
		@errornumber varchar(10),
		@start_date datetime;

	SET @errornumber = '13400';
	SET @contract_ref = LTRIM(RTRIM(@contract_ref));
	SET @wo_suffix    = LTRIM(RTRIM(@wo_suffix));
	SET @wo_type_f    = LTRIM(RTRIM(@wo_type_f));

	IF @contract_ref = '' OR @contract_ref IS NULL
	BEGIN
		SET @errornumber = '13401';
		SET @errortext = 'contract_ref is required';
		GOTO errorexit;
	END

	IF @cycle_no = '' OR @cycle_no = 0 OR @cycle_no IS NULL
	BEGIN
		SET @errornumber = '13402';
		SET @errortext = 'cycle_no is required';
		GOTO errorexit;
	END

	IF @wo_suffix = '' OR @wo_suffix IS NULL
	BEGIN
		SET @errornumber = '13403';
		SET @errortext = 'wo_suffix is required';
		GOTO errorexit;
	END

	SET @rowcount = 0;

	SET @start_date = GETDATE();

	SET @link_task = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'LINK_TASK_TO_WO_TYPE'))));

	IF @link_task = 'Y'
	BEGIN
		/* Get the wo_type_group if any */
		SELECT @wo_type_group = LTRIM(RTRIM(wo_type.wo_type_group))
			FROM wo_type
			INNER JOIN wo_s
			ON wo_s.wo_suffix = @wo_suffix
				AND wo_s.contract_ref = wo_type.contract_ref
				AND wo_s.wo_type_f = wo_type.wo_type_f
			WHERE wo_type.contract_ref = @contract_ref
				AND wo_type.wo_type_f = @wo_type_f;

		IF @@ROWCOUNT = 1
		BEGIN
			SET @wo_group_flag = 1;
		END
		ELSE
		BEGIN
			SET @wo_group_flag = 0;
		END

		IF @wo_group_flag = 1
		BEGIN
			SELECT taskselection.task_ref
				,taskselection.task_desc
				,taskselection.unit_of_meas
				,taskselection.unit_code
				,taskselection.task_code
				,taskselection.task_flag
				,taskselection.material_code
				,taskselection.wo_type_group
				,taskselection.contract_ref
				,taskselection.cont_cycle_no
				,taskselection.[start_date]
				,taskselection.contractor_ref
				,taskselection.rate_band_code
				,taskselection.task_rate
				,taskselection.completion_date
				FROM
				(
				SELECT task.task_ref
					,task.task_desc
					,task.unit_of_meas
					,task.unit_code
					,task.task_code
					,task.task_flag
					,task.material_code
					,task.wo_type_group
					,ta_r.contract_ref
					,ta_r.cont_cycle_no
					,ta_r.[start_date]
					,ta_r.contractor_ref
					,ta_r.rate_band_code
					,ta_r.task_rate
					,(dbo.cs_woalgs_getCompletionDate(@wo_suffix, task.task_ref, @wo_type_f, @contract_ref, @start_date, @pa_area)) AS completion_date
					,rownumber = ROW_NUMBER() OVER
						(
						PARTITION BY ta_r.task_ref
						ORDER BY ta_r.task_ref, ta_r.[start_date] DESC
						)
					FROM task
					INNER JOIN ta_r
					ON ta_r.task_ref = task.task_ref
						AND ta_r.rate_band_code = 'SELL'
						AND ta_r.cont_cycle_no = @cycle_no
						AND ta_r.contract_ref = @contract_ref
					WHERE
						(
						(task.wo_type_group = @wo_type_group)
						OR (task.wo_type_group = '')
						OR (task.wo_type_group IS NULL)
						)
						AND ta_r.[start_date] <= GETDATE()
				) AS taskselection
				WHERE taskselection.rownumber = 1
				ORDER BY taskselection.task_ref;

			SET @rowcount = @@ROWCOUNT;
		END
		ELSE
		BEGIN
			SELECT taskselection.task_ref
				,taskselection.task_desc
				,taskselection.unit_of_meas
				,taskselection.unit_code
				,taskselection.task_code
				,taskselection.task_flag
				,taskselection.material_code
				,taskselection.wo_type_group
				,taskselection.contract_ref
				,taskselection.cont_cycle_no
				,taskselection.[start_date]
				,taskselection.contractor_ref
				,taskselection.rate_band_code
				,taskselection.task_rate
				,taskselection.completion_date
				FROM
				(
				SELECT task.task_ref
					,task.task_desc
					,task.unit_of_meas
					,task.unit_code
					,task.task_code
					,task.task_flag
					,task.material_code
					,task.wo_type_group
					,ta_r.contract_ref
					,ta_r.cont_cycle_no
					,ta_r.[start_date]
					,ta_r.contractor_ref
					,ta_r.rate_band_code
					,ta_r.task_rate
					,(dbo.cs_woalgs_getCompletionDate(@wo_suffix, task.task_ref, @wo_type_f, @contract_ref, @start_date, @pa_area)) AS completion_date
					,rownumber = ROW_NUMBER() OVER
						(
						PARTITION BY ta_r.task_ref
						ORDER BY ta_r.task_ref, ta_r.[start_date] DESC
						)
					FROM task
					INNER JOIN ta_r
					ON ta_r.task_ref = task.task_ref
						AND ta_r.rate_band_code = 'SELL'
						AND ta_r.cont_cycle_no = @cycle_no
						AND ta_r.contract_ref = @contract_ref
					WHERE
						(
						(task.wo_type_group = '')
						OR (task.wo_type_group IS NULL)
						)
						AND ta_r.[start_date] <= GETDATE()
				) AS taskselection
				WHERE taskselection.rownumber = 1
				ORDER BY taskselection.task_ref;

			SET @rowcount = @@ROWCOUNT;
		END
	END
	ELSE
	BEGIN
		SELECT taskselection.task_ref
			,taskselection.task_desc
			,taskselection.unit_of_meas
			,taskselection.unit_code
			,taskselection.task_code
			,taskselection.task_flag
			,taskselection.material_code
			,taskselection.wo_type_group
			,taskselection.contract_ref
			,taskselection.cont_cycle_no
			,taskselection.[start_date]
			,taskselection.contractor_ref
			,taskselection.rate_band_code
			,taskselection.task_rate
			,taskselection.completion_date
			FROM
			(
			SELECT task.task_ref
				,task.task_desc
				,task.unit_of_meas
				,task.unit_code
				,task.task_code
				,task.task_flag
				,task.material_code
				,task.wo_type_group
				,ta_r.contract_ref
				,ta_r.cont_cycle_no
				,ta_r.[start_date]
				,ta_r.contractor_ref
				,ta_r.rate_band_code
				,ta_r.task_rate
				,(dbo.cs_woalgs_getCompletionDate(@wo_suffix, task.task_ref, @wo_type_f, @contract_ref, @start_date, @pa_area)) AS completion_date
				,rownumber = ROW_NUMBER() OVER
					(
					PARTITION BY ta_r.task_ref
					ORDER BY ta_r.task_ref, ta_r.[start_date] DESC
					)
				FROM task
				INNER JOIN ta_r
				ON ta_r.task_ref = task.task_ref
					AND ta_r.rate_band_code = 'SELL'
					AND ta_r.cont_cycle_no = @cycle_no
					AND ta_r.contract_ref = @contract_ref
				WHERE ta_r.[start_date] <= GETDATE()
			) AS taskselection
			WHERE taskselection.rownumber = 1
			ORDER BY taskselection.task_ref;

		SET @rowcount = @@ROWCOUNT;
	END

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO
