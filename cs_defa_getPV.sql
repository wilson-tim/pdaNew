/*****************************************************************************
** dbo.cs_defa_getPV
** stored procedure
**
** Description
** Supporting stored procedure for cs_defa_getDefaultPointsValue
**
** Parameters
** @site_ref      = site reference
** @item_ref      = item reference
** @feature_ref   = feature reference
** @contract_ref  = contract reference
** @volume        = volume
**
** Returned
** @points        = points, decimal(10,2)
** @value         = value, decimal(10,2)
** Return value of 0 (success) or -1 (failure, with exception text)
**
** Notes
** Based on def_pnts.4gl
**
** History
** 29/01/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_defa_getPV', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_defa_getPV;
GO
CREATE PROCEDURE dbo.cs_defa_getPV
	@site_ref varchar(16),
	@item_ref varchar(12),
	@feature_ref varchar(12),
	@contract_ref varchar(12),
	@calc_id integer,
	@volume decimal(10,2),
	@points decimal(10,2) = 0 OUTPUT,
	@value decimal(10,2) = 0 OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer,
		@defp3calc_id integer,
		@defp3std_cv char(1),
		@defp3std_pnts char(1),
		@defp3std_val char(1),
		@defp3fr_v_flag char(1),
		@defp3fr_p_flag char(1),
		@defp3d_u_o_m_flag char(1),
		@defp3d_ta_r_flag char(1),
		@defp3multip_v_flag char(1),
		@defp3multip_p_flag char(1),
		@defp3si_i_vol char(1),
		@defp3fr_v decimal(16,4),
		@defp3fr_p decimal(16,4),
		@defp3d_u_o_m decimal(16,4),
		@defp3d_ta_r decimal(16,4),
		@defp3rounding char(1),
		@defp3multip_v decimal(16,4),
		@defp3multip_p decimal(16,4),
		@task_ref varchar(12),
		@duom decimal(16,4),
		@maxstartdate datetime,
		@task_rate decimal(16,8);

	SET @errornumber = '12200';
	SET @site_ref = LTRIM(RTRIM(@site_ref));
	SET @item_ref = LTRIM(RTRIM(@item_ref));
	SET @feature_ref = LTRIM(RTRIM(@feature_ref));
	SET @contract_ref = LTRIM(RTRIM(@contract_ref));

	IF @site_ref = '' OR @site_ref IS NULL
	BEGIN
		SET @errornumber = '12201';
		SET @errortext = 'site_ref is required';
		GOTO errorexit;
	END

	IF @item_ref = '' OR @item_ref IS NULL
	BEGIN
		SET @errornumber = '12202';
		SET @errortext = 'item_ref is required';
		GOTO errorexit;
	END

	IF @feature_ref = '' OR @feature_ref IS NULL
	BEGIN
		SET @errornumber = '12203';
		SET @errortext = 'feature_ref is required';
		GOTO errorexit;
	END

	IF @contract_ref = '' OR @contract_ref IS NULL
	BEGIN
		SET @errornumber = '12204';
		SET @errortext = 'contract_ref is required';
		GOTO errorexit;
	END

	IF @calc_id IS NULL
	BEGIN
		SET @errornumber = '12205';
		SET @errortext = 'calc_id is required';
		GOTO errorexit;
	END

	IF @volume IS NULL
	BEGIN
		SET @errornumber = '12206';
		SET @errortext = 'volume is required';
		GOTO errorexit;
	END

get_dtl_ca:
	SELECT @defp3calc_id = calc_id,
		@defp3std_cv = std_cv,
		@defp3std_pnts = std_pnts,
		@defp3std_val = std_val,
		@defp3fr_v_flag = fr_v_flag,
		@defp3fr_p_flag = fr_p_flag,
		@defp3d_u_o_m_flag = d_u_o_m_flag,
		@defp3d_ta_r_flag = d_ta_r_flag,
		@defp3multip_v_flag = multip_v_flag,
		@defp3multip_p_flag = multip_p_flag,
		@defp3si_i_vol = si_i_vol,
		@defp3fr_v = fr_v,
		@defp3fr_p = fr_p,
		@defp3d_u_o_m = d_u_o_m,
		@defp3d_ta_r = d_ta_r,
		@defp3rounding = rounding,
		@defp3multip_v = multip_v,
		@defp3multip_p = multip_p
		FROM defp3
		WHERE defp3.calc_id = @calc_id;

get_p_v:
	IF @defp3std_cv = 'Y'
		AND @defp3std_val = 'Y'
		AND @defp3fr_v_flag = 'Y'
		AND @defp3multip_v_flag = 'Y'
	BEGIN
		IF @defp3multip_v IS NULL
		BEGIN
			SET @errornumber = '20598';
			SET @errortext = 'multip_v is not defined (std_cv+std_val+fr_v_flag+multip_v_flag)';
			GOTO errorexit;
		END

		SET @value = @volume * @defp3multip_v;
	END
	ELSE
	BEGIN
		IF @defp3si_i_vol = 'Y'
		BEGIN
			SELECT @volume = volume
				FROM si_f
				WHERE site_ref = @site_ref
					AND feature_ref = @feature_ref;

			IF @volume IS NULL
			BEGIN
				SET @errornumber = '20599';
				SET @errortext = 'volume not found (si_i_vol)';
				GOTO errorexit;
			END
		END

		IF @defp3std_cv = 'Y'
		BEGIN
			SELECT @task_ref = task_ref
				FROM item
				WHERE item_ref = @item_ref
					AND contract_ref = @contract_ref;

			IF @task_ref = '' OR @task_ref IS NULL
			BEGIN
				SET @errornumber = '20600';
				SET @errortext = 'task_ref not found (std_cv)';
				GOTO errorexit;
			END
		END

		IF @defp3d_u_o_m_flag = 'Y'
		BEGIN
			SET @duom = @defp3d_u_o_m;
		END
		ELSE
		BEGIN
			SELECT @duom = unit_of_meas
				FROM task
				WHERE task_ref = @task_ref;
		END

		IF @defp3std_cv = 'Y'
		BEGIN
			IF @defp3d_ta_r_flag = 'N'
			BEGIN
				SELECT @maxstartdate = MAX([start_date])
					FROM ta_r
					WHERE task_ref = @task_ref
						AND contract_ref = @contract_ref
						AND [start_date] <= GETDATE();

				IF @maxstartdate IS NULL
				BEGIN
					SET @errornumber = '20601';
					SET @errortext = 'task information for ' + @task_ref + ' is not defined (std_cv, maxstartdate)';
					GOTO errorexit;
				END

				SELECT @task_rate = task_rate
					FROM ta_r
					WHERE task_ref = @task_ref
						AND contract_ref = @contract_ref
						AND rate_band_code = 'BUY'
						AND [start_date] = @maxstartdate;

				IF @task_rate IS NULL
				BEGIN
					SET @errornumber = '20602';
					SET @errortext = 'task information for ' + @task_ref + ' is not defined (std_cv, task_rate)';
					GOTO errorexit;
				END
			END
			ELSE
			BEGIN
				SET @task_rate = @defp3d_ta_r;

				IF @task_rate IS NULL
				BEGIN
					SET @errornumber = '20603';
					SET @errortext = 'task_rate is not defined (std_cv)';
					GOTO errorexit;
				END
			END

			IF @duom = 0 OR @duom IS NULL
			BEGIN
				SET @errornumber = '12207';
				SET @errortext = 'unit of measure is not defined (std_cv)';
				GOTO errorexit;
			END
			ELSE
			BEGIN
				SET @value = @task_rate * @volume / @duom;
			END
		END
		ELSE
		BEGIN
			SET @value = 0;
		END

		IF @defp3std_val = 'Y'
		BEGIN
			IF @duom = 0 OR @duom IS NULL
			BEGIN
				SET @errornumber = '12208';
				SET @errortext = 'unit of measure is not defined (std_val)';
				GOTO errorexit;
			END
			ELSE
			BEGIN
				SET @value = @volume / @duom;
			END
		END

		IF @defp3multip_v_flag = 'Y'
		BEGIN
			IF @defp3multip_v IS NULL
			BEGIN
				SET @errornumber = '20604';
				SET @errortext = 'multip_v is not defined (multip_v_flag)';
				GOTO errorexit;
			END

			SET @value = @value * @defp3multip_v;
		END

		IF @defp3fr_v_flag = 'Y'
		BEGIN
			IF @defp3fr_v IS NULL
			BEGIN
				SET @errornumber = '20605';
				SET @errortext = 'fr_v is not defined (fr_v_flag)';
				GOTO errorexit;
			END

			SET @value = @value + @defp3fr_v;
		END

	END

	IF @defp3std_pnts = 'Y'
	BEGIN
		IF @duom = 0 OR @duom IS NULL
		BEGIN
			SET @errornumber = '12209';
			SET @errortext = 'unit of measure is not defined (std_pnts)';
			GOTO errorexit;
		END
		ELSE
		BEGIN
			SET @points = @volume / @duom;
		END
	END
	ELSE
	BEGIN
		SET @points = 0;
	END

	IF @defp3fr_p_flag = 'Y'
	BEGIN
		IF @defp3fr_p IS NULL
		BEGIN
			SET @errornumber = '20606';
			SET @errortext = 'fr_p is not defined (fr_p_flag)';
			GOTO errorexit;
		END

		SET @points = @points + @defp3fr_p;
	END

	IF @defp3multip_p_flag = 'Y'
	BEGIN
		IF @defp3multip_p IS NULL
		BEGIN
			SET @errornumber = '20607';
			SET @errortext = 'multip_p is not defined (multip_p_flag)';
			GOTO errorexit;
		END

		SET @points = @points * @defp3multip_p;
	END

	IF @defp3rounding = 'Y'
	BEGIN
		/* Round up to nearest integer */
		SET @points = CEILING(@points);
		SET @value  = CEILING(@value);
	END

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
