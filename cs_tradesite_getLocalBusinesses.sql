/*****************************************************************************
** dbo.cs_tradesite_getLocalBusinesses
** stored procedure
**
** Description
** Selects a list of trade waste site records within a given radius of a specified location.
** The search results are ordered by increasing distance from the specified location.
**
** Parameters
** @easting  = 6 digit decimal easting value, i.e. units of 1 metre
** @northing = 6 digit decimal northing value, i.e. units of 1 metre
** @radius   = distance in metres (e.g. keys LOCAL_SEARCH_RADIUS / PDAINI)
**
** Returned
** @xmlTradeBusiness = XML result set of trade waste site records
**
** History
** 06/06/2013  TW  New
** 07/06/2013  TW  Continued development
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_tradesite_getLocalBusinesses', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_tradesite_getLocalBusinesses;
GO
CREATE PROCEDURE dbo.cs_tradesite_getLocalBusinesses
	@peasting decimal(10,2),
	@pnorthing decimal(10,2),
	@pradius decimal(10,2),
	@xmlTradeBusiness xml OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errornumber varchar(10),
			@errortext varchar(500),
			@easting_min decimal(10,2),
			@easting_max decimal(10,2),
			@northing_min decimal(10,2),
			@northing_max decimal(10,2),
			@easting decimal(10,2),
			@northing decimal(10,2),
			@radius decimal(10,2);

	SET @errornumber = '20590';

	SET @easting = @peasting;
	SET @northing = @pnorthing;
	SET @radius = @pradius;

	IF @easting = 0 OR @easting IS NULL
	BEGIN
		SET @errornumber = '20591';
		SET @errortext   = 'easting is required';
		GOTO errorexit;
	END

	IF @northing = 0 OR @northing IS NULL
	BEGIN
		SET @errornumber = '20592';
		SET @errortext   = 'northing is required';
		GOTO errorexit;
	END

	IF @radius = 0 OR @radius IS NULL
	BEGIN
		SET @errornumber = '20593';
		SET @errortext   = 'radius is required';
		GOTO errorexit;
	END

	SET @easting_min = @easting - @radius;
	SET @easting_max = @easting + @radius;

	SET @northing_min = @northing - @radius;
	SET @northing_max = @northing + @radius;

	BEGIN TRY

		SET @xmlTradeBusiness = 
			(
			SELECT
				site_ref
				,site_no
				,ta_name
				,site_name
				,building
				,LTRIM(RTRIM(addr_num)) AS addr_num
				,addr_1
				,addr_2
				,addr_3
				,addr_4
				,addr_5
				,addr_6
				,addr_7
				,trade_postcode
				,telephone
				,contact_name
				,contact_title
				,contact_tel
				,bus_category
				,bus_category_desc
				,site_address
				,site_c
				,site_distance
				,history
				,agreements
				,site_sortkey
				,LTRIM(RTRIM(build_sub_no)) AS build_sub_no
				,LTRIM(RTRIM(build_no)) AS build_no
				,LTRIM(RTRIM(build_sub_no_disp)) AS build_sub_no_disp
				,LTRIM(RTRIM(build_no_disp)) AS build_no_disp
				,build_sub_name
				,build_name
				,townname
				,site_postcode
				,location_name
				,location_desc
				,[start_date]
				,close_date
				,name_flag
				,name_flag_desc
				,fax_num
				,contact_fax
				,debtor_ref
				,account_ref
				,pa_area
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
							WHEN status_ref = 'C' THEN 'Closed'
							WHEN status_ref = 'L' THEN 'Legal'
							WHEN status_ref = 'R' THEN 'Running'
							WHEN status_ref = 'S' THEN 'Suspended'
							WHEN status_ref = 'D' THEN 'Deleted'
						END
					FROM agreement AS TradeAgreementDTO
					WHERE TradeAgreementDTO.site_ref = TradeBusinessDTO.site_no
						AND GETDATE() >= TradeAgreementDTO.[start_date]
						AND (GETDATE() < TradeAgreementDTO.close_date OR TradeAgreementDTO.close_date IS NULL)
					FOR XML AUTO, ELEMENTS, TYPE, ROOT('AgreementsSummary'))
			FROM
				(
				SELECT
					trade_site.site_ref
					,trade_site.site_no
					,trade_site.ta_name
					,trade_site.site_name
					,trade_site.building
					,trade_site.addr_num
					,trade_site.addr_1
					,trade_site.addr_2
					,trade_site.addr_3
					,trade_site.addr_4
					,trade_site.addr_5
					,trade_site.addr_6
					,trade_site.addr_7
					,trade_site.postcode AS trade_postcode
					,trade_site.telephone
					,trade_site.contact_name
					,trade_site.contact_title
					,trade_site.contact_tel
					,trade_site.bus_category
					,(SELECT bus_categories.cate_desc FROM bus_categories WHERE bus_categories.bus_category = trade_site.bus_category) AS bus_category_desc
					,RTRIM(LTRIM(RTRIM(ISNULL([site].site_name_1, ''))) + ' ' + LTRIM(RTRIM(ISNULL([site].site_name_2, '')))) AS site_address
					,[site].site_c
					,ISNULL(CAST(SQRT( SQUARE(@easting - site_detail.easting) + SQUARE(@northing - site_detail.northing) ) AS DECIMAL (10,2)), 0) AS site_distance
					,(SELECT COUNT(*) FROM cs_comp_viewHistory WHERE cs_comp_viewHistory.site_ref = site_detail.site_ref) AS history
					,(SELECT COUNT(*) FROM agreement WHERE agreement.site_ref = trade_site.site_no AND GETDATE() >= agreement.[start_date] AND (GETDATE() < agreement.close_date OR agreement.close_date IS NULL)) AS agreements
					,(dbo.cs_site_getPropertySortkey(locn.location_name, site.build_no, site.build_name, site.build_sub_name, site.build_sub_no)) AS site_sortkey
					,[site].build_sub_no
					,[site].build_no
					,[site].build_sub_no_disp
					,[site].build_no_disp
					,[site].build_sub_name
					,[site].build_name
					,[site].townname
					,[site].postcode AS site_postcode
					,locn.location_name
					,locn.location_desc
					,trade_site.[start_date]
					,trade_site.close_date
					,trade_site.name_flag
					,name_flag_desc =
						CASE
							WHEN trade_site.name_flag = 'T' THEN 'Trade details'
							WHEN trade_site.name_flag = 'S' THEN 'Site details'
						END
					,trade_site.fax_num
					,trade_site.contact_fax
					,trade_site.debtor_ref
					,trade_site.account_ref
					,trade_site.pa_area
				FROM trade_site
				INNER JOIN [site]
				ON [site].site_ref = trade_site.site_ref
				INNER JOIN site_detail
				ON site_detail.site_ref = trade_site.site_ref
				LEFT OUTER JOIN locn
				ON [site].location_c = locn.location_c
				WHERE trade_site.status_ref = 'R'
					AND site_detail.easting BETWEEN @easting_min AND @easting_max
					AND site_detail.northing BETWEEN @northing_min AND @northing_max
					AND (SQRT( ( SQUARE(@easting - site_detail.easting) + SQUARE(@northing - site_detail.northing) ) ) <= @radius AND @easting IS NOT NULL AND @northing IS NOT NULL)
				) TradeBusinessDTO
			ORDER BY site_distance, site_sortkey
			FOR XML AUTO, ELEMENTS, TYPE, ROOT('ArrayOfTradeBusinessDTO')
			);

	END TRY
	BEGIN CATCH
		SET @errornumber = '20594';
		SET @errortext   = ERROR_MESSAGE();
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
