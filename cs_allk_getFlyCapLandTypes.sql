/*****************************************************************************
** dbo.cs_allk_getFlyCapLandTypes
** stored procedure
**
** Description
** [Fly Capture] Selects a list of land types
**
** Parameters
** None
**
** Returned
** Result set of land types data
** Return value of @@ROWCOUNT
**
** History
** 09/05/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_allk_getFlyCapLandTypes', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_allk_getFlyCapLandTypes;
GO
CREATE PROCEDURE dbo.cs_allk_getFlyCapLandTypes
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer;

	SELECT lookup_code AS code,
		lookup_text AS [description]
		FROM allk
		WHERE lookup_func = 'FCLAND'
			AND status_yn = 'Y'
		ORDER BY lookup_text;

	SET @rowcount = @@ROWCOUNT;

	RETURN @rowcount;

END
GO 
