/*****************************************************************************
** dbo.cs_sitemark_getContractValue
** stored procedure
**
** Description
** Wandsworth method for calculating contract value
**
** Parameters
** @site_ref     = site reference
** @contract_ref = contract reference
** @start_date   = start date
**
** Returned
** @value        = calculated value
** Return value of 0 (success) or -1 (failure, with exception text)
**
** History
** 05/02/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_sitemark_getContractValue', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_sitemark_getContractValue;
GO
CREATE PROCEDURE dbo.cs_sitemark_getContractValue
	@site_ref varchar(16),
	@contract_ref varchar(12),
	@start_date datetime,
	@value decimal(10,2) = 0 OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@an_val_def_alg char(1),
		@contract_value decimal(10,2),
		@year integer;

	SET @errornumber = '13100';
	SET @site_ref = LTRIM(RTRIM(@site_ref));
	SET @contract_ref = LTRIM(RTRIM(@contract_ref));

	IF @site_ref = '' OR @site_ref IS NULL
	BEGIN
		SET @errornumber = '13101';
		SET @errortext = 'site_ref is required';
	END

	IF @contract_ref = '' OR @contract_ref IS NULL
	BEGIN
		SET @errornumber = '13102';
		SET @errortext = 'contract_ref is required';
	END

	IF @start_date IS NULL
	BEGIN
		SET @start_date = GETDATE();
	END

	/*
	SET @an_val_def_alg = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'AN_VAL_DEF_ALG'))));
	IF @an_val_def_alg = 'Y'
	BEGIN
	*/
		IF DATEDIFF(day, @start_date, GETDATE()) = 0
		BEGIN
			SELECT @contract_value = site_value
				FROM site_mark
				WHERE site_ref = @site_ref
					AND contract_ref = @contract_ref
					AND lookup_code = 'CONVAL';
		END
		ELSE
		BEGIN
			SELECT TOP(1) @contract_value = site_value
				FROM site_mark_log
				WHERE site_ref = @site_ref
					AND contract_ref = @contract_ref
					AND lookup_code = 'CONVAL'
					AND log_date <= @start_date
				ORDER BY log_seq DESC;

			IF @@ROWCOUNT <> 1
			BEGIN
				SELECT @contract_value = site_value
					FROM site_mark
					WHERE site_ref = @site_ref
					AND contract_ref = @contract_ref
					AND lookup_code = 'CONVAL';
			END

		END

		SET @year = YEAR(@start_date);

		IF (@year % 4 = 0 AND @year % 100 = 0) OR (@year % 400 = 0)
		BEGIN
			/* Leap year */
			SET @value = @contract_value / 366;
		END
		ELSE
		BEGIN
			/* Other year */
			SET @value = @contract_value / 365;
		END
	/*
	END
	*/

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
