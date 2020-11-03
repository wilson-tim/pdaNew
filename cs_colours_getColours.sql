/*****************************************************************************
** dbo.cs_colours_getColours
** stored procedure
**
** Description
** Return a list of vehicle colours
**
** Parameters
** none
**
** Returned
** Result set of vehicle colour data
**
** History
** 12/02/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_colours_getColours', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_colours_getColours;
GO
CREATE PROCEDURE dbo.cs_colours_getColours
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500);

	SELECT colour_ref AS code,
		colour_desc AS [description]
		FROM colour
		ORDER BY colour_desc;

END
GO 
