/*****************************************************************************
** dbo.cs_wotype_getTypes
** stored procedure
**
** Description
** Selects a set of wo_type records for a given contract ref
**
** Parameters
** @contract_ref = contract ref
** @item_ref     = item_ref (highways defect)
** @area_value   = area (highways defect)
** @linear_value = linear (highways defect)
** @priority     = priority flag (highways defect)
**
** Returned
** Result set of works order type data
** Return value of @@ROWCOUNT or -1
**
** History
** 15/01/2013  TW  New
** 03/10/2013  TW  Additional parameters for highways defect
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_wotype_getTypes', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_wotype_getTypes;
GO
CREATE PROCEDURE dbo.cs_wotype_getTypes
	@contract_ref varchar(12),
	@item_ref varchar(12) = NULL,
	@area_value decimal(10,1) = 0,
	@linear_value decimal(10,1) = 0,
	@priority varchar(1) = NULL
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer;

	SET @errornumber = '14100';
	SET @contract_ref = LTRIM(RTRIM(@contract_ref));

	IF @contract_ref = '' OR @contract_ref IS NULL
	BEGIN
		SET @errornumber = '14101';
		SET @errortext = 'contract_ref is required';
		GOTO errorexit;
	END

	IF (@item_ref <> '' AND @item_ref IS NOT NULL)
		AND (@priority <> '' AND @priority IS NOT NULL)
	BEGIN
		IF (@linear_value > 0 AND @linear_value IS NOT NULL)
			AND (@area_value = 0 OR @area_value IS NULL)
		BEGIN
			SELECT measurement_task.wo_type_f,
				wo_type.wo_type_desc,
				measurement_task.contract_ref,
				NULL
				FROM measurement_task
				LEFT OUTER JOIN wo_type
				ON wo_type.wo_type_f = measurement_task.wo_type_f
					AND wo_type.contract_ref = measurement_task.contract_ref
				WHERE measurement_task.contract_ref = @contract_ref
					AND measurement_task.item_ref = @item_ref
					AND measurement_task.linear_or_area = 'L'
					AND measurement_task.[priority] = @priority
				ORDER BY measurement_task.wo_suffix;
		END

		IF (@linear_value = 0 OR @linear_value IS NULL)
			AND (@area_value > 0 AND @area_value IS NOT NULL)
		BEGIN
			SELECT measurement_task.wo_type_f,
				wo_type.wo_type_desc,
				measurement_task.contract_ref,
				NULL
				FROM measurement_task
				LEFT OUTER JOIN wo_type
				ON wo_type.wo_type_f = measurement_task.wo_type_f
					AND wo_type.contract_ref = measurement_task.contract_ref
				WHERE measurement_task.contract_ref = @contract_ref
					AND measurement_task.item_ref = @item_ref
					AND measurement_task.linear_or_area = 'A'
					AND measurement_task.[priority] = @priority
				ORDER BY measurement_task.wo_suffix;
		END

		IF (@linear_value > 0 AND @linear_value IS NOT NULL)
			AND (@area_value > 0 AND @area_value IS NOT NULL)
		BEGIN
			SELECT measurement_task.wo_type_f,
				wo_type.wo_type_desc,
				measurement_task.contract_ref,
				NULL
				FROM measurement_task
				LEFT OUTER JOIN wo_type
				ON wo_type.wo_type_f = measurement_task.wo_type_f
					AND wo_type.contract_ref = measurement_task.contract_ref
				WHERE measurement_task.contract_ref = @contract_ref
					AND measurement_task.item_ref = @item_ref
					AND (measurement_task.linear_or_area = 'L'
						OR measurement_task.linear_or_area = 'A')
					AND measurement_task.[priority] = @priority
				ORDER BY measurement_task.wo_suffix;
		END
	END
	ELSE
	BEGIN
		SELECT wo_type_f,
			wo_type_desc,
			contract_ref,
			wo_type_group
			FROM wo_type
			WHERE contract_ref = @contract_ref
			ORDER BY wo_type_f;
	END

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
