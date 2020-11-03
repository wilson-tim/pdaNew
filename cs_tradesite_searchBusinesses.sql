/*****************************************************************************
** dbo.cs_tradesite_searchBusinesses
** stored procedure
**
** Description
** Selects a list of trade waste site records using business name, postcode,
** building number, building name and location search data.
** Search values are searched using a 'like '<search value>%'' query
** and a logical AND is applied to search results for multiple search parameters.
** If a business name search value is specified then the search results are ordered
** by business name, otherwise the ordering is by site_sortkey, business name.
**
** Parameters
** @businessname = business name search value (optional)
** @postcode     = postcode search value (optional)
** @buildingno   = building number search value (optional)
** @buildingname = building name search value (optional)
** @location     = location search value (optional)
**
** Returned
** Result set of trade waste site records
**
** History
** 06/06/2013  TW  New
** 10/06/2013  TW  Continued development
** 11/06/2013  TW  Continued development
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_tradesite_searchBusinesses', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_tradesite_searchBusinesses;
GO
CREATE PROCEDURE dbo.cs_tradesite_searchBusinesses
	@pbusinessname varchar(60) = NULL,
	@ppostcode varchar(8) = NULL,
	@pbuildingno varchar(14) = NULL,
	@pbuildingname varchar(100) = NULL,
	@plocation varchar(100) = NULL,
	@xmlTradeBusiness xml OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
			@comp_build_no_disp char(1),
			@query nvarchar(MAX),
			@params nvarchar(MAX),
			@errornumber varchar(10),
			@businessname varchar(120),
			@postcode varchar(16),
			@buildingno varchar(28),
			@buildingname varchar(200),
			@location varchar(200);

	SET @errornumber = '20587';

	SET @businessname = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@pbusinessname)), '''', ''''''), '[', '[[]'), '%', '[%]'), '_', '[_]'), ';', ''), '--', '-'), '/*', ''), '*/', '');
	SET @postcode     = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@ppostcode)), '''', ''''''), '[', '[[]'), '%', '[%]'), '_', '[_]'), ';', ''), '--', '-'), '/*', ''), '*/', '');
	SET @buildingno   = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@pbuildingno)), '''', ''''''), '[', '[[]'), '%', '[%]'), '_', '[_]'), ';', ''), '--', '-'), '/*', ''), '*/', '');
	SET @buildingname = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@pbuildingname)), '''', ''''''), '[', '[[]'), '%', '[%]'), '_', '[_]'), ';', ''), '--', '-'), '/*', ''), '*/', '');
	SET @location     = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@plocation)), '''', ''''''), '[', '[[]'), '%', '[%]'), '_', '[_]'), ';', ''), '--', '-'), '/*', ''), '*/', '');

	IF (@businessname = '' OR @businessname IS NULL)
		AND (@postcode = '' OR @postcode IS NULL)
		AND (@buildingno = '' OR @buildingno IS NULL)
		AND (@buildingname = '' OR @buildingname IS NULL)
		AND (@location = '' OR @location IS NULL)
	BEGIN
		SET @errornumber = '20589';
		SET @errortext = 'No search parameters were passed';
		GOTO errorexit;
	END

	/* Using build_no or build_no_disp? */
	SET @comp_build_no_disp = UPPER(RTRIM(dbo.cs_keys_getCField('ALL', 'COMP_BUILD_NO_DISP')));
	IF @comp_build_no_disp IS NULL OR @comp_build_no_disp = ''
	BEGIN
		SET @comp_build_no_disp = 'N';
	END

	/* Using SELECT * and alias names to reduce the length of @query to around 3,300 characters */
	SET @query = 

		'SET @dynamicxmlTradeBusiness = 
			(
			SELECT
				*
				,(SELECT agreement_no
					,agreement_name
					,latest_cwtn
					,waste_type
					,(SELECT waste_type.waste_desc FROM waste_type WHERE waste_type.waste_type = TradeAgreementDTO.waste_type) AS waste_type_desc
					,[start_date]
					,close_date
					,contractor_ref
					,(SELECT cntr.contr_name FROM cntr WHERE cntr.contractor_ref = TradeAgreementDTO.contractor_ref) AS contractor_name
					,status_ref
					,status_ref_desc =
						CASE
							WHEN status_ref = ''C'' THEN ''Closed''
							WHEN status_ref = ''L'' THEN ''Legal''
							WHEN status_ref = ''R'' THEN ''Running''
							WHEN status_ref = ''S'' THEN ''Suspended''
							WHEN status_ref = ''D'' THEN ''Deleted''
						END
					FROM agreement TradeAgreementDTO
					WHERE TradeAgreementDTO.site_ref = TradeBusinessDTO.site_no
						AND GETDATE() >= TradeAgreementDTO.[start_date]
						AND (GETDATE() < TradeAgreementDTO.close_date OR TradeAgreementDTO.close_date IS NULL)
					ORDER BY agreement_no
					FOR XML AUTO, ELEMENTS, TYPE, ROOT(''AgreementsSummary''))
			FROM
				(
				SELECT
					ts.site_ref
					,ts.site_no
					,ts.ta_name
					,ts.site_name
					,ts.building
					,LTRIM(RTRIM(ts.addr_num)) AS addr_num
					,ts.addr_1
					,ts.addr_2
					,ts.addr_3
					,ts.addr_4
					,ts.addr_5
					,ts.addr_6
					,ts.addr_7
					,ts.postcode AS trade_postcode
					,ts.telephone
					,ts.contact_name
					,ts.contact_title
					,ts.contact_tel
					,ts.bus_category
					,(SELECT bus_categories.cate_desc FROM bus_categories WHERE bus_categories.bus_category = ts.bus_category) AS bus_category_desc
					,RTRIM(LTRIM(RTRIM(ISNULL(site1.site_name_1, ''''))) + '' '' + LTRIM(RTRIM(ISNULL(site1.site_name_2, '''')))) AS site_address
					,site1.site_c
					,NULL AS site_distance
					,(SELECT COUNT(*) FROM cs_comp_viewHistory WHERE cs_comp_viewHistory.site_ref = ts.site_ref) AS history
					,(SELECT COUNT(*) FROM agreement WHERE agreement.site_ref = ts.site_no AND GETDATE() >= agreement.[start_date] AND (GETDATE() < agreement.close_date OR agreement.close_date IS NULL)) AS agreements
					,(dbo.cs_site_getPropertySortkey(locn.location_name, site1.build_no, site1.build_name, site1.build_sub_name, site1.build_sub_no)) AS site_sortkey
					,LTRIM(RTRIM(site1.build_sub_no)) AS build_sub_no
					,LTRIM(RTRIM(site1.build_no)) AS build_no
					,LTRIM(RTRIM(site1.build_sub_no_disp)) AS build_sub_no_disp
					,LTRIM(RTRIM(site1.build_no_disp)) AS build_no_disp
					,site1.build_sub_name
					,site1.build_name
					,site1.townname
					,site1.postcode AS site_postcode
					,locn.location_name
					,locn.location_desc
					,ts.[start_date]
					,ts.close_date
					,ts.name_flag
					,name_flag_desc =
						CASE
							WHEN ts.name_flag = ''T'' THEN ''Trade details''
							WHEN ts.name_flag = ''S'' THEN ''Site details''
						END
					,ts.fax_num
					,ts.contact_fax
					,ts.debtor_ref
					,ts.account_ref
					,ts.pa_area
				FROM trade_site ts
				INNER JOIN [site] site1
				ON site1.site_ref = ts.site_ref';

	SET @query = @query + ' INNER JOIN [site] site2 ON site1.site_ref = site2.site_ref';

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

	IF (@location = '') OR (@location IS NULL)
	BEGIN
		SET @query = @query +
		' INNER JOIN locn
		ON site1.location_c = locn.location_c';
	END
	ELSE
	BEGIN
		SET @query = @query +
		' INNER JOIN locn
		ON site1.location_c = locn.location_c
			AND locn.location_name LIKE ''' + UPPER(@location) + '%''';
	END

	/* WHERE clause */
	SET @query = @query + ' WHERE ts.status_ref = ''R''';
	IF (@businessname <> '') AND (@businessname IS NOT NULL)
	BEGIN
		SET @query = @query +
		' AND (ts.ta_name LIKE ''' + UPPER(@businessname) + '%'' OR ts.site_name LIKE ''' + UPPER(@businessname) + '%'')';
	END
	SET @query = @query + ') TradeBusinessDTO';

	/* ORDER BY clause */
	IF (@businessname = '') OR (@businessname IS NULL)
	BEGIN
		SET @query = @query + ' ORDER BY TradeBusinessDTO.site_sortkey, TradeBusinessDTO.ta_name';
	END
	ELSE
	BEGIN
		SET @query = @query + ' ORDER BY TradeBusinessDTO.ta_name';
	END

	SET @query = @query + ' FOR XML AUTO, ELEMENTS, TYPE, ROOT(''ArrayOfTradeBusinessDTO''));';

	BEGIN TRY
		SET @params = N'@dynamicxmlTradeBusiness xml OUTPUT';
		EXECUTE sp_executesql @query, @params, @dynamicxmlTradeBusiness = @xmlTradeBusiness OUTPUT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20588';
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
