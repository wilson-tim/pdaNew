/*****************************************************************************
** dbo.cs_enfact_getActions
** stored procedure
**
** Description
** Return a list of permitted enforcement actions and associated information
**   for a given complaint number
**
** Parameters
** @complaint_no = complaint number (required if known)
**
** Returned
** Result set of actions codes data
** Return value of rowcount (if successful), or -1
**
** Notes
**
** History
** 12/03/2013  TW  New
** 19/03/2013  TW  Additional columns enf_doc, reference_enabled
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_enfact_getActions', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_enfact_getActions;
GO
CREATE PROCEDURE dbo.cs_enfact_getActions
	@complaint_no integer = NULL
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer,
		@last_action_code varchar(6),
		@car_id varchar(12),
		@date_closed datetime,
		@action_flag varchar(1),
		@dest_ref integer,
		@dest_suffix varchar(1),
		@enf_fpcn_action varchar(500);

	SET @errornumber = '20058';

	SET @enf_fpcn_action = ',' + LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'ENF_FPCN_ACTION'))) + ',';

	/* Get the current action code for this customer care record */
	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @last_action_code = NULL;
	END
	ELSE
	BEGIN
		SELECT @last_action_code = enf_action.action_ref
			FROM comp_enf
			INNER JOIN enf_action
			ON comp_enf.complaint_no = @complaint_no
				AND enf_action.complaint_no  = comp_enf.complaint_no
				AND enf_action.action_seq = comp_enf.action_seq;
	END

	IF @last_action_code = '' OR @last_action_code IS NULL
	BEGIN
		SET @last_action_code = 'NONE';
	END

	SELECT DISTINCT enfact_action_link.next_action_code,
		enf_act.[description],
		enf_act.reference,
		enf_act.reference_auto,
		enf_act.reference_validate,
		enf_act.reference_format,
		enf_act.reference_max,
		reference_enabled =
			CASE
				WHEN (enf_act.reference = 'N'
					OR (enf_act.reference_auto = 'Y' AND CHARINDEX(','+enfact_action_link.next_action_code+',',@enf_fpcn_action,1) > 0)) THEN 'N'
				ELSE 'Y'
			END,
		(SELECT COUNT(*) FROM enf_docs WHERE enf_docs.action_code = enfact_action_link.next_action_code AND enf_docs.doc_file <> '' AND enf_docs.doc_file IS NOT NULL) AS enf_docs,
		enf_act.[delay],
		enf_act.pda,
		enf_act.plea,
		enf_act.judgement,
		enf_act.penalty,
		enf_act.appeal,
		enf_act.header_flag,
		enf_act.notification_text,
		enf_act.autoclose_days
		FROM enfact_action_link, enf_act
		WHERE enfact_action_link.action_code = @last_action_code
			AND enf_act.action_code = enfact_action_link.next_action_code
			AND enf_act.pda = 'Y'
        ORDER BY enfact_action_link.next_action_code;

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
