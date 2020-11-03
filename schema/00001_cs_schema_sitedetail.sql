/*****************************************************************************
** dbo.cs_schema_sitedetail
** schema change script
**
** Description
** Adds indexes to site_detail table if not present
** (for stored procedure cs_site_getLocalProperties and cs_site_getLocalStreets)
**
** Parameters
**
** Returned
**
** History
** 10/12/2012  TW  New
** 19/07/2013  TW  Better performing index on easting, easting_end, northing, northing_end
**
*****************************************************************************/

IF EXISTS (SELECT name FROM sys.indexes WHERE name = 'idx_site_detail3' AND object_id = OBJECT_ID('dbo.site_detail'))
	DROP INDEX dbo.site_detail.idx_site_detail3;
GO

IF EXISTS (SELECT name FROM sys.indexes WHERE name = 'idx_site_detail4' AND object_id = OBJECT_ID('dbo.site_detail'))
	DROP INDEX dbo.site_detail.idx_site_detail4;
GO

IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = 'idx_easting_northing' AND object_id = OBJECT_ID('dbo.site_detail'))
BEGIN
	CREATE NONCLUSTERED INDEX [idx_easting_northing] ON [dbo].[site_detail]
	(
		[easting] ASC,
		[northing] ASC,
		[easting_end] ASC,
		[northing_end] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
END

GO
