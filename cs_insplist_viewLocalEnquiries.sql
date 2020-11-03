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
** of enquiries within a given radius of a specified location
**
** Parameters
** @UName = user login name
** @service_c = service code (optional)
** @pmonths = only include records with do_date later than @pmonths ago (if zero then return all records)
** @pcomplaint_no = only include records for specified complaint_no
** @paction_flag = only include records for specified action_flag
** @pdo_date = only include records for specified do_date
** @easting  = 6 digit decimal easting value, i.e. units of 1 metre
** @northing = 6 digit decimal northing value, i.e. units of 1 metre
** @radius   = distance in metres
**
** Returned
** Inspection list
**
** History
** 22/03/2013  TW  Version of cs_insplist_viewEnquiries to return records by site_distance
** 10/04/2013  TW  Include works orders
** 24/04/2013  TW  Include works orders parameterised
** 01/05/2013  TW  System key holding default value of @months
** 22/05/2013  TW  Additional column ward_name
** 30/05/2013  TW  Additional column action_flag_desc
** 07/06/2013  TW  Additional column priority_flag
** 07/06/2013  TW  do_date - now with specific processing for inspection items
** 02/07/2013  TW  Added user related where clause
** 03/07/2013  TW  Works order selection working correctly at last
** 04/07/2013  TW  Revised 02/07/2013 change to get user / covering user selection working correctly
** 09/07/2013  TW  Additional column covered_by
**                 Replace function call to ...getFaultCodesTable with ...getFaultCodeDesc
** 12/07/2013  TW  Additional column flycap_record
** 23/07/2013  TW  Exclude TRADE records
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_insplist_viewLocalEnquiries', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_insplist_viewLocalEnquiries;
GO
CREATE PROCEDURE dbo.cs_insplist_viewLocalEnquiries
	@pUName varchar(15)
	,@pservice_c varchar(6) = NULL
	,@pmonths integer = NULL
	,@pcomplaint_no integer = 0
	,@paction_flag varchar(1) = NULL
	,@pdo_date datetime = NULL
	,@peasting decimal(10,2)
	,@pnorthing decimal(10,2)
	,@pradius decimal(10,2)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@InsDef bit, 
		@InsIsp bit, 
		@InsSap bit,
		@InsWo bit,
		@InsWoStatuses varchar(40),
		@Adhoc varchar(40), 
		@MonFlt varchar(40),
		@bvItemRef varchar(40),
		@defNameNoun varchar(40),
		@UName varchar(15),
		@service_c varchar(6),
		@easting decimal(10,2),
		@northing decimal(10,2),
		@radius decimal(10,2),
		@months integer,
		@complaint_no integer,
		@action_flag varchar,
		@do_date datetime,
		@easting_min decimal(10,2),
		@easting_max decimal(10,2),
		@northing_min decimal(10,2),
		@northing_max decimal(10,2),
		@fcinstalled bit;

	SET @errornumber = '20143';

	SET @UName = LTRIM(RTRIM(@pUName));
	SET @service_c = LTRIM(RTRIM(@pservice_c));
	SET @easting = @peasting;
	SET @northing = @pnorthing;
	SET @radius = @pradius;
	SET @months = @pmonths;
	SET @complaint_no = @pcomplaint_no;
	SET @action_flag = LTRIM(RTRIM(@paction_flag));
	SET @do_date = @pdo_date;

	SET @easting_min = @easting - @radius;
	SET @easting_max = @easting + @radius;

	SET @northing_min = @northing - @radius;
	SET @northing_max = @northing + @radius;

	IF @UName = '' OR @UName IS NULL
	BEGIN
		SET @errornumber = '20144';
		SET @errortext   = 'UName is required';
		GOTO errorexit;
	END

	IF UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('PDAINI', 'INSPLIST_INS_RECT')))) = 'Y'
	BEGIN
		SET @InsDef = 1;
	END
	ELSE
	BEGIN
		SET @InsDef = 0;
	END

	IF UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('PDAINI', 'INSPLIST_INS_INSP')))) = 'Y'
	BEGIN
		SET @InsIsp = 1;
	END
	ELSE
	BEGIN
		SET @InsIsp = 0;
	END

	IF UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('PDAINI', 'INSPLIST_INS_SAMP')))) = 'Y'
	BEGIN
		SET @InsSap = 1;
	END
	ELSE
	BEGIN
		SET @InsSap = 0;
	END

	IF UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('PDAINI', 'INSPLIST_INS_WO')))) = 'Y'
	BEGIN
		SET @InsWo = 1;
	END
	ELSE
	BEGIN
		SET @InsWo = 0;
	END

	SET @InsWoStatuses = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('PDAINI', 'INSPLIST_WO_STATUSES'))));

	SET @Adhoc = LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'ADHOC_SAMPLE_FAULT')));

	SET @MonFlt = LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'MONITOR_FAULT')));

	SET @bvItemRef = LTRIM(RTRIM(dbo.cs_keys_getCField('', 'BV199_ITEM')));

	SET @defNameNoun = dbo.cs_keys_getCField('PDAINI', 'DEF_NAME_NOUN');

	SET @fcinstalled = dbo.cs_modulelic_getInstalled('FC');

	IF @months IS NULL
	BEGIN
		SET @months = dbo.cs_keys_getNField('PDAINI', 'INSPLIST_MONTHS')
	END

	SELECT complaint_no
		,dest_ref
		,action_flag
		,action_flag_desc
		,item_ref
		,item_desc
		,priority_flag
		,site_ref
		,postcode
		,recvd_by
		,comp_code
		,comp_code_desc
		,service_c
		,service_c_desc
		,service_type
		,contract_ref
		,feature_ref
		,location_c
		,date_entered
		,ent_time_h
		,ent_time_m
		,pa_area
		,flycap_record
		,[user_name]
		,covered_by
		,limit_list_flag
		,wo_stat
		,rectification_action
		,site_name_1
		,ward_code
		,ward_name
		,do_date
		,end_time_h
		,end_time_m
		,start_time_h
		,start_time_m
		,record_type
		,action_text
		,action_colour
		,site_distance
		FROM 
		(
		SELECT
			C.complaint_no,
			C.dest_ref,
			C.action_flag,
			action_flag_desc = 
				CASE
					WHEN C.action_flag = 'A' THEN 'Auto ' + @defNameNoun
					WHEN C.action_flag = 'D' THEN @defNameNoun
					WHEN C.action_flag = 'E' THEN 'Enforcement'
					WHEN C.action_flag = 'H' THEN 'Hold'
					WHEN C.action_flag = 'I' THEN 'Inspect'
					WHEN C.action_flag = 'P' THEN 'Pending'
					WHEN C.action_flag = 'N' THEN 'No Action'
					WHEN C.action_flag = 'W' THEN 'Works Order'
					WHEN C.action_flag = 'X' THEN 'Express Works Order'
				END,
			C.item_ref,
			item.item_desc,
			(SELECT si_i.priority_flag FROM si_i WHERE si_i.site_ref = C.site_ref AND si_i.item_ref = C.item_ref AND si_i.contract_ref = C.contract_ref) AS priority_flag,
			C.site_ref,
			C.postcode,
			C.recvd_by,
			C.comp_code,
			(dbo.cs_pdalookup_getFaultCodeDesc(C.comp_code, C.service_c, C.item_ref, NULL)) AS comp_code_desc,
			C.service_c,
			(SELECT TOP(1) pda_lookup.service_c_desc FROM pda_lookup WHERE pda_lookup.service_c = C.service_c AND pda_lookup.role_name = 'pda-in') AS service_c_desc,
			(dbo.cs_utils_getServiceType(C.service_c)) AS service_type,
			C.contract_ref,
			C.feature_ref,
			C.location_c,
			C.date_entered,
			C.ent_time_h,
			C.ent_time_m,
			C.pa_area,
			flycap_record =
				CASE
					WHEN (
						@fcinstalled = 1
						AND EXISTS
						(SELECT 1 FROM allk
							WHERE lookup_func = 'FCCOMP'
								AND lookup_code = C.comp_code)
						) THEN 1
					ELSE 0
				END,
			U.[user_name],
			U.covered_by,
			U.limit_list_flag,
			wo_h.wo_h_stat AS wo_stat,
			rectification_action = 
				CASE
					WHEN (C.action_flag = 'D') THEN def_cont_i.[action]
					ELSE NULL
				END,
			RTRIM(LTRIM(RTRIM(ISNULL([site].site_name_1, ''))) + ' ' + LTRIM(RTRIM(ISNULL([site].site_name_2, '')))) AS site_name_1,
			[site].ward_code,
			(SELECT ward_name FROM ward WHERE ward_code = [site].ward_code) AS ward_name,
			do_date =
				CASE
					WHEN (C.action_flag = 'D') THEN rectify_date
					WHEN (C.action_flag = 'I') THEN diry.date_due
					WHEN (C.action_flag = 'W') THEN wo_h.wo_date_due
					ELSE C.date_entered
				END,
			end_time_h =
				CASE
					WHEN (C.action_flag = 'D') THEN rectify_time_h
					WHEN (C.action_flag = 'I') THEN C.ent_time_h
					WHEN (C.action_flag = 'W') THEN wo_h.expected_time_h
					ELSE NULL
				END,
			end_time_m =
				CASE
					WHEN (C.action_flag = 'D') THEN rectify_time_m
					WHEN (C.action_flag = 'I') THEN C.ent_time_m
					WHEN (C.action_flag = 'W') THEN wo_h.expected_time_m
					ELSE NULL
				END,
			start_time_h =
				CASE
					WHEN (C.action_flag = 'D') THEN rectify_time_h
					WHEN (C.action_flag = 'I') THEN C.ent_time_h
					WHEN (C.action_flag = 'W') THEN wo_h.expected_time_h
					ELSE NULL
				END,
			start_time_m =
				CASE
					WHEN (C.action_flag = 'D') THEN rectify_time_m
					WHEN (C.action_flag = 'I') THEN C.ent_time_m
					WHEN (C.action_flag = 'W') THEN wo_h.expected_time_m
					ELSE NULL
				END,
			record_type = 
				CASE
					WHEN (C.item_ref = '' OR C.item_ref IS NULL) THEN ''
					WHEN ((C.item_ref <> '' AND C.item_ref IS NOT NULL) AND C.action_flag = 'P') THEN 'Sample'
					WHEN ((C.item_ref <> '' AND C.item_ref IS NOT NULL) AND C.action_flag = 'D') THEN @defNameNoun
					WHEN ((C.item_ref <> '' AND C.item_ref IS NOT NULL) AND C.action_flag = 'I') THEN 'Inspection'
					WHEN ((C.item_ref <> '' AND C.item_ref IS NOT NULL) AND C.action_flag = 'W') THEN 'Works Order'
				END,
			action_text = 
				CASE
					WHEN (C.action_flag = 'D' AND (def_cont_i.[action] = '' OR def_cont_i.[action] IS NULL)) THEN @defNameNoun
					WHEN (C.action_flag = 'D' AND (def_cont_i.[action] = 'A')) THEN @defNameNoun
					WHEN (C.action_flag = 'D' AND (def_cont_i.[action] <> 'U' AND (def_cont_i.[action] <> '' AND def_cont_i.[action] IS NOT NULL))) THEN @defNameNoun
					WHEN (C.action_flag = 'D' AND (def_cont_i.[action] = 'U')) THEN @defNameNoun
					WHEN (C.action_flag = 'P' AND C.item_ref <> @bvItemRef) THEN 'Pending'
					WHEN (C.action_flag = 'P' AND C.item_ref = @bvItemRef) THEN 'NI195 Pending'
					WHEN (C.action_flag = 'I' AND C.item_ref <> @bvItemRef) THEN 'Inspect'
					WHEN (C.action_flag = 'I' AND C.item_ref = @bvItemRef) THEN 'NI195 Inspect'
					WHEN (C.action_flag = 'W') THEN 'Works Order'
				END,
			action_colour = 
				CASE
					WHEN (C.action_flag = 'D' AND (def_cont_i.[action] = '' OR def_cont_i.[action] IS NULL)) THEN 'amber'
					WHEN (C.action_flag = 'D' AND (def_cont_i.[action] = 'A')) THEN 'green'
					WHEN (C.action_flag = 'D' AND (def_cont_i.[action] <> 'U' AND (def_cont_i.[action] <> '' AND def_cont_i.[action] IS NOT NULL))) THEN 'amber'
					WHEN (C.action_flag = 'D' AND (def_cont_i.[action] = 'U')) THEN 'red'
					WHEN (C.action_flag = 'P' AND C.item_ref <> @bvItemRef) THEN 'green'
					WHEN (C.action_flag = 'P' AND C.item_ref = @bvItemRef) THEN 'blue'
					WHEN (C.action_flag = 'I' AND C.item_ref <> @bvItemRef) THEN 'green'
					WHEN (C.action_flag = 'I' AND C.item_ref = @bvItemRef) THEN 'blue'
					WHEN (C.action_flag = 'W') THEN ''
				END,
			ISNULL(CAST(SQRT( SQUARE(@easting - site_detail.easting) + SQUARE(@northing - site_detail.northing) ) AS DECIMAL (10,2)), 0) AS site_distance
			FROM comp C 
			/* For the passed user name (own and covered records)   */
			/* if the complaint is in the user's area               */
			/* but only selecting one instance of the complaint.    */
			/* Where a user and covered user have an area in common */
			/* then @UName's instance of the complaint is selected. */
			INNER JOIN
				(
				SELECT area_c
					,[user_name]
					,covered_by
					,limit_list_flag
				FROM
				(
					SELECT patr_area.area_c
						,pda_cover_list.[user_name]
						,pda_cover_list.covered_by
						,pda_user.limit_list_flag
						/*
						,passeduser =
							CASE
								WHEN pda_cover_list.[user_name] = @UName THEN 1
								ELSE 0
							END
						*/
						,ROW_NUMBER() OVER
							(PARTITION BY patr_area.area_c
								ORDER BY CASE
									WHEN pda_cover_list.[user_name] = @UName THEN 1
									ELSE 0
								END DESC, pda_cover_list.[user_name]) AS rn
					FROM patr_area, pda_user, pda_cover_list
					WHERE patr_area.pa_site_flag = 'P'
						AND pda_user.po_code = patr_area.po_code
						AND pda_cover_list.[user_name] = pda_user.[user_name]
						AND pda_cover_list.covered_by = @UName
				) innerselect
				WHERE innerselect.rn = 1
				) U
			ON U.area_c = C.pa_area
			INNER JOIN [site]
			ON [site].site_ref = C.site_ref
			INNER JOIN site_detail
			ON site_detail.site_ref = C.site_ref
				AND site_detail.site_ref IN
					/* Restrict to local site_refs */
					(
					SELECT site_detail.site_ref
						FROM [site]
						INNER JOIN site_detail
						ON site_detail.site_ref = [site].site_ref
						WHERE [site].site_status = 'L'
							AND
							(
							(site_detail.easting BETWEEN @easting_min AND @easting_max
								OR ( (site_detail.easting_end BETWEEN @easting_min AND @easting_max) AND site_detail.easting_end IS NOT NULL ))
							AND (site_detail.northing BETWEEN @northing_min AND @northing_max
								OR ( (site_detail.northing_end BETWEEN @northing_min AND @northing_max) AND site_detail.northing_end IS NOT NULL ))
							AND ((SQRT( ( SQUARE(@easting - site_detail.easting) + SQUARE(@northing - site_detail.northing) ) ) <= @radius AND site_detail.easting IS NOT NULL AND site_detail.northing IS NOT NULL)
								OR ( SQRT( ( SQUARE(@easting - site_detail.easting_end) + SQUARE(@northing - site_detail.northing_end) ) ) <= @radius AND site_detail.easting_end IS NOT NULL AND site_detail.northing_end IS NOT NULL ))
							)
					)
			LEFT OUTER JOIN diry
			ON source_ref = C.complaint_no
				AND source_flag = 'C'
			LEFT OUTER JOIN def_cont_i
			ON cust_def_no = C.dest_ref
				AND C.action_flag = 'D'
			LEFT OUTER JOIN defi_rect
			ON default_no = C.dest_ref
				AND C.action_flag = 'D'
				AND seq_no = (SELECT MAX(seq_no) FROM defi_rect WHERE default_no = C.dest_ref)
			LEFT OUTER JOIN item
			ON item.item_ref = C.item_ref
				AND item.contract_ref = C.contract_ref
			LEFT OUTER JOIN wo_h
			ON wo_ref = C.dest_ref
				AND wo_suffix = C.dest_suffix
				AND C.action_flag = 'W'
			WHERE
				/* Current records */
				C.date_closed IS NULL 
				AND (
					/* Detailed checks whether to include record or not */
					/* Rectifications */
					(C.action_flag = 'D' AND @InsDef = 1 AND (C.dest_ref <> '' AND C.dest_ref IS NOT NULL)
							AND
							(
							/* Include complaint if NOT IN the limit_list */
							(limit_list_flag = 'N' AND NOT EXISTS (SELECT 1 FROM pda_limit_list WHERE pda_limit_list.[user_name] = U.[user_name] AND pda_limit_list.item_ref = C.item_ref AND pda_limit_list.comp_code = C.comp_code))
							OR
							/* Include complaint if IN the limit_list */
							(limit_list_flag = 'Y' AND EXISTS (SELECT 1 FROM pda_limit_list WHERE pda_limit_list.[user_name] = U.[user_name] AND pda_limit_list.item_ref = C.item_ref AND pda_limit_list.comp_code = C.comp_code))
							OR
							/* Include the complaint regardless of limit list settings */
							(limit_list_flag = 'Z')
							)
					) 
					OR
					/* Inspections */
					(C.action_flag = 'I' AND @InsIsp = 1 AND (CHARINDEX(',' + LTRIM(RTRIM(C.comp_code)) + ',', ',' + @MonFlt + ',', 1) = 0) AND (CHARINDEX(',' + LTRIM(RTRIM(C.comp_code)) + ',', ',' + @Adhoc + ',', 1) = 0)
							AND
							(
							/* Include complaint if NOT IN the limit_list */
							(limit_list_flag = 'N' AND NOT EXISTS (SELECT 1 FROM pda_limit_list WHERE pda_limit_list.[user_name] = U.[user_name] AND pda_limit_list.item_ref = C.item_ref AND pda_limit_list.comp_code = C.comp_code))
							OR
							/* Include complaint if IN the limit_list */
							(limit_list_flag = 'Y' AND EXISTS (SELECT 1 FROM pda_limit_list WHERE pda_limit_list.[user_name] = U.[user_name] AND pda_limit_list.item_ref = C.item_ref AND pda_limit_list.comp_code = C.comp_code))
							OR
							/* Include the complaint regardless of limit list settings */
							(limit_list_flag = 'Z')
							)
					) 
					OR
					/* Pending */
					(C.action_flag = 'P' AND (CHARINDEX(',' + LTRIM(RTRIM(C.comp_code)) + ',', ',' + @MonFlt + ',', 1) = 0) AND @InsSap = 1)
					OR
					/* Works Orders */
					(
					C.action_flag = 'W' AND @InsWo = 1
						AND C.dest_ref <> '' AND C.dest_ref IS NOT NULL AND C.dest_suffix <> '' AND C.dest_suffix IS NOT NULL
						AND wo_h.wo_h_stat IS NOT NULL
						AND
						(
						(@InsWoStatuses = '' OR @InsWoStatuses IS NULL)
						OR (CHARINDEX(',' + LTRIM(RTRIM(wo_h.wo_h_stat)) + ',', ',' + @InsWoStatuses + ',', 1) > 0)
						)
							AND
							(
							/* Include complaint if NOT IN the limit_list */
							(limit_list_flag = 'N' AND NOT EXISTS (SELECT 1 FROM pda_limit_list WHERE pda_limit_list.[user_name] = U.[user_name] AND pda_limit_list.item_ref = C.item_ref AND pda_limit_list.comp_code = C.comp_code))
							OR
							/* Include complaint if IN the limit_list */
							(limit_list_flag = 'Y' AND EXISTS (SELECT 1 FROM pda_limit_list WHERE pda_limit_list.[user_name] = U.[user_name] AND pda_limit_list.item_ref = C.item_ref AND pda_limit_list.comp_code = C.comp_code))
							OR
							/* Include the complaint regardless of limit list settings */
							(limit_list_flag = 'Z')
							)
					)
					)
				AND (
					(@service_c = '' OR @service_c IS NULL)
						OR (C.service_c = @service_c)
					)
				AND (
					(@months IS NULL OR @months = 0)
					OR
					(
						@months > 0
						AND
						(CASE
							WHEN (C.action_flag = 'D') THEN rectify_date
							WHEN (C.action_flag = 'I') THEN diry.date_due
							WHEN (C.action_flag = 'W') THEN wo_h.wo_date_due
							ELSE C.date_entered
						END)
							> DATEADD(month, -@months, GETDATE())
					)
					)
				AND (
					(@complaint_no = 0 OR @complaint_no IS NULL)
					OR
					(C.complaint_no = @complaint_no)
					)
				AND (
					(@action_flag = '' OR @action_flag IS NULL)
					OR
					(C.action_flag = @action_flag)
					)
				AND (
					(@do_date IS NULL)
					OR
					((CASE
							WHEN (C.action_flag = 'D') THEN rectify_date
							WHEN (C.action_flag = 'I') THEN diry.date_due
							WHEN (C.action_flag = 'W') THEN wo_h.wo_date_due
							ELSE C.date_entered
						END) >= DATEADD(day, DATEDIFF(day, 0, @do_date), 0)
					AND (CASE
							WHEN (C.action_flag = 'D') THEN rectify_date
							WHEN (C.action_flag = 'I') THEN diry.date_due
							WHEN (C.action_flag = 'W') THEN wo_h.wo_date_due
							ELSE C.date_entered
						END) < DATEADD(day, DATEDIFF(day, 0, @do_date) + 1, 0))
					)
		) insplist
		WHERE service_c IN
			(
			SELECT 
				DISTINCT pda_lookup.service_c
				FROM pda_lookup
				LEFT OUTER JOIN keys keys2
				ON pda_lookup.service_c = keys2.c_field
					AND keys2.keyname LIKE '%_SERVICE'
					AND keys2.keyname NOT LIKE 'BV199_%'
					AND keys2.keyname NOT LIKE '% %'
				LEFT OUTER JOIN modulelic
				ON ISNULL(LTRIM(RTRIM(modulelic.keyname)), 'CORE') = dbo.cs_utils_getField(keys2.keyname, '_', 1)
				INNER JOIN keys keys4
				ON keys4.service_c = pda_lookup.service_c
					AND keys4.keyname = 'HEADER'
				WHERE pda_lookup.role_name = 'pda-in'
					AND (dbo.cs_modulelic_getInstalled(LTRIM(RTRIM(modulelic.keyname))) = 1)
					AND (ISNULL(LTRIM(RTRIM(modulelic.keyname)), 'CORE') <> 'TRADE')
					AND (
						(ISNULL(LTRIM(RTRIM(modulelic.keyname)), 'CORE') = 'ENF' AND dbo.cs_pdauser_getEnfOfficerPoCode(@UName) IS NOT NULL)
						OR
						(ISNULL(LTRIM(RTRIM(modulelic.keyname)), 'CORE') <> 'ENF')
						OR
						(ISNULL(LTRIM(RTRIM(modulelic.keyname)), 'CORE') = '')
						OR
						(modulelic.keyname IS NULL)
						)
			)
		ORDER BY site_distance, site_name_1;

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO
