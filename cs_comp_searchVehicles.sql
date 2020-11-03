/*****************************************************************************
** dbo.cs_comp_searchVehicles
** stored procedure
**
** Description
** Selects a set of current comp records for AV service using make, model and colour
** search data
**
** Parameters
** @car_id       = car registration number search data
** @make_string  = make search data
** @model_string = model search data
**
** Returned
** Result set of AV customer care data
**
** Notes
**
** History
** 12/02/2013  TW  New
** 20/02/2013  TW  keeper details required flag
** 23/05/2013  TW  Additional fly capture columns
** 30/05/2013  TW  Additional column action_flag_desc
** 07/06/2013  TW  Additional column priority_flag
** 11/06/2013  TW  Use aliases to reduce query length
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_comp_searchVehicles', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comp_searchVehicles;
GO
CREATE PROCEDURE dbo.cs_comp_searchVehicles
	@pcar_id varchar(12) = NULL,
	@pmake_string varchar(20) = NULL,
	@pmodel_string varchar(20) = NULL
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@query varchar(5000),
		@car_id varchar(24),
		@make_string varchar(40),
		@model_string varchar(40);

	SET @errornumber = '11400';

	SET @car_id = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@pcar_id)), '''', ''''''), '[', '[[]'), '%', '[%]'), '_', '[_]'), ';', ''), '--', '-'), '/*', ''), '*/', '');
	SET @make_string = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@pmake_string)), '''', ''''''), '[', '[[]'), '%', '[%]'), '_', '[_]'), ';', ''), '--', '-'), '/*', ''), '*/', '');
	SET @model_string = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@pmodel_string)), '''', ''''''), '[', '[[]'), '%', '[%]'), '_', '[_]'), ';', ''), '--', '-'), '/*', ''), '*/', '');

	IF (@car_id = '' OR @car_id IS NULL) AND (@make_string = '' OR @make_string IS NULL) AND (@model_string = '' OR @model_string IS NULL)
	BEGIN
		SET @errornumber = '11401';
		SET @errortext = 'No search parameters were passed';
		GOTO errorexit;
	END

	SET @query = 

	'SELECT
		cvh.complaint_no,
		cvh.entered_by,
		cvh.site_ref,
		cvh.site_name_1,
		cvh.exact_location,
		cvh.service_c,
		cvh.service_c_desc,
		cvh.comp_code,
		cvh.comp_code_desc,
		cvh.item_ref,
		cvh.item_desc,
		cvh.priority_flag,
		cvh.feature_ref,
		cvh.feature_desc,
		cvh.contract_ref,
		cvh.[contract_name],
		cvh.action_flag,
		cvh.action_flag_desc,
		dbo.cs_comptext_getNotes(cvh.complaint_no, 0) AS notes,
		cvh.compl_init,
		cvh.compl_name,
		cvh.compl_surname,
		cvh.compl_build_no,
		cvh.compl_build_name,
		cvh.compl_addr2,
		cvh.compl_addr4,
		cvh.compl_addr5,
		cvh.compl_addr6,
		cvh.compl_postcode,
		cvh.compl_phone,
		cvh.compl_email,
		cvh.compl_business,
		cvh.int_ext_flag,
		cvh.date_entered,
		cvh.ent_time_h,
		cvh.ent_time_m,
		cvh.dest_ref,
		cvh.dest_suffix,
		cvh.date_due,
		cvh.date_closed,
		cvh.incident_id,
		cvh.details_1,
		cvh.details_2,
		cvh.details_3,
		cvh.notice_type,
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

		cav.generated_no,
		cav.car_id,
		cav.make_ref,
		(SELECT make_desc FROM makes WHERE make_ref = cav.make_ref) AS make_desc,
		cav.model_ref,
		(SELECT model_desc FROM models WHERE model_ref = cav.model_ref AND make_ref = cav.make_ref) AS model_desc,
		cav.colour_ref,
		(SELECT colour_desc FROM colour WHERE colour_ref = cav.colour_ref) AS colour_desc,
		cav.date_stickered,
		cav.time_stickered_h,
		cav.time_stickered_m,
		cav.vehicle_class,
		cav.officer_id,
		cav.road_fund_flag,
		cav.road_fund_valid,
		cav.last_seq,
		cav.date_police_email,
		cav.date_fire_email,
		cav.date_housing_email,
		cav.dho_rep,
		cav.dho_cc_building,
		cav.how_long_there,
		cav.vin,
		cavh.status_ref,
		av_status.[description] AS status_description,
		cavh.notes AS status_notes,
		status_days_remaining = 
			CASE 
				WHEN DATEDIFF(day, CONVERT(datetime, CONVERT(date, GETDATE())), cavh.[expiry_date]) > 0 THEN DATEDIFF(day, CONVERT(datetime, CONVERT(date, GETDATE())), cavh.[expiry_date])
				ELSE 0
			END,
		keeper_required =
			/* Keeper details required for this status?  */
			CASE 
				WHEN
					(
					av_status.keeper = ''Y''
					AND cvh.complaint_no IS NOT NULL
					AND
						(
						LTRIM(RTRIM(cavh.keeper_title)) IS NULL
						OR LTRIM(RTRIM(cavh.compl_addr1)) IS NULL
						OR LTRIM(RTRIM(cavh.compl_addr4)) IS NULL
						OR LTRIM(RTRIM(cavh.motor_dealer)) IS NULL
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
					av_status.keeper = ''Y''
					AND cvh.complaint_no IS NOT NULL
					AND
						(
						LTRIM(RTRIM(cavh.keeper_title)) IS NULL
						OR LTRIM(RTRIM(cavh.compl_addr1)) IS NULL
						OR LTRIM(RTRIM(cavh.compl_addr4)) IS NULL
						OR LTRIM(RTRIM(cavh.motor_dealer)) IS NULL
						)
					)
				THEN 0
				ELSE
					(SELECT COUNT(*) FROM allk_avstat_link WHERE lookup_code = cavh.status_ref)
			END

		FROM cs_comp_viewHistory cvh
		INNER JOIN comp_av cav
		ON cav.complaint_no = cvh.complaint_no';

	IF @car_id <> '' AND @car_id IS NOT NULL
	BEGIN
		SET @query = @query +
			' AND cav.car_id LIKE ''' + @car_id + '%''';
	END

	IF @make_string IS NOT NULL
	BEGIN
		SET @query = @query +
			' AND cav.make_ref IN
			(SELECT make_ref FROM makes WHERE make_desc LIKE ''' + @make_string + '%'')';
	END

	IF @model_string IS NOT NULL
	BEGIN
		SET @query = @query +
			' AND cav.model_ref IN
			(SELECT model_ref FROM models WHERE model_desc LIKE ''' + @model_string + '%'')';
	END

	SET @query = @query +
		/* LEFT OUTER JOINs to select vehicles both with and without statuses */
		' LEFT OUTER JOIN comp_av_hist cavh' +
		' ON cavh.seq = cav.last_seq' +
		' AND cavh.complaint_no = cav.complaint_no' +
		' LEFT OUTER JOIN av_status' +
		' ON av_status.status_ref = cavh.status_ref' +
		' WHERE cvh.date_closed IS NULL' +
		' ORDER BY make_desc,' +
		'	model_desc,' +
		'	cvh.site_name_1';

	BEGIN TRY
		EXECUTE (@query);
	END TRY
	BEGIN CATCH
		SET @errornumber = '11402';
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
