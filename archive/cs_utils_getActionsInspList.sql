/*****************************************************************************
** dbo.cs_utils_getActionsInspList
** stored procedure
**
** Description
** Selects a list of available action codes for an inspection list item
**
** Parameters
** @complaint_no = complaint number (required for update routes)
**
** Returned
** Result set of available action codes with columns
**   action_code  = action code, varchar(6)
**   action_desc  = action code description, varchar(40)
** ordered by display_order
** Return value of @@ROWCOUNT or -1
**
** History
** 23/05/2013  TW  New
** 04/06/2013  TW  Revised check for already credited
** 25/06/2013  TW  Revised for works order action options
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_utils_getActionsInspList', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_utils_getActionsInspList;
GO
CREATE PROCEDURE dbo.cs_utils_getActionsInspList
	@complaint_no integer
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
		;

	SET @errornumber = '20576';

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
		SET @errortext = RTRIM(LTRIM(STR(@complaint_no))) + ' is not a valid complaint reference';
		GOTO errorexit;
	END

	SELECT @comp_action_flag = RTRIM(LTRIM(action_flag))
		,@dest_ref = dest_ref
		,@dest_suffix = dest_suffix
		,@service_c = service_c
		,@feature_ref = feature_ref
		,@item_ref = item_ref
		FROM comp
		WHERE complaint_no = @complaint_no;

	SET @service_type = dbo.cs_utils_getServiceType(@service_c);

	SET @xmldoc = '<ROOT>';

	/* Rectification */
	IF @comp_action_flag = 'D'
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
				/* @possible may be 1 so skip to the end */
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
	IF @comp_action_flag = 'W'
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
		IF @service_type <> 'AV'
		BEGIN
			SET @xmldoc = @xmldoc + '<ActionFlag action_code="D"  action_desc="' + @def_name_noun + '" default_flag="" display_order=""/>';
		END
		SET @xmldoc = @xmldoc + '<ActionFlag action_code="W"  action_desc="Works Order" default_flag="" display_order=""/>';
		SET @xmldoc = @xmldoc + '<ActionFlag action_code="I"  action_desc="Inspect" default_flag="" display_order=""/>';

		GOTO done;
	END

	/* Inspection */
	IF @comp_action_flag = 'I'
	BEGIN
		IF @service_type = 'AV' OR @service_type = 'ERT' OR @service_type = 'DART'
		BEGIN
			SET @xmldoc = @xmldoc + '<ActionFlag action_code="W"  action_desc="Works Order" default_flag="" display_order=""/>';
			SET @xmldoc = @xmldoc + '<ActionFlag action_code="I"  action_desc="Change Inspection Date" default_flag="" display_order=""/>';
		END

		IF @service_type = 'CORE'
		BEGIN
			SET @def_name_noun = dbo.cs_keys_getCField('PDAINI', 'DEF_NAME_NOUN');

			SET @xmldoc = @xmldoc + '<ActionFlag action_code="N"  action_desc="No Action" default_flag="" display_order=""/>';
			SET @xmldoc = @xmldoc + '<ActionFlag action_code="H"  action_desc="Hold" default_flag="" display_order=""/>';
			SET @xmldoc = @xmldoc + '<ActionFlag action_code="D"  action_desc="' + @def_name_noun + '" default_flag="" display_order=""/>';
			SET @xmldoc = @xmldoc + '<ActionFlag action_code="W"  action_desc="Works Order" default_flag="" display_order=""/>';
			SET @xmldoc = @xmldoc + '<ActionFlag action_code="I"  action_desc="Change Inspection Date" default_flag="" display_order=""/>';
		END

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
