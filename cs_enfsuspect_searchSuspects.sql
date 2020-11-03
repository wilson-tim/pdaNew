/*****************************************************************************
** dbo.cs_enfsuspect_searchSuspects
** stored procedure
**
** Description
** Selects a set of enforcements suspect records using suspect name
**   and company name search data
**
** Parameters
** @suspect_name = suspect surname search_data
** @company_name = company company_name search data
**
** Returned
** Result set of enforcements suspect data
**
** Notes
**
** History
** 18/03/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_enfsuspect_searchSuspects', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_enfsuspect_searchSuspects;
GO
CREATE PROCEDURE dbo.cs_enfsuspect_searchSuspects
	@surname varchar(30) = NULL,
	@company_name varchar(50) = NULL
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10);

	SET @errornumber = '20094';

	SET @surname = UPPER(LTRIM(RTRIM(@surname)));
	SET @company_name = UPPER(LTRIM(RTRIM(@company_name)));

	IF (@surname = '' OR @surname IS NULL) AND (@company_name = '' OR @company_name IS NULL)
	BEGIN
		SET @errornumber = '20095';
		SET @errortext = 'No search parameters were passed';
		GOTO errorexit;
	END

	BEGIN TRY
		IF @surname <> '' AND @surname IS NOT NULL AND @company_name <> '' AND @company_name IS NOT NULL
		BEGIN
			SELECT enf_suspect.suspect_ref
				,enf_suspect.company_ref
				,enf_company.company_name
				,enf_suspect.title
				,enf_suspect.surname
				,enf_suspect.fstname
				,enf_suspect.midname
				,enf_suspect.site_ref
				,RTRIM(LTRIM(RTRIM(ISNULL([site].site_name_1, ''))) + ' ' + LTRIM(RTRIM(ISNULL([site].site_name_2, '')))) AS site_name_1
				,enf_suspect.location_c
				,locn.location_name
				,locn.location_desc
				,enf_suspect.build_no
				,enf_suspect.build_name
				,enf_suspect.addr1
				,enf_suspect.addr2
				,enf_suspect.addr3
				,enf_suspect.postcode
				,enf_suspect.home_phone
				,enf_suspect.work_phone
				,enf_suspect.mobile
				,enf_suspect.email
				,enf_suspect.est_age
				,enf_suspect.dob
				,enf_suspect.sex
				,(SELECT lookup_text FROM allk WHERE lookup_func = 'GENDER' and lookup_code =  enf_suspect.sex) AS gender
				,enf_suspect.date_entered
				,enf_suspect.entered_by
				,enf_suspect.ent_time_h
				,enf_suspect.ent_time_m
				,enf_suspect.text_flag
				,enf_suspect.orig_compl_no
				,enf_suspect.actions
				,enf_suspect.external_ref_type
				,enf_suspect.external_ref
				FROM enf_suspect
				LEFT OUTER JOIN enf_company
					ON enf_company.company_ref = enf_suspect.company_ref
				LEFT OUTER JOIN [site]
				ON [site].site_ref = enf_suspect.site_ref
				LEFT OUTER JOIN locn
				ON locn.location_c = enf_suspect.location_c
				WHERE surname LIKE @surname + '%'
					AND company_name LIKE @company_name + '%'
					AND 
						(
						(enf_suspect.company_ref = enf_company.company_ref)
						OR
						(enf_suspect.company_ref IS NULL OR enf_suspect.company_ref = 0 OR enf_suspect.company_ref = '')
						)
				ORDER BY company_name, surname;
		END
		ELSE
		BEGIN
			IF @surname <> '' AND @surname IS NOT NULL
			BEGIN
				SELECT enf_suspect.suspect_ref
					,enf_suspect.company_ref
					,enf_company.company_name
					,enf_suspect.title
					,enf_suspect.surname
					,enf_suspect.fstname
					,enf_suspect.midname
					,enf_suspect.site_ref
					,RTRIM(LTRIM(RTRIM(ISNULL([site].site_name_1, ''))) + ' ' + LTRIM(RTRIM(ISNULL([site].site_name_2, '')))) AS site_name_1
					,enf_suspect.location_c
					,locn.location_name
					,locn.location_desc
					,enf_suspect.build_no
					,enf_suspect.build_name
					,enf_suspect.addr1
					,enf_suspect.addr2
					,enf_suspect.addr3
					,enf_suspect.postcode
					,enf_suspect.home_phone
					,enf_suspect.work_phone
					,enf_suspect.mobile
					,enf_suspect.email
					,enf_suspect.est_age
					,enf_suspect.dob
					,enf_suspect.sex
					,(SELECT lookup_text FROM allk WHERE lookup_func = 'GENDER' and lookup_code =  enf_suspect.sex) AS gender
					,enf_suspect.date_entered
					,enf_suspect.entered_by
					,enf_suspect.ent_time_h
					,enf_suspect.ent_time_m
					,enf_suspect.text_flag
					,enf_suspect.orig_compl_no
					,enf_suspect.actions
					,enf_suspect.external_ref_type
					,enf_suspect.external_ref
					FROM enf_suspect
					LEFT OUTER JOIN enf_company
						ON enf_company.company_ref = enf_suspect.company_ref
					LEFT OUTER JOIN [site]
					ON [site].site_ref = enf_suspect.site_ref
					LEFT OUTER JOIN locn
					ON locn.location_c = enf_suspect.location_c
					WHERE surname LIKE @surname + '%'
						AND 
							(
							(enf_suspect.company_ref = enf_company.company_ref)
							OR
							(enf_suspect.company_ref IS NULL OR enf_suspect.company_ref = 0 OR enf_suspect.company_ref = '')
							)
					ORDER BY company_name, surname;
			END

			IF @company_name <> '' AND @company_name IS NOT NULL
			BEGIN
				SELECT enf_suspect.suspect_ref
					,enf_suspect.company_ref
					,enf_company.company_name
					,enf_suspect.title
					,enf_suspect.surname
					,enf_suspect.fstname
					,enf_suspect.midname
					,enf_suspect.site_ref
					,RTRIM(LTRIM(RTRIM(ISNULL([site].site_name_1, ''))) + ' ' + LTRIM(RTRIM(ISNULL([site].site_name_2, '')))) AS site_name_1
					,enf_suspect.location_c
					,locn.location_name
					,locn.location_desc
					,enf_suspect.build_no
					,enf_suspect.build_name
					,enf_suspect.addr1
					,enf_suspect.addr2
					,enf_suspect.addr3
					,enf_suspect.postcode
					,enf_suspect.home_phone
					,enf_suspect.work_phone
					,enf_suspect.mobile
					,enf_suspect.email
					,enf_suspect.est_age
					,enf_suspect.dob
					,enf_suspect.sex
					,(SELECT lookup_text FROM allk WHERE lookup_func = 'GENDER' and lookup_code =  enf_suspect.sex) AS gender
					,enf_suspect.date_entered
					,enf_suspect.entered_by
					,enf_suspect.ent_time_h
					,enf_suspect.ent_time_m
					,enf_suspect.text_flag
					,enf_suspect.orig_compl_no
					,enf_suspect.actions
					,enf_suspect.external_ref_type
					,enf_suspect.external_ref
					FROM enf_company
					INNER JOIN enf_suspect
						ON enf_suspect.company_ref = enf_company.company_ref
					LEFT OUTER JOIN [site]
					ON [site].site_ref = enf_suspect.site_ref
					LEFT OUTER JOIN locn
					ON locn.location_c = enf_suspect.location_c
					WHERE company_name LIKE @company_name + '%'
					ORDER BY enf_company.company_name, enf_suspect.surname;
			END
		END
	END TRY
	BEGIN CATCH
		SET @errornumber = '20096';
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
