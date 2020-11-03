/*****************************************************************************
** dbo.csis_woh_getChangedRectifications
** stored procedure
**
** Description
** Selects changed rectifications
**
** Parameters
** @user_name    = user name
** @FromDateTime = date due threshold (optional)
**
** Returned
** @xmlISRectifications = rectification data in XML format
**
** History
** 07/08/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.csis_defh_getChangedRectifications', N'P') IS NOT NULL
    DROP PROCEDURE dbo.csis_defh_getChangedRectifications;
GO
CREATE PROCEDURE dbo.csis_defh_getChangedRectifications
	@puser_name varchar(8)
	,@pFromDateTime datetime = NULL
	,@xmlISRectifications xml OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500)
		,@errornumber varchar(10)
		,@rowcount integer
		,@user_name varchar(8)
		,@FromDateTime datetime
		,@complaint_no integer
		;

	SET @user_name = LTRIM(RTRIM(@puser_name));
	SET @FromDateTime = @pFromDateTime;

	/* @user_name validation */
	IF @user_name = '' OR @user_name IS NULL
	BEGIN
		SET @errornumber = '20748';
		SET @errortext = 'user_name is required';
		GOTO errorexit;
	END

	IF OBJECT_ID('tempdb..#tempDefh') IS NOT NULL
	BEGIN
		DROP TABLE #tempDefh;
	END

	/* Select rectifications */
	SELECT
		comp.complaint_no
		,defh.contract_ref
		,deft.seq_no
		,deft.default_level
		,deft.action_flag
		,deft.item_ref
		,(SELECT item_desc FROM item WHERE item_ref = (SELECT item_ref FROM defi WHERE defi.default_no = defh.cust_def_no)) AS item_desc
		,deft.feature_ref
		,(SELECT feature_desc FROM feat WHERE feature_ref = (SELECT feature_ref FROM defi WHERE defi.default_no = defh.cust_def_no)) AS feature_desc
		,deft.notice_type
		,deft.points
		,deft.value
		,(DATEADD(minute, CAST(ISNULL(deft.time_m, 0) AS integer),
				DATEADD(hour,   CAST(ISNULL(deft.time_h, 0) AS integer),
				DATEADD(day,    DATEPART(day,   deft.trans_date) - 1, 
				DATEADD(month,  DATEPART(month, deft.trans_date) - 1, 
				DATEADD(year,   DATEPART(year,  deft.trans_date) - 1900, 0)))))) AS trans_date
		,defh.cust_def_no
		,(DATEADD(minute, CAST(ISNULL(defh.start_time_m, 0) AS integer),
				DATEADD(hour,   CAST(ISNULL(defh.start_time_h, 0) AS integer),
				DATEADD(day,    DATEPART(day,   defh.[start_date]) - 1, 
				DATEADD(month,  DATEPART(month, defh.[start_date]) - 1, 
				DATEADD(year,   DATEPART(year,  defh.[start_date]) - 1900, 0)))))) AS [start_date]
		,defh.site_ref
		,[site].location_c
		,[site].site_name_1
		,[site].site_name_2
		,(SELECT locn.location_name FROM locn WHERE locn.location_c = [site].location_c) AS location_name
		,defi.volume
		,defi.cum_points
		,defi.cum_value
		,defi.default_reason
		,(SELECT lookup_text FROM allk WHERE lookup_func = 'DEFRN' AND lookup_code = (SELECT default_reason FROM defi WHERE defi.default_no = defh.cust_def_no)) AS lookup_text
		,(DATEADD(minute, CAST(ISNULL(defi_rect.rectify_time_m, 0) AS integer),
				DATEADD(hour,   CAST(ISNULL(defi_rect.rectify_time_h, 0) AS integer),
				DATEADD(day,    DATEPART(day,   defi_rect.rectify_date) - 1, 
				DATEADD(month,  DATEPART(month, defi_rect.rectify_date) - 1, 
				DATEADD(year,   DATEPART(year,  defi_rect.rectify_date) - 1900, 0)))))) AS rectify_date
		,closed = 
			CASE
				WHEN comp.date_closed IS NOT NULL THEN 'Y'
				ELSE NULL
			END
,rank()  over(partition by comp.complaint_no order by deft.seq_no desc ,rectify_date desc ,defi_rect.rect_key desc) rank_number
		INTO #tempDefh
		FROM defh
		INNER JOIN comp
		ON comp.dest_ref = defh.cust_def_no
		INNER JOIN [site]
		ON [site].site_ref = defh.site_ref
		INNER JOIN defi
		ON defi.default_no = defh.cust_def_no
		INNER JOIN deft
		ON deft.default_no = defh.cust_def_no
		INNER JOIN defi_rect
		ON defi_rect.default_no = defh.cust_def_no
		INNER JOIN integration_transfer_log itl
		ON itl.complaint_no = comp.complaint_no
			AND (itl.contractor_ref IS NOT NULL AND itl.contractor_ref <> '')
			AND (itl.rejected IS NULL OR itl.rejected <> 'Y')
		WHERE 
			/* Relevant to user */
			defh.contract_ref IN
				(SELECT cont_logins.contract_ref FROM cont_logins WHERE cont_logins.login_name = @user_name)
			AND (
				((SELECT COUNT(*) FROM deft
				WHERE deft.default_no = defh.cust_def_no
					AND
					(DATEADD(minute, CAST(ISNULL(deft.time_m, 0) AS integer) + 1,
					DATEADD(hour,   CAST(ISNULL(deft.time_h, 0) AS integer),
					DATEADD(day,    DATEPART(day,   deft.trans_date) - 1, 
					DATEADD(month,  DATEPART(month, deft.trans_date) - 1, 
					DATEADD(year,   DATEPART(year,  deft.trans_date) - 1900, 0)))))) >= itl.transfer_datetime
					) > 0)
				OR
				((SELECT COUNT(*) FROM defi_nb
					WHERE defi_nb.default_no = defh.cust_def_no
						AND
						(DATEADD(minute, CAST(ISNULL(defi_nb.time_entered_m, 0) AS integer) + 1,
						DATEADD(hour,   CAST(ISNULL(defi_nb.time_entered_h, 0) AS integer),
						DATEADD(day,    DATEPART(day,   defi_nb.doa) - 1, 
						DATEADD(month,  DATEPART(month, defi_nb.doa) - 1, 
						DATEADD(year,   DATEPART(year,  defi_nb.doa) - 1900, 0)))))) >= itl.transfer_datetime
						) > 0)
				)
			AND (@FromDateTime IS NULL
				OR
				(DATEADD(minute, CAST(ISNULL(defi_rect.rectify_time_m, 0) AS integer),
				DATEADD(hour,   CAST(ISNULL(defi_rect.rectify_time_h, 0) AS integer),
				DATEADD(day,    DATEPART(day,   defi_rect.rectify_date) - 1, 
				DATEADD(month,  DATEPART(month, defi_rect.rectify_date) - 1, 
				DATEADD(year,   DATEPART(year,  defi_rect.rectify_date) - 1900, 0)))))) >= @FromDateTime
				);

	/* Create XML data string */
	BEGIN TRY
		SET @xmlISRectifications = 
			(
			SELECT
				complaint_no AS Reference
				,contract_ref AS [Contract]
				,seq_no AS SequenceNo
				,default_level AS RectificationLevel
				,action_flag AS ActionCode
				,item_ref AS Item
				,item_desc AS ItemDesc
				,feature_ref AS Feature
				,feature_desc AS FeatureDesc
				,notice_type AS NoticeType
				,points AS Points
				,value AS Value
				,trans_date AS TransTime
				,cust_def_no AS CustomerDef
				,[start_date] AS StartDateTime
				,site_ref AS [Site]
				,location_c AS USRN
				,site_name_1 AS SiteName1
				,site_name_2 AS SiteName2
				,location_name AS LocationName
				,volume AS Volume
				,cum_points AS CumlPoints
				,cum_value AS CumlValue
				,default_reason AS ItemReason
				,lookup_text AS ItemReasonDesc
				,rectify_date AS DateDue
				,closed AS Closed
				,(SELECT
					(DATEADD(minute, CAST(ISNULL(ReText.time_entered_h, 0) AS integer),
					DATEADD(hour,   CAST(ISNULL(ReText.time_entered_h, 0) AS integer),
					DATEADD(day,    DATEPART(day,   ReText.doa) - 1, 
					DATEADD(month,  DATEPART(month, ReText.doa) - 1, 
					DATEADD(year,   DATEPART(year,  ReText.doa) - 1900, 0)))))) AS [Date]
					,ReText.txt AS [Text]
					FROM defi_nb AS ReText
					WHERE ReText.default_no = ISRectification.cust_def_no
					ORDER BY seq_no
					FOR XML AUTO, ELEMENTS, TYPE, ROOT('Texts'))
				FROM #tempDefh AS ISRectification
				where rank_number=1
				ORDER BY complaint_no
				FOR XML AUTO, ELEMENTS, TYPE, ROOT('ArrayOfISRectification')
			);
	END TRY
	BEGIN CATCH
		SET @errornumber = '20749';
		SET @errortext = 'Error creating XML data string @xmlISRectifications';
		GOTO errorexit;
	END CATCH

	/* Update the transfer log */
	/* XML data string will be fully formed, */
	/* and assuming that the transfer log will be updated without mishap */
	DECLARE csr_itl CURSOR FOR
		SELECT complaint_no
		FROM #tempDefh
		where rank_number=1
		ORDER BY complaint_no;

	OPEN csr_itl;

	FETCH NEXT FROM csr_itl INTO
		@complaint_no;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		BEGIN TRY
			EXECUTE dbo.csis_itl_updateRecord
				@complaint_no
				,NULL
				,NULL
				,NULL
				,1;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20750';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH

		FETCH NEXT FROM csr_itl INTO
			@complaint_no;
	END

	CLOSE csr_itl;
	DEALLOCATE csr_itl;

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END

GO
