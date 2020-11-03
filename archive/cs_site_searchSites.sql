/*****************************************************************************
** dbo.cs_site_searchSites
** stored procedure
**
** Description
** Selects a list of site records using postcode, building number,
** building name and location search data.
** Search values are searched using a 'like '%<search value>%'' query
** and a logical AND is applied to search results for multiple search parameters.
**
** Parameters
** @postcode     = postcode search value (optional)
** @buildingno   = building number search value (optional)
** @buildingname = building name search value (optional)
** @location     = location search value (optional)
**
** Returned
** Result set of site information
**   site_ref, char(16)
**   site_name_1, char(70)
**   site_c, char(6)
**   site_distance, decimal(10,2) [not relevant here so always returns NULL]
** ordered by site_c, site_name_1
**
** History
** 07/12/2012  TW  New
** 10/12/2012  TW  Rewritten - resolved problem of intersecting null results
** 12/12/2012  TW  Additionally return column site_distance
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_site_searchSites', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_site_searchSites;
GO
CREATE PROCEDURE dbo.cs_site_searchSites
	@postcode varchar(8) = NULL,
	@buildingno varchar(14) = NULL,
	@buildingname varchar(100) = NULL,
	@location varchar(100) = NULL
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @comp_build_no_disp char(1),
			@use_supersites char(1);

	DECLARE @searchSites1 AS table
				(
					site_ref char(16),
					site_name_1 char(70),
					site_c char(6),
					site_distance decimal(10,0)
				);

	DECLARE @searchSites2 AS table
				(
					site_ref char(16),
					site_name_1 char(70),
					site_c char(6),
					site_distance decimal(10,0)
				);

	DECLARE @searchSites3 AS table
				(
					site_ref char(16),
					site_name_1 char(70),
					site_c char(6),
					site_distance decimal(10,0)
				);

	DECLARE @searchSites4 AS table
				(
					site_ref char(16),
					site_name_1 char(70),
					site_c char(6),
					site_distance decimal(10,0)
				);


	DECLARE @searchSitesResults AS table
				(
					site_ref char(16),
					site_name_1 char(70),
					site_c char(6),
					site_distance decimal(10,0)
				);

	SET @postcode     = RTRIM(LTRIM(@postcode));
	SET @buildingno   = RTRIM(LTRIM(@buildingno));
	SET @buildingname = RTRIM(LTRIM(@buildingname));
	SET @location     = RTRIM(LTRIM(@location));

	/* Using build_no or build_no_disp? */
	SET @comp_build_no_disp = UPPER(RTRIM(dbo.cs_keys_getCField('ALL', 'COMP_BUILD_NO_DISP')));
	IF @comp_build_no_disp IS NULL OR @comp_build_no_disp = ''
	BEGIN
		SET @comp_build_no_disp = 'N';
	END

	/* Using supersites? */
	SET @use_supersites = UPPER(RTRIM(dbo.cs_keys_getCField('ALL', 'GENERATE_SUPERSITES')));
	IF @use_supersites IS NULL OR @use_supersites = ''
	BEGIN
		SET @use_supersites = 'Y';
	END

	/* Perform searches */
	IF (@postcode IS NOT NULL) AND (@postcode <> '')
	BEGIN
		INSERT INTO @searchSites1
			(
				site_ref,
				site_name_1,
				site_c,
				site_distance
			)
		SELECT site_detail.site_ref, site.site_name_1, site.site_c, NULL
		FROM site_detail
		INNER JOIN site
		ON site.site_ref = site_detail.site_ref
			AND site.site_status = 'L'
			AND ((site.site_c IN ('S', 'G', 'P')
			AND @use_supersites <> 'Y')
			OR ((site.site_ref like '%S' OR site.site_ref like '%G' OR (site.site_ref NOT LIKE '%S' AND site.site_ref NOT LIKE '%G'))
			AND @use_supersites = 'Y'))
		INNER JOIN site site2
		ON site.site_ref = site2.site_ref
			AND site2.postcode like '%' + UPPER(@postcode) + '%';
	END
	IF (@buildingno IS NOT NULL) AND (@buildingno <> '') AND @comp_build_no_disp = 'Y'
	BEGIN
		INSERT INTO @searchSites2
			(
				site_ref,
				site_name_1,
				site_c,
				site_distance
			)
		SELECT site_detail.site_ref, site.site_name_1, site.site_c, NULL
		FROM site_detail
		INNER JOIN site
		ON site.site_ref = site_detail.site_ref
			AND site.site_status = 'L'
			AND ((site.site_c IN ('S', 'G', 'P')
			AND @use_supersites <> 'Y')
			OR ((site.site_ref like '%S' OR site.site_ref like '%G' OR (site.site_ref NOT LIKE '%S' AND site.site_ref NOT LIKE '%G'))
			AND @use_supersites = 'Y'))
		INNER JOIN site site2
		ON site.site_ref = site2.site_ref
			AND site2.build_no_disp like '%' + UPPER(@buildingno) + '%'
			OR site2.build_sub_no like '%' + UPPER(@buildingno) + '%';
	END
	IF (@buildingno IS NOT NULL) AND (@buildingno <> '') AND @comp_build_no_disp <> 'Y'
	BEGIN
		INSERT INTO @searchSites2
			(
				site_ref,
				site_name_1,
				site_c,
				site_distance
			)
		SELECT site_detail.site_ref, site.site_name_1, site.site_c, NULL
		FROM site_detail
		INNER JOIN site
		ON site.site_ref = site_detail.site_ref
			AND site.site_status = 'L'
			AND ((site.site_c IN ('S', 'G', 'P')
			AND @use_supersites <> 'Y')
			OR ((site.site_ref like '%S' OR site.site_ref like '%G' OR (site.site_ref NOT LIKE '%S' AND site.site_ref NOT LIKE '%G'))
			AND @use_supersites = 'Y'))
		INNER JOIN site site2
		ON site.site_ref = site2.site_ref
			AND site2.build_no like '%' + UPPER(@buildingno) + '%'
			OR site2.build_sub_no like '%' + UPPER(@buildingno) + '%';
	END
	IF (@buildingname IS NOT NULL) AND (@buildingname <> '')
	BEGIN
		INSERT INTO @searchSites3
			(
				site_ref,
				site_name_1,
				site_c,
				site_distance
			)
		SELECT site_detail.site_ref, site.site_name_1, site.site_c, NULL
		FROM site_detail
		INNER JOIN site
		ON site.site_ref = site_detail.site_ref
			AND site.site_status = 'L'
			AND ((site.site_c IN ('S', 'G', 'P')
			AND @use_supersites <> 'Y')
			OR ((site.site_ref like '%S' OR site.site_ref like '%G' OR (site.site_ref NOT LIKE '%S' AND site.site_ref NOT LIKE '%G'))
			AND @use_supersites = 'Y'))
		INNER JOIN site site2
		ON site.site_ref = site2.site_ref
			AND site2.build_name like '%' + UPPER(@buildingname) + '%'
			OR site2.build_sub_name like '%' + UPPER(@buildingname) + '%';
	END
	IF (@location IS NOT NULL) AND (@location <> '')
	BEGIN
		INSERT INTO @searchSites4
			(
				site_ref,
				site_name_1,
				site_c,
				site_distance
			)
		SELECT site_detail.site_ref, site.site_name_1, site.site_c, NULL
		FROM site_detail
		INNER JOIN site
		ON site.site_ref = site_detail.site_ref
			AND site.site_status = 'L'
			AND ((site.site_c IN ('S', 'G', 'P')
			AND @use_supersites <> 'Y')
			OR ((site.site_ref like '%S' OR site.site_ref like '%G' OR (site.site_ref NOT LIKE '%S' AND site.site_ref NOT LIKE '%G'))
			AND @use_supersites = 'Y'))
		INNER JOIN locn
		ON site.location_c = locn.location_c
			AND locn.location_name like '%' + UPPER(@location) + '%';
	END

	/* 
	** Need to intersect tables of search results
	** but of course some may be NULL so a standard intersect would have failed
	** therefore perform a conditional intersect programmatically
	*/

	/* First UNION all search results */
	INSERT INTO @searchSitesResults
		SELECT site_ref, site_name_1, site_c, site_distance
			FROM @searchSites1
		UNION
		SELECT site_ref, site_name_1, site_c, site_distance
			FROM @searchSites2
		UNION
		SELECT site_ref, site_name_1, site_c, site_distance
			FROM @searchSites3
		UNION
		SELECT site_ref, site_name_1, site_c, site_distance
			FROM @searchSites4

	/* Then INTERSECT search results conditionally */
	IF (SELECT COUNT(*) FROM @searchSites1) > 0
	BEGIN
		DELETE r FROM @searchSitesResults r
			WHERE NOT EXISTS(SELECT 1 FROM @searchSites1 WHERE site_ref=r.site_ref);
	END
	IF (SELECT COUNT(*) FROM @searchSites1) = 0 AND @postcode <> '' AND @postcode IS NOT NULL
	BEGIN
		DELETE r FROM @searchSitesResults r
	END

	IF (SELECT COUNT(*) FROM @searchSites2) > 0
	BEGIN
		DELETE r FROM @searchSitesResults r
			WHERE NOT EXISTS(SELECT 1 FROM @searchSites2 WHERE site_ref=r.site_ref);
	END
	IF (SELECT COUNT(*) FROM @searchSites2) = 0 AND @buildingno <> '' AND @buildingno IS NOT NULL
	BEGIN
		DELETE r FROM @searchSitesResults r
	END

	IF (SELECT COUNT(*) FROM @searchSites3) > 0
	BEGIN
		DELETE r FROM @searchSitesResults r
			WHERE NOT EXISTS(SELECT 1 FROM @searchSites3 WHERE site_ref=r.site_ref);
	END
	IF (SELECT COUNT(*) FROM @searchSites3) = 0 AND @buildingname <> '' AND @buildingname IS NOT NULL
	BEGIN
		DELETE r FROM @searchSitesResults r
	END

	IF (SELECT COUNT(*) FROM @searchSites4) > 0
	BEGIN
		DELETE r FROM @searchSitesResults r
			WHERE NOT EXISTS(SELECT 1 FROM @searchSites4 WHERE site_ref=r.site_ref);
	END
	IF (SELECT COUNT(*) FROM @searchSites4) = 0 AND @location <> '' AND @location IS NOT NULL
	BEGIN
		DELETE r FROM @searchSitesResults r
	END

	/* Return final search results */
	SELECT site_ref, site_name_1, site_c, site_distance
		FROM @searchSitesResults
		ORDER BY site_c, site_name_1;

END

GO 
