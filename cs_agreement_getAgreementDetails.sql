/*****************************************************************************
** dbo.cs_agreement_getAgreementDetails
** stored procedure
**
** Description
** Selects agreement and task details for the specified agreement
** Search results are ordered by agree_task_no, lift_sno
**
** Parameters
** @agreement_no = agreement number
**
** Returned
** @xmlTradeAgreement = XML result set of agreement and task details
**
** History
** 07/06/2013  TW  New
** 10/06/2013  TW  Continued development
** 14/06/2013  TW  TEMPORARILY replace agreement.close_date with cwtn.end_date
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_agreement_getAgreementDetails', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_agreement_getAgreementDetails;
GO
CREATE PROCEDURE dbo.cs_agreement_getAgreementDetails
	@pagreement_no integer
	,@xmlTradeAgreement xml OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500)
		,@errornumber varchar(10)
		,@agreement_no integer;

	SET @agreement_no = @pagreement_no;

	IF @agreement_no IS NULL
	BEGIN
		SET @errornumber = '20586';
		SET @errortext   = 'agreement_no is required';
		GOTO errorexit;
	END

	SET @xmlTradeAgreement = 
		(
		SELECT
			agreement_no
			,agreement_name
			,latest_cwtn
			,waste_type
			,(SELECT waste_type.waste_desc FROM waste_type WHERE waste_type.waste_type = TradeAgreementDetailsDTO.waste_type) AS waste_type_desc
			,[start_date]
			,(SELECT cwtn.end_date FROM cwtn WHERE cwtn.cwtn_sno = TradeAgreementDetailsDTO.latest_cwtn) AS close_date
			,contractor_ref
			,(SELECT cntr.contr_name FROM cntr WHERE cntr.contractor_ref = TradeAgreementDetailsDTO.contractor_ref) AS contractor_name
			,status_ref
			,status_ref_desc =
				CASE
					WHEN status_ref = 'C' THEN 'Closed'
					WHEN status_ref = 'L' THEN 'Legal'
					WHEN status_ref = 'R' THEN 'Running'
					WHEN status_ref = 'S' THEN 'Suspended'
					WHEN status_ref = 'D' THEN 'Deleted'
				END
			,(SELECT TradeTaskDTO.agree_task_no
					,TradeTaskDTO.[start_date]
					,TradeTaskDTO.[close_date]
					,TradeTaskDTO.task_ref
					,(SELECT task_desc FROM task WHERE task.task_ref = TradeTaskDTO.task_ref) AS task_desc
					,TradeTaskDTO.exact_locn
					,(SELECT LiftDTO.lift_sno
						,LiftDTO.no_of_bins
						,LiftDTO.round_ref
						,(SELECT round_desc FROM [round] WHERE [round].round_ref = LiftDTO.round_ref) AS round_desc
						,LiftDTO.coll_day
						,LiftDTO.before_after
						,before_after_text =
							CASE
								WHEN LiftDTO.before_after = 'B' THEN 'Before'
								WHEN LiftDTO.before_after = 'A' THEN 'After'
							END
						,LiftDTO.time_hr
						,LiftDTO.time_min
						FROM lifts AS LiftDTO
						WHERE LiftDTO.agree_task_no = TradeTaskDTO.agree_task_no
							AND GETDATE() >= LiftDTO.[start_date]
						ORDER BY LiftDTO.lift_sno
						FOR XML AUTO, ELEMENTS, TYPE, ROOT('Lifts')
					)
				FROM agree_task AS TradeTaskDTO
				WHERE TradeTaskDTO.agreement_no = TradeAgreementDetailsDTO.agreement_no
					AND TradeTaskDTO.status_ref = 'R'
					AND GETDATE() >= TradeTaskDTO.[start_date]
					AND (GETDATE() < TradeTaskDTO.close_date
						OR
						TradeTaskDTO.close_date IS NULL
						OR
						TradeTaskDTO.close_date = ''
						)
				ORDER BY TradeTaskDTO.agree_task_no
				FOR XML AUTO, ELEMENTS, TYPE, ROOT('Tasks'))
		FROM agreement AS TradeAgreementDetailsDTO
		WHERE TradeAgreementDetailsDTO.agreement_no = @agreement_no
		ORDER BY TradeAgreementDetailsDTO.agreement_no
		FOR XML AUTO, ELEMENTS, TYPE
		);

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END

GO
