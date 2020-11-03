/*****************************************************************************
** dbo.cs_contenderlicences_getAllLicences
** stored procedure
**
** Description
** Select all ContenderLicences records
**
** Parameters
** None
**
** Returned
** Result set of ContenderLicences data
** Return value of @@ROWCOUNT or -1
**
** History
** 10/05/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_contenderlicences_getAllLicences', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_contenderlicences_getAllLicences;
GO
CREATE PROCEDURE dbo.cs_contenderlicences_getAllLicences
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer;

	SELECT module,
		user_type,
		[description],
		[expiry_date],
		max_users,
		token,
		NULL AS licence
		FROM ContenderLicences;

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
