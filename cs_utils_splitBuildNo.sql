/*****************************************************************************
** dbo.cs_utils_splitBuildNo
** user defined function
**
** Description
** Split build_no / build_sub_no into constituent parts
**
** Parameters
** @build_no = build_no or build_sub_no data in NLPG format
**             (NNNNXnnnnx or NNNNXXnnnnxx)
**
** Returned
** Pipe '|' delimited string of build_no / build_sub_no parts
**
** History
** 02/05/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_utils_splitBuildNo', N'FN') IS NOT NULL
    DROP FUNCTION dbo.cs_utils_splitBuildNo;
GO
CREATE FUNCTION dbo.cs_utils_splitBuildNo
(
	@pbuild_no varchar(14)
)
RETURNS varchar(56)
AS
BEGIN

	DECLARE @result varchar(56)
		,@build_no varchar(14)
		,@build_no_length integer
		,@mode integer
		,@blank integer
		,@loopvar integer
		,@char char(1)
		,@part1 varchar(14)
		,@part2 varchar(14)
		,@part3 varchar(14)
		,@part4 varchar(14);

	SET @build_no = @pbuild_no;

	SET @build_no_length = LEN(@build_no);

	SET @mode = 1;

	SET @blank = 0;

	SET @part1 = '';
	SET @part2 = '';
	SET @part3 = '';
	SET @part4 = '';

	SET @loopvar = 1;

	WHILE @loopvar <= @build_no_length
	BEGIN
		SET @char = SUBSTRING(@build_no, @loopvar, 1);
		IF PATINDEX('%[0-9]%', @char) > 0
		BEGIN
			SET @blank = 0;
			IF @mode = 1
			BEGIN
				SET @part1 = @part1 + @char;
				GOTO loopagain;
			END
			IF @mode = 2
			BEGIN
				SET @mode = 3;
				SET @part3 = @part3 + @char;
				GOTO loopagain;
			END
			IF @mode = 3
			BEGIN
				SET @part3 = @part3 + @char;
				GOTO loopagain;
			END
			IF @mode = 4
			BEGIN
				GOTO loopagain;
			END
		END
		IF PATINDEX('%[A-Za-z]%', @char) > 0
		BEGIN
			SET @blank = 0;
			IF @mode = 1
			BEGIN
				SET @mode = 2
				SET @part2 = @part2 + @char;
				GOTO loopagain
			END
			IF @mode = 2
			BEGIN
				SET @part2 = @part2 + @char;
				GOTO loopagain;
			END
			IF @mode = 3
			BEGIN
				SET @mode = 4;
				SET @part4 = @part4 + @char;
				GOTO loopagain;
			END
			IF @mode = 4
			BEGIN
				SET @part4 = @part4 + @char;
				GOTO loopagain;
			END
		END
		/* Otherwise */
		IF @blank = 0
		BEGIN
			SET @blank = 1;
			IF @mode = 1
			BEGIN
				SET @mode = 2;
				GOTO loopagain;
			END
			IF @mode = 2
			BEGIN
				SET @mode = 3;
				GOTO loopagain;
			END
			IF @mode = 3
			BEGIN
				SET @mode = 4;
				GOTO loopagain;
			END
			IF @mode = 4
			BEGIN
				GOTO loopagain;
			END
		END

	loopagain:

		SET @loopvar = @loopvar + 1;

	END

	SET @result = @part1 + '|' + @part2 + '|' + @part3 + '|' + @part4;

	RETURN (@result);

END
GO 
