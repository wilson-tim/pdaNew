/*****************************************************************************
** dbo.cs_defa_getDefaultPointsValue
** stored procedure
**
** Description
** Calculate the default values for rectification points and value for a given volume
** (a value for volume is calculated by cs_defa_getVolume for instance).
** Also calculate the level and occurrence.
** The next action is assumed to be 'R Re-Rectification' and is not calculated/returned.
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
** @level         = rectification level, integer
** @occ           = occurrence number, integer
** @points        = points, decimal(10,2)
** @value         = value, decimal(10,2)
** @cb_time_id    = key to defp4 table
** Return value of 0 (success) or -1 (failure, with exception text)
**
** Notes
** Based on def_pnts.4gl, def_reps.4gl
**
** History
** 29/01/2013  TW  New
** 01/02/2013  TW  Renamed from cs_defa_getDefaultPointsValueDate
** 05/02/2013  TW  Added Wandsworth method for calculating contract value
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_defa_getDefaultPointsValue', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_defa_getDefaultPointsValue;
GO
CREATE PROCEDURE dbo.cs_defa_getDefaultPointsValue
	@site_ref varchar(16),
	@item_ref varchar(12),
	@feature_ref varchar(12),
	@contract_ref varchar(12),
	@priority_flag varchar(1),
	@comp_code varchar(6),
	@algorithm varchar(12),
	@volume decimal(10,2) = 1,
	@level integer = 0 OUTPUT,
	@occ integer = 0 OUTPUT,
	@points decimal(10,2) = 0 OUTPUT,
	@value decimal(10,2) = 0 OUTPUT,
	@cb_time_id integer = NULL OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
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
		@new_cdatetime datetime,
		@level_original integer,
		@level_changed integer,
		@an_val_def_alg char(1),
		@start_date datetime;

	SET @errornumber = '12000';
	SET @site_ref = LTRIM(RTRIM(@site_ref));
	SET @item_ref = LTRIM(RTRIM(@item_ref));
	SET @feature_ref = LTRIM(RTRIM(@feature_ref));
	SET @contract_ref = LTRIM(RTRIM(@contract_ref));
	SET @priority_flag = LTRIM(RTRIM(@priority_flag));
	SET @comp_code = LTRIM(RTRIM(@comp_code));
	SET @algorithm = LTRIM(RTRIM(@algorithm));
	SET @points = 0;
	SET @value = 0;

	IF @site_ref = '' OR @site_ref IS NULL
	BEGIN
		SET @errornumber = '12001';
		SET @errortext = 'site_ref is required';
		GOTO errorexit;
	END

	IF @item_ref = '' OR @item_ref IS NULL
	BEGIN
		SET @errornumber = '12002';
		SET @errortext = 'item_ref is required';
		GOTO errorexit;
	END

	IF @feature_ref = '' OR @feature_ref IS NULL
	BEGIN
		SET @errornumber = '12003';
		SET @errortext = 'feature_ref is required';
		GOTO errorexit;
	END

	IF @contract_ref = '' OR @contract_ref IS NULL
	BEGIN
		SET @errornumber = '12004';
		SET @errortext = 'contract_ref is required';
		GOTO errorexit;
	END

	IF @priority_flag = '' OR @priority_flag IS NULL
	BEGIN
		SET @errornumber = '12005';
		SET @errortext = 'priority_flag is required';
		GOTO errorexit;
	END

	IF @comp_code = '' OR @comp_code IS NULL
	BEGIN
		SET @errornumber = '12006';
		SET @errortext = 'comp_code is required';
		GOTO errorexit;
	END

	IF @algorithm = '' OR @algorithm IS NULL
	BEGIN
		SET @errornumber = '12007';
		SET @errortext = 'algorithm is required';
		GOTO errorexit;
	END

	IF @volume IS NULL
	BEGIN
		SET @errornumber = '12008';
		SET @errortext = 'volume is required';
		GOTO errorexit;
	END

	IF @level IS NULL
	BEGIN
		SET @errornumber = '12009';
		SET @errortext = 'level is required';
		GOTO errorexit;
	END

	IF @occ IS NULL
	BEGIN
		SET @errornumber = '12010';
		SET @errortext = 'occ is required';
		GOTO errorexit;
	END

	SET @level_original = @level;
	SET @level_changed = 0;

get_hdr1:
	IF @level = 0
	BEGIN
		SET @level = 1;
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
		WHERE [algorithm] = @algorithm
			AND default_level = @level
			AND [priority] = @priority_flag
			AND contract_ref = @contract_ref
			AND item_type IN
				(
				SELECT item_type
					FROM item
					WHERE item_ref = @item_ref
						AND contract_ref = @contract_ref
				);

	IF @@ROWCOUNT <> 1
	BEGIN
		SET @errornumber = '12011';
		SET @errortext = 'defp1 record not found';
		GOTO errorexit;
	END

	SET @cb_time_id = @defp1cb_time_id;

	SET @level = @level_original;

	IF @defp1monthly = 'Y'
	BEGIN
		SELECT @defcount = COUNT(*)
			FROM defi, defh
			WHERE defi.default_algorithm = @algorithm
				AND defi.default_no = defh.cust_def_no
				AND (defh.[start_date] >= DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0) AND defh.[start_date] < DATEADD(month, DATEDIFF(month, 0, GETDATE()) + 1, 0))
				AND (defh.[start_date] >= DATEADD(year, DATEDIFF(year, 0, GETDATE()), 0) AND defh.[start_date] < DATEADD(year, DATEDIFF(year, 0, GETDATE()) + 1, 0));

		IF @defcount >= @defp1max_occ
		BEGIN
			SET @level = @level + 1;
			SET @occ = 0; 
			SET @level_original = @level;
			SET @level_changed = 1;
		END
	END
	ELSE
	BEGIN
		IF @occ >= @defp1max_occ
		BEGIN
			SET @level = @level + 1;
			SET @occ = 0; 
			SET @level_original = @level;
			SET @level_changed = 1;
		END
	END

get_hdr2:
	IF @level_changed = 1
	BEGIN
		/* Level has been changed, re-read defp1 parameters */
		IF @level = 0
		BEGIN
			SET @level = 1;
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
			WHERE [algorithm] = @algorithm
				AND default_level = @level
				AND [priority] = @priority_flag
				AND contract_ref = @contract_ref
				AND item_type IN
					(
					SELECT item_type
						FROM item
						WHERE item_ref = @item_ref
							AND contract_ref = @contract_ref
					);

		IF @@ROWCOUNT <> 1
		BEGIN
		SET @errornumber = '12012';
			SET @errortext = 'defp1 record not found (level_changed)';
			GOTO errorexit;
		END

		SET @cb_time_id = @defp1cb_time_id;

		SET @level = @level_original;
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
		WHERE si_i.item_ref = @item_ref
			AND si_i.feature_ref = @feature_ref
			AND si_i.contract_ref = @contract_ref
			AND si_i.site_ref = @site_ref
			AND (si_i.date_due >= DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0)
				AND si_i.date_due < DATEADD(day, DATEDIFF(day, 0, GETDATE()) + 1, 0));

	SET @algignoredatedue = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'ALG_IGNORE_DATE_DUE'))));

	IF @siicount = 1 AND @algignoredatedue = 'N'
	BEGIN
		/*
		** Today is the due date per the site item record (as updated by the 'overnight process')
		** and the system is parameterised to take account of this
		*/
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
			/* Rectify */
			IF @defp1last_level = 'N'
				OR @defp1last_level = ''
				OR @defp1last_level IS NULL
			BEGIN
				/* Move on to next level */
				SET @level = @level + 1;
				SET @occ = 1; 
			END
			ELSE
			BEGIN
				/* Already on last level */
				SET @occ = @occ + 1; 
			END

			/* get_p_v */
			BEGIN TRY
				EXECUTE dbo.cs_defa_getPV
					@site_ref,
					@item_ref,
					@feature_ref,
					@contract_ref,
					@defp1calc_id,
					@volume,
					@points OUTPUT,
					@value OUTPUT;
			END TRY
			BEGIN CATCH
				SET @errornumber = '20608';
				SET @errortext = ERROR_MESSAGE();
				GOTO errorexit;
			END CATCH
		END

		IF @defp2and_redeft = 'Y'
		BEGIN
			/* Re-rectify on current level */
			SET @occ = @occ + 1; 

			/* get_p_v */
			BEGIN TRY
				EXECUTE dbo.cs_defa_getPV
					@site_ref,
					@item_ref,
					@feature_ref,
					@contract_ref,
					@defp1calc_id,
					@volume,
					@points OUTPUT,
					@value OUTPUT;
			END TRY
			BEGIN CATCH
				SET @errornumber = '20609';
				SET @errortext = ERROR_MESSAGE();
				GOTO errorexit;
			END CATCH
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
			/* Rectify */
			IF @defp1last_level = 'N'
				OR @defp1last_level = ''
				OR @defp1last_level IS NULL
			BEGIN
				/* Move on to next level */
				SET @level = @level + 1;
				SET @occ = 1; 
			END
			ELSE
			BEGIN
				/* Already on last level */
				SET @occ = @occ + 1; 
			END

			/* get_p_v */
			BEGIN TRY
				EXECUTE dbo.cs_defa_getPV
					@site_ref,
					@item_ref,
					@feature_ref,
					@contract_ref,
					@defp1calc_id,
					@volume,
					@points OUTPUT,
					@value OUTPUT;
			END TRY
			BEGIN CATCH
				SET @errornumber = '20610';
				SET @errortext = ERROR_MESSAGE();
				GOTO errorexit;
			END CATCH
		END

		IF @defp2na_redeft = 'Y'
		BEGIN
			/* Re-rectify on current level */
			SET @occ = @occ + 1;

			/* get_p_v */
			BEGIN TRY
				EXECUTE dbo.cs_defa_getPV
					@site_ref,
					@item_ref,
					@feature_ref,
					@contract_ref,
					@defp1calc_id,
					@volume,
					@points OUTPUT,
					@value OUTPUT;
			END TRY
			BEGIN CATCH
				SET @errornumber = '20611';
				SET @errortext = ERROR_MESSAGE();
				GOTO errorexit;
			END CATCH
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

	/* Wandsworth method for calculating contract value */
	SET @an_val_def_alg = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'AN_VAL_DEF_ALG'))));
	IF @an_val_def_alg = 'Y'
	BEGIN
		SET @start_date = GETDATE();
		EXECUTE dbo.cs_sitemark_getContractValue @site_ref, @contract_ref, @start_date, @value OUTPUT;
	END

	IF @points IS NULL
	BEGIN
		SET @errornumber = '20596';
		SET @errortext = 'Problem with algorithm calculation (points)';
		GOTO errorexit;
	END

	IF @value IS NULL
	BEGIN
		SET @errornumber = '20597';
		SET @errortext = 'Problem with algorithm calculation (value)';
		GOTO errorexit;
	END

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
