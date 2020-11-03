/*****************************************************************************
** dbo.cs_models_getModels
** stored procedure
**
** Description
** Return a list of vehicle models for a given make
**
** Parameters
** @make_ref = makes table key
**
** Returned
** Result set of vehicle model data
**
** History
** 12/02/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_models_getModels', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_models_getModels;
GO
CREATE PROCEDURE dbo.cs_models_getModels
	@make_ref integer
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10);

	SET @errornumber = '12600';
	IF @make_ref IS NULL
	BEGIN
		SET @errornumber = '12601';
		SET @errortext = 'make_ref is required';
		GOTO errorexit;
	END

	SELECT model_ref AS code,
		model_desc AS [description]
		FROM models
		WHERE make_ref = @make_ref
		ORDER BY model_desc;

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
