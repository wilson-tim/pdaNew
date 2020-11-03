/*****************************************************************************
** dbo.cs_comp_getHistory
** stored procedure
**
** Description
** Selects a set of comp records for a given site and optionally a given item
**
** Parameters
** @site_ref = site reference
** @item_ref = item reference (optional)
** @numrecs  = number of records to return, 0 or NULL to return all records (optional)
**
** Returned
** Result set of customer care core data
** Return value of @@ROWCOUNT or -1
**
** Notes
** The syntax below is only compatible with MSSQL 2005 and later
** Requires view cs_comp_viewHistory
**
** History
** 13/12/2012  TW  New
** 31/12/2012  TW  Revised to return customer care core data
** 14/01/2013  TW  Revised to use view cs_comp_viewHistory
** 23/05/2013  TW  Additional fly capture columns
** 30/05/2013  TW  Additional column action_flag_desc
** 07/06/2013  TW  Additional column priority_flag
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_comp_getHistory', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comp_getHistory;
GO
CREATE PROCEDURE dbo.cs_comp_getHistory
	@psite_ref varchar(16),
	@pitem_ref varchar(12) = NULL,
	@pnumrecs integer
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @rowcount integer,
		@errornumber varchar(10),
		@errortext varchar(500),
		@site_ref varchar(16),
		@item_ref varchar(12),
		@numrecs integer;

	SET @errornumber = '11300';

	SET @site_ref = LTRIM(RTRIM(@psite_ref));
	SET @item_ref = LTRIM(RTRIM(@pitem_ref));
	SET @numrecs  = @pnumrecs;

	IF @site_ref = '' OR @site_ref IS NULL
	BEGIN
		SET @errornumber = '11301';
		SET @errortext = 'site_ref is required';
		GOTO errorexit;
	END

	/* Allow for @numrecs 0 or NULL */
	IF @numrecs IS NULL
	BEGIN
		SET @numrecs = 0;
	END

	IF @numrecs > 0
	BEGIN

		/* Return first @numrecs matching records */
		IF @item_ref = '' OR @item_ref IS NULL
		BEGIN
			SELECT TOP (@numrecs)
				entered_by,
				site_ref,
				site_name_1,
				exact_location,
				service_c,
				service_c_desc,
				comp_code,
				comp_code_desc,
				item_ref,
				item_desc,
				priority_flag,
				feature_ref,
				feature_desc,
				contract_ref,
				[contract_name],
				action_flag,
				action_flag_desc,
				dbo.cs_comptext_getNotes(complaint_no, 0) AS notes,
				compl_init,
				compl_name,
				compl_surname,
				compl_build_no,
				compl_build_name,
				compl_addr2,
				compl_addr4,
				compl_addr5,
				compl_addr6,
				compl_postcode,
				compl_phone,
				compl_email,
				compl_business,
				int_ext_flag,
				complaint_no,
				date_entered,
				ent_time_h,
				ent_time_m,
				dest_ref,
				dest_suffix,
				date_due,
				date_closed,
				incident_id,
				details_1,
				details_2,
				details_3,
				notice_type,
				NULL AS site_distance,
				flycap_record,
				landtype_ref,
				landtype_desc,
				dominant_waste_ref,
				dominant_waste_desc,
				dominant_waste_qty,
				load_ref,
				load_desc,
				load_qty,
				load_unit_cost,
				load_est_cost
			FROM cs_comp_viewHistory
			WHERE site_ref = @site_ref
			ORDER BY date_entered DESC

			SET @rowcount = @@ROWCOUNT;
		END
		ELSE
		BEGIN
			SELECT TOP (@numrecs)
				entered_by,
				site_ref,
				site_name_1,
				exact_location,
				service_c,
				service_c_desc,
				comp_code,
				comp_code_desc,
				item_ref,
				item_desc,
				priority_flag,
				feature_ref,
				feature_desc,
				contract_ref,
				[contract_name],
				action_flag,
				action_flag_desc,
				dbo.cs_comptext_getNotes(complaint_no, 0) AS notes,
				compl_init,
				compl_name,
				compl_surname,
				compl_build_no,
				compl_build_name,
				compl_addr2,
				compl_addr4,
				compl_addr5,
				compl_addr6,
				compl_postcode,
				compl_phone,
				compl_email,
				compl_business,
				int_ext_flag,
				complaint_no,
				date_entered,
				ent_time_h,
				ent_time_m,
				dest_ref,
				dest_suffix,
				date_due,
				date_closed,
				incident_id,
				details_1,
				details_2,
				details_3,
				notice_type,
				NULL AS site_distance,
				flycap_record,
				landtype_ref,
				landtype_desc,
				dominant_waste_ref,
				dominant_waste_desc,
				dominant_waste_qty,
				load_ref,
				load_desc,
				load_qty,
				load_unit_cost,
				load_est_cost
			FROM cs_comp_viewHistory
			WHERE site_ref = @site_ref
				AND item_ref = @item_ref
			ORDER BY date_entered DESC

			SET @rowcount = @@ROWCOUNT;
		END

	END
	ELSE
	BEGIN

		/* Return all matching records */
		IF @item_ref = '' OR @item_ref IS NULL
		BEGIN
			SELECT entered_by,
				site_ref,
				site_name_1,
				exact_location,
				service_c,
				service_c_desc,
				comp_code,
				comp_code_desc,
				item_ref,
				item_desc,
				priority_flag,
				feature_ref,
				feature_desc,
				contract_ref,
				[contract_name],
				action_flag,
				action_flag_desc,
				dbo.cs_comptext_getNotes(complaint_no, 0) AS notes,
				compl_init,
				compl_name,
				compl_surname,
				compl_build_no,
				compl_build_name,
				compl_addr2,
				compl_addr4,
				compl_addr5,
				compl_addr6,
				compl_postcode,
				compl_phone,
				compl_email,
				compl_business,
				int_ext_flag,
				complaint_no,
				date_entered,
				ent_time_h,
				ent_time_m,
				dest_ref,
				dest_suffix,
				date_due,
				date_closed,
				incident_id,
				details_1,
				details_2,
				details_3,
				notice_type,
				NULL AS site_distance,
				flycap_record,
				landtype_ref,
				landtype_desc,
				dominant_waste_ref,
				dominant_waste_desc,
				dominant_waste_qty,
				load_ref,
				load_desc,
				load_qty,
				load_unit_cost,
				load_est_cost
			FROM cs_comp_viewHistory
			WHERE site_ref = @site_ref
			ORDER BY date_entered DESC

			SET @rowcount = @@ROWCOUNT;
		END
		ELSE
		BEGIN
			SELECT entered_by,
				site_ref,
				site_name_1,
				exact_location,
				service_c,
				service_c_desc,
				comp_code,
				comp_code_desc,
				item_ref,
				item_desc,
				priority_flag,
				feature_ref,
				feature_desc,
				contract_ref,
				[contract_name],
				action_flag,
				action_flag_desc,
				dbo.cs_comptext_getNotes(complaint_no, 0) AS notes,
				compl_init,
				compl_name,
				compl_surname,
				compl_build_no,
				compl_build_name,
				compl_addr2,
				compl_addr4,
				compl_addr5,
				compl_addr6,
				compl_postcode,
				compl_phone,
				compl_email,
				compl_business,
				int_ext_flag,
				complaint_no,
				date_entered,
				ent_time_h,
				ent_time_m,
				dest_ref,
				dest_suffix,
				date_due,
				date_closed,
				incident_id,
				details_1,
				details_2,
				details_3,
				notice_type,
				NULL AS site_distance,
				flycap_record,
				landtype_ref,
				landtype_desc,
				dominant_waste_ref,
				dominant_waste_desc,
				dominant_waste_qty,
				load_ref,
				load_desc,
				load_qty,
				load_unit_cost,
				load_est_cost
			FROM cs_comp_viewHistory
			WHERE site_ref = @site_ref
				AND item_ref = @item_ref
			ORDER BY date_entered DESC

			SET @rowcount = @@ROWCOUNT;
		END

	END

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO
