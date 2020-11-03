/*****************************************************************************
** dbo.cs_enfsuspect_createRecord
** stored procedure
**
** Description
** Create an enforcement suspect record
**
** Parameters
** @xmlEnfSuspect = XML structure containing enf_suspect record
** @notes         = notes text
**
** Returned
** All passed parameters are INPUT and OUTPUT
** Return value of new suspect_ref or -1
**
** Notes
** data passed in via XML
** extract data into temporary table
** validate key data
** do stuff
** update data in temporary table
** convert data in temporary table into XML and return to caller
**
** external_ref_type will not be used in the new mobile app
** though for future reference the possible values are:
**   S trade site
**   C customer
**   T (Markets) trader
**   A (Markets) assistant
**   E migration flag
**
** external_ref is the associated reference, but will not be used
**
** History
** 14/03/2013  TW  New
** 15/03/2013  TW  Continued development
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_enfsuspect_createRecord', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_enfsuspect_createRecord;
GO
CREATE PROCEDURE dbo.cs_enfsuspect_createRecord
	@xmlEnfSuspect xml OUTPUT,
	@notes varchar(MAX) OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @result integer
		,@errortext varchar(500)
		,@errornumber varchar(10)
		,@numberstr varchar(2)
		,@seq integer
		,@enfsuspect_rowcount integer

		,@suspect_ref integer
		,@company_ref integer
		,@company_name varchar(50)
		,@title varchar(10)
		,@surname varchar(30)
		,@fstname varchar(15)
		,@midname varchar(15)
		,@site_ref varchar(16)
		,@site_name_1 varchar(70)
		,@location_c varchar(10)
		,@location_name varchar(100)
		,@location_desc varchar(100)
		,@build_no varchar(14)
		,@build_name varchar(60)
		,@addr1 varchar(70)
		,@addr2 varchar(70)
		,@addr3 varchar(50)
		,@postcode varchar(10)
		,@home_phone varchar(20)
		,@work_phone varchar(20)
		,@mobile varchar(20)
		,@email varchar(40)
		,@est_age varchar(5)
		,@dob datetime
		,@sex varchar(6)
		,@date_entered datetime
		,@entered_by varchar(8)
		,@ent_time_h char(2)
		,@ent_time_m char(2)
		,@text_flag char(1)
		,@orig_compl_no integer
		,@actions integer
		,@external_ref_type varchar(1)
		,@external_ref integer

	SET @errornumber = '20083';

	IF OBJECT_ID('tempdb..#tempEnfSuspect') IS NOT NULL
	BEGIN
		DROP TABLE #tempEnfSuspect;
	END

	BEGIN TRY
		SELECT
			xmldoc.enfsuspect.value('suspect_ref[1]','integer') AS 'suspect_ref'
			,xmldoc.enfsuspect.value('company_ref[1]','integer') AS 'company_ref'
			,xmldoc.enfsuspect.value('company_name[1]','varchar(50)') AS 'company_name'
			,xmldoc.enfsuspect.value('title[1]','varchar(10)') AS 'title'
			,xmldoc.enfsuspect.value('surname[1]','varchar(30)') AS 'surname'
			,xmldoc.enfsuspect.value('fstname[1]','varchar(15)') AS 'fstname'
			,xmldoc.enfsuspect.value('midname[1]','varchar(30)') AS 'midname'
			,xmldoc.enfsuspect.value('site_ref[1]','varchar(16)') AS 'site_ref'
			,xmldoc.enfsuspect.value('site_name_1[1]','varchar(70)') AS 'site_name_1'
			,xmldoc.enfsuspect.value('location_c[1]','varchar(10)') AS 'location_c'
			,xmldoc.enfsuspect.value('location_name[1]','varchar(100)') AS 'location_name'
			,xmldoc.enfsuspect.value('location_desc[1]','varchar(100)') AS 'location_desc'
			,xmldoc.enfsuspect.value('build_no[1]','varchar(14)') AS 'build_no'
			,xmldoc.enfsuspect.value('build_name[1]','varchar(60)') AS 'build_name'
			,xmldoc.enfsuspect.value('addr1[1]','varchar(70)') AS 'addr1'
			,xmldoc.enfsuspect.value('addr2[1]','varchar(70)') AS 'addr2'
			,xmldoc.enfsuspect.value('addr3[1]','varchar(50)') AS 'addr3'
			,xmldoc.enfsuspect.value('postcode[1]','varchar(10)') AS 'postcode'
			,xmldoc.enfsuspect.value('home_phone[1]','varchar(20)') AS 'home_phone'
			,xmldoc.enfsuspect.value('work_phone[1]','varchar(20)') AS 'work_phone'
			,xmldoc.enfsuspect.value('mobile[1]','varchar(20)') AS 'mobile'
			,xmldoc.enfsuspect.value('email[1]','varchar(40)') AS 'email'
			,xmldoc.enfsuspect.value('est_age[1]','varchar(5)') AS 'est_age'
			,xmldoc.enfsuspect.value('dob[1]','datetime') AS 'dob'
			,xmldoc.enfsuspect.value('sex[1]','varchar(6)') AS 'sex'
			,xmldoc.enfsuspect.value('date_entered[1]','datetime') AS 'date_entered'
			,xmldoc.enfsuspect.value('entered_by[1]','varchar(8)') AS 'entered_by'
			,xmldoc.enfsuspect.value('ent_time_h[1]','varchar(2)') AS 'ent_time_h'
			,xmldoc.enfsuspect.value('ent_time_m[1]','varchar(2)') AS 'ent_time_m'
			,xmldoc.enfsuspect.value('text_flag[1]','varchar(1)') AS 'text_flag'
			,xmldoc.enfsuspect.value('orig_compl_no[1]','integer') AS 'orig_compl_no'
			,xmldoc.enfsuspect.value('actions[1]','integer') AS 'actions'
			,xmldoc.enfsuspect.value('external_ref_type[1]','varchar(1)') AS 'external_ref_type'
			,xmldoc.enfsuspect.value('external_ref[1]','integer') AS 'external_ref'
		INTO #tempEnfSuspect
		FROM @xmlEnfSuspect.nodes('/SuspectEnfDTO') AS xmldoc(enfsuspect);

		SELECT @suspect_ref = suspect_ref
			,@company_ref = company_ref
			,@company_name = company_name
			,@title = title
			,@surname = surname
			,@fstname = fstname
			,@midname = midname
			,@site_ref = site_ref
			,@site_name_1 = site_name_1
			,@location_c = location_c
			,@location_name = location_name
			,@location_desc = location_desc
			,@build_no = build_no
			,@build_name = build_name
			,@addr1 = addr1
			,@addr2 = addr2
			,@addr3 = addr3
			,@postcode = postcode
			,@home_phone = home_phone
			,@work_phone = work_phone
			,@mobile = mobile
			,@email = email
			,@est_age = est_age
			,@dob = dob
			,@sex = sex
			,@date_entered = date_entered
			,@entered_by = entered_by
			,@ent_time_h = ent_time_h
			,@ent_time_m = ent_time_m
			,@text_flag = text_flag
			,@orig_compl_no = orig_compl_no
			,@actions = actions
			,@external_ref_type = external_ref_type
			,@external_ref = external_ref
			FROM #tempEnfSuspect;

		SET @enfsuspect_rowcount = @@ROWCOUNT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20084';
		SET @errortext = 'Error processing @xmlEnfSuspect';
		GOTO errorexit;
	END CATCH

	IF @enfsuspect_rowcount > 1
	BEGIN
		SET @errornumber = '20085';
		SET @errortext = 'Error processing @xmlEnfSuspect - too many rows';
		GOTO errorexit;
	END
	IF @enfsuspect_rowcount < 1
	BEGIN
		SET @errornumber = '20086';
		SET @errortext = 'Error processing @xmlEnfSuspect - no rows found';
		GOTO errorexit;
	END

	SET @company_name = UPPER(LTRIM(RTRIM(@company_name)));
	SET @surname = UPPER(LTRIM(RTRIM(@surname)));
	SET @fstname = UPPER(LTRIM(RTRIM(@fstname)));
	SET @midname = UPPER(LTRIM(RTRIM(@midname)));
	SET @build_no = UPPER(LTRIM(RTRIM(@build_no)));
	SET @build_name = UPPER(LTRIM(RTRIM(@build_name)));
	SET @addr1 = UPPER(LTRIM(RTRIM(@addr1)));
	SET @addr2 = UPPER(LTRIM(RTRIM(@addr2)));
	SET @addr3 = UPPER(LTRIM(RTRIM(@addr3)));
	SET @postcode = UPPER(LTRIM(RTRIM(@postcode)));
	SET @site_ref = UPPER(LTRIM(RTRIM(@site_ref)));
	SET @location_c = UPPER(LTRIM(RTRIM(@location_c)));

	SET @external_ref_type = NULL;
	SET @external_ref = NULL;

	IF (@surname = '' OR @surname IS NULL) AND (@company_ref = 0 OR @company_ref IS NULL) AND (@company_name = '' OR @company_name IS NULL)
	BEGIN
		SET @errornumber = '20087';
		SET @errortext = 'A surname, a company ref or a company name is required';
		GOTO errorexit;
	END

	/* @suspect_ref */
	BEGIN TRY
		EXECUTE @result = dbo.cs_sno_getSerialNumber 'enf_suspect', '', @serial_no = @suspect_ref OUTPUT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20088';
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

	/* @company_ref passed, get @company_name */
	IF @company_ref <> 0 AND @company_ref IS NOT NULL
	BEGIN
		/* Use an existing company */
		SELECT @company_name = company_name
			FROM enf_company
			WHERE company_ref = @company_ref;
	END

	/* @company_name passed */
	IF (@company_name <> '' AND @company_name IS NOT NULL) AND (@company_ref = 0 OR @company_ref IS NULL)
	BEGIN
		/* Creating a new company record */
		BEGIN TRY
			EXECUTE dbo.cs_enfcompany_createRecord
				@company_ref OUTPUT
				,@company_name
		END TRY
		BEGIN CATCH
			SET @errornumber = '20089';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH
	END

	SELECT @site_name_1 = site_name_1
		FROM site
		WHERE site_ref = @site_ref;

	SELECT @location_name = location_name,
		@location_desc = location_desc
		FROM locn
		WHERE location_c = @location_c;

	/* @date_entered */
	SET @date_entered = GETDATE();

	SET @numberstr = DATENAME(hour, @date_entered);
	SET @ent_time_h = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @numberstr = DATENAME(minute, @date_entered);
	SET @ent_time_m = STUFF(@numberstr, 1, 0, REPLICATE('0', 2 - LEN(@numberstr)));

	SET @date_entered = CONVERT(datetime, CONVERT(date, @date_entered));

	SET @text_flag = 'N';

	/* orig_compl_no will be updated by cs_comp_createRecordEnf */
	SET @orig_compl_no = 0;

	SET @actions = 0;

	SET @external_ref_type = NULL;

	SET @external_ref = NULL;

	/*
	** enf_suspect
	*/
	BEGIN TRY
		INSERT INTO enf_suspect
			(
			suspect_ref
			,company_ref
			,title
			,surname
			,fstname
			,midname
			,site_ref
			,location_c
			,build_no
			,build_name
			,addr1
			,addr2
			,addr3
			,postcode
			,home_phone
			,work_phone
			,mobile
			,email
			,est_age
			,dob
			,sex
			,date_entered
			,entered_by
			,ent_time_h
			,ent_time_m
			,text_flag
			,orig_compl_no
			,actions
			,external_ref_type
			,external_ref
			)
			VALUES
			(
			@suspect_ref
			,@company_ref
			,@title
			,@surname
			,@fstname
			,@midname
			,@site_ref
			,@location_c
			,@build_no
			,@build_name
			,@addr1
			,@addr2
			,@addr3
			,@postcode
			,@home_phone
			,@work_phone
			,@mobile
			,@email
			,@est_age
			,@dob
			,@sex
			,@date_entered
			,@entered_by
			,@ent_time_h
			,@ent_time_m
			,@text_flag
			,@orig_compl_no
			,@actions
			,@external_ref_type
			,@external_ref
			);
	END TRY
	BEGIN CATCH
		SET @errornumber = '20090';
		SET @errortext = 'Error inserting enf_suspect record';
		GOTO errorexit;
	END CATCH

	/*
	** enf_sus_text
	*/
	IF LEN(@notes) > 0
	BEGIN
		BEGIN TRY
			EXECUTE dbo.cs_enfsustext_updateNotes
				@suspect_ref,
				@entered_by,
				@notes OUTPUT;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20091';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH
	END

	BEGIN TRY
		/* Update #tempEnfSuspect with actual data ready to return via @xmlEnfSuspect */
		UPDATE #tempEnfSuspect
			SET suspect_ref = @suspect_ref
			,company_ref = @company_ref
			,company_name = @company_name
			,title = @title
			,surname = @surname
			,fstname = @fstname
			,midname = @midname
			,site_ref = @site_ref
			,site_name_1 = @site_name_1
			,location_c = @location_c
			,location_name = @location_name
			,location_desc = @location_desc
			,build_no = @build_no
			,build_name = @build_name
			,addr1 = @addr1
			,addr2 = @addr2
			,addr3 = @addr3
			,postcode = @postcode
			,home_phone = @home_phone
			,work_phone = @work_phone
			,mobile = @mobile
			,email = @email
			,est_age = @est_age
			,dob = @dob
			,sex = @sex
			,date_entered = @date_entered
			,entered_by = @entered_by
			,ent_time_h = @ent_time_h
			,ent_time_m = @ent_time_m
			,text_flag = @text_flag
			,orig_compl_no = @orig_compl_no
			,actions = @actions
			,external_ref_type = @external_ref_type
			,external_ref = @external_ref
	END TRY
	BEGIN CATCH
		SET @errornumber = '20092';
		SET @errortext = 'Error updating #tempEnfSuspect record';
		GOTO errorexit;
	END CATCH
	BEGIN TRY
		SET @xmlEnfSuspect = (SELECT * FROM #tempEnfSuspect FOR XML PATH('SuspectEnfDTO'))
	END TRY
	BEGIN CATCH
		SET @errornumber = '20093';
		SET @errortext = 'Error updating @xmlEnfSuspect';
		GOTO errorexit;
	END CATCH

normalexit:
	RETURN @suspect_ref;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO
