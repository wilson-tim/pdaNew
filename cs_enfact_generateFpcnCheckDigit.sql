/*****************************************************************************
** dbo.cs_enfact_generateFpcnCheckDigit
** user defined function
**
** Description
** Generate the check digit character for the specified FPCN number
**
** Parameters
** @fpcn = the FPCN number
**
** Returned
** FPCN check digit character for the specified FPCN number
**
** History
** 19/03/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_enfact_generateFpcnCheckDigit', N'FN') IS NOT NULL
    DROP FUNCTION dbo.cs_enfact_generateFpcnCheckDigit;
GO
CREATE FUNCTION dbo.cs_enfact_generateFpcnCheckDigit
(
	@fpcn varchar(20)
)
RETURNS varchar(1)
AS
BEGIN

	DECLARE @result varchar(1),
		@enf_check_digit_calc varchar(500),
		@startpos smallint,
		@endpos smallint,
		@fpcn_char varchar(20),
		@digit1 smallint,
		@digit2 smallint,
		@digit3 smallint,
		@digit4 smallint,
		@digit5 smallint,
		@digit6 smallint,
		@digit7 smallint,
		@checksum integer,
		@mod smallint;

	SET @enf_check_digit_calc = LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'ENF_CHECK_DIGIT_CALC')));
	SET @startpos = CAST(dbo.cs_utils_getField(@enf_check_digit_calc, ',', 1) AS smallint);
	SET @endpos   = CAST(dbo.cs_utils_getField(@enf_check_digit_calc, ',', 2) AS smallint);

	SET @fpcn_char = SUBSTRING(@fpcn, @startpos, @endpos - @startpos + 1);

	SET @digit1 = CAST(SUBSTRING(@fpcn_char, 1, 1) AS smallint);
	SET @digit2 = CAST(SUBSTRING(@fpcn_char, 2, 1) AS smallint);
	SET @digit3 = CAST(SUBSTRING(@fpcn_char, 3, 1) AS smallint);
	SET @digit4 = CAST(SUBSTRING(@fpcn_char, 4, 1) AS smallint);
	SET @digit5 = CAST(SUBSTRING(@fpcn_char, 5, 1) AS smallint);
	SET @digit6 = CAST(SUBSTRING(@fpcn_char, 6, 1) AS smallint);
	SET @digit7 = CAST(SUBSTRING(@fpcn_char, 7, 1) AS smallint);

	SET @checksum = @digit1 + (@digit2 * 6) + (@digit3 * 7) + (@digit4 * 3) + (@digit5 * 5) + (@digit6 * 4) + (@digit7 * 2);

	SET @mod = @checksum % 11;
	SET @mod = 11 - @mod;
	IF @mod < 10
	BEGIN
		SET @result = LTRIM(RTRIM(STR(@mod)));
	END
	ELSE
	BEGIN
		IF @mod = 10
		BEGIN
			SET @result = 'X';
		END
		ELSE
		BEGIN
			SET @result = '0';
		END
	END

	RETURN (@result);

END
GO 
