/*****************************************************************************
** dbo.cs_site_getLocalStreets
** stored procedure
**
** Description
** Selects a list of street records within a given radius of a given location
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
** 06/03/2013  TW  Revised selection method
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_site_getLocalStreets', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_site_getLocalStreets;
GO
CREATE PROCEDURE dbo.cs_site_getLocalStreets
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

	/* Using CTE */
	/* Initial selection of all site records within the radius */
	;WITH cteSite AS
		(
		SELECT a.location_c,
			a.site_ref,
			a.site_status,
			a.site_name_1,
			a.site_name_2,
			a.site_c,
			a.build_sub_no,
			a.build_no,
			a.build_sub_no_disp,
			a.build_no_disp,
			a.build_sub_name,
			a.build_name,
			a.townname,
			a.postcode
			FROM [site] a
			INNER JOIN site_detail b
			ON b.site_ref = a.site_ref
			WHERE a.site_status = 'L'
				AND
				(b.easting BETWEEN @easting_min AND @easting_max
					OR ( (b.easting_end BETWEEN @easting_min AND @easting_max) AND b.easting_end IS NOT NULL ))
				AND (b.northing BETWEEN @northing_min AND @northing_max
					OR ( (b.northing_end BETWEEN @northing_min AND @northing_max) AND b.northing_end IS NOT NULL ))
				AND ((SQRT( ( SQUARE(@easting - b.easting) + SQUARE(@northing - b.northing) ) ) <= @radius AND b.easting IS NOT NULL AND b.northing IS NOT NULL)
					OR ( SQRT( ( SQUARE(@easting - b.easting_end) + SQUARE(@northing - b.northing_end) ) ) <= @radius AND b.easting_end IS NOT NULL AND b.northing_end IS NOT NULL ))
				)

	/* Select S and G sites from the initial selection */
	SELECT site_detail.site_ref,
		cteSite.site_name_1,
		cteSite.site_name_2,
		cteSite.site_c,
		ISNULL(CAST(SQRT( SQUARE(@easting - site_detail.easting) + SQUARE(@northing - site_detail.northing) ) AS DECIMAL (10,2)), 0) AS site_distance,
		(SELECT COUNT(*) FROM cs_comp_viewHistory WHERE cs_comp_viewHistory.site_ref = site_detail.site_ref) AS history,
		NULL AS site_sortkey,
		cteSite.build_sub_no,
		cteSite.build_no,
		cteSite.build_sub_no_disp,
		cteSite.build_no_disp,
		cteSite.build_sub_name,
		cteSite.build_name,
		cteSite.townname,
		cteSite.postcode,
		locn.location_name,
		locn.location_desc,
		site_sort = 
			CASE 
				WHEN
					((cteSite.site_c = 'G'
					AND @use_supersites <> 'Y')
					OR ((cteSite.site_ref like '%G')
					AND @use_supersites = 'Y')) THEN 1
				WHEN
					((cteSite.site_c = 'S'
					AND @use_supersites <> 'Y')
					OR ((cteSite.site_ref like '%S')
					AND @use_supersites = 'Y')) THEN 2
				WHEN
					((cteSite.site_c = 'P'
					AND @use_supersites <> 'Y')
					OR ((cteSite.site_ref NOT LIKE '%S' AND cteSite.site_ref NOT LIKE '%G')
					AND @use_supersites = 'Y')) THEN 3
			END
	FROM cteSite
	INNER JOIN site_detail
	ON site_detail.site_ref = cteSite.site_ref
	LEFT OUTER JOIN locn
	ON cteSite.location_c = locn.location_c
	WHERE
		(
			((cteSite.site_c IN ('S', 'G') AND @use_supersites <> 'Y')
				OR ((cteSite.site_ref like '%S' OR cteSite.site_ref like '%G') AND @use_supersites = 'Y'))
		)

	UNION

	/* Also select all S and G sites which have location_c         */
	/* matching the location_c of P sites in the initial selection */
	SELECT site_detail.site_ref,
		[site].site_name_1,
		[site].site_name_2,
		[site].site_c,
		ISNULL(CAST(SQRT( SQUARE(@easting - site_detail.easting) + SQUARE(@northing - site_detail.northing) ) AS DECIMAL (10,2)), 0) AS site_distance,
		(SELECT COUNT(*) FROM cs_comp_viewHistory WHERE cs_comp_viewHistory.site_ref = site_detail.site_ref) AS history,
		NULL AS site_sortkey,
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
		site_sort = 
			CASE 
				WHEN
					(([site].site_c = 'G'
					AND @use_supersites <> 'Y')
					OR (([site].site_ref like '%G')
					AND @use_supersites = 'Y')) THEN 1
				WHEN
					(([site].site_c = 'S'
					AND @use_supersites <> 'Y')
					OR (([site].site_ref like '%S')
					AND @use_supersites = 'Y')) THEN 2
				WHEN
					(([site].site_c = 'P'
					AND @use_supersites <> 'Y')
					OR (([site].site_ref NOT LIKE '%S' AND [site].site_ref NOT LIKE '%G')
					AND @use_supersites = 'Y')) THEN 3
			END
	FROM [site]
	INNER JOIN site_detail
	ON site_detail.site_ref = [site].site_ref
	LEFT OUTER JOIN locn
	ON [site].location_c = locn.location_c
	WHERE [site].location_c IN
		(
			SELECT location_c FROM cteSite
				WHERE ((cteSite.site_c = 'P' AND @use_supersites <> 'Y')
						OR ((cteSite.site_ref NOT LIKE '%S' AND cteSite.site_ref NOT LIKE '%G') AND @use_supersites = 'Y'))
		)
		AND NOT
		(
			([site].site_c = 'P' AND @use_supersites <> 'Y')
					OR (([site].site_ref NOT LIKE '%S' AND [site].site_ref NOT LIKE '%G') AND @use_supersites = 'Y')
		)
		/* This version is slower
		AND
		(
			(([site].site_c = 'G' AND @use_supersites <> 'Y') OR (([site].site_ref like '%G') AND @use_supersites = 'Y'))
			OR
			(([site].site_c = 'S' AND @use_supersites <> 'Y') OR (([site].site_ref like '%S') AND @use_supersites = 'Y'))
		)
		*/
	
	ORDER BY site_sort, site_distance, site_name_1;

END

GO
