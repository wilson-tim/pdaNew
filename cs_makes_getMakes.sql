/*****************************************************************************
** dbo.cs_makes_getMakes
** stored procedure
**
** Description
** Return a list of vehicle makes
**
** Parameters
** none
**
** Returned
** Result set of vehicle make data
**
** History
** 12/02/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_makes_getMakes', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_makes_getMakes;
GO
CREATE PROCEDURE dbo.cs_makes_getMakes
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500);

	SELECT make_ref AS code,
		make_desc AS [description]
		FROM makes
		ORDER BY make_desc;

END
GO
