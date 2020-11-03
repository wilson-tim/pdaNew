/*****************************************************************************
** dbo.cs_defa_getDefaultPointsValueDate
** stored procedure
**
** Description
** Get the default values for rectification points, value and completion date/time
** (the default value for volume is obtained by cs_defa_getVolume).
** Also calculate the level and occurrence.
** The next action is assumed to be 'R Re-Rectification' and not calculated/returned.
**
** Parameters
** @site_ref      = site reference
** @item_ref      = item reference
** @feature_ref   = feature reference
** @contract_ref  = contract reference
** @priority_flag = priority flag
** @comp_code     = fault code
** @algorithm     = algorithm
** @volume        = volume
**
** Returned
** @level         = rectification level
** @occ           = occurrence number
** @points        = points, decimal(10,2)
** @value         = value, decimal(10,2)
** @cdatetime     = completion date and time
** Return value of 0 (success) or -1 (failure, with exception text)
**
** Notes
** Based on def_pnts.4gl, def_reps.4gl
**
** History
** 29/01/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_defa_getDefaultPointsValueDate', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_defa_getDefaultPointsValueDate;
GO
CREATE PROCEDURE dbo.cs_defa_getDefaultPointsValueDate
	@site_ref varchar(16),
	@item_ref varchar(12),
	@feature_ref varchar(12),
	@contract_ref varchar(12),
	@priority_flag varchar(1),
	@comp_code varchar(6),
	@algorithm varchar(12),
	@volume decimal(10,2),
	@level integer = 1 OUTPUT,
	@occ integer = 1 OUTPUT,
	@points decimal(10,2) = 0 OUTPUT,
	@value decimal(10,2) = 0 OUTPUT,
	@cdatetime datetime = NULL OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(100),
		@defp1algorithm varchar(12),
		@defp1algorithm_desc varchar(40),
		@defp1contract_ref varchar(12),
		@defp1item_type varchar(6),
		@defp1priority varchar(1),
		@defp1max_occ integer,
		@defp1last_level varchar(1),
		@defp1monthly varchar(1),
		@defp1default_level integer,
		@defp1notice_ref varchar(12),
		@defp1next_action_id integer,
		@defp1calc_id integer,
		@defp1cb_time_id integer,
		@defcount integer,
		@month integer,
		@defp2next_action_id integer,
		@defp2na_clear char(1),
		@defp2na_default char(1),
		@defp2na_redeft char(1),
		@defp2and_clear char(1),
		@defp2and_default char(1),
		@defp2and_redeft char(1),
		@siicount integer,
		@algignoredatedue char(1),
		@defshappeningflag char(1),
		@defpaction_next_ddate char(1),
		@item_status char(1),
		@checkworkingweek char(7),
		@new_cdatetime datetime;

	SET @site_ref = RTRIM(LTRIM(@site_ref));
	SET @item_ref = RTRIM(LTRIM(@item_ref));
	SET @feature_ref = RTRIM(LTRIM(@feature_ref));
	SET @contract_ref = RTRIM(LTRIM(@contract_ref));
	SET @priority_flag = RTRIM(LTRIM(@priority_flag));
	SET @comp_code = RTRIM(LTRIM(@comp_code));
	SET @algorithm = RTRIM(LTRIM(@algorithm));

	IF @site_ref = '' OR @site_ref IS NULL
	BEGIN
		SET @errortext = 'site_ref is required';
		GOTO errorexit;
	END

	IF @item_ref = '' OR @item_ref IS NULL
	BEGIN
		SET @errortext = 'item_ref is required';
		GOTO errorexit;
	END

	IF @feature_ref = '' OR @feature_ref IS NULL
	BEGIN
		SET @errortext = 'feature_ref is required';
		GOTO errorexit;
	END

	IF @contract_ref = '' OR @contract_ref IS NULL
	BEGIN
		SET @errortext = 'contract_ref is required';
		GOTO errorexit;
	END

	IF @priority_flag = '' OR @priority_flag IS NULL
	BEGIN
		SET @errortext = 'priority_flag is required';
		GOTO errorexit;
	END

	IF @comp_code = '' OR @comp_code IS NULL
	BEGIN
		SET @errortext = 'comp_code is required';
		GOTO errorexit;
	END

	IF @algorithm = '' OR @algorithm IS NULL
	BEGIN
		SET @errortext = 'algorithm is required';
		GOTO errorexit;
	END

	IF @volume IS NULL
	BEGIN
		SET @errortext = 'volume is required';
		GOTO errorexit;
	END

	IF @level IS NULL
	BEGIN
		SET @errortext = 'level is required';
		GOTO errorexit;
	END

	IF @occ IS NULL
	BEGIN
		SET @errortext = 'occ is required';
		GOTO errorexit;
	END

get_hdr:
	IF @level = 0
	BEGIN
		SET @level = 1;
	END

	IF @algorithm = '' OR @algorithm IS NULL
	BEGIN
		SET @errortext = 'algorithm is required';
		GOTO errorexit;
	END

	SELECT @defp1algorithm = [algorithm],
		@defp1algorithm_desc = algorithm_desc,
		@defp1contract_ref = contract_ref,
		@defp1item_type = item_type,
		@defp1priority = [priority],
		@defp1max_occ = max_occ,
		@defp1last_level = last_level,
		@defp1monthly = monthly,
		@defp1default_level = default_level,
		@defp1notice_ref = notice_ref,
		@defp1next_action_id = next_action_id,
		@defp1calc_id = calc_id,
		@defp1cb_time_id = cb_time_id
		FROM defp1
		WHERE RTRIM(LTRIM([algorithm])) = @algorithm
			AND default_level = @level
			AND RTRIM(LTRIM([priority])) = @priority_flag
			AND RTRIM(LTRIM(contract_ref)) = @contract_ref
			AND RTRIM(LTRIM(item_type)) IN
				(
				SELECT item_type
					FROM item
					WHERE RTRIM(LTRIM(item_ref)) = @item_ref
						AND RTRIM(LTRIM(contract_ref)) = @contract_ref
				);

	IF @@ROWCOUNT <> 1
	BEGIN
		SET @errortext = 'defp1 record not found';
		GOTO errorexit;
	END

	/* Assign @cdatetime to today */
	IF @cdatetime IS NULL
	BEGIN
		SET @cdatetime = GETDATE();
	END

	/* Validate working week pattern (will be required later by cs_utils_checkWorkingDay) */
	SELECT @checkworkingweek = working_week
		FROM defp4
		WHERE cb_time_id = @defp1cb_time_id;

	IF @checkworkingweek = '' OR @checkworkingweek IS NULL
	BEGIN
		SELECT @checkworkingweek = work_week
			FROM ww, item, fr_i, pa_i
			WHERE RTRIM(LTRIM(item.item_ref)) = @item_ref
				AND RTRIM(LTRIM(item.contract_ref)) = @contract_ref
				AND item.pattern_code = fr_i.freq_ref
				AND fr_i.date_ref = pa_i.pattern_code
				AND pa_i.[start_date] <= @cdatetime
				AND pa_i.finish_date >= @cdatetime
				AND ww.ww_type = fr_i.ww_type;
	END

	/* Check that @checkworkingweek exists */
	IF @checkworkingweek = '' OR @checkworkingweek IS NULL
	BEGIN
		SET @errortext = 'Unable to locate working week for item ' + @item_ref + ' contract ' + @contract_ref + ' date ' + LTRIM(RTRIM(CONVERT(varchar(10), @cdatetime, 103)));
		GOTO errorexit;
	END

	/* Check for @checkworkingweek having no working days */
	IF @checkworkingweek = 'NNNNNNN'
	BEGIN
		SET @errortext = 'There are no working days defined in working week NNNNNNN';
		GOTO errorexit;
	END

	/* Check for @checkworkingweek having incorrect characters */
	IF LEN(REPLACE(REPLACE(@checkworkingweek, 'Y', ''), 'N', '')) <> 0
	BEGIN
		SET @errortext = 'Working week ' + @checkworkingweek + ' is not valid';
		GOTO errorexit;
	END

	/* Check for @checkworkingweek being incorrect length */
	IF LEN(@checkworkingweek) <> 7
	BEGIN
		SET @errortext = 'Working week ' + @checkworkingweek + ' is not valid';
		GOTO errorexit;
	END

	IF @defp1monthly = 'Y'
	BEGIN
		SET @month = MONTH(GETDATE());

		SELECT @defcount = COUNT(*)
			FROM defi, defh
			WHERE RTRIM(LTRIM(defi.default_algorithm)) = @algorithm
				AND defi.default_no = defh.cust_def_no
				AND MONTH(defh.[start_date]) = @month;

		IF @defcount >= @defp1max_occ
		BEGIN
			SET @level = @level + 1;
			SET @occ   = 0; 
		END
	END
	ELSE
	BEGIN
		IF @occ >= @defp1max_occ
		BEGIN
			SET @level = @level + 1;
			SET @occ   = 0; 
		END
	END

