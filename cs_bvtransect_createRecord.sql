/*****************************************************************************
** dbo.cs_bvtransect_createRecord
** stored procedure
**
** Description
** [NI195] Create a bv_transect record
**
** Parameters (all compulsory, except either start_ref and end_ref, or description)
** @pland_use varchar(6)        = land use code (SP cs_allk_getNI195LandUses)
** @plowdensity_flag varchar(1) = low density flag (Y / N)
** @pward_flag varchar(1)       = outside ward flag (Y / N)
** @psite_ref varchar(16)       = site reference (from the inspection list selection)
** @pmeasure_method varchar(6)  = measurement method (SP cs_allk_getNI195MeasurementMethods)
** @pstart_ref varchar(10)      = start reference (street light number or property number)
** @pend_ref varchar(10)        = end reference (street light number or property number)
** @pdescription varchar(150)   = description (if measurement method not by street light number
**                                  nor by property number)
**
** Returned
** @transect_ref  = the transect reference for the new record
** @transect_date = (for completeness only) the datestamp when the record was created
** Return value of 0 if successful, otherwise -1
**
** History
** 13/05/2013  TW  New
** 16/05/2013  TW  Additional output columns land_use_desc and measure_method_desc
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_bvtransect_createRecord', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_bvtransect_createRecord;
GO
CREATE PROCEDURE dbo.cs_bvtransect_createRecord
	@pland_use varchar(6) OUTPUT,
	@plowdensity_flag varchar(1) = NULL OUTPUT,
	@pward_flag varchar(1) = NULL OUTPUT,
	@psite_ref varchar(16) OUTPUT,
	@pmeasure_method varchar(6) OUTPUT,
	@pstart_ref varchar(10) OUTPUT,
	@pend_ref varchar(10) OUTPUT,
	@pdescription varchar(150) OUTPUT,
	@transect_ref integer OUTPUT,
	@transect_date datetime OUTPUT,
	@land_use_desc varchar(40) = NULL OUTPUT,
	@measure_method_desc varchar(40) = NULL OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@land_use varchar(6),
		@lowdensity_flag varchar(1),
		@ward_flag varchar(1),
		@site_ref varchar(16),
		@measure_method varchar(6),
		@start_ref varchar(10),
		@end_ref varchar(10),
		@description varchar(150),
		@result integer;

	SET @errornumber = '20438';

	SET @land_use = LTRIM(RTRIM(@pland_use));
	SET @lowdensity_flag = LTRIM(RTRIM(@plowdensity_flag));
	SET @ward_flag = LTRIM(RTRIM(@pward_flag));
	SET @site_ref = LTRIM(RTRIM(@psite_ref));
	SET @measure_method = LTRIM(RTRIM(@pmeasure_method));
	SET @start_ref = LTRIM(RTRIM(@pstart_ref));
	SET @end_ref = LTRIM(RTRIM(@pend_ref));
	SET @description = LTRIM(RTRIM(@pdescription));
	IF @land_use = '' OR @land_use IS NULL
	BEGIN
		SET @errornumber = '20439';
		SET @errortext = 'land_use is required';
		GOTO errorexit;
	END
/*
	IF @lowdensity_flag = '' OR @lowdensity_flag IS NULL
	BEGIN
		SET @errornumber = '20440';
		SET @errortext = 'lowdensity_flag is required';
		GOTO errorexit;
	END

	IF @ward_flag = '' OR @ward_flag IS NULL
	BEGIN
		SET @errornumber = '20441';
		SET @errortext = 'ward_flag is required';
		GOTO errorexit;
	END
*/
	IF @site_ref = '' OR @site_ref IS NULL
	BEGIN
		SET @errornumber = '20442';
		SET @errortext = 'site_ref is required';
		GOTO errorexit;
	END

	IF @measure_method = '' OR @measure_method IS NULL
	BEGIN
		SET @errornumber = '20443';
		SET @errortext = 'measure_method is required';
		GOTO errorexit;
	END

	IF (@start_ref = '' OR @start_ref IS NULL)
		AND (@end_ref = '' OR @end_ref IS NULL)
		AND (@description = '' OR @description IS NULL)
	BEGIN
		SET @errornumber = '20444';
		SET @errortext = 'either start_ref plus end_ref, or description is required';
		GOTO errorexit;
	END

	IF (@start_ref = '' OR @start_ref IS NULL)
		AND (@end_ref <> '' AND @end_ref IS NOT NULL)
	BEGIN
		SET @errornumber = '20445';
		SET @errortext = 'start_ref is required';
		GOTO errorexit;
	END

	IF (@start_ref <> '' AND @start_ref IS NOT NULL)
		AND (@end_ref = '' OR @end_ref IS NULL)
	BEGIN
		SET @errornumber = '20446';
		SET @errortext = 'end_ref is required';
		GOTO errorexit;
	END

	BEGIN TRY
		EXECUTE @result = dbo.cs_sno_getSerialNumber 'bv_transect', '', @serial_no = @transect_ref OUTPUT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20447';
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

	SET @transect_date = GETDATE();

	SELECT @land_use_desc = lookup_text
		FROM allk
		WHERE lookup_code = @land_use
			AND lookup_func = 'BVLAND';

	SELECT @measure_method_desc = lookup_text
		FROM allk
		WHERE lookup_code = @measure_method
			AND lookup_func = 'BVMEAS';

	BEGIN TRY
		INSERT INTO bv_transect
			(
			transect_ref,
			transect_date,
			land_use,
			lowdensity_flag,
			ward_flag,
			site_ref,
			measure_method,
			start_ref,
			end_ref,
			[description]
			)
			VALUES
			(
			@transect_ref,
			@transect_date,
			@land_use,
			@lowdensity_flag,
			@ward_flag,
			@site_ref,
			@measure_method,
			@start_ref,
			@end_ref,
			@description
			)
	END TRY
	BEGIN CATCH
		SET @errornumber = '20448';
		SET @errortext = 'Error inserting bv_transect record';
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
