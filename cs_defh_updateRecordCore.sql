/*****************************************************************************
** dbo.cs_defh_updateRecordCore
** stored procedure
**
** Description
** Update a rectification
**
** Parameters
** @complaint_no  = complaint number
**                  [Required]
** @action_flag   = action flag (CL=Clear / RE=Re-Rectification / CR=Credit / CRA=Credit All)
**                  [Required]
** @level         = rectification level (cs_defa_getDefaultPointsValue)
**                  [Required if action_flag = 'RE']
** @occ           = occurrence number (cs_defa_getDefaultPointsValue)
**                  [Required if action_flag = 'RE']
** @points        = points
**                  [Required if action_flag = 'RE']
** @value         = value
**                  [Required if action_flag = 'RE']
** @rectify_date  = completion date
**                  [Required if action_flag = 'RE']
** @username      = user name
**                  [Required]
**
** Returned
** Return value of 0 (success), or -1 (failure)
**
** Notes
**
** History
** 30/05/2013  TW  New
** 31/05/2013  TW  Continued development
** 03/06/2013  TW  Continued development
** 21/06/2013  TW  Additional output parameters @defh_default_no and @defh_cust_def_no
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_defh_updateRecordCore', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_defh_updateRecordCore;
GO
CREATE PROCEDURE dbo.cs_defh_updateRecordCore
	@complaint_no integer,
	@action_flag varchar(6),
	@level integer,
	@occ integer,
	@points decimal(10,2),
	@value decimal(10,2),
	@rectify_date datetime,
	@username varchar(8),
	@defh_default_no integer OUTPUT,
	@defh_cust_def_no integer OUTPUT,
	@deft_time_h varchar(2) OUTPUT,
	@deft_time_m varchar(2) OUTPUT,
	@defh_default_status varchar(1) OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @result integer
		,@errortext varchar(500)
		,@errornumber varchar(10)
		,@comp_rowcount integer
		,@default_no integer  /* this is defh,cust_def_no and default_no on all other defxxx tables */
		,@site_ref varchar(16)
		,@item_ref varchar(12)
		,@feature_ref varchar(12)
		,@contract_ref varchar(12)
		,@max_seq_no integer
		,@notice_type varchar(4)
		,@priority_flag varchar(1)
		,@temprowcount integer
		,@defi_cum_points decimal(10,2)
		,@defi_cum_value decimal(10,2)
		;

	SET @errornumber = '20500';

	/* @complaint_no validation */
	IF @complaint_no IS NULL
	BEGIN
		SET @errornumber = '20501';
		SET @errortext = 'complaint_no is required';
		GOTO errorexit;
	END
	SELECT @comp_rowcount = COUNT(*)
		FROM comp
		WHERE complaint_no = @complaint_no;
	IF @comp_rowcount <> 1
	BEGIN
		SET @errornumber = '20502';
		SET @errortext = LTRIM(RTRIM(STR(@complaint_no))) + ' is not a valid complaint reference';
		GOTO errorexit;
	END

	/* @action_flag validation */
	IF @action_flag = '' OR @action_flag IS NULL
	BEGIN
		SET @errornumber = '20503';
		SET @errortext = 'action_flag is required';
		GOTO errorexit;
	END

	/* @username validation */
	/* Assuming that @username has already been validated by calling process(es) */
	/* so only a basic test here for non-blank and non-null data being passed */
	IF @username = '' OR @username IS NULL
	BEGIN
		SET @errornumber = '20504';
		SET @errortext = 'username is required';
		GOTO errorexit;
	END

	/* Enquiry data */
	SELECT @default_no = dest_ref
		,@site_ref = site_ref
		,@item_ref = item_ref
		,@feature_ref = feature_ref
		,@contract_ref = contract_ref
		FROM comp
		WHERE complaint_no = @complaint_no;

	IF @feature_ref = '' OR @feature_ref IS NULL
	BEGIN
		SELECT @feature_ref = it_f.feature_ref
			FROM it_f
			INNER JOIN feat
			ON feat.feature_ref=it_f.feature_ref
			WHERE item_ref = @item_ref;

		IF @feature_ref = '' OR @feature_ref IS NULL
		BEGIN
			SET @errornumber = '20675';
			SET @errortext = 'feature_ref is not defined in the it_f table for item_ref ' + @item_ref;
			GOTO errorexit;
		END
	END

	/* notice_type */
	SELECT @max_seq_no = MAX(seq_no)
		FROM deft
		WHERE default_no = @default_no;
	SELECT @notice_type = notice_type
		FROM deft
		WHERE seq_no = @max_seq_no
			AND default_no = @default_no;

	/* @priority_flag */
	SELECT @priority_flag = priority_flag
		FROM si_i
		WHERE site_ref = @site_ref
			AND item_ref = @item_ref
			AND feature_ref = @feature_ref
			AND contract_ref = @contract_ref;
	IF @@ROWCOUNT < 1
	BEGIN
		/* If no si_i try to get priority flag from item */
		SELECT @priority_flag = priority_f
			FROM item
			WHERE item_ref = @item_ref
				AND contract_ref = @contract_ref;
	END

	IF @action_flag = 'CL'
	BEGIN
		BEGIN TRY
			EXECUTE dbo.cs_defh_clearRectification
				@complaint_no
				,@default_no
				,@site_ref
				,@item_ref
				,@feature_ref
				,@contract_ref
				,@notice_type
				,@priority_flag
				,@username
				,@defh_default_status OUTPUT;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20505';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH

		GOTO normalexit
	END

	IF @action_flag = 'CR' OR @action_flag = 'CRA'
	BEGIN
		BEGIN TRY
			EXECUTE dbo.cs_defh_creditRectification
				@complaint_no
				,@default_no
				,@item_ref
				,@feature_ref
				,@action_flag
				,@username
				,@deft_time_h OUTPUT
				,@deft_time_m OUTPUT
				,@defh_default_status OUTPUT;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20506';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH

		GOTO normalexit
	END

	IF @action_flag = 'RE'
	BEGIN
		BEGIN TRY
			EXECUTE dbo.cs_defh_rerectifyRectification
				@complaint_no
				,@default_no
				,@site_ref
				,@item_ref
				,@feature_ref
				,@contract_ref
				,@notice_type
				,@priority_flag
				,@level
				,@occ
				,@points
				,@value
				,@rectify_date
				,@username
				,@defh_default_status OUTPUT;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20510';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH

		GOTO normalexit
	END

normalexit:
	SELECT @defh_default_no = default_no
		,@defh_cust_def_no = cust_def_no
		FROM defh
		WHERE cust_def_no = @default_no;

	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO
