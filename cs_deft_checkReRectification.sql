/*****************************************************************************
** dbo.cs_deft_checkReRectification
** stored procedure
**
** Description
** Check that re-rectification is possible for a specified rectification (default_no)
** Additionally check whether to clear the rectification
**
** Parameters
** @pdefault_no   = default number (in the defi and deft sense, i.e. cust_def_no)
** @pcomplaint_no = complaint reference
**
** Returned
** @possible 1=rerectification possible, otherwise 0
** @message  if @possible = 0 then @message is assigned explanatory text
** @clear    1=clear rectification, otherwise 0
** Return value of 0 (success) or -1 (failure, with exception text)
**
** History
** 24/05/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_deft_checkReRectification', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_deft_checkReRectification;
GO
CREATE PROCEDURE dbo.cs_deft_checkReRectification
	@pdefault_no integer
	,@pcomplaint_no integer
	,@possible bit = 1 OUTPUT
	,@message varchar(100) = '' OUTPUT
	,@clear bit = 0 OUTPUT
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @errortext varchar(500)
		,@errornumber varchar(10)
		,@rowcount integer
		,@site_ref varchar(16)
		,@item_ref varchar(12)
		,@feature_ref varchar(12)
		,@contract_ref varchar(12)
		,@priority varchar(1)
		,@date_due datetime
		,@item_type varchar(6)
		,@default_no integer
		,@complaint_no integer
		,@default_level integer
		,@default_occ integer
		,@action_flag varchar(1)
		,@max_seq_no integer
		,@query_seq_no integer
		,@deft_default_level integer
		,@deft_default_occ integer
		,@deft_action_flag varchar(1)
		,@prev_default_level integer
		,@prev_default_occ integer
		,@prev_deft_action_flag varchar(1)
		,@saved_default_level integer
		,@saved_default_occ integer
		,@algorithm varchar(12)
		,@fault_code varchar(6)
		,@fault_desc varchar(40)
		,@notice_no integer
		,@last_level varchar(1)
		,@max_occ integer
		,@next_action_id integer
		,@algorithmFailed bit
		,@def_name_verb varchar(40)
		,@defaultLevelIncr bit
		,@na_redeft varchar(1)
		,@and_redeft varchar(1)
		,@na_clear varchar(1)
		,@and_clear varchar(1)
		;

	SET @errornumber = '20579';

	SET @default_no = @pdefault_no;
	SET @complaint_no = @pcomplaint_no;

	IF @default_no = 0 OR @default_no IS NULL
	BEGIN
		SET @errornumber = '20580';
		SET @errortext   = 'default_no is required';
		GOTO errorexit;
	END

	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @errornumber = '20581';
		SET @errortext   = 'complaint_no is required';
		GOTO errorexit;
	END

	SELECT @site_ref = site_ref
		,@item_ref = item_ref
		,@feature_ref = feature_ref
		,@contract_ref = contract_ref
		FROM comp
		WHERE complaint_no = @complaint_no;

	SELECT @priority = priority_flag
		,@date_due = date_due
		FROM si_i
		WHERE site_ref       = @site_ref
			AND item_ref     = @item_ref
			AND feature_ref  = @feature_ref
			AND contract_ref = @contract_ref;

	SELECT @item_type = item_type
		FROM item
		WHERE item_ref = @item_ref;

	SET @algorithmFailed  = 0;
	SET @defaultLevelIncr = 0;
	SET @def_name_verb    = dbo.cs_keys_getCField('PDAINI', 'DEF_NAME_VERB');
	SET @possible         = 1;
	SET @clear            = 0;

	/* Get the current state */
	SELECT @default_level = default_level
		,@default_occ = default_occ
		,@action_flag = action_flag
		,@max_seq_no = seq_no
		FROM deft
		WHERE default_no = @default_no
			AND seq_no = 
				(
				SELECT MAX(seq_no)
					FROM deft
					WHERE default_no = @default_no
				);

	/*
	** If not current D=Default or R=Re-Rectification then loop through all transactions
	** to determine the current level and occurrence
	** Given the condition then the last record (max seq_no) will not be D or R
	*/
	SET @query_seq_no = 1;

	IF @action_flag <> 'D' AND @action_flag <> 'R'
	BEGIN
		SET @prev_default_level = 1;
		SET @prev_default_occ   = 1;
		SET @prev_deft_action_flag = '';
		SET @saved_default_level = 1;
		SET @saved_default_occ = 1;

		WHILE @query_seq_no <= @max_seq_no
		BEGIN
			SELECT @deft_default_level = default_level
				,@deft_default_occ = default_occ
				,@deft_action_flag = action_flag
				FROM deft
				WHERE seq_no = @query_seq_no
					AND default_no = @default_no;

			IF @deft_action_flag = 'D' OR @deft_action_flag = 'R'
			BEGIN
				IF @prev_deft_action_flag = 'D' OR @prev_deft_action_flag = 'R'
				BEGIN
					SET @saved_default_level = @prev_default_level;
					SET @saved_default_level = @prev_default_occ;
				END

				SET @prev_default_level    = @deft_default_level;
				SET @prev_default_occ      = @deft_default_occ;
				SET @prev_deft_action_flag = @deft_action_flag;
			END
			ELSE
			BEGIN
				SET @prev_deft_action_flag = @deft_action_flag;
			END

			SET @query_seq_no = @query_seq_no + 1;
		END

		SET @default_level = @saved_default_level;
		SET @default_occ   = @saved_default_occ;
	END

	/* Get algorithm */
	SELECT @algorithm = default_algorithm
		,@fault_code = default_reason
		FROM defi
		WHERE default_no = @default_no;
	IF @@ROWCOUNT = 0
	BEGIN
		SET @algorithmFailed = 1;
	END

	/* Get notice_rep_no */
	SELECT @fault_desc = lookup_text
		,@notice_no = lookup_num
		FROM allk
		WHERE lookup_func = 'DEFRN'
			AND lookup_code = @fault_code;
	IF @@ROWCOUNT = 0
	BEGIN
		SET @algorithmFailed = 1;
	END

	/* Determine new default_level and default_occ */
	SELECT @last_level = last_level
		,@max_occ = max_occ
		,@next_action_id = next_action_id
		FROM defp1
		WHERE [algorithm] = @algorithm
			AND default_level = @default_level
			AND item_type = @item_type
			AND contract_ref = @contract_ref
			AND [priority] = @priority;
	IF @@ROWCOUNT = 0
	BEGIN
		SET @algorithmFailed = 1;
	END

	IF @algorithmFailed = 0
	BEGIN
		IF @last_level <> 'Y' AND @default_occ >= @max_occ
		BEGIN
			SET @defaultLevelIncr = 1;
			SET @default_level    = @default_level + 1;
			SET @default_occ      = @default_occ + 1;
		END
		IF @default_occ < @max_occ
		BEGIN
			SET @default_occ = @default_occ + 1;
		END

		/* Get details for the new @default_level and @default_occ */
		IF @defaultLevelIncr = 1
		BEGIN
			SELECT @last_level = last_level
				,@max_occ = max_occ
				,@next_action_id = next_action_id
				FROM defp1
				WHERE [algorithm] = @algorithm
					AND default_level = @default_level
					AND item_type = @item_type
					AND contract_ref = @contract_ref
					AND [priority] = @priority;
			IF @@ROWCOUNT = 0
			BEGIN
				SET @algorithmFailed = 1;
			END
		END


		IF @algorithmFailed = 0
		BEGIN
			/* Get the next action */
			SELECT @na_redeft = na_redeft
				,@and_redeft = and_redeft
				,@na_clear = na_clear
				,@and_clear = and_clear
				FROM defp2
				WHERE next_action_id = @next_action_id;

			/* Check whether the next action is allowed */
			/* If there is no date due then the next action is allowed */
			IF @date_due IS NOT NULL
			BEGIN
				IF DATEDIFF(day, @date_due, GETDATE()) = 0
				BEGIN
					IF @and_redeft = 'N' AND @and_clear = 'N'
					BEGIN
						SET @algorithmFailed = 1;
					END
				END
				ELSE
				BEGIN
					IF @na_redeft = 'N' AND @na_clear = 'N'
					BEGIN
						SET @algorithmFailed = 1;
					END
				END
			END

			IF @algorithmFailed = 0
			BEGIN
				/* Should the rectification be cleared? */
				IF @na_clear = 'Y' OR @and_clear = 'Y'
				BEGIN
					SET @clear = 1;
				END
			END
		END
	END

	/* Is re-rectification possible? */
	/* Is the next action allowed?   */
	IF @algorithmFailed = 1
	BEGIN
		SET @possible = 0;
		SET @message  = 'Cannot re-' + @def_name_verb + ' this item, the algorithm will not allow it.';
	END

	/* Has the last level been reached? */
	IF @last_level = 'Y' AND @default_level >= @max_occ
	BEGIN
		SET @possible = 0;
		SET @message  = 'Cannot re-' + @def_name_verb + ' this item, it is on the last level.';
	END
	
normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO
