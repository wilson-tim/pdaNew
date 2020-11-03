/*****************************************************************************
** dbo.cs_defp4_getParams
** stored procedure
**
** Description
** Selects a set of defp4 records for a given algorithm, item_ref, contract_ref, 
**   priority, level
**
** Parameters
** @algorithm     = algorithm code
** @item_ref      = item ref
** @contract_ref  = contract reference
** @priority      = priority flag
** @level         = rectification level
**
** Returned
** Result set of defp4 data
** Return value of @@ROWCOUNT or -1
**
** History
** 22/01/2013  TW  New
** 25/01/2013  TW  Changed input parameter @item_type to @item_ref
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_defp4_getParams', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_defp4_getParams;
GO
CREATE PROCEDURE dbo.cs_defp4_getParams
	@algorithm varchar(12),
	@item_ref varchar(12),
	@contract_ref varchar(12),
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

	SELECT defp4.time_delay,
		defp4.report_by_hrs1,
		defp4.report_by_mins1,
		defp4.report_by_hrs2,
		defp4.report_by_mins2,
		defp4.report_by_hrs3,
		defp4.report_by_mins3,
		defp4.correct_by_hrs1,
		defp4.correct_by_mins1,
		defp4.correct_by_hrs2,
		defp4.correct_by_mins2,
		defp4.correct_by_hrs3,
		defp4.correct_by_mins3,
		defp4.working_week,
		defp4.clock_start_hrs,
		defp4.clock_start_mins,
		defp4.clock_stop_hrs,
		defp4.clock_stop_mins,
		defp4.cut_off_hrs,
		defp4.cut_off_mins
		FROM defp4
		INNER JOIN item
		ON RTRIM(LTRIM(item.item_ref)) = @item_ref
			AND RTRIM(LTRIM(item.contract_ref)) = @contract_ref
		WHERE defp4.cb_time_id =
			(
			SELECT defp1.cb_time_id
				FROM defp1
				WHERE RTRIM(LTRIM(defp1.[algorithm])) = @algorithm
					AND RTRIM(LTRIM(defp1.contract_ref)) = @contract_ref
					--AND defp1.item_type = item.item_type
					AND RTRIM(LTRIM(defp1.[priority])) = @priority
					AND defp1.default_level = @level
			);

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
