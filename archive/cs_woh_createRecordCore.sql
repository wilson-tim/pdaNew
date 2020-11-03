/*****************************************************************************
** dbo.cs_woh_createRecordCore
** stored procedure
**
** Description
** Create a works order
**
** Parameters
** See CREATE PROCEDURE statement below
**
** Returned
** All passed parameters are INPUT and OUTPUT
** Return value of new wo_ref or -1
**
** History
** 03/01/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_woh_createRecordCore', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_woh_createRecordCore;
GO
CREATE PROCEDURE dbo.cs_woh_createRecordCore
	/* key data */
	@complaint_no integer OUTPUT,
	@wo_contract_ref varchar(12) OUTPUT,
	@wo_suffix varchar(6) OUTPUT,
	@wo_type_f varchar(2) OUTPUT,
	@wo_date_due datetime OUTPUT,
	@task_ref varchar(12) OUTPUT,
	@task_quantity decimal(11,3) OUTPUT,
	/* works order data */
	@wo_ref integer = NULL OUTPUT,
	@wo_key integer = NULL OUTPUT,
	@date_raised datetime = NULL OUTPUT,
	@time_raised_h varchar(2) = NULL OUTPUT,
	@time_raised_m varchar(2) = NULL OUTPUT,
	@wo_account_ref varchar(12) = NULL OUTPUT,
	@wo_h_stat varchar(3) = NULL OUTPUT,
	@wo_action_ref varchar(12) = NULL OUTPUT,
	@wo_paymeth varchar(6) = NULL OUTPUT,
	@wo_payment_f char(1) = NULL OUTPUT,
	@expected_time_h varchar(2) = NULL OUTPUT,
	@expected_time_m varchar(2) = NULL OUTPUT,
	@wo_est_value decimal(13,4) = NULL OUTPUT,
	@wo_act_value decimal(13,4) = NULL OUTPUT,
	/* delivery data*/
	@del_site_ref varchar(16) = NULL OUTPUT,
	@del_comp_name varchar(100) = NULL OUTPUT,
	@del_contact varchar(40) = NULL OUTPUT,
	@del_trade_contact varchar(60) = NULL OUTPUT,
	@del_build_no varchar(14) = NULL OUTPUT,
	@del_build_name varchar(60) = NULL OUTPUT,
	@del_addr1 varchar(100) = NULL OUTPUT,
	@del_addr2 varchar(100) = NULL OUTPUT,
	@del_addr3 varchar(100) = NULL OUTPUT,
	@del_addr4 varchar(30) = NULL OUTPUT,
	@del_addr5 varchar(30) = NULL OUTPUT,
	@del_addr6 varchar(30) = NULL OUTPUT,
	@del_postcode varchar(8) = NULL OUTPUT,
	@del_phone varchar(20) = NULL OUTPUT,
	@del_email varchar(40) = NULL OUTPUT,
	/* invoice data */
	@inv_site_ref varchar(16) = NULL OUTPUT,
	@inv_comp_name varchar(100) = NULL OUTPUT,
	@inv_contact varchar(40) = NULL OUTPUT,
	@inv_build_no varchar(14) = NULL OUTPUT,
	@inv_build_name varchar(60) = NULL OUTPUT,
	@inv_addr1 varchar(100) = NULL OUTPUT,
	@inv_addr2 varchar(100) = NULL OUTPUT,
	@inv_addr3 varchar(100) = NULL OUTPUT,
	@inv_addr4 varchar(30) = NULL OUTPUT,
	@inv_addr5 varchar(30) = NULL OUTPUT,
	@inv_addr6 varchar(30) = NULL OUTPUT,
	@inv_postcode varchar(8) = NULL OUTPUT,
	@inv_phone varchar(20) = NULL OUTPUT,
	@inv_email varchar(40) = NULL OUTPUT,
	/* works order item data */
	@woi_serial_no integer = NULL OUTPUT,
	@woi_no integer = NULL OUTPUT,
	@woi_site_ref varchar(16) = NULL OUTPUT,
	@woi_task_ref varchar(12) = NULL OUTPUT,
	@woi_feature_ref varchar(12) = NULL OUTPUT,
	@woi_item_ref varchar(12) = NULL OUTPUT,
	@woi_volume decimal(11,3) = NULL OUTPUT,
	@woi_item_price decimal(15,8) = NULL OUTPUT,
	@woi_line_total decimal(11,2) = NULL OUTPUT,
	@woi_comp_date datetime = NULL OUTPUT,
	@woi_act_vol decimal(11,3) = NULL OUTPUT,
	@woi_act_price decimal(13,4) = NULL OUTPUT,
	@woi_act_line_total decimal(11,2) = NULL OUTPUT

AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @result integer,
		@errortext varchar(500),
		@service_c varchar(6),
		@entered_by varchar(8),
		@compl_init varchar(10),
		@compl_name varchar(100),
		@compl_surname varchar(100),
		@compl_addr6 varchar(30),
		@disp_county_or_post char(1);

	SET @complaint_no = LTRIM(RTRIM(@complaint_no));
	SET @wo_contract_ref = LTRIM(RTRIM(@wo_contract_ref));
	SET @wo_suffix = LTRIM(RTRIM(@wo_suffix));
	SET @wo_type_f = LTRIM(RTRIM(@wo_type_f));
	SET @wo_date_due = LTRIM(RTRIM(@wo_date_due));
	SET @task_ref = LTRIM(RTRIM(@task_ref));
	SET @task_quantity = LTRIM(RTRIM(@task_quantity));

	/* @complaint_no validation */
	IF @complaint_no = '' OR @complaint_no IS NULL
	BEGIN
		SET @errortext = 'complaint_no is required';
		GOTO errorexit;
	END
	SELECT complaint_no
		FROM comp
		WHERE complaint_no = @complaint_no
	IF @@ROWCOUNT = 0
	BEGIN
		SET @errortext = @complaint_no + ' is not a valid complaint reference';
		GOTO errorexit;
	END

	IF @wo_contract_ref = '' OR @wo_contract_ref IS NULL
	BEGIN
		SET @errortext = 'wo_contract_ref is required';
		GOTO errorexit;
	END

	IF @wo_suffix = '' OR @wo_suffix IS NULL
	BEGIN
		SET @errortext = 'wo_suffix is required';
		GOTO errorexit;
	END

	IF @wo_type_f = '' OR @wo_type_f IS NULL
	BEGIN
		SET @errortext = 'wo_type_f is required';
		GOTO errorexit;
	END

	IF @wo_date_due = '' OR @wo_date_due IS NULL
	BEGIN
		SET @errortext = 'wo_date_due is required';
		GOTO errorexit;
	END

	SELECT @service_c   = RTRIM(LTRIM(service_c)),
		@entered_by     = RTRIM(LTRIM(entered_by)),
		@del_site_ref   = RTRIM(LTRIM(site_ref)),
		@del_postcode   = RTRIM(LTRIM(postcode)),
		@del_build_no   = RTRIM(LTRIM(build_no)),
		@del_build_name = RTRIM(LTRIM(build_name)),
		@del_addr1      = RTRIM(LTRIM(location_name)),
		@del_addr2      = RTRIM(LTRIM(location_desc)),
		@del_addr3      = RTRIM(LTRIM(area_ward_desc)),
		@del_addr4      = RTRIM(LTRIM(townname)),
		@del_addr5      = RTRIM(LTRIM(countyname)),
		@del_addr6      = RTRIM(LTRIM(posttown))
		FROM comp
		WHERE complaint_no = @complaint_no;

	SELECT @compl_init  = RTRIM(LTRIM(customer.compl_init)),
		@compl_name     = RTRIM(LTRIM(customer.compl_name)), 
		@compl_surname  = RTRIM(LTRIM(customer.compl_surname)),
		@inv_comp_name  = RTRIM(LTRIM(customer.compl_business)),
		@inv_phone      = RTRIM(LTRIM(customer.compl_phone)),
		@inv_email      = RTRIM(LTRIM(customer.compl_email)),
		@inv_site_ref   = RTRIM(LTRIM(customer.compl_site_ref)),
		@inv_postcode   = RTRIM(LTRIM(customer.compl_postcode)),
		@inv_build_no   = RTRIM(LTRIM(customer.compl_build_no)),
		@inv_build_name = RTRIM(LTRIM(customer.compl_build_name)),
		@inv_addr1      = RTRIM(LTRIM(customer.compl_addr2)),
		@inv_addr2      = RTRIM(LTRIM(customer.compl_addr3)),
		@inv_addr3      = RTRIM(LTRIM(customer.compl_addr4)),
		@inv_addr4      = RTRIM(LTRIM(customer.compl_addr5)),
		@compl_addr6    = RTRIM(LTRIM(customer.compl_addr6))
		FROM customer, comp_clink
		WHERE comp_clink.complaint_no = @complaint_no
			AND comp_clink.seq_no =
				(
				SELECT MAX(seq_no)
					FROM comp_clink
					WHERE complaint_no = @complaint_no
				)
			AND customer.customer_no = comp_clink.customer_no

	IF @compl_init <> '' AND @compl_init <> NULL
	BEGIN
		SET @del_contact = @compl_init;
	END
	IF @compl_name <> '' AND @compl_name <> NULL
	BEGIN
		IF @del_contact <> '' AND @del_contact <> NULL
		BEGIN
			SET @del_contact = @del_contact + ' ';
		END
		SET @del_contact = @compl_name;
	END
	IF @compl_surname <> '' AND @compl_surname <> NULL
	BEGIN
		IF @del_contact <> '' AND @del_contact <> NULL
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

	SET @disp_county_or_post = UPPER(RTRIM(LTRIM(dbo.cs_keys_getCField('ALL', 'DISP_COUNTY_OR_POST'))));
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

	SET @wo_paymeth = UPPER(RTRIM(LTRIM(dbo.cs_keys_getCField('', 'WO_PAYMETH_PREPD'))));
	IF @wo_paymeth = '' OR @wo_paymeth IS NULL
	BEGIN
		SET @wo_paymeth = 'P';
	END

	SET @wo_h_stat = UPPER(RTRIM(LTRIM(dbo.cs_keys_getCField(@service_c, 'WO_H_INIT_STATUS'))));
	IF @wo_h_stat = '' OR @wo_h_stat IS NULL
	BEGIN
		SET @wo_h_stat = 'I';
	END

	/*
	** wo_h table
	*/
	BEGIN TRY
		EXECUTE @result = dbo.cs_sno_getSerialNumber 'WK_ORD', @wo_contract_ref, @serial_no = @wo_ref OUTPUT;

		EXECUTE @result = dbo.cs_sno_getSerialNumber 'wo_h', '', @serial_no = @wo_key OUTPUT;
	END TRY
	BEGIN CATCH
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

	SET @date_raised = CONVERT(datetime, CONVERT(date, GETDATE()));

	SET @time_raised_h = CONVERT(varchar(2), dbo.cs_utils_getField( CONVERT(time, GETDATE()), ':', 1 ) );

	SET @time_raised_m = CONVERT(varchar(2), dbo.cs_utils_getField( CONVERT(time, GETDATE()), ':', 2 ) );

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
			@wo_account_ref,
			@wo_contract_ref,
			@wo_type_f,
			@wo_h_stat,
			@wo_action_ref,
			'N',
			@wo_paymeth,
			@wo_payment_f,
			@wo_date_due,
			'23',
			'59',
			@wo_est_value,
			@wo_act_value
			);
	END TRY
	BEGIN CATCH
		SET @errortext = 'Error inserting wo_h record';
		GOTO errorexit;
	END CATCH

normalexit:
	RETURN @wo_ref;

errorexit:
	SET @errortext = '[' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO
