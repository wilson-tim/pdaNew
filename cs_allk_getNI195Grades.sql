/*****************************************************************************
** dbo.cs_allk_getNI195Grades
** stored procedure
**
** Description
** [NI195] Selects a list of NI195 grades
**
** Parameters
** @pcategory = category ('LITTER', 'DETRITUS', 'GRAFFITI', 'FLYPOSTING')
**
** Returned
** Result set of NI195 grades data
** Return value of @@ROWCOUNT
**
** History
** 09/05/2013  TW  New
** 14/05/2013  TW  Additional column rectificationRequired
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_allk_getNI195Grades', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_allk_getNI195Grades;
GO
CREATE PROCEDURE dbo.cs_allk_getNI195Grades
	@pcategory varchar(10)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer,
		@category varchar(10),
		@keyscategory varchar(10),
		@rectificationOn bit;

	SET @errornumber = '20456';

	SET @category = LTRIM(RTRIM(@pcategory));

	IF @category = '' OR @category IS NULL
	BEGIN
		SET @errornumber = '20457';
		SET @errortext = 'category is required';
		GOTO errorexit;
	END

	SET @keyscategory =
		CASE
			WHEN @category = 'LITTER' THEN 'LITTER'
			WHEN @category = 'DETRITUS' THEN 'DETRIT'
			WHEN @category = 'GRAFFITI' THEN 'GRAFF'
			WHEN @category = 'FLYPOSTING' THEN 'FLYPOS'
			ELSE NULL
		END;

	IF @keyscategory = '' OR @keyscategory IS NULL
	BEGIN
		SET @errornumber = '20458';
		SET @errortext = 'category ''' + @category + ''' is not valid';
		GOTO errorexit;
	END

	SET @rectificationOn = 
		CASE
			WHEN UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('PDAINI', 'NI195_RECTIFICATION')))) = 'Y' THEN 1
			ELSE 0
		END;

	SELECT lookup_code AS code,
		lookup_text AS [description],
		rectificationRequired = 
			CASE
				WHEN (lookup_text <> ''
					AND lookup_text IS NOT NULL
					AND CHARINDEX(',' + lookup_text + ',', ',' + LTRIM(RTRIM(dbo.cs_keys_getCField(NULL, 'BV199_' + @keyscategory + '_DEF'))) + ',') > 0
					AND @rectificationOn = 1)
					THEN 1
				ELSE 0
			END
		FROM allk
		WHERE lookup_func = 'BVGRAD'
			AND status_yn = 'Y'
		ORDER BY lookup_code;

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
