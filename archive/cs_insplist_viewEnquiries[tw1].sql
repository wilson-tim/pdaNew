SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Richard Fisher
-- Create date: 25/02/2013
-- Description:	A user specific view of the 
--              inspections list.
-- =============================================
/*****************************************************************************
** dbo.cs_insplist_viewEnquiries
** stored procedure
**
** Description
** A user specific view of the inspections list
**
** Parameters
** @UName = user login name
**
** Returned
** Inspection list
**
** History
** 07/03/2013  TW  Revised to use CTE technique
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_insplist_viewEnquiries', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_insplist_viewEnquiries;
GO
CREATE PROCEDURE dbo.cs_insplist_viewEnquiries
	@UName VARCHAR(15)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @InsDef AS BIT, 
		@InsIsp AS BIT, 
		@InsSap AS BIT,
		@Adhoc AS VARCHAR(500), 
		@MonFlt AS VARCHAR(500); 

	IF UPPER(RTRIM(LTRIM(dbo.cs_keys_getCField('PDAINI', 'INSPLIST_INS_RECT')))) = 'Y'
	BEGIN
		SET @InsDef = 1;
	END
	ELSE
	BEGIN
		SET @InsDef = 0;
	END

	IF UPPER(RTRIM(LTRIM(dbo.cs_keys_getCField('PDAINI', 'INSPLIST_INS_INSP')))) = 'Y'
	BEGIN
		SET @InsIsp = 1;
	END
	ELSE
	BEGIN
		SET @InsIsp = 0;
	END

	IF UPPER(RTRIM(LTRIM(dbo.cs_keys_getCField('PDAINI', 'INSPLIST_INS_SAMP')))) = 'Y'
	BEGIN
		SET @InsSap = 1;
	END
	ELSE
	BEGIN
		SET @InsSap = 0;
	END

	SET @Adhoc = RTRIM(LTRIM(dbo.cs_keys_getCField('ALL', 'ADHOC_SAMPLE_FAULT')));

	SET @MonFlt = RTRIM(LTRIM(dbo.cs_keys_getCField('ALL', 'MONITOR_FAULT')));
	
	/* Using CTE */
	/* Initial selection of comp records matching insplist criteria */
	;WITH cteInspList AS
		(
		SELECT complaint_no,
			dest_ref,
			action_flag,
			item_ref,
			site_ref,
			postcode,
			recvd_by,
			comp_code,
			service_c,
			contract_ref,
			feature_ref,
			location_c,
			date_entered,
			ent_time_h,
			ent_time_m,
			pa_area,
			U.[user_name],
			U.limit_list_flag
		FROM comp C 
		/* For the passed user name */
		INNER JOIN patr_area A ON (C.pa_area = A.area_c) 
		INNER JOIN pda_user U ON (A.po_code = U.po_code AND U.user_name = @UName) 
		WHERE A.pa_site_flag = 'P' 
			/* Current records */
			AND C.date_closed IS NULL 
		AND (
			/* Detailed check whether to include record or not */
			/* Rectifications */
			(action_flag = 'D' AND @InsDef = 1 AND (dest_ref <> '' AND dest_ref IS NOT NULL)
					AND
					(
					(limit_list_flag = 'N' AND (SELECT COUNT(*) FROM pda_limit_list WHERE pda_limit_list.user_name = U.user_name AND pda_limit_list.item_ref = C.item_ref AND pda_limit_list.comp_code = C.comp_code) = 0)
					OR
					(limit_list_flag = 'Y' AND (SELECT COUNT(*) FROM pda_limit_list WHERE pda_limit_list.user_name = U.user_name AND pda_limit_list.item_ref = C.item_ref AND pda_limit_list.comp_code = C.comp_code) > 0)
					OR
					(limit_list_flag = 'Z')
					)
			) 
			OR
			/* Inspections */
			(action_flag = 'I' AND comp_code NOT IN (@MonFlt) AND comp_code <> @Adhoc AND @InsIsp = 1
					AND
					(
					(limit_list_flag = 'N' AND (SELECT COUNT(*) FROM pda_limit_list WHERE pda_limit_list.user_name = U.user_name AND pda_limit_list.item_ref = C.item_ref AND pda_limit_list.comp_code = C.comp_code) = 0)
					OR
					(limit_list_flag = 'Y' AND (SELECT COUNT(*) FROM pda_limit_list WHERE pda_limit_list.user_name = U.user_name AND pda_limit_list.item_ref = C.item_ref AND pda_limit_list.comp_code = C.comp_code) > 0)
					OR
					(limit_list_flag = 'Z')
					)
			) 
			OR
			/* Pending */
			(action_flag = 'P' AND comp_code NOT IN (@MonFlt) AND @InsSap = 1)
			)
	)

	/* Create the final result set */
	SELECT cteInspList.complaint_no,
		cteInspList.dest_ref,
		cteInspList.action_flag,
		cteInspList.item_ref,
		cteInspList.site_ref,
		cteInspList.postcode,
		cteInspList.recvd_by,
		cteInspList.comp_code,
		cteInspList.service_c,
		cteInspList.contract_ref,
		cteInspList.feature_ref,
		cteInspList.location_c,
		cteInspList.date_entered,
		cteInspList.ent_time_h,
		cteInspList.ent_time_m,
		cteInspList.pa_area,
		cteInspList.[user_name],
		cteInspList.limit_list_flag,
		rectification_action = 
			CASE
				WHEN (action_flag = 'D') THEN (SELECT action FROM def_cont_i WHERE cust_def_no = dest_ref)
				ELSE NULL
			END,
		[site].site_name_1,
		[site].ward_code,
		do_date =
			CASE
				WHEN (action_flag = 'D') THEN rectify_date
				ELSE date_entered
			END,
		end_time_h =
			CASE
				WHEN (action_flag = 'D') THEN rectify_time_h
				WHEN (action_flag = 'I') THEN ent_time_h
				ELSE NULL
			END,
		end_time_m =
			CASE
				WHEN (action_flag = 'D') THEN rectify_time_m
				WHEN (action_flag = 'I') THEN ent_time_m
				ELSE NULL
			END,
		start_time_h =
			CASE
				WHEN (action_flag = 'D') THEN rectify_time_h
				WHEN (action_flag = 'I') THEN ent_time_h
				ELSE NULL
			END,
		start_time_m =
			CASE
				WHEN (action_flag = 'D') THEN rectify_time_m
				WHEN (action_flag = 'I') THEN ent_time_m
				ELSE NULL
			END
	FROM cteInspList
	INNER JOIN [site]
	ON [site].site_ref = cteInspList.site_ref
	LEFT OUTER JOIN defi_rect
	ON default_no = dest_ref
		AND seq_no = (SELECT TOP(1) seq_no FROM defi_rect WHERE default_no = dest_ref ORDER by seq_no DESC)
	
END
GO
