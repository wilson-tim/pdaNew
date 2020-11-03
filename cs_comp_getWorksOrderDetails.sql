/*****************************************************************************
** dbo.cs_comp_getWorksOrderDetails
** stored procedure
**
** Description
** Selection of customer care works order data for a specified complaint_no
**   for use with an inspection list works order item
**
** Parameters
** @complaint_no = complaint number
** @xmlWoh = works order header XML structure (output)
**
** Returned
** Result set of customer care works order data
** Return value of rowcount (should be 1) if successful, otherwise -1
**
** Notes
**
** History
** 30/05/2013  TW  New
** 04/06/2013  TW  Revised to return an XML structure
** 05/06/2013  TW  Additional columns
** 19/06/2013  TW  Additional output parameter @xmlWoi
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_comp_getWorksOrderDetails', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comp_getWorksOrderDetails;
GO
CREATE PROCEDURE dbo.cs_comp_getWorksOrderDetails
	@pcomplaint_no integer
	,@xmlWoh xml OUTPUT
	,@xmlWoi xml OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @rowcount integer
		,@errortext varchar(500)
		,@errornumber varchar(10)
		,@complaint_no integer
		,@wo_ref integer
		,@wo_suffix varchar(6)
		,@contract_ref varchar(12);

	SET @errornumber = '20495';

	SET @complaint_no = @pcomplaint_no;

	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @errornumber = '20496';
		SET @errortext = 'complaint_no is required';
		GOTO errorexit;
	END

	IF OBJECT_ID('tempdb..#tempWoh') IS NOT NULL
	BEGIN
		DROP TABLE #tempWoh;
	END
	SELECT
		xmldoc.woh.value('wo_ref[1]','integer') AS 'wo_ref'
		,xmldoc.woh.value('wo_suffix[1]','varchar(6)') AS 'wo_suffix'
		,xmldoc.woh.value('wo_key[1]','integer') AS 'wo_key'
		,xmldoc.woh.value('service_c[1]','varchar(6)') AS 'service_c'
		,xmldoc.woh.value('date_raised[1]','datetime') AS 'date_raised'
		,xmldoc.woh.value('time_raised_h[1]','varchar(2)') AS 'time_raised_h'
		,xmldoc.woh.value('time_raised_m[1]','varchar(2)') AS 'time_raised_m'
		,xmldoc.woh.value('username[1]','varchar(8)') AS 'username'
		,xmldoc.woh.value('del_site_ref[1]','varchar(16)') AS 'del_site_ref'
		,xmldoc.woh.value('del_comp_name[1]','varchar(100)') AS 'del_comp_name'
		,xmldoc.woh.value('del_contact[1]','varchar(40)') AS 'del_contact'
		,xmldoc.woh.value('del_trade_contact[1]','varchar(60)') AS 'del_trade_contact'
		,xmldoc.woh.value('del_build_no[1]','varchar(14)') AS 'del_build_no'
		,xmldoc.woh.value('del_build_name[1]','varchar(60)') AS 'del_build_name'
		,xmldoc.woh.value('del_addr1[1]','varchar(100)') AS 'del_addr1'
		,xmldoc.woh.value('del_addr2[1]','varchar(100)') AS 'del_addr2'
		,xmldoc.woh.value('del_addr3[1]','varchar(100)') AS 'del_addr3'
		,xmldoc.woh.value('del_addr4[1]','varchar(30)') AS 'del_addr4'
		,xmldoc.woh.value('del_addr5[1]','varchar(30)') AS 'del_addr5'
		,xmldoc.woh.value('del_addr6[1]','varchar(30)') AS 'del_addr6'
		,xmldoc.woh.value('del_postcode[1]','varchar(8)') AS 'del_postcode'
		,xmldoc.woh.value('del_phone[1]','varchar(20)') AS 'del_phone'
		,xmldoc.woh.value('del_fax[1]','varchar(20)') AS 'del_fax'
		,xmldoc.woh.value('del_mobile[1]','varchar(20)') AS 'del_mobile'
		,xmldoc.woh.value('del_email[1]','varchar(40)') AS 'del_email'
		,xmldoc.woh.value('inv_site_ref[1]','varchar(16)') AS 'inv_site_ref'
		,xmldoc.woh.value('inv_comp_name[1]','varchar(100)') AS 'inv_comp_name'
		,xmldoc.woh.value('inv_contact[1]','varchar(40)') AS 'inv_contact'
		,xmldoc.woh.value('inv_build_no[1]','varchar(14)') AS 'inv_build_no'
		,xmldoc.woh.value('inv_build_name[1]','varchar(60)') AS 'inv_build_name'
		,xmldoc.woh.value('inv_addr1[1]','varchar(100)') AS 'inv_addr1'
		,xmldoc.woh.value('inv_addr2[1]','varchar(100)') AS 'inv_addr2'
		,xmldoc.woh.value('inv_addr3[1]','varchar(100)') AS 'inv_addr3'
		,xmldoc.woh.value('inv_addr4[1]','varchar(30)') AS 'inv_addr4'
		,xmldoc.woh.value('inv_addr5[1]','varchar(30)') AS 'inv_addr5'
		,xmldoc.woh.value('inv_addr6[1]','varchar(30)') AS 'inv_addr6'
		,xmldoc.woh.value('inv_postcode[1]','varchar(8)') AS 'inv_postcode'
		,xmldoc.woh.value('inv_phone[1]','varchar(20)') AS 'inv_phone'
		,xmldoc.woh.value('inv_fax[1]','varchar(20)') AS 'inv_fax'
		,xmldoc.woh.value('inv_mobile[1]','varchar(20)') AS 'inv_mobile'
		,xmldoc.woh.value('inv_email[1]','varchar(40)') AS 'inv_email'
		,xmldoc.woh.value('account_ref[1]','varchar(12)') AS 'account_ref'
		,xmldoc.woh.value('contract_ref[1]','varchar(12)') AS 'contract_ref'
		,xmldoc.woh.value('wo_budg_ref[1]','varchar(20)') AS 'wo_budg_ref'
		,xmldoc.woh.value('wo_type_f[1]','varchar(2)') AS 'wo_type_f'
		,xmldoc.woh.value('wo_h_stat[1]','varchar(3)') AS 'wo_h_stat'
		,xmldoc.woh.value('action_ref[1]','varchar(12)') AS 'action_ref'
		,xmldoc.woh.value('wo_text[1]','varchar(40)') AS 'wo_text'
		,xmldoc.woh.value('wo_paymeth[1]','varchar(6)') AS 'wo_paymeth'
		,xmldoc.woh.value('wo_payref[1]','varchar(12)') AS 'wo_payref'
		,xmldoc.woh.value('wo_pay_date[1]','datetime') AS 'wo_pay_date'
		,xmldoc.woh.value('wo_pay_comments[1]','varchar(50)') AS 'wo_pay_comments'
		,xmldoc.woh.value('wo_payment_f[1]','varchar(1)') AS 'wo_payment_f'
		,xmldoc.woh.value('wo_paycl_dte[1]','datetime') AS 'wo_paycl_dte'
		,xmldoc.woh.value('wo_recharge_ref[1]','varchar(20)') AS 'wo_recharge_ref'
		,xmldoc.woh.value('wo_date_due[1]','datetime') AS 'wo_date_due'
		,xmldoc.woh.value('expected_time_m[1]','varchar(2)') AS 'expected_time_m'
		,xmldoc.woh.value('wo_date_compl[1]','datetime') AS 'wo_date_compl'
		,xmldoc.woh.value('wo_est_value[1]','decimal(13,4)') AS 'wo_est_value'
		,xmldoc.woh.value('wo_act_value[1]','decimal(13,4)') AS 'wo_act_value'
		,xmldoc.woh.value('expected_time_h[1]','varchar(2)') AS 'expected_time_h'
		,xmldoc.woh.value('card_id[1]','varchar(20)') AS 'card_id'
		,xmldoc.woh.value('auth_code[1]','varchar(6)') AS 'auth_code'
		,xmldoc.woh.value('expiry_month[1]','varchar(2)') AS 'expiry_month'
		,xmldoc.woh.value('expiry_year[1]','varchar(2)') AS 'expiry_year'
		,xmldoc.woh.value('wo_paycc_flag[1]','varchar(1)') AS 'wo_paycc_flag'
		,xmldoc.woh.value('wo_payissue[1]','varchar(3)') AS 'wo_payissue'
		,xmldoc.woh.value('wo_paycard_holder[1]','varchar(100)') AS 'wo_paycard_holder'
		,xmldoc.woh.value('wo_paycard_type[1]','varchar(6)') AS 'wo_paycard_type'
		,xmldoc.woh.value('wo_paycard_amt[1]','decimal(13,2)') AS 'wo_paycard_amt'
		,xmldoc.woh.value('wo_paycard_secure[1]','varchar(3)') AS 'wo_paycard_secure'
		,xmldoc.woh.value('wo_valfrom_month[1]','varchar(2)') AS 'wo_valfrom_month'
		,xmldoc.woh.value('wo_valfrom_year[1]','varchar(2)') AS 'wo_valfrom_year'
		,xmldoc.woh.value('blank1[1]','varchar(6)') AS 'blank1'
		,xmldoc.woh.value('blank2[1]','varchar(1)') AS 'blank2'
		,xmldoc.woh.value('cycle_no[1]','integer') AS 'cycle_no'
		,xmldoc.woh.value('site_name_1[1]','varchar(140)') AS 'site_name_1'
		,xmldoc.woh.value('service_c_desc[1]','varchar(40)') AS 'service_c_desc'
		,xmldoc.woh.value('contract_desc[1]','varchar(40)') AS 'contract_desc'
		,xmldoc.woh.value('wo_type_f_desc[1]','varchar(12)') AS 'wo_type_f_desc'
		,xmldoc.woh.value('wo_h_stat_desc[1]','varchar(20)') AS 'wo_h_stat_desc'
		,xmldoc.woh.value('exact_location[1]','varchar(70)') AS 'exact_location'
		,xmldoc.woh.value('contractor_reminders_1[1]','varchar(70)') AS 'contractor_reminders_1'
		,xmldoc.woh.value('contractor_reminders_2[1]','varchar(70)') AS 'contractor_reminders_2'
	INTO #tempWoh
	FROM @xmlWoh.nodes('/WorksOrderCoreHDTO') AS xmldoc(woh);

	BEGIN TRY
		INSERT INTO #tempWoh
			(
			wo_ref
			,wo_suffix
			,wo_key
			,service_c
			,service_c_desc
			,contract_ref
			,contract_desc
			,wo_type_f
			,wo_type_f_desc
			,wo_h_stat
			,wo_h_stat_desc
			,date_raised
			,wo_date_due
			,del_comp_name
			,del_contact
			,del_phone
			,site_name_1
			,exact_location
			,contractor_reminders_1
			,contractor_reminders_2
			)
			SELECT
				wo_h.wo_ref
				,wo_h.wo_suffix
				,wo_h.wo_key
				,wo_h.service_c
				,(SELECT TOP(1) pda_lookup.service_c_desc FROM pda_lookup WHERE pda_lookup.service_c = wo_h.service_c AND pda_lookup.role_name = 'pda-in') AS service_c_desc
				,wo_h.contract_ref
				,(SELECT TOP(1) [contract_name] FROM cont, c_da WHERE cont.contract_ref = wo_h.contract_ref AND service_c = wo_h.service_c AND c_da.period_start <= wo_h.date_raised AND c_da.period_finish >= wo_h.date_raised) AS contract_desc
				,wo_h.wo_type_f
				,(SELECT TOP(1) wo_type_desc FROM wo_type WHERE wo_type.wo_type_f = wo_h.wo_type_f) AS wo_type_f_desc
				,wo_h.wo_h_stat
				,(SELECT TOP(1) wo_stat_desc FROM wo_stat WHERE wo_stat.wo_h_stat = wo_h.wo_h_stat) AS wo_h_stat_desc
				,DATEADD(minute, CAST(ISNULL(wo_h.time_raised_m, 0) AS integer),
					DATEADD(hour,   CAST(ISNULL(wo_h.time_raised_h, 0) AS integer),
					DATEADD(day,    DATEPART(day,   wo_h.date_raised) - 1, 
					DATEADD(month,  DATEPART(month, wo_h.date_raised) - 1, 
					DATEADD(year,   DATEPART(year,  wo_h.date_raised) - 1900, 0))))) AS date_raised
				,DATEADD(minute, CAST(ISNULL(wo_h.expected_time_m, 0) AS integer),
					DATEADD(hour,   CAST(ISNULL(wo_h.expected_time_h, 0) AS integer),
					DATEADD(day,    DATEPART(day,   wo_h.wo_date_due) - 1, 
					DATEADD(month,  DATEPART(month, wo_h.wo_date_due) - 1, 
					DATEADD(year,   DATEPART(year,  wo_h.wo_date_due) - 1900, 0))))) AS wo_date_due
				,wo_h.del_comp_name
				,wo_h.del_contact
				,wo_h.del_phone
				,RTRIM(LTRIM(RTRIM(ISNULL([site].site_name_1, ''))) + ' ' + LTRIM(RTRIM(ISNULL([site].site_name_2, '')))) AS site_name_1
				,comp.exact_location
				,wo_cont_h.cont_rem1 AS contractor_reminders_1
				,wo_cont_h.cont_rem2 AS contractor_reminders_2
				FROM comp
				INNER JOIN wo_h
				ON wo_h.wo_ref = comp.dest_ref
					AND wo_h.wo_suffix = comp.dest_suffix
				LEFT OUTER JOIN wo_cont_h
				ON wo_cont_h.wo_ref = wo_h.wo_ref
					AND wo_cont_h.wo_suffix = wo_h.wo_suffix
				LEFT OUTER JOIN [site]
				ON [site].site_ref = comp.site_ref
				WHERE complaint_no = @complaint_no;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20572';
		SET @errortext = 'Error inserting #tempWoh record(s)';
		GOTO errorexit;
	END CATCH
				
	/* Check that only a single row has been found */
	SELECT @rowcount = COUNT(*)
		FROM #tempWoh;
	IF @rowcount > 1
	BEGIN
		SET @errornumber = '20497';
		SET @errortext = 'Multiple records found';
		GOTO errorexit;
	END

	BEGIN TRY
		SET @xmlWoh = (SELECT * FROM #tempWoh FOR XML PATH('WorksOrderCoreHDTO'))
	END TRY
	BEGIN CATCH
		SET @errornumber = '20573';
		SET @errortext = 'Error updating @xmlWoh';
		GOTO errorexit;
	END CATCH

	SELECT @wo_ref = wo_ref
		,@wo_suffix = wo_suffix
		,@contract_ref = contract_ref
		FROM #tempWoh;

	IF OBJECT_ID('tempdb..#tempWoi') IS NOT NULL
	BEGIN
		DROP TABLE #tempWoi;
	END
	SELECT
		xmldoc.woi.value('woi_serial_no[1]','integer') AS 'woi_serial_no'
		,xmldoc.woi.value('wo_ref[1]','integer') AS 'wo_ref'
		,xmldoc.woi.value('wo_suffix[1]','varchar(6)') AS 'wo_suffix'
		,xmldoc.woi.value('woi_no[1]','integer') AS 'woi_no'
		,xmldoc.woi.value('woi_site_ref[1]','varchar(16)') AS 'woi_site_ref'
		,xmldoc.woi.value('woi_task_ref[1]','varchar(12)') AS 'woi_task_ref'
		,xmldoc.woi.value('woi_feature_ref[1]','varchar(12)') AS 'woi_feature_ref'
		,xmldoc.woi.value('woi_item_ref[1]','varchar(12)') AS 'woi_item_ref'
		,xmldoc.woi.value('woi_volume[1]','decimal(11,3)') AS 'woi_volume'
		,xmldoc.woi.value('woi_item_price[1]','decimal(15,8)') AS 'woi_item_price'
		,xmldoc.woi.value('woi_line_total[1]','decimal(11,2)') AS 'woi_line_total'
		,xmldoc.woi.value('woi_comp_date[1]','datetime') AS 'woi_comp_date'
		,xmldoc.woi.value('woi_act_comp[1]','datetime') AS 'woi_act_comp'
		,xmldoc.woi.value('woi_text_flag[1]','varchar(1)') AS 'woi_text_flag'
		,xmldoc.woi.value('del_build_no[1]','varchar(14)') AS 'del_build_no'
		,xmldoc.woi.value('del_build_name[1]','varchar(60)') AS 'del_build_name'
		,xmldoc.woi.value('del_addr1[1]','varchar(100)') AS 'del_addr1'
		,xmldoc.woi.value('del_addr2[1]','varchar(100)') AS 'del_addr2'
		,xmldoc.woi.value('allocation_ref[1]','varchar(20)') AS 'allocation_ref'
		,xmldoc.woi.value('payment_f[1]','varchar(1)') AS 'payment_f'
		,xmldoc.woi.value('woi_act_vol[1]','decimal(11,3)') AS 'woi_act_vol'
		,xmldoc.woi.value('woi_act_price[1]','decimal(13,4)') AS 'woi_act_price'
		,xmldoc.woi.value('woi_act_line_total[1]','decimal(13,4)') AS 'woi_act_line_total'
		,xmldoc.woi.value('blank1[1]','varchar(6)') AS 'blank1'
		,xmldoc.woi.value('blank2[1]','varchar(6)') AS 'blank2'
		,xmldoc.woi.value('woi_buy_price[1]','decimal(15,8)') AS 'woi_buy_price'
		,xmldoc.woi.value('woi_buy_value[1]','decimal(11,2)') AS 'woi_buy_value'
		,xmldoc.woi.value('task_desc[1]','varchar(40)') AS 'task_desc'
		,xmldoc.woi.value('item_desc[1]','varchar(40)') AS 'item_desc'
		,xmldoc.woi.value('feature_desc[1]','varchar(40)') AS 'feature_desc'
	INTO #tempWoi
	FROM @xmlwoi.nodes('/ArrayOfWorksOrderCoreIDTO/WorksOrderCoreIDTO') AS xmldoc(woi);
				
	BEGIN TRY
		INSERT INTO #tempWoi
			(
			woi_serial_no
			,wo_ref
			,wo_suffix
			,woi_no
			,woi_site_ref
			,woi_task_ref
			,task_desc
			,woi_feature_ref
			,feature_desc
			,woi_item_ref
			,item_desc
			,woi_volume
			,woi_item_price
			,woi_line_total
			,woi_comp_date
			,woi_act_comp
			,woi_text_flag
			,del_build_no
			,del_build_name
			,del_addr1
			,del_addr2
			,allocation_ref
			,payment_f
			,woi_act_vol
			,woi_act_price
			,woi_act_line_total
			,blank1
			,blank2
			,woi_buy_price
			,woi_buy_value
			)
			SELECT
				woi_serial_no
				,wo_ref
				,wo_suffix
				,woi_no
				,woi_site_ref
				,woi_task_ref
				,(SELECT task.task_desc FROM task WHERE task.task_ref = wo_i.woi_task_ref) AS task_desc
				,woi_feature_ref
				,(SELECT feat.feature_desc FROM feat WHERE feat.feature_ref = wo_i.woi_feature_ref) AS feature_desc
				,woi_item_ref
				,(SELECT item.item_desc FROM item WHERE item.item_ref = wo_i.woi_item_ref AND item.contract_ref = @contract_ref AND item.customer_care_yn = 'Y') AS item_desc
				,woi_volume
				,woi_item_price
				,woi_line_total
				,woi_comp_date
				,woi_act_comp
				,woi_text_flag
				,LTRIM(RTRIM(del_build_no)) AS del_build_no
				,del_build_name
				,del_addr1
				,del_addr2
				,allocation_ref
				,payment_f
				,woi_act_vol
				,woi_act_price
				,woi_act_line_total
				,blank1
				,blank2
				,woi_buy_price
				,woi_buy_value
				FROM wo_i
				WHERE wo_ref = @wo_ref
					AND wo_suffix = @wo_suffix;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20613';
		SET @errortext = 'Error inserting #tempWoi record(s)';
		GOTO errorexit;
	END CATCH
				
	BEGIN TRY
		SET @xmlWoi = (SELECT * FROM #tempWoi FOR XML PATH('WorksOrderCoreIDTO'), ROOT('ArrayOfWorksOrderCoreIDTO'));
	END TRY
	BEGIN CATCH
		SET @errornumber = '20614';
		SET @errortext = 'Error updating @xmlWoi';
		GOTO errorexit;
	END CATCH

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO
