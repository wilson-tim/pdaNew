/*****************************************************************************
** dbo.cs_bvtransect_getNI195Transects
** stored procedure
**
** Description
** [NI195] Selects a list of existing NI195 transects
**
** Parameters
** None
**
** Returned
** Result set of NI195 transects data
** Return value of @@ROWCOUNT or -1
**
** History
** 09/05/2013  TW  New
** 14/05/2013  TW  Additional columns lowdensity_flag, ward_flag
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_bvtransect_getNI195Transects', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_bvtransect_getNI195Transects;
GO
CREATE PROCEDURE dbo.cs_bvtransect_getNI195Transects
	@site_ref varchar(16)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer;

	SET @errornumber = '20399';

	SET @site_ref = LTRIM(RTRIM(@site_ref));

	IF @site_ref = '' OR @site_ref IS NULL
	BEGIN
		SET @errornumber = '20400';
		SET @errortext   = 'site_ref is required';
		GOTO errorexit;
	END

	SELECT bv_transect.transect_ref,
		bv_transect.land_use,
		allk1.lookup_text AS land_use_desc,
		measure_method,
		allk2.lookup_text AS measure_method_desc,
		start_ref,
		end_ref,
		[description],
		transect_date,
		lowdensity_flag,
		ward_flag
		FROM bv_transect
		INNER JOIN allk allk1
		ON allk1.lookup_code = bv_transect.land_use
			AND allk1.lookup_func = 'BVLAND'
		INNER JOIN allk allk2
		ON allk2.lookup_code = bv_transect.measure_method
			AND allk2.lookup_func = 'BVMEAS'
		WHERE bv_transect.site_ref = @site_ref;

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
