/*****************************************************************************
** dbo.cs_enfact_validateFpcnRef
** stored procedure
**
** Description
** Validate a FPCN number
**
** Parameters
** @reference_format = the format mask
** @fpcn             = the FPCN number
**
** Returned
** Return value of 1 (if successful), or -1
**
** Notes
**
** History
** 19/03/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_enfact_validateFpcnRef', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_enfact_validateFpcnRef;
GO
CREATE PROCEDURE dbo.cs_enfact_validateFpcnRef
	@reference_format varchar(20),
	@fpcn varchar(20)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer,
		@match bit,
		@x int,
		@xlen int,
		@y int,
		@prefix varchar(20),
		@enf_check_digit_calc varchar(500),
		@startpos integer,
		@endpos integer,
		@checkdigit varchar(1);

	SET @errornumber = '20110';

	SET @match = 1;
	SET @x = 1;
	SET @prefix = '';
	SET @xlen = LEN(@reference_format);

	IF CHARINDEX('$$1', @reference_format, 1) > 0
	BEGIN
		WHILE SUBSTRING(@reference_format, @x, 1) <> '$' AND @x <= @xlen
		BEGIN
			SET @prefix = @prefix + SUBSTRING(@reference_format, @x, 1);
			IF SUBSTRING(@reference_format, @x, 1) <> '*'
				AND SUBSTRING(@reference_format, @x, 1) <> SUBSTRING(@fpcn, @x, 1)
			BEGIN
				SET @match = 0;
			END
			SET @x = @x + 1;
		END
		IF (@match = 0)
		BEGIN
			SET @errornumber = '20113';
			SET @errortext   = 'Prefix must be ' + @prefix;
			GOTO errorexit;
		END

		IF CHARINDEX('$$2', @reference_format, 1) > 0
		BEGIN
			SET @enf_check_digit_calc = LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'ENF_CHECK_DIGIT_CALC')));
			SET @startpos = CAST(dbo.cs_utils_getField(@enf_check_digit_calc, ',', 1) AS integer);
			SET @endpos   = CAST(dbo.cs_utils_getField(@enf_check_digit_calc, ',', 2) AS integer);

			IF LEN(@fpcn) < @endpos
			BEGIN
				SET @errornumber = '20114';
				SET @errortext   = 'Problem with check digit parameters';
				GOTO errorexit;
			END

			SET @y = @startpos;

			WHILE @y <= @endpos
			BEGIN
				IF PATINDEX('%[0-9]%', SUBSTRING(@fpcn, @y, 1)) = 0
				BEGIN
					SET @errornumber = '20115';
					SET @errortext   = 'Characters ' + LTRIM(RTRIM(STR(@startpos))) + ' to ' + LTRIM(RTRIM(STR(@endpos))) + ' must be numeric';
					GOTO errorexit;
				END

				SET @y = @y + 1;
			END

			SET @checkdigit = dbo.cs_enfact_generateFpcnCheckDigit(@fpcn);
			IF @checkdigit <> SUBSTRING(@fpcn, @endpos + 1, 1)
			BEGIN
				SET @errornumber = '20116';
				SET @errortext   = 'Check digit is incorrect';
				GOTO errorexit;
			END
		END
	END

normalexit:
	RETURN 1;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
