/*****************************************************************************
** dbo.cs_utils_testXmlParam
** stored procedure
**
** Description
** Test passing of XML document from C# SqlXml datatype to MSSQL xml datatype
**
** Parameters
** @xmldoc = XML document (C# SqlXml datatype)
**
** Returned
** Result set of data extracted from the XML document
**
** History
** 10/01/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_utils_testXmlParam', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_utils_testXmlParam;
GO
CREATE PROCEDURE dbo.cs_utils_testXmlParam
	@xmldoc xml OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500);

	/* For testing purposes */
	/*
	DECLARE @xdoc xml,
		@errortext varchar(500);

	SET @xdoc =
		'<ArrayOfWorkOrderCoreIDTO>
		  <WorkOrderCoreIDTO>
			<SiteRef>67890</SiteRef>
			<Volume>2.55</Volume>
		  </WorkOrderCoreIDTO>
		  <WorkOrderCoreIDTO>
			<SiteRef>67890</SiteRef>
			<Volume>1.99</Volume>
		  </WorkOrderCoreIDTO>
		</ArrayOfWorkOrderCoreIDTO>';

		IF OBJECT_ID('tempdb..#tempWoh') IS NOT NULL
		BEGIN
			DROP TABLE  #tempWoh
		END

		SELECT T.N.value('SiteRef[1]', 'varchar(16)') AS SiteRef,
			T.N.value('Volume[1]', 'decimal(11,3)') AS Volume
			INTO #tempWoh
			FROM @xdoc.nodes('/ArrayOfWorkOrderCoreIDTO/WorkOrderCoreIDTO') AS T(N);

		SELECT * FROM #tempWoh

		UPDATE #tempWoh
			SET SiteRef = 'timwozere' + SiteRef
			WHERE SiteRef = '67890'
				AND Volume = 1.99

		SELECT * FROM #tempWoh

--		SET @xdoc = (SELECT * FROM #tempWoh FOR XML PATH('WorkOrderCoreIDTO'), ROOT('ArrayOfWorkOrderCoreIDTO'))
		SET @xdoc = (SELECT * FROM #tempWoh FOR XML PATH('WorkOrderCoreIDTO'))

		PRINT CAST(@xdoc AS nvarchar(MAX))
	*/

	IF OBJECT_ID('tempdb..#tempWoh') IS NOT NULL
	BEGIN
		DROP TABLE  #tempWoh
	END

	BEGIN TRY
		SELECT T.N.value('SiteRef[1]', 'varchar(16)') AS SiteRef,
			T.N.value('Volume[1]', 'decimal(11,3)') AS Volume
			INTO #tempWoh
			FROM @xmldoc.nodes('/ArrayOfWorkOrderCoreIDTO/WorkOrderCoreIDTO') AS T(N);

		UPDATE #tempWoh
			SET SiteRef = 'timwozere' + SiteRef
			WHERE SiteRef = '67890'
				AND Volume = 1.99

		SET @xmldoc = (SELECT * FROM #tempWoh FOR XML PATH('WorkOrderCoreIDTO'), ROOT('ArrayOfWorkOrderCoreIDTO'))

	END TRY
	BEGIN CATCH
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
