/*****************************************************************************
** dbo.cs_utils_getActionsCreate
** stored procedure
**
** Description
** Selects a list of available action codes for a given service code
** and a given fault code
**
** Parameters
** @service_c    = service code
** @comp_code    = fault code
** @user_name    = login id
**
** Returned
** Result set of available action codes with columns
**   action_code  = action code, char(1)
**   action_desc  = action code description, char(40)
**   default_flag = default action code flag, bit (assigned for create route only)
**   display_order
** ordered by display_order
** Return value of @@ROWCOUNT or -1
**
** History
** 01/07/2013  TW  New (essentially the original cs_utils_getActions renamed)
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_utils_getActionsCreate', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_utils_getActionsCreate;
GO
CREATE PROCEDURE dbo.cs_utils_getActionsCreate
	@pservice_c varchar(6)
	,@pcomp_code varchar(6)
	,@puser_name varchar(8)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @default_code varchar(6)
		,@action_flag varchar(1)
		,@xmldoc varchar(1000)
		,@idoc integer
		,@flag char(1)
		,@display_order integer
		,@def_name_noun varchar(40)
		,@errortext varchar(500)
		,@errornumber varchar(10)
		,@rowcount integer
		,@comp_action_flag varchar(1)
		,@service_c varchar(6)
		,@comp_code varchar(6)
		,@user_name varchar(8)
		,@service_type varchar(30)
		;

	SET @errornumber = '13800';

	SET @service_c = LTRIM(RTRIM(@pservice_c));
	SET @comp_code = LTRIM(RTRIM(@pcomp_code));
	SET @user_name = LTRIM(RTRIM(@puser_name));

	IF @service_c = '' OR @service_c IS NULL
	BEGIN
		SET @errornumber = '13801';
		SET @errortext   = 'service_c is required';
		GOTO errorexit;
	END

	IF @comp_code = '' OR @comp_code IS NULL
	BEGIN
		SET @errornumber = '13802';
		SET @errortext   = 'comp_code is required';
		GOTO errorexit;
	END

	IF @user_name = '' OR @user_name IS NULL
	BEGIN
		SET @errornumber = '20132';
		SET @errortext   = 'user_name is required';
		GOTO errorexit;
	END

	SET @comp_action_flag = NULL;

	SET @service_type = dbo.cs_utils_getServiceType(@service_c);

	SET @display_order = 0;

	/* Determine the default value of the action flag */
	/* From comp_action table */
	SELECT @action_flag = LTRIM(RTRIM(action_flag))
		FROM comp_action
		WHERE comp_code = @comp_code;

	/* Determine the default value of the action flag */
	/* From system key */
	IF @@ROWCOUNT < 1
	BEGIN
		SET @action_flag = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField(@service_c, 'COMPLAINT_ACTION'))));
	END

	/* If no default action flag value is defined then default to 'H' */
	IF @action_flag = '' OR @action_flag IS NULL
	BEGIN
		SET @action_flag = 'H';
	END

	/* If default action flag value is 'X' (eXpress works order) then default to 'W' (works order) */
	IF @action_flag = 'X'
	BEGIN
		SET @action_flag = 'W';
	END

	SET @xmldoc = '<ROOT>';

	/* Rectification / Default */
	/* If NOT DART, Graffiti or AV service type then */
	IF (@service_type <> 'DART')
		AND (@service_type <> 'ERT')
		AND (@service_type <> 'AV')
	BEGIN
		SET @def_name_noun = dbo.cs_keys_getCField('PDAINI', 'DEF_NAME_NOUN');

		/* Automatic */
		SET @xmldoc = @xmldoc + '<ActionFlag action_code="A" action_desc="Auto ' + @def_name_noun + '" default_flag="';
		IF @action_flag = 'A'
		BEGIN
			SET @flag = '1';
		END
		ELSE
		BEGIN
			SET @flag = '0';
		END
		SET @display_order = @display_order + 1;
		SET @xmldoc = @xmldoc + @flag + '" display_order="' + CAST(@display_order AS char(1)) + '"/>'

		/* Manual */
		SET @xmldoc = @xmldoc + '<ActionFlag action_code="D" action_desc="' + @def_name_noun + '" default_flag="';
		IF @action_flag = 'D'
		BEGIN
			SET @flag = '1';
		END
		ELSE
		BEGIN
			SET @flag = '0';
		END
		SET @display_order = @display_order + 1;
		SET @xmldoc = @xmldoc + @flag + '" display_order="' + CAST(@display_order AS char(1)) + '"/>'
	END

	/* Enforcement */
	IF dbo.cs_modulelic_getInstalled('ENF') = 1
		AND @service_type = 'AV'
		AND dbo.cs_pdauser_getEnfOfficerPoCode(@user_name) IS NOT NULL
	BEGIN
		SET @xmldoc = @xmldoc + '<ActionFlag action_code="E" action_desc="Enforcement" default_flag="';
		IF @action_flag = 'E'
		BEGIN
			SET @flag = '1';
		END
		ELSE
		BEGIN
			SET @flag = '0';
		END
		SET @display_order = @display_order + 1;
		SET @xmldoc = @xmldoc + @flag + '" display_order="' + CAST(@display_order AS char(1)) + '"/>'
	END

	/* Hold */
	SET @xmldoc = @xmldoc + '<ActionFlag action_code="H" action_desc="Hold" default_flag="';
	IF @action_flag = 'H'
	BEGIN
		SET @flag = '1';
	END
	ELSE
	BEGIN
		SET @flag = '0';
	END
	SET @display_order = @display_order + 1;
	SET @xmldoc = @xmldoc + @flag + '" display_order="' + CAST(@display_order AS char(1)) + '"/>'

	/* Inspect */
	SET @xmldoc = @xmldoc + '<ActionFlag action_code="I" action_desc="Inspect" default_flag="';
	IF @action_flag = 'I'
	BEGIN
		SET @flag = '1';
	END
	ELSE
	BEGIN
		SET @flag = '0';
	END
	SET @display_order = @display_order + 1;
	SET @xmldoc = @xmldoc + @flag + '" display_order="' + CAST(@display_order AS char(1)) + '"/>'

	/* Pending */
	SET @xmldoc = @xmldoc + '<ActionFlag action_code="P" action_desc="Pending" default_flag="';
	IF @action_flag = 'P'
	BEGIN
		SET @flag = '1';
	END
	ELSE
	BEGIN
		SET @flag = '0';
	END
	SET @display_order = @display_order + 1;
	SET @xmldoc = @xmldoc + @flag + '" display_order="' + CAST(@display_order AS char(1)) + '"/>';

	/* No Action */
	SET @xmldoc = @xmldoc + '<ActionFlag action_code="N" action_desc="No Action" default_flag="';
	IF @action_flag = 'N'
	BEGIN
		SET @flag = '1';
	END
	ELSE
	BEGIN
		SET @flag = '0';
	END
	SET @display_order = @display_order + 1;
	SET @xmldoc = @xmldoc + @flag + '" display_order="' + CAST(@display_order AS char(1)) + '"/>';

	/* Works Order */
	/* If NOT DART service type then */
	/* If NOT (AV service type + 'AV WO USED' <> 'Y') then */
	/* If NOT already a works order then */
	IF (@service_type <> 'DART')
		AND NOT (@service_type = 'AV' AND UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'AV WO USED')))) <> 'Y')
	BEGIN
		SET @xmldoc = @xmldoc + '<ActionFlag action_code="W" action_desc="Works Order" default_flag="';
		IF @action_flag = 'W'
		BEGIN
			SET @flag = '1';
		END
		ELSE
		BEGIN
			SET @flag = '0';
		END
		SET @display_order = @display_order + 1;
		SET @xmldoc = @xmldoc + @flag + '" display_order="' + CAST(@display_order AS char(1)) + '"/>'
	END

	SET @xmldoc = @xmldoc + '</ROOT>';

	/* Create an internal representation of the XML document. */
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmldoc;
	/* Execute a SELECT statement that uses the OPENXML rowset provider. */
	SELECT action_code,
		action_desc,
		default_flag,
		display_order
		FROM OPENXML (@idoc, '/ROOT/ActionFlag', 1)
        WITH (action_code varchar(1),
			action_desc varchar(40),
			default_flag bit,
			display_order integer)
		ORDER BY display_order;

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO
