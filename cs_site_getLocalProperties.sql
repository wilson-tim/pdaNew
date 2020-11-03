/*****************************************************************************
** dbo.cs_site_getLocalProperties
** stored procedure
**
** Description
** Selects a list of property records within a given radius of a given location
**
** Parameters
** @easting  = 6 digit decimal easting value, i.e. units of 1 metre
** @northing = 6 digit decimal northing value, i.e. units of 1 metre
** @radius   = distance in metres (e.g. keys LOCAL_SEARCH_RADIUS / PDAINI)
**
** Returned
** Result set of site information including
**   site_ref, char(16)
**   site_name_1, char(70)
**   site_name_2, char(70)
**   site_c, char(6)
**   site_distance, decimal(10,2) [not relevant here so always returns NULL]
**   history, integer
**   site_sortkey, varchar(100)
**   address data analysis columns
** ordered by site_distance
**
** History
** 07/12/2012  TW  New
** 12/12/2012  TW  Additionally return column site_c
** 28/01/2013  TW  Additionally return column history (count of history records)
** 06/02/2013  TW  Additionally return address analysis columns
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_site_getLocalProperties', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_site_getLocalProperties;
GO
CREATE PROCEDURE dbo.cs_site_getLocalProperties
	@peasting decimal(10,2),
	@pnorthing decimal(10,2),
	@pradius decimal(10,2)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @easting_min decimal(10,2),
			@easting_max decimal(10,2),
			@northing_min decimal(10,2),
			@northing_max decimal(10,2),
			@use_supersites char(1),
			@easting decimal(10,2),
			@northing decimal(10,2),
			@radius decimal(10,2);

	SET @easting = @peasting;
	SET @northing = @pnorthing;
	SET @radius = @pradius;

	SET @easting_min = @easting - @radius;
	SET @easting_max = @easting + @radius;

	SET @northing_min = @northing - @radius;
	SET @northing_max = @northing + @radius;

	/* Using supersites? */
	SET @use_supersites = UPPER(RTRIM(dbo.cs_keys_getCField('ALL', 'GENERATE_SUPERSITES')));
	IF @use_supersites IS NULL OR @use_supersites = ''
	BEGIN
		SET @use_supersites = 'Y';
	END

	SELECT site_detail.site_ref,
		[site].site_name_1,
		[site].site_name_2,
		[site].site_c,
		ISNULL(CAST(SQRT( SQUARE(@easting - site_detail.easting) + SQUARE(@northing - site_detail.northing) ) AS DECIMAL (10,2)), 0) AS site_distance,
		(SELECT COUNT(*) FROM cs_comp_viewHistory WHERE cs_comp_viewHistory.site_ref = site_detail.site_ref) AS history,
		(dbo.cs_site_getPropertySortkey(locn.location_name, site.build_no, site.build_name, site.build_sub_name, site.build_sub_no)) AS site_sortkey,
		[site].build_sub_no,
		[site].build_no,
		[site].build_sub_no_disp,
		[site].build_no_disp,
		[site].build_sub_name,
		[site].build_name,
		[site].townname,
		[site].postcode,
		locn.location_name,
		locn.location_desc,
		NULL AS site_sort
	FROM [site]
	INNER JOIN site_detail
	ON site_detail.site_ref = [site].site_ref
	LEFT OUTER JOIN locn
	ON [site].location_c = locn.location_c
	WHERE [site].site_status = 'L'
		AND
			(
				([site].site_c = 'P' AND @use_supersites <> 'Y')
					OR (([site].site_ref NOT LIKE '%S' AND [site].site_ref NOT LIKE '%G') AND @use_supersites = 'Y')
			)
		AND site_detail.easting BETWEEN @easting_min AND @easting_max
		AND site_detail.northing BETWEEN @northing_min AND @northing_max
		AND (SQRT( ( SQUARE(@easting - site_detail.easting) + SQUARE(@northing - site_detail.northing) ) ) <= @radius AND @easting IS NOT NULL AND @northing IS NOT NULL)
	ORDER BY site_distance, site_sortkey;

END

GO