get_dtl_na:
	SELECT @defp2next_action_id = next_action_id,
		@defp2na_clear = na_clear,
		@defp2na_default = na_default,
		@defp2na_redeft = na_redeft,
		@defp2and_clear = and_clear,
		@defp2and_default = and_default,
		@defp2and_redeft = and_redeft		
		FROM defp2
		WHERE defp2.next_action_id = @defp1next_action_id;

analyse_def_alg:
	SELECT @siicount = COUNT(*)
		FROM si_i
		WHERE RTRIM(LTRIM(si_i.item_ref)) = @item_ref
			AND RTRIM(LTRIM(si_i.feature_ref)) = @feature_ref
			AND RTRIM(LTRIM(si_i.contract_ref)) = @contract_ref
			AND RTRIM(LTRIM(si_i.site_ref)) = @site_ref
			AND si_i.date_due = GETDATE();

	SET @algignoredatedue = UPPER(RTRIM(LTRIM(dbo.cs_keys_getCField('ALL', 'ALG_IGNORE_DATE_DUE'))));

	IF @siicount = 1 AND @algignoredatedue = 'N'
	BEGIN
		/* whats_happening_to_date_due */
		/*
		** Bob says that system key DEFS_HAPPENING FLAG should be ignored
		** and that next action should be set to 'R Re-default' in all cases
		*/
		SET @defpaction_next_ddate = 'R';

		SET @defp2and_clear = 'N';

		SET @item_status = 'Y';

		IF @defp2and_default = 'Y'
		BEGIN
			IF @defp1last_level = 'N'
				OR @defp1last_level = ''
				OR @defp1last_level IS NULL
			BEGIN
				SET @level = @level + 1;
				SET @occ   = 1; 
			END
			ELSE
			BEGIN
				SET @occ   = @occ + 1; 
			END

			/* get_p_v */
			EXECUTE dbo.cs_defa_getPV
				@site_ref,
				@item_ref,
				@feature_ref,
				@contract_ref,
				@defp1calc_id,
				@volume,
				@points OUTPUT,
				@value OUTPUT;
		END

		IF @defp2and_redeft = 'Y'
		BEGIN
			SET @occ   = @occ + 1; 

			/* get_p_v */
			EXECUTE dbo.cs_defa_getPV
				@site_ref,
				@item_ref,
				@feature_ref,
				@contract_ref,
				@defp1calc_id,
				@volume,
				@points OUTPUT,
				@value OUTPUT;
		END
	END
	ELSE
	BEGIN
		IF @defp2na_clear = 'Y'
		BEGIN
			SET @item_status = 'N';
		END
		ELSE
		BEGIN
			SET @item_status = 'Y';
		END

		IF @defp2na_default = 'Y'
		BEGIN
			IF @defp1last_level = 'N'
				OR @defp1last_level = ''
				OR @defp1last_level IS NULL
			BEGIN
				SET @level = @level + 1;
				SET @occ   = 1; 
			END
			ELSE
			BEGIN
				SET @occ   = @occ + 1; 
			END

			/* get_p_v */
			EXECUTE dbo.cs_defa_getPV
				@site_ref,
				@item_ref,
				@feature_ref,
				@contract_ref,
				@defp1calc_id,
				@volume,
				@points OUTPUT,
				@value OUTPUT;
		END

		IF @defp2na_redeft = 'Y'
		BEGIN
			SET @occ   = @occ + 1; 

			/* get_p_v */
			EXECUTE dbo.cs_defa_getPV
				@site_ref,
				@item_ref,
				@feature_ref,
				@contract_ref,
				@defp1calc_id,
				@volume,
				@points OUTPUT,
				@value OUTPUT;
		END
	END

	IF @level = 0
	BEGIN
		SET @level = 1;
	END

	IF @item_status = 'N'
	BEGIN
		SET @level = 0;
		SET @occ = 0;
	END

	/* get_correct_by_dates */
	EXECUTE dbo.cs_defa_getCorrectByDates
		@defp1cb_time_id,
		@item_ref,
		@contract_ref,
		@cdatetime,
		@new_cdatetime OUTPUT;

	SET @cdatetime = @new_cdatetime;

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
