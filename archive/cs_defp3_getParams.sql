/*****************************************************************************
** dbo.cs_defp3_getParams
** stored procedure
**
** Description
** Selects a set of defp3 records for a given algorithm, contract_ref, item_type,
**   priority, level
**
** Parameters
** @algorithm     = algorithm code
** @contract_ref  = contract reference
** @item_ref      = item reference
** @item_type     = item type
** @priority      = priority flag
** @level         = rectification level
**
** Returned
** Result set of defp3 data
** Return value of @@ROWCOUNT or -1
**
** History
** 22/01/2013  TW  New
** 23/01/2013  TW  Additionally return task_rate and unit_of_meas
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_defp3_getParams', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_defp3_getParams;
GO
CREATE PROCEDURE dbo.cs_defp3_getParams
	@algorithm varchar(12),
	@contract_ref varchar(12),
	@item_ref varchar(12),
	@item_type varchar(6),
	@priority varchar(1),
	@level integer
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(100),
		@rowcount integer;

	SET @algorithm = RTRIM(LTRIM(@algorithm));
	SET @contract_ref = RTRIM(LTRIM(@contract_ref));
	SET @item_ref = RTRIM(LTRIM(@item_ref));
	SET @item_type = RTRIM(LTRIM(@item_type));
	SET @priority = RTRIM(LTRIM(@priority));

	IF @algorithm = '' OR @algorithm IS NULL
	BEGIN
		SET @errortext = 'algorithm is required';
		GOTO errorexit;
	END

	IF @contract_ref = '' OR @contract_ref IS NULL
	BEGIN
		SET @errortext = 'contract_ref is required';
		GOTO errorexit;
	END

	IF @item_ref = '' OR @item_ref IS NULL
	BEGIN
		SET @errortext = 'item_ref is required';
		GOTO errorexit;
	END

	IF @item_type = '' OR @item_type IS NULL
	BEGIN
		SET @errortext = 'item_type is required';
		GOTO errorexit;
	END

	IF @priority = '' OR @priority IS NULL
	BEGIN
		SET @errortext = 'priority is required';
		GOTO errorexit;
	END

	IF @level IS NULL
	BEGIN
		SET @errortext = 'level is required';
		GOTO errorexit;
	END

	SELECT defp3.std_cv,
		defp3.std_pnts,
		defp3.std_val,
		defp3.fr_v_flag,
		defp3.fr_p_flag,
		defp3.d_u_o_m_flag,
		defp3.d_ta_r_flag,
		defp3.multip_v_flag,
		defp3.multip_p_flag,
		defp3.si_i_vol,
		defp3.fr_v,
		defp3.fr_p,
		defp3.d_u_o_m,
		defp3.d_ta_r,
		defp3.rounding,
		defp3.multip_v,
		defp3.multip_p,
		/* Not the most efficient code but hopefully more readable in this form */
		ISNULL(
			(
			/* Find the most recent applicable task rate */
			/* Default to 1.0 if not defined */
			SELECT TOP (1) ta_r.task_rate
				FROM ta_r
				WHERE ta_r.task_ref = item.task_ref
					AND RTRIM(LTRIM(ta_r.contract_ref)) = @contract_ref
					AND ta_r.cont_cycle_no =
						(
						SELECT c_da.cont_cycle_no
							FROM c_da
							WHERE RTRIM(LTRIM(c_da.contract_ref)) = @contract_ref
								AND c_da.period_start <= GETDATE()
								AND c_da.period_finish >= GETDATE()
						)
					AND ta_r.[start_date] <= GETDATE()
					AND ta_r.rate_band_code = 'BUY'
				ORDER BY ta_r.[start_date] DESC
			), 1.0) AS task_rate,
		task.unit_of_meas,
		NULL AS [start_date]
		FROM defp3
		INNER JOIN defp1
		ON defp1.calc_id = defp3.calc_id
			AND RTRIM(LTRIM(defp1.[algorithm])) = @algorithm
			AND RTRIM(LTRIM(defp1.contract_ref)) = @contract_ref
			AND RTRIM(LTRIM(defp1.item_type)) = @item_type
			AND RTRIM(LTRIM(defp1.[priority])) = @priority
			AND defp1.default_level = @level
		INNER JOIN item
		ON RTRIM(LTRIM(item.item_ref)) = @item_ref
			and RTRIM(LTRIM(item.contract_ref)) = @contract_ref
		INNER JOIN task
		ON task.task_ref = item.task_ref

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
