/*****************************************************************************
** dbo.cs_enfsuspect_getDetails
** stored procedure
**
** Description
** [Enforcements] Selects suspect details, optionally for a given suspect ref
**
** Parameters
** @suspect_ref
**
** Returned
** Result set of company data
** Return value of @@ROWCOUNT or -1
**
** History
** 15/03/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_enfsuspect_getDetails', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_enfsuspect_getDetails;
GO
CREATE PROCEDURE dbo.cs_enfsuspect_getDetails
	@suspect_ref integer
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer;

	SET @errornumber = '10000';

	IF @suspect_ref > 0
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
			WHERE enf_suspect.suspect_ref = @suspect_ref
			ORDER BY company_name, surname;
	END
	ELSE
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
			ORDER BY company_name, surname;
		END

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
