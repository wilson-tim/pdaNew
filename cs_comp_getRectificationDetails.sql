/*****************************************************************************
** dbo.cs_comp_getRectificationDetails
** stored procedure
**
** Description
** Selection of customer care rectification data for a specified complaint_no
**   for use with an inspection list rectification item
**
** Parameters
** @complaint_no = complaint number
**
** Returned
** Result set of customer care rectification data
** Return value of rowcount (should be 1) if successful, otherwise -1
**
** Notes
** Returns parameters for calling cs_defa_getDefaultPointsValue and cs_defa_getDefaultCompletionDate
**
** History
** 29/05/2013  TW  New
** 30/05/2013  TW  Error message if more than one row is found
** 21/06/2013  TW  Additional output column defh.default_no , defh.default_status
** 09/07/2013  TW  Replace function call to ...getFaultCodesTable with ...getFaultCodeDesc
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_comp_getRectificationDetails', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comp_getRectificationDetails;
GO
CREATE PROCEDURE dbo.cs_comp_getRectificationDetails
	@pcomplaint_no integer
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @rowcount integer
		,@errortext varchar(500)
		,@errornumber varchar(10)
		,@complaint_no integer;

	SET @errornumber = '20491';

	SET @complaint_no = @pcomplaint_no;

	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @errornumber = '20492';
		SET @errortext = 'complaint_no is required';
		GOTO errorexit;
	END

	SELECT comp.complaint_no
		,comp.comp_code
		,(dbo.cs_pdalookup_getFaultCodeDesc(comp.comp_code, comp.service_c, comp.item_ref, NULL)) AS comp_code_desc
		,defh.default_no
		,defh.cust_def_no
		,defh.site_ref
		,defh.default_status
		,joineddeft.item_ref
		,defa.item_type
		,joineddeft.feature_ref
		,defh.contract_ref
		,joineddeft.priority_flag
		,defi.default_algorithm
		,defp1.algorithm_desc
		,pda_algorithm.user_desc
		,defi.volume
		,joineddeft.points
		,joineddeft.value
		,DATEADD(minute, CAST(ISNULL(defi_rect.rectify_time_m, 0) AS integer),
				DATEADD(hour,   CAST(ISNULL(defi_rect.rectify_time_h, 0) AS integer),
				DATEADD(day,    DATEPART(day,   defi_rect.rectify_date) - 1, 
				DATEADD(month,  DATEPART(month, defi_rect.rectify_date) - 1, 
				DATEADD(year,   DATEPART(year,  defi_rect.rectify_date) - 1900, 0))))) AS rectify_datetime
		,defi_rect.rectify_date
		,defi_rect.rectify_time_h
		,defi_rect.rectify_time_m
		,joineddeft.default_level
		,joineddeft.default_occ
		,defp1.cb_time_id
		,joineddeft.seq_no
		,defa.notice_rep_no
		,defa.change_alg_yn
		,defa.prompt_for_points
		,defa.prompt_for_value
		,defa.prompt_for_rectify
	FROM comp
	INNER JOIN defh
	ON defh.cust_def_no = comp.dest_ref
	INNER JOIN defi
	ON defi.default_no = defh.cust_def_no
	INNER JOIN deft AS joineddeft
	ON joineddeft.default_no = defh.cust_def_no
		AND joineddeft.seq_no =
			(
			SELECT MAX(seq_no)
				FROM deft
				WHERE default_no = defh.cust_def_no
			)
	INNER JOIN defi_rect
	ON defi_rect.default_no = defh.cust_def_no
		AND defi_rect.seq_no =
			(
			SELECT MAX(seq_no)
				FROM deft
				WHERE default_no = defh.cust_def_no
			)
	INNER JOIN defp1
	ON defp1.contract_ref = defh.contract_ref
		AND defp1.[algorithm] = defi.default_algorithm
		AND defp1.default_level = joineddeft.default_level
		AND defp1.[priority] = joineddeft.priority_flag
	INNER JOIN defa
	ON defa.default_algorithm = defi.default_algorithm
	INNER JOIN pda_algorithm
	ON pda_algorithm.[algorithm] = defi.default_algorithm
	WHERE comp.complaint_no = @complaint_no
		AND comp.action_flag='D'
		AND comp.dest_ref IS NOT NULL
		AND comp.date_closed IS NULL;

	SET @rowcount = @@ROWCOUNT;

	IF @rowcount > 1
	BEGIN
		SET @errornumber = '20494';
		SET @errortext = 'Multiple records found';
		GOTO errorexit;
	END

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO
