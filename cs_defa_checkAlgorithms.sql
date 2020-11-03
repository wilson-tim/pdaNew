/*****************************************************************************
** dbo.cs_defa_checkAlgorithms
** stored procedure
**
** Description
** Checks whether the prerequisites for creating a rectification are satisfied
**
** Parameters
** @site_ref      = site reference
** @item_ref      = item reference
** @feature_ref   = feature reference
** @contract_ref  = contract reference
** @priority_flag = priority flag
** @comp_code     = fault code
** @level         = rectification level
**
** Returned
** Return value of 0 (success) or -1 (failure, with exception text)
**
** History
** 24/01/2013  TW  New
** 04/02/2013  TW  Take account of DEF_CHECK_WHOLE_VOL system key
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_defa_checkAlgorithms', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_defa_checkAlgorithms;
GO
CREATE PROCEDURE dbo.cs_defa_checkAlgorithms
	@site_ref varchar(16),
	@item_ref varchar(12),
	@feature_ref varchar(12),
	@contract_ref varchar(12),
	@priority_flag varchar(1),
	@comp_code varchar(6),
	@level integer
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer,
		@status varchar(1),
		@item_type varchar(6),
		@sii_volume decimal (10,2),
		@defi_volume decimal (10,2),
		@def_check_whole_vol char(1);

	SET @errornumber = '11700';
	SET @site_ref = LTRIM(RTRIM(@site_ref));
	SET @item_ref = LTRIM(RTRIM(@item_ref));
	SET @contract_ref = LTRIM(RTRIM(@contract_ref));
	SET @feature_ref = LTRIM(RTRIM(@feature_ref));
	SET @priority_flag = LTRIM(RTRIM(@priority_flag));
	SET @comp_code = LTRIM(RTRIM(@comp_code));

	IF @site_ref = '' OR @site_ref IS NULL
	BEGIN
		SET @errornumber = '11701';
		SET @errortext = 'site_ref is required';
		GOTO errorexit;
	END

	IF @item_ref = '' OR @item_ref IS NULL
	BEGIN
		SET @errornumber = '11702';
		SET @errortext = 'item_ref is required';
		GOTO errorexit;
	END

	IF @feature_ref = '' OR @feature_ref IS NULL
	BEGIN
		SET @errornumber = '11703';
		SET @errortext = 'feature_ref is required';
		GOTO errorexit;
	END

	IF @contract_ref = '' OR @contract_ref IS NULL
	BEGIN
		SET @errornumber = '11704';
		SET @errortext = 'contract_ref is required';
		GOTO errorexit;
	END

	IF @priority_flag = '' OR @priority_flag IS NULL
	BEGIN
		SET @errornumber = '11705';
		SET @errortext = 'priority_flag is required';
		GOTO errorexit;
	END

	IF @comp_code = '' OR @comp_code IS NULL
	BEGIN
		SET @errornumber = '11706';
		SET @errortext = 'comp_code is required';
		GOTO errorexit;
	END

	IF @level IS NULL
	BEGIN
		SET @errornumber = '11707';
		SET @errortext = 'level is required';
		GOTO errorexit;
	END

	/* Validate rectification reason */
	SELECT @status = UPPER(LTRIM(RTRIM(status_yn)))
		FROM allk
		WHERE lookup_code = @comp_code
			AND lookup_func = 'DEFRN';

	IF @status <> 'Y'
	BEGIN
		IF @status = 'N'		
		BEGIN
			SET @errornumber = '11708';
			SET @errortext = 'The rectification reason ' + @comp_code + ' exists but has been disabled';
			GOTO errorexit;
		END
		ELSE
		BEGIN
			SET @errornumber = '11709';
			SET @errortext = 'The rectification reason ' + @comp_code + ' does not exist';
			GOTO errorexit;
		END
	END

	/* Validate item type */
	SELECT @item_type = LTRIM(RTRIM(item_type))
		FROM item
		WHERE LTRIM(RTRIM(item_ref)) = @item_ref
			AND LTRIM(RTRIM(contract_ref)) = @contract_ref;

	IF @@ROWCOUNT < 1
	BEGIN
		SET @errornumber = '11710';
		SET @errortext = 'The item type for item ' + @item_ref + ' and contract ' + @contract_ref + ' is not valid';
		GOTO errorexit;
	END

	/* Validate volume */
	SET @def_check_whole_vol = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'DEF_CHECK_WHOLE_VOL'))));
	IF @def_check_whole_vol = 'Y'
	BEGIN
		SELECT @sii_volume = volume
			FROM si_i
			WHERE LTRIM(RTRIM(site_ref)) = @site_ref
				AND LTRIM(RTRIM(item_ref)) = @item_ref
				AND LTRIM(RTRIM(feature_ref)) = @feature_ref
				AND LTRIM(RTRIM(contract_ref)) = @contract_ref;

		IF @@ROWCOUNT <> 1
		BEGIN
			SET @sii_volume = 0;
		END

		IF @sii_volume > 0 AND @sii_volume IS NOT NULL
		BEGIN
			/* Continue checking if @sii_volume is not zero */
			SELECT @defi_volume = SUM(defi.volume)
				FROM defi
				INNER JOIN defh
				ON defh.cust_def_no = defi.default_no
					AND defh.site_ref = @site_ref
					AND defh.contract_ref = @contract_ref
				WHERE defi.item_ref = @item_ref
					AND defi.feature_ref = @feature_ref
					AND defi.item_status = 'Y';

			IF @defi_volume = @sii_volume
			BEGIN
				SET @errornumber = '11711';
				SET @errortext = 'The whole volume has already been progressed to rectification for the selected site item';
				GOTO errorexit;
			END
		END
	END

	/* Check for algorithm records */
	IF @level = 0
	BEGIN
		SET @level = 1;
	END

	SELECT @rowcount = COUNT(*)
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
		WHERE defa.item_type = @item_type
			AND defa.notice_rep_no = allk.lookup_num
			AND defp1.default_level = @level
			AND defp1.item_type = @item_type
			AND defp1.contract_ref = @contract_ref
			AND defp1.[priority] = @priority_flag
			AND pda_algorithm.item_type = @item_type
			AND pda_algorithm.contract_ref = @contract_ref
			AND pda_algorithm.[priority] = @priority_flag;

	/* No algorithms found */
	IF @rowcount < 1
	BEGIN
		SET @errornumber = '11712';
		SET @errortext = 'No algorithms exist for item ' + @item_ref;
		GOTO errorexit;
	END

	/* Multiple algorithms found */
	/*
		It used to be the case that multiple algorithms were only permitted
		if the item_type began with 'MULTI'. Now however multiple algorithms
		for any item_type trigger the display of a popup selection of algorithms
		for the user to select one before processing can continue.
		(DEFS\def_pnts.4gl, function get_def_alg)
	*/

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
