/*****************************************************************************
** dbo.cs_customer_updateRecord
** stored procedure
**
** Description
** Insert or update a customer record for the specified complaint_no
**
** Parameters
** @complaint_no = customer care reference
**
** Returned
** Return value of new / updated customer_no (success), or -1
**
** Notes
** Assuming that we are always processing the latest (by seq_no) customer
**
** History
** 27/03/2013  TW  New
** 12/07/2013  TW  Revised validation
** 27/08/2013  TW  Additional check for @int_ext_flag
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_customer_updateRecord', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_customer_updateRecord;
GO
CREATE PROCEDURE dbo.cs_customer_updateRecord
	@complaint_no integer,
	@entered_by varchar(8),
	@compl_init varchar(10) = NULL OUTPUT,
	@compl_name varchar(100) = NULL OUTPUT,
	@compl_surname varchar(100) = NULL OUTPUT,
	@compl_build_no varchar(14) = NULL OUTPUT,
	@compl_build_name varchar(60) = NULL OUTPUT,
	@compl_addr2 varchar(100) = NULL OUTPUT,
	@compl_addr4 varchar(40) = NULL OUTPUT,
	@compl_addr5 varchar(30) = NULL OUTPUT,
	@compl_addr6 varchar(30) = NULL OUTPUT,
	@compl_postcode varchar(8) = NULL OUTPUT,
	@compl_phone varchar(20) = NULL OUTPUT,
	@compl_email varchar(40) = NULL OUTPUT,
	@compl_business varchar(100) = NULL OUTPUT,
	@int_ext_flag varchar(1) = 'E' OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@result integer,
		@customer_no integer,
		@full_name varchar(40),
		@cs_flag char(1),
		@date_entered datetime,
		@ent_time_h varchar(2),
		@ent_time_m varchar(2),
		@numberstr varchar(2),
		@rowcount integer,
		@namelen integer,
		@othrlen integer;

	SET @errornumber = '20164';

	SET @entered_by       = UPPER(LTRIM(RTRIM(@entered_by)));
	SET @compl_init       = UPPER(LTRIM(RTRIM(@compl_init)));
	SET @compl_name       = UPPER(LTRIM(RTRIM(@compl_name)));
	SET @compl_surname    = UPPER(LTRIM(RTRIM(@compl_surname)));
	SET @compl_build_no   = UPPER(LTRIM(RTRIM(@compl_build_no)));
	SET @compl_build_name = UPPER(LTRIM(RTRIM(@compl_build_name)));
	SET @compl_addr2      = UPPER(LTRIM(RTRIM(@compl_addr2)));
	SET @compl_addr4      = UPPER(LTRIM(RTRIM(@compl_addr4)));
	SET @compl_addr5      = UPPER(LTRIM(RTRIM(@compl_addr5)));
	SET @compl_addr6      = UPPER(LTRIM(RTRIM(@compl_addr6)));
	SET @compl_postcode   = UPPER(LTRIM(RTRIM(@compl_postcode)));
	SET @compl_phone      = LTRIM(RTRIM(@compl_phone));
	SET @compl_email      = LTRIM(RTRIM(@compl_email));
	SET @compl_business   = UPPER(LTRIM(RTRIM(@compl_business)));
	SET @int_ext_flag     = UPPER(LTRIM(RTRIM(@int_ext_flag)));

	SET @namelen = LEN(ISNULL(@compl_name, '')) + LEN(ISNULL(@compl_surname, ''));

	SET @othrlen = LEN(ISNULL(@compl_init, ''))
				+ LEN(ISNULL(@compl_build_no, ''))
				+ LEN(ISNULL(@compl_build_name, ''))
				+ LEN(ISNULL(@compl_addr2, ''))
				+ LEN(ISNULL(@compl_addr4, ''))
				+ LEN(ISNULL(@compl_addr5, ''))
				+ LEN(ISNULL(@compl_addr6, ''))
				+ LEN(ISNULL(@compl_postcode, ''))
				+ LEN(ISNULL(@compl_phone, ''))
				+ LEN(ISNULL(@compl_email, ''))
				+ LEN(ISNULL(@compl_business, ''));

	SET @customer_no = 0;

	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @errornumber = '20165';
		SET @errortext   = 'complaint_no is required';
		GOTO errorexit;
	END

	IF @entered_by = '' OR @entered_by IS NULL
	BEGIN
		SET @errornumber = '20166';
		SET @errortext   = 'entered_by is required';
		GOTO errorexit;
	END

	/* Default to using the PDA user as the customer */
	/* or failing that simply use 'NO NAME' */
	/* 12/07/2013  TW  Commented out - the user can input as much or little data as they wish
	IF (@compl_name = '' OR @compl_name IS NULL)
		AND (@compl_surname = '' OR @compl_surname IS NULL)
	BEGIN
		SET @compl_init = NULL;
		SET @compl_name = NULL;
		SET @compl_surname = NULL;
		SET @compl_build_no = NULL;
		SET @compl_build_name = NULL;
		SET @compl_addr2 = NULL;
		SET @compl_addr4 = NULL;
		SET @compl_addr5 = NULL;
		SET @compl_addr6 = NULL;
		SET @compl_postcode = NULL;
		SET @compl_phone = NULL;
		SET @compl_email = NULL;
		SET @compl_business = NULL;
		SET @int_ext_flag = 'I';
		
		SELECT @full_name = full_name
			FROM pda_user
			WHERE [user_name] = @entered_by;

		IF @@ROWCOUNT <> 1
		BEGIN
			SET @full_name = 'NO NAME';
		END

		IF CHARINDEX(' ', @full_name) > 0
		BEGIN
			SET @compl_name = dbo.cs_utils_getField(@full_name, '\S', 1);
			IF @compl_name <> @full_name
			BEGIN
				SET @compl_surname = SUBSTRING(@full_name, LEN(@compl_name) + 2, (LEN(@full_name) - (LEN(@compl_name) + 1)) );
			END
		END
	END
	*/

	IF @int_ext_flag = '' OR @int_ext_flag IS NULL
	BEGIN
		SET @int_ext_flag = 'E';
	END

	/* Select the most recent customer record for this complaint_no */
	SELECT @customer_no = customer_no
		FROM
		(
		SELECT customer_no,
			ROW_NUMBER() OVER (PARTITION BY complaint_no ORDER BY seq_no DESC) AS rn
			FROM comp_clink
			WHERE complaint_no = @complaint_no
		) AS innerselect
		WHERE rn = 1;

	SET @rowcount = @@ROWCOUNT;

	/* Delete existing record if no data has been passed */
	IF @namelen = 0 AND @othrlen = 0 AND @rowcount = 1
	BEGIN
		BEGIN TRY
			DELETE FROM customer
				WHERE customer_no = @customer_no;

			DELETE FROM comp_clink
				WHERE complaint_no = @complaint_no
					AND customer_no = @customer_no;

			GOTO normalexit;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20690';
			SET @errortext = 'Error deleting customer record';
			GOTO errorexit;
		END CATCH
	END

	IF @rowcount = 1
	BEGIN
		/* Update customer */
		BEGIN TRY
			UPDATE customer
				SET compl_init = @compl_init
					,compl_name = @compl_name
					,compl_surname = @compl_surname
					,compl_site_ref = NULL
					,compl_location_c = NULL
					,compl_build_no = @compl_build_no
					,compl_build_name = @compl_build_name
					,compl_addr2 = @compl_addr2
					,compl_addr3 = NULL
					,compl_addr4 = @compl_addr4
					,compl_addr5 = @compl_addr5
					,compl_addr6 = @compl_addr6
					,compl_postcode = @compl_postcode
					,compl_phone = @compl_phone
					,compl_email = @compl_email
					,compl_business = @compl_business
					,int_ext_flag = @int_ext_flag
				WHERE customer_no = @customer_no;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20167';
			SET @errortext = 'Error updating customer record';
			GOTO errorexit;
		END CATCH
	END

	IF @rowcount = 0
	BEGIN
		/* Insert customer */
		BEGIN TRY
			EXECUTE @result = dbo.cs_sno_getSerialNumber 'customer', '', @serial_no = @customer_no OUTPUT;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20168';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH

		BEGIN TRY
			INSERT INTO customer
				(
				customer_no,
				compl_init,
				compl_name,
				compl_surname,
				compl_site_ref,
				compl_location_c,
				compl_build_no,
				compl_build_name,
				compl_addr2,
				compl_addr3,
				compl_addr4,
				compl_addr5,
				compl_addr6,
				compl_postcode,
				compl_phone,
				compl_email,
				compl_business,
				int_ext_flag
				)
				VALUES
				(
				@customer_no,
				@compl_init,
				@compl_name,
				@compl_surname,
				NULL,
				NULL,
				@compl_build_no,
				@compl_build_name,
				@compl_addr2,
				NULL,
				@compl_addr4,
				@compl_addr5,
				@compl_addr6,
				@compl_postcode,
				@compl_phone,
				@compl_email,
				@compl_business,
				@int_ext_flag
				);
		END TRY
		BEGIN CATCH
			SET @errornumber = '20169';
			SET @errortext = 'Error inserting customer record';
			GOTO errorexit;
		END CATCH

		/*
		** comp_clink table
		*/
		SET @date_entered = GETDATE();

		SET @numberstr = DATENAME(hour, @date_entered);
		SET @ent_time_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

		SET @numberstr = DATENAME(minute, @date_entered);
		SET @ent_time_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

		SET @date_entered = CONVERT(datetime, CONVERT(date, @date_entered));

		SET @cs_flag = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'CS_FLAG'))));

		BEGIN TRY
			INSERT INTO comp_clink
				(
				complaint_no,
				customer_no,
				username,
				seq_no,
				date_added,
				time_added_h,
				time_added_m,
				cust_satisfaction
				)
				VALUES
				(
				@complaint_no,
				@customer_no,
				@entered_by,
				1,
				@date_entered,
				@ent_time_h,
				@ent_time_m,
				@cs_flag
				);
		END TRY
		BEGIN CATCH
			SET @errornumber = '20170';
			SET @errortext = 'Error inserting comp_clink record';
			GOTO errorexit;
		END CATCH
	END

normalexit:
	RETURN @customer_no;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
