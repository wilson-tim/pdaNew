/*****************************************************************************
** dbo.cs_comp_getMyVehicles
** stored procedure
**
** Description
** Selects a set of current comp records for AV service and a given officer
**
** Parameters
** @username = user name
**
** Returned
** Result set of AV customer care data
**
** Notes
** Per Bob the correct approach is to display a list of vehicles
** assigned to the officer's patrol area or 'patch'.
** A particular vehicle may be assigned to different officers of a patrol area
** at different stages of vehicle processing.
**
** History
** 12/02/2013  TW  New
** 20/02/2013  TW  keeper details required flag
** 23/05/2013  TW  Additional fly capture columns
** 30/05/2013  TW  Additional column action_flag_desc
** 07/06/2013  TW  Additional column priority_flag
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_comp_getMyVehicles', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comp_getMyVehicles;
GO
CREATE PROCEDURE dbo.cs_comp_getMyVehicles
	@pusername varchar(8) = NULL
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@username varchar(8);

	SET @username = LTRIM(RTRIM(@pusername));

	SELECT 
		cs_comp_viewHistory.complaint_no,
		cs_comp_viewHistory.entered_by,
		cs_comp_viewHistory.site_ref,
		cs_comp_viewHistory.site_name_1,
		cs_comp_viewHistory.exact_location,
		cs_comp_viewHistory.service_c,
		cs_comp_viewHistory.service_c_desc,
		cs_comp_viewHistory.comp_code,
		cs_comp_viewHistory.comp_code_desc,
		cs_comp_viewHistory.item_ref,
		cs_comp_viewHistory.item_desc,
		cs_comp_viewHistory.priority_flag,
		cs_comp_viewHistory.feature_ref,
		cs_comp_viewHistory.feature_desc,
		cs_comp_viewHistory.contract_ref,
		cs_comp_viewHistory.[contract_name],
		cs_comp_viewHistory.action_flag,
		cs_comp_viewHistory.action_flag_desc,
		dbo.cs_comptext_getNotes(cs_comp_viewHistory.complaint_no, 0) AS notes,
		cs_comp_viewHistory.compl_init,
		cs_comp_viewHistory.compl_name,
		cs_comp_viewHistory.compl_surname,
		cs_comp_viewHistory.compl_build_no,
		cs_comp_viewHistory.compl_build_name,
		cs_comp_viewHistory.compl_addr2,
		cs_comp_viewHistory.compl_addr4,
		cs_comp_viewHistory.compl_addr5,
		cs_comp_viewHistory.compl_addr6,
		cs_comp_viewHistory.compl_postcode,
		cs_comp_viewHistory.compl_phone,
		cs_comp_viewHistory.compl_email,
		cs_comp_viewHistory.compl_business,
		cs_comp_viewHistory.int_ext_flag,
		cs_comp_viewHistory.date_entered,
		cs_comp_viewHistory.ent_time_h,
		cs_comp_viewHistory.ent_time_m,
		cs_comp_viewHistory.dest_ref,
		cs_comp_viewHistory.dest_suffix,
		cs_comp_viewHistory.date_due,
		cs_comp_viewHistory.date_closed,
		cs_comp_viewHistory.incident_id,
		cs_comp_viewHistory.details_1,
		cs_comp_viewHistory.details_2,
		cs_comp_viewHistory.details_3,
		cs_comp_viewHistory.notice_type,
		NULL AS site_distance,
		NULL AS flycap_record,
		NULL AS landtype_ref,
		NULL AS landtype_desc,
		NULL AS dominant_waste_ref,
		NULL AS dominant_waste_desc,
		NULL AS dominant_waste_qty,
		NULL AS load_ref,
		NULL AS load_desc,
		NULL AS load_qty,
		NULL AS load_unit_cost,
		NULL AS load_est_cost,

		comp_av.generated_no,
		comp_av.car_id,
		comp_av.make_ref,
		(SELECT make_desc FROM makes WHERE make_ref = comp_av.make_ref) AS make_desc,
		comp_av.model_ref,
		(SELECT model_desc FROM models WHERE model_ref = comp_av.model_ref AND make_ref = comp_av.make_ref) AS model_desc,
		comp_av.colour_ref,
		(SELECT colour_desc FROM colour WHERE colour_ref = comp_av.colour_ref) AS colour_desc,
		comp_av.date_stickered,
		comp_av.time_stickered_h,
		comp_av.time_stickered_m,
		comp_av.vehicle_class,
		comp_av.officer_id,
		comp_av.road_fund_flag,
		comp_av.road_fund_valid,
		comp_av.last_seq,
		comp_av.date_police_email,
		comp_av.date_fire_email,
		comp_av.date_housing_email,
		comp_av.dho_rep,
		comp_av.dho_cc_building,
		comp_av.how_long_there,
		comp_av.vin,
		comp_av_hist.status_ref,
		av_status.[description] AS status_description,
		comp_av_hist.notes AS status_notes,
		status_days_remaining = 
			CASE 
				WHEN DATEDIFF(day, CONVERT(datetime, CONVERT(date, GETDATE())), comp_av_hist.[expiry_date]) > 0 THEN DATEDIFF(day, CONVERT(datetime, CONVERT(date, GETDATE())), comp_av_hist.[expiry_date])
				ELSE 0
			END,
		keeper_required =
			/* Keeper details required for this status?  */
			CASE 
				WHEN
					(
					av_status.keeper = 'Y'
					AND cs_comp_viewHistory.complaint_no IS NOT NULL
					AND
						(
						LTRIM(RTRIM(comp_av_hist.keeper_title)) IS NULL
						OR LTRIM(RTRIM(comp_av_hist.compl_addr1)) IS NULL
						OR LTRIM(RTRIM(comp_av_hist.compl_addr4)) IS NULL
						OR LTRIM(RTRIM(comp_av_hist.motor_dealer)) IS NULL
						)
					)
				THEN 1
				ELSE 0
			END,
		next_code_count =
			/* Keeper details required for this status?  */
			CASE 
				WHEN
					(
					av_status.keeper = 'Y'
					AND cs_comp_viewHistory.complaint_no IS NOT NULL
					AND
						(
						LTRIM(RTRIM(comp_av_hist.keeper_title)) IS NULL
						OR LTRIM(RTRIM(comp_av_hist.compl_addr1)) IS NULL
						OR LTRIM(RTRIM(comp_av_hist.compl_addr4)) IS NULL
						OR LTRIM(RTRIM(comp_av_hist.motor_dealer)) IS NULL
						)
					)
				THEN 0
				ELSE
					(SELECT COUNT(*) FROM allk_avstat_link WHERE lookup_code = comp_av_hist.status_ref)
			END

		FROM cs_comp_viewHistory
		INNER JOIN pda_user
		ON pda_user.[user_name] = @username
		INNER JOIN patr_area
		ON patr_area.po_code = pda_user.po_code
		INNER JOIN comp_av
		ON comp_av.complaint_no = cs_comp_viewHistory.complaint_no
		/* LEFT OUTER JOINs to select vehicles both with and without statuses */
		LEFT OUTER JOIN comp_av_hist
		ON comp_av_hist.seq = comp_av.last_seq
			AND comp_av_hist.complaint_no = comp_av.complaint_no
		LEFT OUTER JOIN av_status
		ON av_status.status_ref = comp_av_hist.status_ref
		WHERE cs_comp_viewHistory.pa_area = patr_area.area_c
			AND cs_comp_viewHistory.date_closed IS NULL
		ORDER BY make_desc,
			model_desc,
			cs_comp_viewHistory.site_name_1;

END
GO 
