/*****************************************************************************
** dbo.csis_woh_getWorksOrders
** stored procedure
**
** Description
** Selects new works orders
**
** Parameters
** @user_name    = user name
** @FromDateTime = date due threshold (optional)
** @service_c    = service (optional)
** @wo_suffix    = works order suffix (optional)
**
** Returned
** @xmlISWorksOrders = works order data in XML format
**
** History
** 02/08/2013  TW  New
** 05/08/2013  TW  Continued development
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.csis_woh_getWorksOrders', N'P') IS NOT NULL
    DROP PROCEDURE dbo.csis_woh_getWorksOrders;
GO
CREATE PROCEDURE dbo.csis_woh_getWorksOrders
	@puser_name varchar(8)
	,@pFromDateTime datetime = NULL
	,@pservice_c varchar(6) = NULL
	,@pwo_suffix varchar(6) = NULL
	,@xmlISWorksOrders xml OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500)
		,@errornumber varchar(10)
		,@rowcount integer
		,@user_name varchar(8)
		,@FromDateTime datetime
		,@service_c varchar(6)
		,@wo_suffix varchar(6)
		,@complaint_no integer
		;

	SET @user_name = LTRIM(RTRIM(@puser_name));
	SET @FromDateTime = @pFromDateTime;
	SET @service_c = LTRIM(RTRIM(@pservice_c));
	SET @wo_suffix = LTRIM(RTRIM(@pwo_suffix));

	/* @user_name validation */
	IF @user_name = '' OR @user_name IS NULL
	BEGIN
		SET @errornumber = '20703';
		SET @errortext = 'user_name is required';
		GOTO errorexit;
	END

	/* @service_c validation */
	IF @service_c <> '' AND @service_c IS NOT NULL
	BEGIN
		SELECT @rowcount = COUNT(*)
			FROM pda_lookup
			WHERE pda_lookup.role_name = 'pda-in'
			/*
				(
				SELECT keys.c_field
					FROM keys
					WHERE keys.service_c = 'ALL'
						AND keys.keyname = 'PDA_INSPECTOR_ROLE'
				)
			*/
			AND LTRIM(RTRIM(pda_lookup.service_c)) = @service_c;
		IF @rowcount = 0
		BEGIN
			SET @errornumber = '20704';
			SET @errortext = @service_c + ' is not a valid service code';
			GOTO errorexit;
		END
	END

	/* @wo_suffix validation */
	IF @wo_suffix <> '' AND @wo_suffix IS NOT NULL
	BEGIN
		SELECT @rowcount = COUNT(*)
			FROM wo_s
			WHERE wo_suffix = @wo_suffix;
		IF @rowcount = 0
		BEGIN
			SET @errornumber = '20705';
			SET @errortext = @wo_suffix + ' is not a valid works order suffix code';
			GOTO errorexit;
		END
	END

	IF OBJECT_ID('tempdb..#tempWoh') IS NOT NULL
	BEGIN
		DROP TABLE #tempWoh;
	END

	/* Select works orders */
	SELECT
		comp.complaint_no
		,wo_h.contract_ref
		,wo_h.wo_ref
		,wo_h.wo_suffix
		,wo_h.wo_key
		,wo_h.service_c
		,(DATEADD(minute, CAST(ISNULL(wo_h.time_raised_m, 0) AS integer),
				DATEADD(hour,   CAST(ISNULL(wo_h.time_raised_h, 0) AS integer),
				DATEADD(day,    DATEPART(day,   wo_h.date_raised) - 1, 
				DATEADD(month,  DATEPART(month, wo_h.date_raised) - 1, 
				DATEADD(year,   DATEPART(year,  wo_h.date_raised) - 1900, 0)))))) AS date_raised
		,wo_h.del_site_ref
		,wo_h.del_comp_name
		,wo_h.del_contact
		,wo_h.del_trade_contact
		,wo_h.del_build_no
		,wo_h.del_build_name
		,wo_h.del_addr1
		,wo_h.del_addr2
		,wo_h.del_addr3
		,wo_h.del_addr4
		,wo_h.del_addr5
		,wo_h.del_addr6
		,wo_h.del_postcode
		,wo_h.del_phone
		,wo_h.del_email
		,wo_h.wo_type_f
		,wo_h.wo_h_stat
		,wo_h.wo_text
		,wo_h.wo_date_due
		INTO #tempWoh
		FROM wo_h
		INNER JOIN comp
		ON comp.dest_ref = wo_h.wo_ref
			AND comp.dest_suffix = wo_h.wo_suffix
		LEFT OUTER JOIN integration_transfer_log itl
		ON itl.complaint_no = comp.complaint_no
		WHERE wo_h.wo_h_stat IN (SELECT wo_stat.wo_h_stat FROM wo_stat WHERE wo_stat.issue = 'Y')
			AND (itl.contractor_ref IS NULL OR itl.contractor_ref = '')
			AND (itl.rejected IS NULL OR itl.rejected <> 'Y')
			AND wo_h.contract_ref IN (SELECT cont_logins.contract_ref FROM cont_logins WHERE cont_logins.login_name = @user_name)
			AND (@FromDateTime IS NULL
				OR
				(DATEADD(minute, CAST(ISNULL(wo_h.expected_time_m, 0) AS integer),
				DATEADD(hour,   CAST(ISNULL(wo_h.expected_time_h, 0) AS integer),
				DATEADD(day,    DATEPART(day,   wo_h.wo_date_due) - 1, 
				DATEADD(month,  DATEPART(month, wo_h.wo_date_due) - 1, 
				DATEADD(year,   DATEPART(year,  wo_h.wo_date_due) - 1900, 0)))))) >= @FromDateTime
				)
			AND ((@service_c = '' OR @service_c IS NULL)
				OR
				wo_h.service_c = @service_c
				)
			AND ((@wo_suffix = '' OR @wo_suffix IS NULL)
				OR
				wo_h.wo_suffix = @wo_suffix
				);

	/* Create XML data string */
	BEGIN TRY
		SET @xmlISWorksOrders = 
			(
			SELECT
				complaint_no AS Reference
				,contract_ref AS [Contract]
				,wo_ref AS WoReference
				,wo_suffix AS Suffix
				,wo_key AS [Key]
				,service_c AS [Service]
				,date_raised AS DateRaised
				,del_site_ref AS DelSiteRef
				,del_comp_name AS DelCompName
				,del_contact AS DelContact
				,LTRIM(RTRIM(del_build_no)) AS DelBuildNo
				,del_build_name AS DelBuildName
				,del_addr1 AS DelAddr1
				,del_addr1 AS DelAddr2
				,del_addr1 AS DelAddr3
				,del_addr1 AS DelAddr4
				,del_addr1 AS DelAddr5
				,del_addr1 AS DelAddr6
				,del_postcode AS DelPostcode
				,del_phone AS DelPhone
				,del_email AS DelEmail
				,wo_type_f AS [Type]
				,wo_h_stat AS [Status]
				,wo_text AS Text
				,wo_date_due AS DateDue
				,(SELECT
					(DATEADD(minute, CAST(ISNULL(WoText.time_entered_h, 0) AS integer),
					DATEADD(hour,   CAST(ISNULL(WoText.time_entered_h, 0) AS integer),
					DATEADD(day,    DATEPART(day,   WoText.doa) - 1, 
					DATEADD(month,  DATEPART(month, WoText.doa) - 1, 
					DATEADD(year,   DATEPART(year,  WoText.doa) - 1900, 0)))))) AS [Date]
					,WoText.txt AS [Text]
					FROM wo_h_txt AS WoText
					WHERE WoText.wo_ref = ISWorksOrder.wo_ref
						AND WoText.wo_suffix = ISWorksOrder.wo_suffix
					ORDER BY seq
					FOR XML AUTO, ELEMENTS, TYPE, ROOT('HeaderTexts'))
				,(SELECT
					CollectionItem.item_quantity
					,CollectionItem.collection_item
					FROM comp_sched_item AS CollectionItem
					WHERE complaint_no =
						(
						SELECT MAX(complaint_no)
							FROM comp
							WHERE comp.dest_ref = ISWorksOrder.wo_ref
								AND comp.dest_suffix = ISWorksOrder.wo_suffix
						)
					FOR XML AUTO, ELEMENTS, TYPE, ROOT('CollectionItems'))
				,(SELECT
					WoItem.woi_serial_no AS SerialNo
					,WoItem.woi_volume AS Volume
					,WoItem.woi_site_ref AS [Site]
					,NULL AS USRN
					,LTRIM(RTRIM(WoItem.del_build_no)) AS DelBuildNo
					,WoItem.del_build_name AS DelBuildName
					,WoItem.del_addr1 AS DelAddr1
					,WoItem.del_addr2 AS DelAddr2
					,WoItem.woi_act_vol AS ActVol
					,WoItem.woi_task_ref AS Task
					,(SELECT task_desc FROM task WHERE task.task_ref = WoItem.woi_task_ref) AS TaskDesc
					,(SELECT unit_of_meas FROM task WHERE task.task_ref = WoItem.woi_task_ref) AS UnitOfMeasure
					,(SELECT unit_code FROM task WHERE task.task_ref = WoItem.woi_task_ref) AS UnitCode
					,(SELECT task_code FROM task WHERE task.task_ref = WoItem.woi_task_ref) AS TaskCode
					,(SELECT task_flag FROM task WHERE task.task_ref = WoItem.woi_task_ref) AS TaskFlag
					,(SELECT material_code FROM task WHERE task.task_ref = WoItem.woi_task_ref) AS MaterialCode
					,(SELECT task.wo_type_group FROM task WHERE task.task_ref = WoItem.woi_task_ref) AS TaskGroup
					,(SELECT
						WoText.txt AS [Text]
						FROM wo_i_nb AS WoText
						WHERE WoText.woi_no = WoItem.woi_serial_no
						ORDER BY WoText.seq
						FOR XML AUTO, ELEMENTS, TYPE, ROOT('ItemTexts'))
					FROM wo_i AS WoItem
					WHERE WoItem.wo_ref = ISWorksOrder.wo_ref
						AND WoItem.wo_suffix = ISWorksOrder.wo_suffix
					FOR XML AUTO, ELEMENTS, TYPE, ROOT('WoItems'))
				,(SELECT [Status].wo_h_stat AS Code
					,(SELECT wo_stat.wo_stat_desc FROM wo_stat WHERE wo_stat.wo_h_stat = [Status].wo_h_stat) AS [Description]
					FROM wo_next_stat AS [Status]
					WHERE [Status].wo_next_stat = ISWorksOrder.wo_h_stat
						AND (SELECT wo_stat.remote_status FROM wo_stat WHERE wo_stat.wo_h_stat = [Status].wo_h_stat) = 'Y'
					FOR XML AUTO, ELEMENTS, TYPE, ROOT('NextStatus'))
				FROM #tempWoh AS ISWorksOrder
				ORDER BY complaint_no
				FOR XML AUTO, ELEMENTS, TYPE, ROOT('ArrayOfISWorksOrder')
			);
	END TRY
	BEGIN CATCH
		SET @errornumber = '20706';
		SET @errortext = 'Error creating XML data string @xmlISWorksOrders';
		GOTO errorexit;
	END CATCH

	/* Update the transfer log */
	/* XML data string will be fully formed, */
	/* and assuming that the transfer log will be updated without mishap */
	DECLARE csr_itl CURSOR FOR
		SELECT complaint_no
		FROM #tempWoh
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
			SET @errornumber = '20707';
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
