/*****************************************************************************
** dbo.cs_woh_createRecordCore
** stored procedure
**
** Description
** Create a works order
**
** Parameters
** @complaint_no = complaint number
** @xmlWoh       = XML structure containing wo_h record
** @xmlWoi       = XML structure containing wo_i record(s)
**
** Returned
** All passed parameters are INPUT and OUTPUT
** Return value of new wo_ref or -1
**
** Notes
** data passed in via XML
** extract data into temporary table
** validate key data
** do stuff
** update data in temporary table
** convert data in temporary table into XML and return to caller
**
** History
** 10/01/2013  TW  New
** 14/01/2013  TW  Continued
** 07/05/2013  TW  Revised to populate wo_budg_ref, woi_buy_price, woi_buy_value
**                 Validation for new woh element cycle_no
** 20/06/2013  TW  Fix for incorrect error message text
** 15/07/2013  TW  Check for 'COMP_TEXT TO WO' system key and notes copying
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_woh_createRecordCore', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_woh_createRecordCore;
GO
CREATE PROCEDURE dbo.cs_woh_createRecordCore
	@complaint_no integer,
	@xmlWoh xml OUTPUT,
	@xmlWoi xml OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @result integer
		,@errortext varchar(500)
		,@errornumber varchar(10)
		,@comp_rowcount integer
		,@woh_rowcount integer
		,@woi_rowcount integer
		,@woi_rowcount_distinct integer
		,@wo_ref integer
		,@wo_suffix varchar(6)
		,@wo_key integer
		,@service_c varchar(6)
		,@date_raised datetime
		,@time_raised_h varchar(2)
		,@time_raised_m varchar(2)
		,@username varchar(8)
		,@del_site_ref varchar(16)
		,@del_comp_name varchar(100)
		,@del_contact varchar(40)
		,@del_trade_contact varchar(60)
		,@del_build_no varchar(14)
		,@del_build_name varchar(60)
		,@del_addr1 varchar(100)
		,@del_addr2 varchar(100)
		,@del_addr3 varchar(100)
		,@del_addr4 varchar(30)
		,@del_addr5 varchar(30)
		,@del_addr6 varchar(30)
		,@del_postcode varchar(8)
		,@del_phone varchar(20)
		,@del_fax varchar(20)
		,@del_mobile varchar(20)
		,@del_email varchar(40)
		,@inv_site_ref varchar(16)
		,@inv_comp_name varchar(100)
		,@inv_contact varchar(40)
		,@inv_build_no varchar(14)
		,@inv_build_name varchar(60)
		,@inv_addr1 varchar(100)
		,@inv_addr2 varchar(100)
		,@inv_addr3 varchar(100)
		,@inv_addr4 varchar(30)
		,@inv_addr5 varchar(30)
		,@inv_addr6 varchar(30)
		,@inv_postcode varchar(8)
		,@inv_phone varchar(20)
		,@inv_fax varchar(20)
		,@inv_mobile varchar(20)
		,@inv_email varchar(40)
		,@account_ref varchar(12)
		,@contract_ref varchar(12)
		,@wo_budg_ref varchar(20)
		,@wo_type_f varchar(2)
		,@wo_h_stat varchar(3)
		,@action_ref varchar(12)
		,@wo_text varchar(40)
		,@wo_paymeth varchar(6)
		,@wo_payref varchar(12)
		,@wo_pay_date datetime
		,@wo_pay_comments varchar(50)
		,@wo_payment_f varchar(1)
		,@wo_paycl_dte datetime
		,@wo_recharge_ref varchar(20)
		,@wo_date_due datetime
		,@expected_time_m varchar(2)
		,@wo_date_compl datetime
		,@wo_est_value decimal(13,4)
		,@wo_act_value decimal(13,4)
		,@expected_time_h varchar(2)
		,@card_id varchar(20)
		,@auth_code varchar(6)
		,@expiry_month varchar(2)
		,@expiry_year varchar(2)
		,@wo_paycc_flag varchar(1)
		,@wo_payissue varchar(3)
		,@wo_paycard_holder varchar(100)
		,@wo_paycard_type varchar(6)
		,@wo_paycard_amt decimal(13,2)
		,@wo_paycard_secure varchar(3)
		,@wo_valfrom_month varchar(2)
		,@wo_valfrom_year varchar(2)
		,@woh_blank1 varchar(6)
		,@woh_blank2 varchar(1)
		,@entered_by varchar(8)
		,@compl_init varchar(10)
		,@compl_name varchar(100)
		,@compl_surname varchar(100)
		,@compl_addr6 varchar(30)
		,@disp_county_or_post char(1)
		,@cont_cycle_no integer
		,@woi_serial_no integer
		,@woi_no integer
		,@woi_site_ref varchar(16)
		,@woi_task_ref varchar(12)
		,@woi_feature_ref varchar(12)
		,@woi_item_ref varchar(12)
		,@woi_volume decimal(11,3)
		,@woi_item_price decimal(15,8)
		,@woi_line_total decimal(11,2)
		,@woi_comp_date datetime
		,@woi_act_comp datetime
		,@woi_text_flag varchar(1)
		,@allocation_ref varchar(20)
		,@payment_f varchar(1)
		,@woi_act_vol decimal(11,3)
		,@woi_act_price decimal(13,4)
		,@woi_act_line_total decimal(13,4)
		,@woi_blank1 varchar(6)
		,@woi_blank2 varchar(6)
		,@woi_buy_price decimal(15,8)
		,@woi_buy_value decimal(11,2)
		,@wo_stat_enhancements char(1)
		,@unit_of_measure integer
		,@wo_diry_ref integer
		,@comp_diry_ref integer
		,@item_ref varchar(12)
		,@pa_area varchar(6)
		,@site_ref varchar(16)
		,@numberstr varchar(2)
		/* Notes variables */
		,@wohtxt_seq integer
		,@wohtxt_username varchar(8)
		,@wohtxt_doa datetime
		,@wohtxt_time_entered_h char(2)
		,@wohtxt_time_entered_m char(2)
		,@wohtxt_txt varchar(60)
		;

	SET @errornumber = '13900';
	IF OBJECT_ID('tempdb..#tempWoh') IS NOT NULL
	BEGIN
		DROP TABLE  #tempWoh;
	END

	BEGIN TRY
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
		INTO #tempWoh
		FROM @xmlWoh.nodes('/WorksOrderCoreHDTO') AS xmldoc(woh);

		SELECT @wo_ref = wo_ref
			,@wo_suffix = wo_suffix
			,@wo_key = wo_key
			,@service_c = service_c
			,@date_raised = date_raised
			,@time_raised_h = time_raised_h
			,@time_raised_m = time_raised_m
			,@username = username
			,@del_site_ref = del_site_ref
			,@del_comp_name = del_comp_name
			,@del_contact = del_contact
			,@del_trade_contact = del_trade_contact
			,@del_build_no = del_build_no
			,@del_build_name = del_build_name
			,@del_addr1 = del_addr1
			,@del_addr2 = del_addr2
			,@del_addr3 = del_addr3
			,@del_addr4 = del_addr4
			,@del_addr5 = del_addr5
			,@del_addr6 = del_addr6
			,@del_postcode = del_postcode
			,@del_phone = del_phone
			,@del_fax = del_fax
			,@del_mobile = del_mobile
			,@del_email = del_email
			,@inv_site_ref = inv_site_ref
			,@inv_comp_name = inv_comp_name
			,@inv_contact = inv_contact
			,@inv_build_no = inv_build_no
			,@inv_build_name = inv_build_name
			,@inv_addr1 = inv_addr1
			,@inv_addr2 = inv_addr2
			,@inv_addr3 = inv_addr3
			,@inv_addr4 = inv_addr4
			,@inv_addr5 = inv_addr5
			,@inv_addr6 = inv_addr6
			,@inv_postcode = inv_postcode
			,@inv_phone = inv_phone
			,@inv_fax = inv_fax
			,@inv_mobile = inv_mobile
			,@inv_email = inv_email
			,@account_ref = account_ref
			,@contract_ref = contract_ref
			,@wo_budg_ref = wo_budg_ref
			,@wo_type_f = wo_type_f
			,@wo_h_stat = wo_h_stat
			,@action_ref = action_ref
			,@wo_text = wo_text
			,@wo_paymeth = wo_paymeth
			,@wo_payref = wo_payref
			,@wo_pay_date = wo_pay_date
			,@wo_pay_comments = wo_pay_comments
			,@wo_payment_f = wo_payment_f
			,@wo_paycl_dte = wo_paycl_dte
			,@wo_recharge_ref = wo_recharge_ref
			,@wo_date_due = wo_date_due
			,@expected_time_m = expected_time_m
			,@wo_date_compl = wo_date_compl
			,@wo_est_value = wo_est_value
			,@wo_act_value = wo_act_value
			,@expected_time_h = expected_time_h
			,@card_id = card_id
			,@auth_code = auth_code
			,@expiry_month = expiry_month
			,@expiry_year = expiry_year
			,@wo_paycc_flag = wo_paycc_flag
			,@wo_payissue = wo_payissue
			,@wo_paycard_holder = wo_paycard_holder
			,@wo_paycard_type = wo_paycard_type
			,@wo_paycard_amt = wo_paycard_amt
			,@wo_paycard_secure = wo_paycard_secure
			,@wo_valfrom_month = wo_valfrom_month
			,@wo_valfrom_year = wo_valfrom_year
			,@woh_blank1 = blank1
			,@woh_blank2 = blank2
			,@cont_cycle_no = cycle_no
		FROM #tempWoh;

		SET @woh_rowcount = @@ROWCOUNT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '13901';
		SET @errortext = 'Error processing @xmlWoh';
		GOTO errorexit;
	END CATCH

	IF @woh_rowcount > 1
	BEGIN
		SET @errornumber = '13902';
		SET @errortext = 'Error processing @xmlWoh - too many rows';
		GOTO errorexit;
	END
	IF @woh_rowcount < 1
	BEGIN
		SET @errornumber = '13903';
		SET @errortext = 'Error processing @xmlWoh - no rows found';
		GOTO errorexit;
	END

	IF OBJECT_ID('tempdb..#tempWoi') IS NOT NULL
	BEGIN
		DROP TABLE  #tempWoi;
	END

	BEGIN TRY
		SELECT xmldoc.woi.value('woi_serial_no[1]','integer') AS 'woi_serial_no'
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
		INTO #tempWoi
		FROM @xmlwoi.nodes('/ArrayOfWorksOrderCoreIDTO/WorksOrderCoreIDTO') AS xmldoc(woi);

		SELECT @woi_rowcount = COUNT(*)
			FROM #tempWoi
	END TRY
	BEGIN CATCH
		SET @errornumber = '13904';
		SET @errortext = 'Error processing @xmlWoi';
		GOTO errorexit;
	END CATCH

	IF @woi_rowcount < 1
	BEGIN
		SET @errornumber = '13905';
		SET @errortext = 'Error processing @xmlWoi - no rows found';
		GOTO errorexit;
	END

	SET @contract_ref = LTRIM(RTRIM(@contract_ref));
	SET @wo_suffix = LTRIM(RTRIM(@wo_suffix));
	SET @wo_type_f = LTRIM(RTRIM(@wo_type_f));

	/* @complaint_no validation */
	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @errornumber = '13906';
		SET @errortext = 'complaint_no is required';
		GOTO errorexit;
	END
	SELECT @comp_rowcount = COUNT(*)
		FROM comp
		WHERE complaint_no = @complaint_no
	IF @comp_rowcount <> 1
	BEGIN
		SET @errornumber = '13907';
		SET @errortext = LTRIM(RTRIM(STR(@complaint_no))) + ' is not a valid complaint reference';
		GOTO errorexit;
	END

	SELECT @service_c   = LTRIM(RTRIM(service_c)),
		@entered_by     = LTRIM(RTRIM(entered_by)),
		@del_site_ref   = LTRIM(RTRIM(site_ref)),
		@del_postcode   = LTRIM(RTRIM(postcode)),
		@del_build_no   = LTRIM(RTRIM(build_no)),
		@del_build_name = LTRIM(RTRIM(build_name)),
		@del_addr1      = LTRIM(RTRIM(location_name)),
		@del_addr2      = LTRIM(RTRIM(location_desc)),
		@del_addr3      = LTRIM(RTRIM(area_ward_desc)),
		@del_addr4      = LTRIM(RTRIM(townname)),
		@del_addr5      = LTRIM(RTRIM(countyname)),
		@del_addr6      = LTRIM(RTRIM(posttown)),
		@item_ref       = LTRIM(RTRIM(item_ref)),
		@pa_area        = LTRIM(RTRIM(pa_area)),
		@site_ref       = LTRIM(RTRIM(site_ref))
		FROM comp
		WHERE complaint_no = @complaint_no;

	/* @contract_ref validation */
	IF @contract_ref = '' OR @contract_ref IS NULL
	BEGIN
		SET @errornumber = '13908';
		SET @errortext = 'contract_ref is required';
		GOTO errorexit;
	END
	SELECT [contract_name]
		FROM cont
		WHERE cont.service_c = @service_c;
	IF @@ROWCOUNT = 0
	BEGIN
		SET @errornumber = '13909';
		SET @errortext = @contract_ref + ' is not a valid works order contract reference';
		GOTO errorexit;
	END

	/* @cont_cycle_no validation */
	IF @cont_cycle_no = 0 OR @cont_cycle_no IS NULL
	BEGIN
		SET @errornumber = '20398';
		SET @errortext = 'cont_cycle_no is required';
		GOTO errorexit;
	END

	/* @wo_suffix validation */
	IF @wo_suffix = '' OR @wo_suffix IS NULL
	BEGIN
		SET @errornumber = '13910';
		SET @errortext = 'wo_suffix is required';
		GOTO errorexit;
	END
	SELECT wo_suffix
		FROM wo_s
		WHERE contract_ref = @contract_ref;
	IF @@ROWCOUNT = 0
	BEGIN
		SET @errornumber = '13911';
		SET @errortext = @wo_suffix + ' is not a valid works order suffix code';
		GOTO errorexit;
	END

	/* @wo_type_f validation */
	IF @wo_type_f = '' OR @wo_type_f IS NULL
	BEGIN
		SET @errornumber = '13912';
		SET @errortext = 'wo_type_f is required';
		GOTO errorexit;
	END
	SELECT wo_type_f
		FROM wo_s
		WHERE wo_suffix = @wo_suffix
			AND contract_ref = @contract_ref;
	IF @@ROWCOUNT = 0
	BEGIN
		SET @errornumber = '13913';
		SET @errortext = @wo_type_f + ' is not a valid works order type code';
		GOTO errorexit;
	END

	/* @wo_date_due validation */
	IF @wo_date_due IS NULL
	BEGIN
		SET @errornumber = '13914';
		SET @errortext = 'wo_date_due is required';
		GOTO errorexit;
	END
	/* IF @wo_date_due is historic or more than 1 month ahead... */
	IF @wo_date_due < GETDATE()
		OR @wo_date_due > DATEADD(MONTH, 1, GETDATE())
	BEGIN
		SET @errornumber = '13915';
		SET @errortext = LTRIM(RTRIM(CONVERT(varchar(10), @wo_date_due, 103))) + ' is not a valid works order date due';
		GOTO errorexit;
	END

	/* @woi_task_ref validation */
	SELECT @woi_rowcount_distinct = COUNT(DISTINCT woi_task_ref)
		FROM #tempWoi
	IF @woi_rowcount_distinct <> @woi_rowcount
	BEGIN
		SET @errornumber = '13916';
		SET @errortext = 'Duplicate woi_task_ref values found in @xmlWoi';
		GOTO errorexit;
	END

	DECLARE csr_task CURSOR FOR
		SELECT woi_task_ref
			,woi_volume
			,woi_item_price
		FROM #tempWoi
		ORDER BY woi_task_ref;

	OPEN csr_task;

	FETCH NEXT FROM csr_task INTO
		@woi_task_ref
		,@woi_volume
		,@woi_item_price
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @woi_task_ref = LTRIM(RTRIM(@woi_task_ref));

		IF (@woi_task_ref = '' OR @woi_task_ref IS NULL)
			AND (@woi_volume IS NOT NULL)
			AND (@woi_item_price IS NOT NULL)
		BEGIN
			SET @errornumber = '13917';
			SET @errortext = 'woi_task_ref is required';
			GOTO errorexit;
		END

		SELECT task_ref
			FROM task
			WHERE task_ref = @woi_task_ref
		IF @@ROWCOUNT = 0
		BEGIN
			SET @errornumber = '13918';
			SET @errortext = @wo_type_f + ' is not a valid task reference';
			GOTO errorexit;
		END

		FETCH NEXT FROM csr_task INTO
			@woi_task_ref
			,@woi_volume
			,@woi_item_price
	END

	CLOSE csr_task;
	DEALLOCATE csr_task;

	/* Collect remaining data */
	SELECT @compl_init  = LTRIM(RTRIM(customer.compl_init)),
		@compl_name     = LTRIM(RTRIM(customer.compl_name)), 
		@compl_surname  = LTRIM(RTRIM(customer.compl_surname)),
		@inv_comp_name  = LTRIM(RTRIM(customer.compl_business)),
		@inv_phone      = LTRIM(RTRIM(customer.compl_phone)),
		@inv_email      = LTRIM(RTRIM(customer.compl_email)),
		@inv_site_ref   = LTRIM(RTRIM(customer.compl_site_ref)),
		@inv_postcode   = LTRIM(RTRIM(customer.compl_postcode)),
		@inv_build_no   = LTRIM(RTRIM(customer.compl_build_no)),
		@inv_build_name = LTRIM(RTRIM(customer.compl_build_name)),
		@inv_addr1      = LTRIM(RTRIM(customer.compl_addr2)),
		@inv_addr2      = LTRIM(RTRIM(customer.compl_addr3)),
		@inv_addr3      = LTRIM(RTRIM(customer.compl_addr4)),
		@inv_addr4      = LTRIM(RTRIM(customer.compl_addr5)),
		@compl_addr6    = LTRIM(RTRIM(customer.compl_addr6))
		FROM customer, comp_clink
		WHERE comp_clink.complaint_no = @complaint_no
			AND comp_clink.seq_no =
				(
				SELECT MAX(seq_no)
					FROM comp_clink
					WHERE complaint_no = @complaint_no
				)
			AND customer.customer_no = comp_clink.customer_no

	IF @compl_init <> '' AND @compl_init IS NOT NULL
	BEGIN
		SET @del_contact = @compl_init;
	END
	IF @compl_name <> '' AND @compl_name IS NOT NULL
	BEGIN
		IF @del_contact <> '' AND @del_contact IS NOT NULL
		BEGIN
			SET @del_contact = @del_contact + ' ';
		END
		SET @del_contact = @compl_name;
	END
	IF @compl_surname <> '' AND @compl_surname IS NOT NULL
	BEGIN
		IF @del_contact <> '' AND @del_contact IS NOT NULL
		BEGIN
			SET @del_contact = @del_contact + ' ';
		END
		SET @del_contact = @compl_surname;
	END
	SET @del_contact = LEFT(@del_contact, 100);

	SET @inv_contact = @del_contact;

	SET @del_comp_name = @inv_comp_name;

	SET @del_phone = @inv_phone;

	SET @del_email = @inv_email;

	SET @disp_county_or_post = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'DISP_COUNTY_OR_POST'))));
	IF @disp_county_or_post = 'Y'
	BEGIN
		SET @inv_addr5 = @compl_addr6;
		SET @inv_addr6 = NULL;
	END
	ELSE
	BEGIN
		SET @inv_addr5 = NULL;
		SET @inv_addr6 = @compl_addr6;
	END

	SET @wo_paymeth = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('', 'WO_PAYMETH_PREPD'))));
	IF @wo_paymeth = '' OR @wo_paymeth IS NULL
	BEGIN
		SET @wo_paymeth = 'P';
	END

	SET @wo_h_stat = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField(@service_c, 'WO_H_INIT_STATUS'))));
	IF @wo_h_stat = '' OR @wo_h_stat IS NULL
	BEGIN
		SET @wo_h_stat = 'I';
	END

	/*
	** wo_h table
	*/
	BEGIN TRY
		EXECUTE @result = dbo.cs_sno_getSerialNumber 'WK_ORD', @contract_ref, @serial_no = @wo_ref OUTPUT;

		EXECUTE @result = dbo.cs_sno_getSerialNumber 'wo_h', '', @serial_no = @wo_key OUTPUT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '13919';
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

	SET @wo_budg_ref = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField(@service_c, 'DEFAULT BUDGET'))));

	SET @date_raised = GETDATE();

	SET @numberstr = DATENAME(hour, @date_raised);
	SET @time_raised_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @numberstr = DATENAME(minute, @date_raised);
	SET @time_raised_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));;

	SET @date_raised = CONVERT(datetime, CONVERT(date, @date_raised));

	SET @wo_text = NULL;

	SET @expected_time_h = '23';

	SET @expected_time_m = '59';

	BEGIN TRY
		INSERT INTO wo_h
			(
			wo_ref,
			wo_key,
			wo_suffix,
			service_c,
			date_raised,
			time_raised_h,
			time_raised_m,
			username,
			del_site_ref,
			del_comp_name,
			del_contact,
			del_trade_contact,
			del_build_no,
			del_build_name,
			del_addr1,
			del_addr2,
			del_addr3,
			del_addr4,
			del_addr5,
			del_addr6,
			del_postcode,
			del_phone,
			del_email,
			inv_site_ref,
			inv_comp_name,
			inv_contact,
			inv_build_no,
			inv_build_name,
			inv_addr1,
			inv_addr2,
			inv_addr3,
			inv_addr4,
			inv_addr5,
			inv_addr6,
			inv_postcode,
			inv_phone,
			inv_email,
			account_ref,
			contract_ref,
			wo_budg_ref,
			wo_type_f,
			wo_h_stat,
			action_ref,
			wo_text,
			wo_paymeth,
			wo_payment_f,
			wo_date_due,
			expected_time_h,
			expected_time_m,
			wo_est_value,
			wo_act_value
			)
			VALUES
			(
			@wo_ref,
			@wo_key,
			@wo_suffix,
			@service_c,
			@date_raised,
			@time_raised_h,
			@time_raised_m,
			@entered_by,
			@del_site_ref,
			@del_comp_name,
			@del_contact,
			@del_trade_contact,
			@del_build_no,
			@del_build_name,
			@del_addr1,
			@del_addr2,
			@del_addr3,
			@del_addr4,
			@del_addr5,
			@del_addr6,
			@del_postcode,
			@del_phone,
			@del_email,
			@inv_site_ref,
			@inv_comp_name,
			@inv_contact,
			@inv_build_no,
			@inv_build_name,
			@inv_addr1,
			@inv_addr2,
			@inv_addr3,
			@inv_addr4,
			@inv_addr5,
			@inv_addr6,
			@inv_postcode,
			@inv_phone,
			@inv_email,
			@account_ref,
			@contract_ref,
			@wo_budg_ref,
			@wo_type_f,
			@wo_h_stat,
			@action_ref,
			@wo_text,
			@wo_paymeth,
			@wo_payment_f,
			@wo_date_due,
			@expected_time_h,
			@expected_time_m,
			@wo_est_value,
			@wo_act_value
			);
	END TRY
	BEGIN CATCH
		SET @errornumber = '13920';
		SET @errortext = 'Error inserting wo_h record';
		GOTO errorexit;
	END CATCH

	/*
	** wo_stat_hist table
	*/
	BEGIN TRY
		EXECUTE dbo.cs_wostathist_createRecord
			@wo_ref
			,@wo_suffix
			,@wo_h_stat
			,@entered_by;
	END TRY
	BEGIN CATCH
		SET @errornumber = '13923';
		SET @errortext   = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

	/*
	** wo_cont_h table
	*/
	BEGIN TRY
		INSERT INTO wo_cont_h
			(
			wo_ref,
			wo_suffix
			)
			VALUES
			(
			@wo_ref,
			@wo_suffix
			);
	END TRY
	BEGIN CATCH
		SET @errornumber = '13924';
		SET @errortext = 'Error inserting wo_cont_h record';
		GOTO errorexit;
	END CATCH

	/*
	** wo_i table
	*/
	SET @woi_no = 0;
	SET @wo_act_value = 0;
	SET @wo_est_value = 0;
	SET @woi_act_comp = NULL;
	SET @woi_text_flag = 'N';

	DECLARE csr_woi CURSOR FOR
		SELECT woi_task_ref
			,woi_volume
			,woi_item_price
			,woi_comp_date
		FROM #tempWoi
		ORDER BY woi_task_ref;

	OPEN csr_woi;

	FETCH NEXT FROM csr_woi INTO
		@woi_task_ref
		,@woi_volume
		,@woi_item_price
		,@woi_comp_date;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		BEGIN TRY
			EXECUTE @result = dbo.cs_sno_getSerialNumber 'wo_i', '', @serial_no = @woi_serial_no OUTPUT;
		END TRY
		BEGIN CATCH
			SET @errornumber = '13925';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH

		BEGIN TRY
			/* Update woi_no */
			SET @woi_no = @woi_no + 1;

			SELECT @unit_of_measure = unit_of_meas
				FROM task
				WHERE task_ref = @woi_task_ref;

			/* Calculate line total */
			SET @woi_line_total = @woi_volume * @woi_item_price / @unit_of_measure;
			SET @wo_act_value   = @wo_act_value + @woi_line_total;
			SET @wo_est_value   = @wo_act_value;

			/* Calculate buy value */
			SELECT @woi_buy_price = task_rate
				FROM ta_r
				WHERE ta_r.task_ref = @woi_task_ref
					AND ta_r.rate_band_code = 'BUY'
					AND ta_r.contract_ref =  @contract_ref
					AND ta_r.cont_cycle_no = @cont_cycle_no
					AND ta_r.[start_date] =
						(
						SELECT MAX(start_date)
							FROM ta_r
							WHERE task_ref = @woi_task_ref
								AND ta_r.rate_band_code = 'BUY'
								AND contract_ref = @contract_ref
								AND cont_cycle_no = @cont_cycle_no
								AND [start_date] <= GETDATE()
						);
			SET @woi_buy_value  = @woi_volume * @woi_buy_price / @unit_of_measure;

			INSERT INTO wo_i
				(
				woi_serial_no,
				wo_ref,
				wo_suffix,
				woi_no,
				woi_site_ref,
				woi_task_ref,
				woi_feature_ref,
				woi_item_ref,
				woi_volume,
				woi_item_price,
				woi_line_total,
				woi_comp_date,
				woi_act_comp,
				woi_text_flag,
				del_build_no,
				del_build_name,
				del_addr1,
				del_addr2,
				woi_act_vol,
				woi_act_price,
				woi_act_line_total,
				woi_buy_price,
				woi_buy_value
				)
				VALUES
				(
				@woi_serial_no,
				@wo_ref,
				@wo_suffix,
				@woi_no,
				@site_ref,
				@woi_task_ref,
				NULL,
				NULL,
				@woi_volume,
				@woi_item_price,
				@woi_line_total,
				@woi_comp_date,
				@woi_act_comp,
				@woi_text_flag,
				@del_build_no,
				@del_build_name,
				@del_addr1,
				@del_addr2,
				@woi_volume,
				@woi_item_price,
				@woi_line_total,
				@woi_buy_price,
				@woi_buy_value
				);
		END TRY
		BEGIN CATCH
			SET @errornumber = '13926';
			SET @errortext = 'Error inserting wo_i record';
			GOTO errorexit;
		END CATCH
		BEGIN TRY
			/* Update #tempWoi with actual data ready to return via @xmlWoi */
			UPDATE #tempWoi
				SET woi_serial_no = @woi_serial_no
				,wo_ref = @wo_ref
				,wo_suffix = @wo_suffix
				,woi_no = @woi_no
				,woi_site_ref = @woi_site_ref
				,woi_task_ref = @woi_task_ref
				,woi_feature_ref = @woi_feature_ref
				,woi_item_ref = @woi_item_ref
				,woi_volume = @woi_volume
				,woi_item_price = @woi_item_price
				,woi_line_total = @woi_line_total
				,woi_comp_date = @woi_comp_date
				,woi_act_comp = @woi_act_comp
				,woi_text_flag = @woi_text_flag
				,del_build_no = @del_build_no
				,del_build_name = @del_build_name
				,del_addr1 = @del_addr1
				,del_addr2 = @del_addr2
				,allocation_ref = @allocation_ref
				,payment_f = @payment_f
				,woi_act_vol = @woi_act_vol
				,woi_act_price = @woi_act_price
				,woi_act_line_total = @woi_act_line_total
				,blank1 = @woi_blank1
				,blank2 = @woi_blank2
				,woi_buy_price = @woi_buy_price
				,woi_buy_value = @woi_buy_value
				WHERE woi_task_ref = @woi_task_ref;
		END TRY
		BEGIN CATCH
			SET @errornumber = '13927';
			SET @errortext = 'Error updating #tempWoi record';
			GOTO errorexit;
		END CATCH

		FETCH NEXT FROM csr_woi INTO
			@woi_task_ref
			,@woi_volume
			,@woi_item_price
			,@woi_comp_date;
	END

	CLOSE csr_woi;
	DEALLOCATE csr_woi;

	BEGIN TRY
		SET @xmlWoi = (SELECT * FROM #tempWoi FOR XML PATH('WorksOrderCoreIDTO'), ROOT('ArrayOfWorksOrderCoreIDTO'));
	END TRY
	BEGIN CATCH
		SET @errornumber = '13928';
		SET @errortext = 'Error updating @xmlWoi';
		GOTO errorexit;
	END CATCH

	/* Update totals in wo_h record */
	BEGIN TRY
		UPDATE wo_h
			SET wo_act_value = @wo_act_value
				,wo_est_value = @wo_est_value
			WHERE wo_ref = @wo_ref
				AND wo_key = @wo_key;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20173';
		SET @errortext = 'Error updating wo_h record (wo_act_value and wo_est_value)';
		GOTO errorexit;
	END CATCH

	BEGIN TRY
		/* Update #tempWoh with actual data ready to return via @xmlWoh */
		UPDATE #tempWoh 
			SET wo_ref = @wo_ref
			,wo_suffix = @wo_suffix
			,wo_key = @wo_key
			,service_c = @service_c
			,date_raised = @date_raised
			,time_raised_h = @time_raised_h
			,time_raised_m = @time_raised_m
			,username = @username
			,del_site_ref = @del_site_ref
			,del_comp_name = @del_comp_name
			,del_contact = @del_contact
			,del_trade_contact = @del_trade_contact
			,del_build_no = @del_build_no
			,del_build_name = @del_build_name
			,del_addr1 = @del_addr1
			,del_addr2 = @del_addr2
			,del_addr3 = @del_addr3
			,del_addr4 = @del_addr4
			,del_addr5 = @del_addr5
			,del_addr6 = @del_addr6
			,del_postcode = @del_postcode
			,del_phone = @del_phone
			,del_fax = @del_fax
			,del_mobile = @del_mobile
			,del_email = @del_email
			,inv_site_ref = @inv_site_ref
			,inv_comp_name = @inv_comp_name
			,inv_contact = @inv_contact
			,inv_build_no = @inv_build_no
			,inv_build_name = @inv_build_name
			,inv_addr1 = @inv_addr1
			,inv_addr2 = @inv_addr2
			,inv_addr3 = @inv_addr3
			,inv_addr4 = @inv_addr4
			,inv_addr5 = @inv_addr5
			,inv_addr6 = @inv_addr6
			,inv_postcode = @inv_postcode
			,inv_phone = @inv_phone
			,inv_fax = @inv_fax
			,inv_mobile = @inv_mobile
			,inv_email = @inv_email
			,account_ref = @account_ref
			,contract_ref = @contract_ref
			,wo_budg_ref = @wo_budg_ref
			,wo_type_f = @wo_type_f
			,wo_h_stat = @wo_h_stat
			,action_ref = @action_ref
			,wo_text = @wo_text
			,wo_paymeth = @wo_paymeth
			,wo_payref = @wo_payref
			,wo_pay_date = @wo_pay_date
			,wo_pay_comments = @wo_pay_comments
			,wo_payment_f = @wo_payment_f
			,wo_paycl_dte = @wo_paycl_dte
			,wo_recharge_ref = @wo_recharge_ref
			,wo_date_due = @wo_date_due
			,expected_time_m = @expected_time_m
			,wo_date_compl = @wo_date_compl
			,wo_est_value = @wo_est_value
			,wo_act_value = @wo_act_value
			,expected_time_h = @expected_time_h
			,card_id = @card_id
			,auth_code = @auth_code
			,expiry_month = @expiry_month
			,expiry_year = @expiry_year
			,wo_paycc_flag = @wo_paycc_flag
			,wo_payissue = @wo_payissue
			,wo_paycard_holder = @wo_paycard_holder
			,wo_paycard_type = @wo_paycard_type
			,wo_paycard_amt = @wo_paycard_amt
			,wo_paycard_secure = @wo_paycard_secure
			,wo_valfrom_month = @wo_valfrom_month
			,wo_valfrom_year = @wo_valfrom_year
			,blank1 = @woh_blank1
			,blank2 = @woh_blank2
			,cycle_no = @cont_cycle_no;
	END TRY
	BEGIN CATCH
		SET @errornumber = '13921';
		SET @errortext = 'Error updating #tempWoh record';
		GOTO errorexit;
	END CATCH
	BEGIN TRY
		SET @xmlWoh = (SELECT * FROM #tempWoh FOR XML PATH('WorksOrderCoreHDTO'));
	END TRY
	BEGIN CATCH
		SET @errornumber = '13922';
		SET @errortext = 'Error updating @xmlWoh (1)';
		GOTO errorexit;
	END CATCH

	/*
	** diry table
	*/
	SELECT @comp_diry_ref = diry_ref
		FROM diry
		WHERE source_flag = 'C'
			AND source_ref = @complaint_no;

	BEGIN TRY
		EXECUTE @result = dbo.cs_sno_getSerialNumber 'diry', '', @serial_no = @wo_diry_ref OUTPUT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '13929';
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

	BEGIN TRY
		INSERT INTO diry
			(
			diry_ref,
			prev_record,
			source_flag,
			source_ref,
			source_date,
			source_time_h,
			source_time_m,
			source_user,
			site_ref,
			item_ref,
			contract_ref,
			inspect_ref,
			inspect_seq,
			feature_ref,
			date_due,
			pa_area,
			action_flag,
			dest_flag,
			dest_date,
			dest_time_h,
			dest_time_m,
			dest_user
			)
			VALUES
			(
			@wo_diry_ref,
			@comp_diry_ref,
			'W',
			@wo_key,
			@date_raised,
			@time_raised_h,
			@time_raised_m,
			@entered_by,
			@site_ref,
			@item_ref,
			@contract_ref,
			NULL,
			NULL,
			NULL,
			@wo_date_due,
			@pa_area,
			'N',
			NULL,
			NULL,
			NULL,
			NULL,
			NULL
			);
	END TRY
	BEGIN CATCH
		SET @errornumber = '13930';
		SET @errortext = 'Error inserting diry record';
		GOTO errorexit;
	END CATCH

	BEGIN TRY
		/* Update the wo_h table with the works order diry_ref */
		SET @errornumber = '13931';
		SET @errortext = 'Error updating wo_h record (action_ref)';
		UPDATE wo_h
			SET action_ref = @wo_diry_ref
			WHERE wo_key = @wo_key;
		SET @errornumber = '13932';
		SET @errortext = 'Error updating #tempWoh record (action_ref)';
		UPDATE #tempWoh 
			SET action_ref = @wo_diry_ref
			WHERE wo_key = @wo_key;
		BEGIN TRY
			SET @xmlWoh = (SELECT * FROM #tempWoh FOR XML PATH('WorksOrderCoreHDTO'));
		END TRY
		BEGIN CATCH
			SET @errornumber = '13933';
			SET @errortext = 'Error updating @xmlWoh (2)';
			GOTO errorexit;
		END CATCH
    
		/* Update the comp table destination details */
		/* and amend the action flag to 'W' */
		SET @errornumber = '13934';
		SET @errortext = 'Error updating comp record';
		UPDATE comp
			SET dest_ref = @wo_ref,
				dest_suffix = @wo_suffix,
				action_flag = 'W'
			WHERE complaint_no = @complaint_no;
    
		/* Update the complaint diry records next_record and dest_ref fields with the */
		/* works order records info. This completes the complaint record. */
		SET @errornumber = '13935';
		SET @errortext = 'Error updating comp diry record';
		UPDATE diry
			SET next_record = @wo_diry_ref,
				dest_ref = @wo_key,
				action_flag = 'W',
				dest_flag = 'W',
				dest_date = @date_raised,
				dest_time_h = @time_raised_h,
				dest_time_m = @time_raised_m,
				dest_user = @entered_by
			WHERE diry_ref = @comp_diry_ref;

		/* Delete any occurrence of the complaint from the inspection */
		/* list table, as it has been changed. */
		SET @errornumber = '13936';
		SET @errortext = 'Error deleting insp_list record';
		DELETE FROM insp_list
			WHERE complaint_no = @complaint_no;
	END TRY
	BEGIN CATCH
		/* Appropriate error message previously assigned */
		GOTO errorexit;
	END CATCH
  
	/* Check whether to copy comp text to works order text */
	IF UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField(@service_c, 'COMP_TEXT TO WO')))) = 'Y'
	BEGIN
		DECLARE csr_notes CURSOR FOR
			SELECT seq
				,username
				,doa
				,time_entered_h
				,time_entered_m
				,txt
				FROM comp_text
				WHERE complaint_no = @complaint_no
				ORDER BY seq;

		OPEN csr_notes;

		FETCH NEXT FROM csr_notes INTO
			@wohtxt_seq
			,@wohtxt_username
			,@wohtxt_doa
			,@wohtxt_time_entered_h
			,@wohtxt_time_entered_m
			,@wohtxt_txt;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			BEGIN TRY
				INSERT INTO wo_h_txt
					(
					wo_ref
					,wo_suffix
					,seq
					,username
					,doa
					,time_entered_h
					,time_entered_m
					,txt
					)
					VALUES
					(
					@wo_ref
					,@wo_suffix
					,@wohtxt_seq
					,@wohtxt_username
					,@wohtxt_doa
					,@wohtxt_time_entered_h
					,@wohtxt_time_entered_m
					,@wohtxt_txt
					);
			END TRY
			BEGIN CATCH
				SET @errornumber = '20696';
				SET @errortext = 'Error inserting wo_h_txt record';
				GOTO errorexit;
			END CATCH

			FETCH NEXT FROM csr_notes INTO
				@wohtxt_seq
				,@wohtxt_username
				,@wohtxt_doa
				,@wohtxt_time_entered_h
				,@wohtxt_time_entered_m
				,@wohtxt_txt;
		END

		CLOSE csr_notes
		DEALLOCATE csr_notes

		/* There is no text flag to update if notes have been copied */
	END
  
normalexit:
	RETURN @wo_ref;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO
