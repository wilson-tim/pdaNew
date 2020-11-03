/*****************************************************************************
** dbo.cs_flyloads_getFlyCapLoadSize
** stored procedure
**
** Description
** [Fly Capture] Selects a list of load sizes
**
** Parameters
** None
**
** Returned
** Result set of load size data
** Return value of @@ROWCOUNT
**
** History
** 09/05/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_flyloads_getFlyCapLoadSize', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_flyloads_getFlyCapLoadSize;
GO
CREATE PROCEDURE dbo.cs_flyloads_getFlyCapLoadSize
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer;

	SELECT load_ref AS code,
		load_desc AS [description],
		unit_cost,
		default_qty,
		sequence
		FROM fly_loads
		ORDER BY sequence;

	SET @rowcount = @@ROWCOUNT;

	RETURN @rowcount;

END
GO 
