/*****************************************************************************
** dbo.cs_site_getPaArea
** user defined function
**
** Description
** Determine the pa_area for a given site_ref and service_c
**
** Parameters
** @site_ref  = site reference
** @service_c = service code
**
** Returned
** @pa_area
**
** History
** 27/02/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_site_getPaArea', N'FN') IS NOT NULL
    DROP FUNCTION dbo.cs_site_getPaArea;
GO
CREATE FUNCTION dbo.cs_site_getPaArea
(
	@site_ref varchar(16),
	@service_c varchar(6)
)
RETURNS varchar(6)
AS
BEGIN

	DECLARE @pa_area varchar(6),
		@site_c varchar(6),
		@location_c varchar(10);

	SET @service_c = LTRIM(RTRIM(@service_c));
	SET @site_ref = LTRIM(RTRIM(@site_ref));

	SELECT @site_c = site_c
		FROM [site]
		WHERE site_ref = @site_ref;
		
	IF LTRIM(RTRIM(dbo.cs_utils_getServiceType(@service_c))) = 'SL'
		AND dbo.cs_modulelic_getInstalled('SL') = 1
	BEGIN
		IF @site_c <> 'S'
		BEGIN
			/* Not a supersite, get the location */
			SELECT @location_c = location_c
				FROM site
				WHERE site_ref = @site_ref;

			SELECT @site_ref = site_ref
				FROM site
				WHERE location_c = @location_c
					AND site_c = 'S'
					AND site_status = 'L';
		END

		SELECT @pa_area = pa_area
			FROM si_i
			WHERE item_ref LIKE 'SL%'
				AND site_ref = @site_ref;
	END
	ELSE
	BEGIN
		SELECT @pa_area = pa_area
			FROM site_pa
			WHERE site_ref = @site_ref
				AND pa_func = @service_c;
	END

	RETURN (@pa_area);

END
GO 
