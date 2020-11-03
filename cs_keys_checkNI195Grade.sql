/*****************************************************************************
** dbo.cs_keys_checkNI195Grade
** stored procedure
**
** Description
** [NI195] Check grade to determine whether a rectification is required
**
** Parameters
** @pcategory = category ('LITTER', 'DETRITUS', 'GRAFFITI', 'FLYPOSTING')
** @pgrade    = grade code
**
** Returned
** @rectification = Boolean true (rectification required), or false (photos / notes input only)
**
** History
** 13/05/2013  TW  New
** 14/05/2013  TW  NI195 rectification on-off switch
** 17/05/2013  TW  @pgrade should be passing the grade code
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_keys_checkNI195Grade', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_keys_checkNI195Grade;
GO
CREATE PROCEDURE dbo.cs_keys_checkNI195Grade
	@pcategory varchar(10),
	@pgrade varchar(3),
	@rectification bit = 0 OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@grade varchar(3),
		@category varchar(10),
		@keyscategory varchar(10),
		@grades varchar(500),
		@grade_desc varchar(10);

	SET @errornumber = '20433';

	/* NI195 rectification on-off switch */
	IF UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('PDAINI', 'NI195_RECTIFICATION')))) <> 'Y'
	BEGIN
		SET @rectification = 0;
		GOTO normalexit;
	END

	SET @grade = LTRIM(RTRIM(@pgrade));
	SET @category = LTRIM(RTRIM(@pcategory));

	/* @category validation */
	IF @category = '' OR @category IS NULL
	BEGIN
		SET @errornumber = '20434';
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
		SET @errornumber = '20435';
		SET @errortext = 'category ''' + @category + ''' is not valid';
		GOTO errorexit;
	END

	/* @grade validation */
	IF @grade = '' OR @grade IS NULL
	BEGIN
		SET @errornumber = '20436';
		SET @errortext = 'grade is required';
		GOTO errorexit;
	END

	/* Convert @grade to a grade letter */
	SELECT @grade_desc = LTRIM(RTRIM(lookup_text))
		FROM allk
		WHERE lookup_func = 'BVGRAD'
			AND lookup_code = @grade
			AND status_yn = 'Y';

	/* Get the rectification grade letters for the specified category */
	SET @grades = LTRIM(RTRIM(dbo.cs_keys_getCField(NULL, 'BV199_' + @keyscategory + '_DEF')));

	IF @grades = '' OR @grades IS NULL
	BEGIN
		SET @errornumber = '20437';
		SET @errortext = 'rectification grades are not defined in system key BV199_' + @keyscategory + '_DEF';
		GOTO errorexit;
	END

	/* Compare */
	IF CHARINDEX(',' + @grade_desc + ',', ',' + @grades + ',') > 0
	BEGIN
		SET @rectification = 1;
	END
	ELSE
	BEGIN
		SET @rectification = 0;
	END

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
