/*****************************************************************************
** dbo.cs_allk_getDefectPriorities
** stored procedure
**
** Description
** [Highways] Selects a list of defect priorities
**
** Parameters
** None
**
** Returned
** Result set of defect priorities
** Return value of @@ROWCOUNT
**
** History
** 03/10/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_allk_getDefectPriorities', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_allk_getDefectPriorities;
GO
CREATE PROCEDURE dbo.cs_allk_getDefectPriorities
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @rowcount integer;

	SELECT lookup_code AS code,
		lookup_text AS [description]
		FROM allk
		WHERE lookup_func = 'URGENT'
			AND status_yn = 'Y'
		ORDER BY lookup_text;

	SET @rowcount = @@ROWCOUNT;

	RETURN @rowcount;

END
GO 
