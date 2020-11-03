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
** 07/03/2013  TW  Revised to use a single selection
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
	
	SELECT C.complaint_no,
		C.dest_ref,
		C.action_flag,
		C.item_ref,
		C.site_ref,
		C.postcode,
		C.recvd_by,
		C.comp_code,
		C.service_c,
		C.contract_ref,
		C.feature_ref,
		C.location_c,
		C.date_entered,
		C.ent_time_h,
		C.ent_time_m,
		C.pa_area,
		U.[user_name],
		U.limit_list_flag,
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
		FROM comp C 
		/* For the passed user name */
		INNER JOIN patr_area A ON (C.pa_area = A.area_c) 
		INNER JOIN pda_user U ON (A.po_code = U.po_code AND U.user_name = @UName) 
		INNER JOIN [site]
		ON [site].site_ref = C.site_ref
		LEFT OUTER JOIN defi_rect
		ON default_no = dest_ref
			AND seq_no = (SELECT TOP(1) seq_no FROM defi_rect WHERE default_no = dest_ref ORDER by seq_no DESC)
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
	
END
GO


