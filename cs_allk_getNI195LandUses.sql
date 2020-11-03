/*****************************************************************************
** dbo.cs_allk_getNI195LandUses
** stored procedure
**
** Description
** [NI195] Selects a list of NI195 land uses
**
** Parameters
** None
**
** Returned
** Result set of NI195 land use data
** Return value of @@ROWCOUNT
**
** History
** 09/05/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_allk_getNI195LandUses', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_allk_getNI195LandUses;
GO
CREATE PROCEDURE dbo.cs_allk_getNI195LandUses
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer;

	SELECT lookup_code AS code,
		lookup_text AS [description]
		FROM allk
		WHERE lookup_func = 'BVLAND'
			AND status_yn = 'Y'
		ORDER BY lookup_code;

	SET @rowcount = @@ROWCOUNT;

	RETURN @rowcount;

END
GO 
