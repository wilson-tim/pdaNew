/*****************************************************************************
** dbo.cs_pars_getScreenTitle
** stored procedure
**
** Description
** Selects the screen title from the pars table
**
** Parameters
** None
**
** Returned
** @title = screen title, varchar(40)
** @system_version = SQL Server version details, varchar(512)
** Return value of 1 (success), 0 or other value (failure)
**
** History
** 22/07/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_pars_getScreenTitle', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_pars_getScreenTitle;
GO
CREATE PROCEDURE dbo.cs_pars_getScreenTitle
	@title varchar(50) OUTPUT
	,@system_version varchar(512) OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE
		@rowcount integer
		;

	SET @title = NULL;
	SET @system_version = NULL;

	SELECT
		@title = cur_vala
		FROM pars
		WHERE par_name = 'company';

	SET @rowcount = @@ROWCOUNT;

	SELECT @system_version = @@VERSION;

	RETURN @rowcount;

END

GO
