/*****************************************************************************
** dbo.cs_defa_getAlgorithms
** stored procedure
**
** Description
** Selects a set of defa records for given
**   item_type, contract_ref, priority_flag [all from cs_sii_getItems], comp_code [from cs_pdalookup_getFaultCodes]
**
** Parameters
** @item_ref      = item reference
** @contract_ref  = contract reference
** @priority_flag = priority flag
** @comp_code     = fault code
** @level         = rectification level
**
** Returned
** Result set of defa data
** Return value of @@ROWCOUNT or -1
**
** History
** 22/01/2013  TW  New
** 24/01/2013  TW  Revised
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_defa_getAlgorithms', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_defa_getAlgorithms;
GO
CREATE PROCEDURE dbo.cs_defa_getAlgorithms
	@item_ref varchar(12),
	@contract_ref varchar(12),
	@priority_flag varchar(1),
	@comp_code varchar(6),
	@level integer
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer;

	SET @errornumber = '11800';
	SET @item_ref = LTRIM(RTRIM(@item_ref));
	SET @contract_ref = LTRIM(RTRIM(@contract_ref));
	SET @priority_flag = LTRIM(RTRIM(@priority_flag));
	SET @comp_code = LTRIM(RTRIM(@comp_code));

	IF @item_ref = '' OR @item_ref IS NULL
	BEGIN
		SET @errornumber = '11801';
		SET @errortext = 'item_ref is required';
		GOTO errorexit;
	END

	IF @contract_ref = '' OR @contract_ref IS NULL
	BEGIN
		SET @errornumber = '11802';
		SET @errortext = 'contract_ref is required';
		GOTO errorexit;
	END

	IF @priority_flag = '' OR @priority_flag IS NULL
	BEGIN
		SET @errornumber = '11803';
		SET @errortext = 'priority_flag is required';
		GOTO errorexit;
	END

	IF @comp_code = '' OR @comp_code IS NULL
	BEGIN
		SET @errornumber = '11804';
		SET @errortext = 'comp_code is required';
		GOTO errorexit;
	END

	IF @level IS NULL
	BEGIN
		SET @errornumber = '11805';
		SET @errortext = 'level is required';
		GOTO errorexit;
	END

	IF @level = 0
	BEGIN
		SET @level = 1;
	END

	SELECT defa.item_type,
		defa.notice_rep_no,
		defa.default_algorithm,
		defa.change_alg_yn,
		defa.prompt_for_points,
		defa.prompt_for_value,
		defa.prompt_for_rectify,
		defp1.[algorithm],
		defp1.algorithm_desc,
		defp1.contract_ref,
		/* defp1.item_type, */
		defp1.[priority],
		defp1.max_occ,
		defp1.last_level,
		defp1.monthly,
		defp1.default_level,
		/* defp1.notice_ref, */
		defp1.next_action_id,
		defp1.calc_id,
		defp1.cb_time_id,
		/* pda_algorithm.[algorithm], */
		/* pda_algorithm.contract_ref, */
		/* pda_algorithm.item_type, */
		/* pda_algorithm.[priority], */
		/* pda_algorithm.notice_ref, */
		pda_algorithm.user_desc,
		pda_algorithm.display_order,
		allk.lookup_func,
		allk.lookup_code,
		allk.lookup_text,
		allk.lookup_num,
		allk.service_c,
		allk.status_yn
		FROM defa
		INNER JOIN defp1
		ON defp1.[algorithm] = defa.default_algorithm
		INNER JOIN pda_algorithm
		ON pda_algorithm.[algorithm] = defa.default_algorithm
		/* The inner join on allk ensures that the fault code is 'rectifiable' */
		INNER JOIN allk
		ON allk.lookup_func = 'DEFRN'
			AND allk.lookup_code = @comp_code
			AND allk.status_yn = 'Y'
		INNER JOIN item
		ON item.item_ref = @item_ref
			AND item.contract_ref = @contract_ref
		WHERE defa.item_type = item.item_type
			AND defa.notice_rep_no = allk.lookup_num
			AND defp1.default_level = @level
			AND defp1.item_type = item.item_type
			AND defp1.contract_ref = @contract_ref
			AND defp1.[priority] = @priority_flag
			AND pda_algorithm.item_type = item.item_type
			AND pda_algorithm.contract_ref = @contract_ref
			AND pda_algorithm.[priority] = @priority_flag
		ORDER BY pda_algorithm.display_order,
			pda_algorithm.user_desc;

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
