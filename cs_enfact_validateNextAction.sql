/*****************************************************************************
** dbo.cs_enfact_validateNextAction
** stored procedure
**
** Description
** Validate new Enforcement action
**
** Parameters
** @complaint_no     = complaint number (required)
** @next_action_code = next (new) action (required)
**
** Returned
** Return value of 1 (if successful), or 0
**
** Notes
**
** History
** 13/03/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_enfact_validateNextAction', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_enfact_validateNextAction;
GO
CREATE PROCEDURE dbo.cs_enfact_validateNextAction
	@complaint_no integer,
	@next_action_code varchar(6)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer,
		@last_action_code varchar(6);

	SET @errornumber = '20032';

	/* Get the current action code for this customer care record */
	SELECT @last_action_code = enf_action.action_ref
		FROM comp_enf
		INNER JOIN enf_action
		ON comp_enf.complaint_no = @complaint_no
			AND enf_action.complaint_no  = comp_enf.complaint_no
			AND enf_action.action_seq = comp_enf.action_seq;

	IF @last_action_code = '' OR @last_action_code IS NULL
	BEGIN
		SET @last_action_code = 'NONE';
	END

	SELECT @rowcount = COUNT(DISTINCT enfact_action_link.next_action_code)
		FROM enfact_action_link, enf_act
		WHERE enfact_action_link.action_code = @last_action_code
			AND enf_act.action_code = enfact_action_link.next_action_code
			AND enf_act.pda = 'Y'
			AND enfact_action_link.next_action_code = @next_action_code;

normalexit:
	IF @rowcount = 1
	BEGIN
		RETURN 1;
	END
	ELSE
	BEGIN
		RETURN 0;
	END

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
