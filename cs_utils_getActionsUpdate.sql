/*****************************************************************************
** dbo.cs_utils_getActionsUpdate
** stored procedure
**
** Description
** Selects a list of available action codes for a given complaint reference
**
** Parameters
** @complaint_no = complaint number (required for update routes)
** @user_name    = login id
**
** Returned
** Result set of available action codes with columns
**   action_code  = action code, varchar(6)
**   action_desc  = action code description, varchar(40)
** ordered by display_order
** Return value of @@ROWCOUNT or -1
**
** History
** 01/07/2013  TW  New (replaces cs_utils_getActionsInspList)
** 03/07/2013  TW  Hold processing
** 04/07/2013  TW  Added Enforcement option (previously overlooked)
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_utils_getActionsUpdate', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_utils_getActionsUpdate;
GO
CREATE PROCEDURE dbo.cs_utils_getActionsUpdate
	@pcomplaint_no integer
	,@puser_name varchar(8)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @default_code varchar(6)
		,@action_flag varchar(1)
		,@xmldoc varchar(1000)
		,@idoc integer
		,@def_name_verb varchar(40)
		,@def_name_noun varchar(40)
		,@errortext varchar(500)
		,@errornumber varchar(10)
		,@rowcount integer
		,@dest_suffix varchar(6)
		,@comp_action_flag varchar(1)
		,@last_seq integer
		,@av_expiry_date datetime
		,@dest_ref integer
		,@default_no integer
		,@default_action varchar(1)
		,@possible bit
		,@message varchar(100)
		,@clear bit
		,@comp_rowcount integer
		,@service_c varchar(6)
		,@service_type varchar(30)
		,@zcount integer
		,@default_level integer
		,@default_occ integer
		,@feature_ref varchar(12)
		,@item_ref varchar(12)
		,@ncount integer
		,@wo_current_stat varchar(3)
		,@complaint_no integer
		,@user_name varchar(8)
		;

	SET @errornumber = '20576';

	SET @complaint_no = @pcomplaint_no;
	SET @user_name = LTRIM(RTRIM(@puser_name));

	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @errornumber = '20577';
		SET @errortext   = 'complaint_no is required';
		GOTO errorexit;
	END
	SELECT @comp_rowcount = COUNT(*)
		FROM comp
		WHERE complaint_no = @complaint_no
	IF @comp_rowcount <> 1
	BEGIN
		SET @errornumber = '20578';
		SET @errortext = LTRIM(RTRIM(STR(@complaint_no))) + ' is not a valid complaint reference';
		GOTO errorexit;
	END

	SELECT @comp_action_flag = LTRIM(RTRIM(action_flag))
		,@dest_ref = dest_ref
		,@dest_suffix = dest_suffix
		,@service_c = service_c
		,@feature_ref = feature_ref
		,@item_ref = item_ref
		FROM comp
		WHERE complaint_no = @complaint_no;

	SET @service_type = dbo.cs_utils_getServiceType(@service_c);

	IF @service_type = 'AV'
	BEGIN
		SELECT @last_seq = last_seq
			FROM comp_av
			WHERE complaint_no = @complaint_no;

		IF @last_seq > 0
		BEGIN
			SELECT @av_expiry_date = [expiry_date]
				FROM comp_av_hist
				WHERE complaint_no = @complaint_no
					AND seq = @last_seq;
		END
		ELSE
		BEGIN
			SET @av_expiry_date = NULL;
		END
	END
	ELSE
	BEGIN
		SET @av_expiry_date = NULL;
	END

	SET @xmldoc = '<ROOT>';

	/* Rectification */
	IF @comp_action_flag = 'A' OR @comp_action_flag = 'D'
	BEGIN
		SET @default_no = @dest_ref;

		/* Is the issue already cleared? */
		SELECT @ncount = COUNT(*)	
			FROM defi
			WHERE default_no = @default_no
				AND item_status = 'N'
				AND item_ref = @item_ref;

		IF @ncount = 0
		BEGIN
			SELECT @ncount = COUNT(*)
				FROM defh
				WHERE cust_def_no = @default_no
					AND default_status = 'N';
		END

		IF @ncount = 0
		BEGIN
			/* Clear option */
			SET @xmldoc = @xmldoc + '<ActionFlag action_code="CL" action_desc="Clear" default_flag="" display_order=""/>';

			EXECUTE dbo.cs_deft_checkReRectification
				@default_no
				,@complaint_no
				,@possible OUTPUT
				,@message OUTPUT
				,@clear OUTPUT
				;

			IF @clear = 1
			BEGIN
				/* 'Clear' is the only action possible   */
				/* skip to the end                       */
				GOTO done;
			END

			/* Re-rectification option */
			IF @possible = 1
			BEGIN
				SET @def_name_verb = dbo.cs_keys_getCField('PDAINI', 'DEF_NAME_VERB');
				SET @xmldoc = @xmldoc + '<ActionFlag action_code="RE" action_desc="Re-' + @def_name_verb + '"  default_flag="" display_order=""/>';
			END

			/* Credit option */
			/* Check that the last transaction is not 'Z' */
			SET @default_no = @dest_ref;

			SELECT @default_level = default_level
				,@default_occ = default_occ
				FROM deft
				WHERE default_no = @default_no
					AND feature_ref = @feature_ref
					AND item_ref = @item_ref
					AND seq_no =
						(
						SELECT MAX(seq_no)
							FROM deft
							WHERE default_no = @default_no
								AND action_flag <> 'Z'
						);

			SELECT @zcount = COUNT(*)
				FROM deft
				WHERE default_no = @default_no
					AND feature_ref = @feature_ref
					AND item_ref = @item_ref
					AND default_level = - @default_level
					AND default_occ = - @default_occ
					AND action_flag = 'Z';

			IF @zcount = 0
			BEGIN
				SET @xmldoc = @xmldoc + '<ActionFlag action_code="CR"  action_desc="Credit"  default_flag="" display_order=""/>';
			END

			/* Credit All option is always available */
			SET @xmldoc = @xmldoc + '<ActionFlag action_code="CRA" action_desc="Credit All" default_flag="" display_order=""/>';
		END

		GOTO done;
	END

	/* Works Order */
	IF @comp_action_flag = 'W' OR @comp_action_flag = 'X'
	BEGIN
		/* Get the current status */
		SELECT @wo_current_stat = wo_h_stat
			FROM wo_h
			WHERE wo_ref = @dest_ref AND wo_suffix = @dest_suffix;

		/* Get list of possible status(es) */
		/* (in the list of next status(es) and with remote_status flag = 'Y') */
		SELECT wo_next_stat.wo_next_stat AS action_code
			,wo_stat.wo_stat_desc AS action_desc
			,NULL AS default_flag
			,NULL AS display_order
			FROM wo_next_stat
			INNER JOIN wo_stat
			ON wo_stat.wo_h_stat = wo_next_stat.wo_next_stat
			WHERE wo_stat.remote_status = 'Y'
				AND wo_next_stat.wo_h_stat = @wo_current_stat;

		SET @rowcount = @@ROWCOUNT;

		GOTO normalexit;
	END

	/* Pending */
	IF @comp_action_flag = 'P'
	BEGIN
		SET @def_name_noun = dbo.cs_keys_getCField('PDAINI', 'DEF_NAME_NOUN');

		SET @xmldoc = @xmldoc + '<ActionFlag action_code="N"  action_desc="No Action" default_flag="" display_order=""/>';
		SET @xmldoc = @xmldoc + '<ActionFlag action_code="H"  action_desc="Hold" default_flag="" display_order=""/>';
		IF dbo.cs_modulelic_getInstalled('ENF') = 1
			AND @service_type = 'AV'
			AND dbo.cs_pdauser_getEnfOfficerPoCode(@user_name) IS NOT NULL
		BEGIN
			SET @xmldoc = @xmldoc + '<ActionFlag action_code="E"  action_desc="Enforcement" default_flag="" display_order=""/>';
		END
		IF @service_type <> 'AV'
		BEGIN
			SET @xmldoc = @xmldoc + '<ActionFlag action_code="D"  action_desc="' + @def_name_noun + '" default_flag="" display_order=""/>';
		END
		/* Works Order option if... */
		/* If NOT (AV service type + 'AV WO USED' <> 'Y') then */
		/* IF NOT (AV service type and unexpired delay period) then */
		IF NOT (@service_type = 'AV' AND UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'AV WO USED')))) <> 'Y')
			AND NOT (@service_type = 'AV' AND DATEDIFF(day, CONVERT(datetime, CONVERT(date, GETDATE())), ISNULL(@av_expiry_date, 0)) > 0)
		BEGIN
			SET @xmldoc = @xmldoc + '<ActionFlag action_code="W"  action_desc="Works Order" default_flag="" display_order=""/>';
		END
		SET @xmldoc = @xmldoc + '<ActionFlag action_code="I"  action_desc="Inspect" default_flag="" display_order=""/>';

		GOTO done;
	END

	/* Inspection */
	IF @comp_action_flag = 'I'
	BEGIN
		IF @service_type = 'AV' OR @service_type = 'ERT' OR @service_type = 'DART'
		BEGIN
			SET @xmldoc = @xmldoc + '<ActionFlag action_code="N"  action_desc="No Action" default_flag="" display_order=""/>';
			SET @xmldoc = @xmldoc + '<ActionFlag action_code="H"  action_desc="Hold" default_flag="" display_order=""/>';
			IF dbo.cs_modulelic_getInstalled('ENF') = 1
				AND @service_type = 'AV'
				AND dbo.cs_pdauser_getEnfOfficerPoCode(@user_name) IS NOT NULL
			BEGIN
				SET @xmldoc = @xmldoc + '<ActionFlag action_code="E"  action_desc="Enforcement" default_flag="" display_order=""/>';
			END
			/* If NOT (AV service type + 'AV WO USED' <> 'Y') then */
			/* IF NOT (AV service type and unexpired delay period) then */
			IF NOT (@service_type = 'AV' AND UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'AV WO USED')))) <> 'Y')
				AND NOT (@service_type = 'AV' AND DATEDIFF(day, CONVERT(datetime, CONVERT(date, GETDATE())), ISNULL(@av_expiry_date, 0)) > 0)
			BEGIN
				SET @xmldoc = @xmldoc + '<ActionFlag action_code="W"  action_desc="Works Order" default_flag="" display_order=""/>';
			END
			SET @xmldoc = @xmldoc + '<ActionFlag action_code="I"  action_desc="Inspection" default_flag="" display_order=""/>';
		END

		IF @service_type = 'CORE'
		BEGIN
			SET @def_name_noun = dbo.cs_keys_getCField('PDAINI', 'DEF_NAME_NOUN');

			SET @xmldoc = @xmldoc + '<ActionFlag action_code="N"  action_desc="No Action" default_flag="" display_order=""/>';
			SET @xmldoc = @xmldoc + '<ActionFlag action_code="H"  action_desc="Hold" default_flag="" display_order=""/>';
			SET @xmldoc = @xmldoc + '<ActionFlag action_code="D"  action_desc="' + @def_name_noun + '" default_flag="" display_order=""/>';
			SET @xmldoc = @xmldoc + '<ActionFlag action_code="W"  action_desc="Works Order" default_flag="" display_order=""/>';
			SET @xmldoc = @xmldoc + '<ActionFlag action_code="I"  action_desc="Inspection" default_flag="" display_order=""/>';
		END

		GOTO done;
	END

	/* Hold */
	IF @comp_action_flag = 'H'
	BEGIN
		SET @def_name_noun = dbo.cs_keys_getCField('PDAINI', 'DEF_NAME_NOUN');

		SET @xmldoc = @xmldoc + '<ActionFlag action_code="N"  action_desc="No Action" default_flag="" display_order=""/>';
		SET @xmldoc = @xmldoc + '<ActionFlag action_code="P"  action_desc="Pending" default_flag="" display_order=""/>';
		IF dbo.cs_modulelic_getInstalled('ENF') = 1
			AND @service_type = 'AV'
			AND dbo.cs_pdauser_getEnfOfficerPoCode(@user_name) IS NOT NULL
		BEGIN
			SET @xmldoc = @xmldoc + '<ActionFlag action_code="E"  action_desc="Enforcement" default_flag="" display_order=""/>';
		END
		IF @service_type <> 'AV'
		BEGIN
			SET @xmldoc = @xmldoc + '<ActionFlag action_code="D"  action_desc="' + @def_name_noun + '" default_flag="" display_order=""/>';
		END
		/* Works Order option if... */
		/* If NOT (AV service type + 'AV WO USED' <> 'Y') then */
		/* IF NOT (AV service type and unexpired delay period) then */
		IF NOT (@service_type = 'AV' AND UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'AV WO USED')))) <> 'Y')
			AND NOT (@service_type = 'AV' AND DATEDIFF(day, CONVERT(datetime, CONVERT(date, GETDATE())), ISNULL(@av_expiry_date, 0)) > 0)
		BEGIN
			SET @xmldoc = @xmldoc + '<ActionFlag action_code="W"  action_desc="Works Order" default_flag="" display_order=""/>';
		END
		SET @xmldoc = @xmldoc + '<ActionFlag action_code="I"  action_desc="Inspect" default_flag="" display_order=""/>';

		GOTO done;
	END

done:
	SET @xmldoc = @xmldoc + '</ROOT>';

	/* Create an internal representation of the XML document. */
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmldoc;
	/* Execute a SELECT statement that uses the OPENXML rowset provider. */
	SELECT action_code
		,action_desc
		,NULL AS default_flag
		,NULL AS display_order
		FROM OPENXML (@idoc, '/ROOT/ActionFlag', 1)
        WITH (action_code varchar(3)
			,action_desc varchar(40)
			,default_flag bit
			,display_order integer);

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO
