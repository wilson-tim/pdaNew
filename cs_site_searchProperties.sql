/*****************************************************************************
** dbo.cs_site_searchProperties
** stored procedure
**
** Description
** Selects a list of site property records using postcode, building number,
** building name and location search data.
** Search values are searched using a 'like '<search value>%'' query
** and a logical AND is applied to search results for multiple search parameters.
**
** Parameters
** @postcode     = postcode search value (optional)
** @buildingno   = building number search value (optional)
** @buildingname = building name search value (optional)
** @location     = location search value (optional)
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
** ordered by site_c, site_sortkey
**
** History
** 11/12/2012  TW  New
** 12/12/2012  TW  Additionally return column site_distance
** 08/01/2013  TW  New column sortkey
** 28/01/2013  TW  Additionally return column history (count of history records)
** 06/02/2013  TW  Revised search method and additionally return address analysis columns
** 06/06/2013  TW  Revised locn inner join code
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_site_searchProperties', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_site_searchProperties;
GO
CREATE PROCEDURE dbo.cs_site_searchProperties
	@ppostcode varchar(8) = NULL,
	@pbuildingno varchar(14) = NULL,
	@pbuildingname varchar(100) = NULL,
	@plocation varchar(100) = NULL
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
			@comp_build_no_disp char(1),
			@use_supersites char(1),
			@query varchar(4000),
			@errornumber varchar(10),
			@postcode varchar(16),
			@buildingno varchar(28),
			@buildingname varchar(200),
			@location varchar(200);

	SET @errornumber = '13200';

	SET @postcode     = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@ppostcode)), '''', ''''''), '[', '[[]'), '%', '[%]'), '_', '[_]'), ';', ''), '--', '-'), '/*', ''), '*/', '');
	SET @buildingno   = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@pbuildingno)), '''', ''''''), '[', '[[]'), '%', '[%]'), '_', '[_]'), ';', ''), '--', '-'), '/*', ''), '*/', '');
	SET @buildingname = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@pbuildingname)), '''', ''''''), '[', '[[]'), '%', '[%]'), '_', '[_]'), ';', ''), '--', '-'), '/*', ''), '*/', '');
	SET @location     = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@plocation)), '''', ''''''), '[', '[[]'), '%', '[%]'), '_', '[_]'), ';', ''), '--', '-'), '/*', ''), '*/', '');

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

	SET @query = '	DECLARE @use_supersites char(1);
					SET @use_supersites = UPPER(RTRIM(dbo.cs_keys_getCField(''ALL'', ''GENERATE_SUPERSITES'')));
					IF @use_supersites IS NULL OR @use_supersites = ''''
					BEGIN
						SET @use_supersites = ''Y'';
					END
					SELECT [site].site_ref,
						[site].site_name_1,
						[site].site_name_2,
						[site].site_c,
						NULL AS site_distance,
						(SELECT COUNT(*) FROM cs_comp_viewHistory WHERE cs_comp_viewHistory.site_ref = [site].site_ref) AS history,
						(dbo.cs_site_getPropertySortkey(locn.location_name, [site].build_no, [site].build_name, [site].build_sub_name, [site].build_sub_no)) AS site_sortkey,
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
									(([site].site_c = ''G''
									AND @use_supersites <> ''Y'')
									OR (([site].site_ref like ''%G'')
									AND @use_supersites = ''Y'')) THEN 1
								WHEN
									(([site].site_c = ''S''
									AND @use_supersites <> ''Y'')
									OR (([site].site_ref like ''%S'')
									AND @use_supersites = ''Y'')) THEN 2
								WHEN
									(([site].site_c = ''P''
									AND @use_supersites <> ''Y'')
									OR (([site].site_ref NOT LIKE ''%S'' AND [site].site_ref NOT LIKE ''%G'')
									AND @use_supersites = ''Y'')) THEN 3
							END
					FROM [site]';

	SET @query = @query + ' INNER JOIN [site] site2 ON [site].site_ref = site2.site_ref';

	IF (@postcode IS NOT NULL) AND (@postcode <> '')
	BEGIN
		SET @query = @query +
		' AND site2.postcode LIKE ''' + UPPER(@postcode) + '%''';
	END
	IF (@buildingno IS NOT NULL) AND (@buildingno <> '') AND @comp_build_no_disp = 'Y'
	BEGIN
		SET @query = @query +
		' AND (site2.build_no_disp LIKE ''' + UPPER(@buildingno) + '%''
			OR site2.build_sub_no LIKE ''' + UPPER(@buildingno) + '%'')';
	END
	IF (@buildingno IS NOT NULL) AND (@buildingno <> '') AND @comp_build_no_disp <> 'Y'
	BEGIN
		SET @query = @query +
		' AND (site2.build_no LIKE ''' + UPPER(@buildingno) + '%''
			OR site2.build_sub_no LIKE ''' + UPPER(@buildingno) + '%'')';
	END
	IF (@buildingname IS NOT NULL) AND (@buildingname <> '')
	BEGIN
		SET @query = @query +
		' AND (site2.build_name LIKE ''' + UPPER(@buildingname) + '%''
			OR site2.build_sub_name LIKE ''' + UPPER(@buildingname) + '%'')';
	END
	IF (@location IS NULL) OR (@location = '')
	BEGIN
		SET @query = @query + 
			' INNER JOIN locn ON [site].location_c = locn.location_c';
	END
	ELSE
	BEGIN
		SET @query = @query +
			' INNER JOIN locn
			ON [site].location_c = locn.location_c
				AND locn.location_name LIKE ''' + UPPER(@location) + '%''';
	END

	SET @query = @query + ' WHERE [site].site_status = ''L''';

	IF @use_supersites = 'Y'
	BEGIN
		SET @query = @query + ' AND ([site].site_ref NOT LIKE ''%S'' AND [site].site_ref NOT LIKE ''%G'')';
	END
	ELSE
	BEGIN
		SET @query = @query + ' AND [site].site_c = ''P''';
	END
	
	SET @query = @query + ' ORDER BY site_sort, site_sortkey;';

	BEGIN TRY
		EXECUTE (@query);
	END TRY
	BEGIN CATCH
		SET @errornumber = '13201';
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
