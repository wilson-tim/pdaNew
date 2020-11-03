/*****************************************************************************
** dbo.cs_utils_getField
** user defined function
**
** Description
** Extracts the data from a delimited string for a given delimiter and 'field' number
**
** Parameters
** @rowdata = delimited string to be analysed
** @delim   = delimiter, up to 5 characters
** @fieldno = 'field' number to be extracted  
**
** Returned
** @result  = data from specified 'field', varchar(500)
**
** History
** 06/12/2012  TW  New
** 02/05/2013  TW  @rowdata - preserve any space characters, they might be delimiters
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_utils_getField', N'FN') IS NOT NULL
BEGIN
  DROP FUNCTION dbo.cs_utils_getField
END
GO
CREATE FUNCTION dbo.cs_utils_getField
(
	@rowdata varchar(500),
	@delim varchar(5),
	@fieldno integer
)  
RETURNS varchar(500)
AS  
BEGIN 
    DECLARE @ctr int,
	        @result varchar(500),
			@data varchar(500);

	/* Preserve any space characters, they might be delimiters
	SET @rowdata = LTRIM(RTRIM(@rowdata));
	*/
	SET @delim   = UPPER(LTRIM(RTRIM(@delim)));
	IF @delim = '\S'
	BEGIN
		SET @delim = ' ';
	END
	
    SET @ctr = 1;
    SET @result = '';

    WHILE (CHARINDEX(@delim, @rowdata)>0) AND @ctr <= @fieldno
    BEGIN
        SET @data = LTRIM(RTRIM(SUBSTRING(@rowdata, 1, CHARINDEX(@delim, @rowdata) - 1)));

        SET @rowdata = SUBSTRING(@rowdata, CHARINDEX(@delim, @rowdata) + LEN(@delim), LEN(@rowdata));
		IF @ctr = @fieldno
		BEGIN
			SET @result = @data;
		END
		SET @ctr = @ctr + 1;
    END
	
    SET @data = LTRIM(RTRIM(@rowdata));
	IF @ctr = @fieldno
	BEGIN
		SET @result = @data;
	END

	RETURN @result;
END

GO
