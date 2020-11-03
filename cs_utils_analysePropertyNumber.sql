/*****************************************************************************
** dbo.cs_utils_analysePropertyNumber
** user defined function
**
** Description
** Analyse passed property number data into alpha and numeric elements
**   called by cs_site_getPropertySortkey
**
** Parameters
** @propertynum = property number data value
**
** Returned
** @letter  = alpha part
** @letter2 = residual letter
** @number  = numeric part
**
** Notes
** Using PATINDEX('%[0-9]%'... and not ISNUMERIC
**   because ISNUMERIC picks up more than just characters 0-9
**
** History
** 08/01/2013  TW  New
** 02/05/2013  TW  Revised
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_utils_analysePropertyNumber', N'FN') IS NOT NULL
    DROP FUNCTION dbo.cs_utils_analysePropertyNumber;
GO
CREATE FUNCTION dbo.cs_utils_analysePropertyNumber
(
	@ppropertynum varchar(100)
)
RETURNS varchar(300)
AS
BEGIN

	DECLARE @propertynum varchar(100),
		@length integer,
		@i1 integer,
		@i2 integer,
		@i3 integer,
		@letter varchar(100),
		@letter2 varchar(100),
		@number varchar(100),
		@result varchar(300),
		@templetter varchar(100);

	SET @result  = '';
	SET @letter  = '';
	SET @letter2 = '';
	SET @number  = '';

	SET @propertynum = UPPER(LTRIM(RTRIM(@ppropertynum)));

	SET @length = LEN(@propertynum);

	/* Find start position of numeric content */
	SET @i1 = 1;
	WHILE @i1 <= @length
	BEGIN
		IF PATINDEX('%[0-9]%', SUBSTRING(@propertynum, @i1, 1)) > 0
		BEGIN
			BREAK;			
		END
		SET @i1 = @i1 + 1;
	END

	/* Find length of numeric content */
	SET @i2 = 0;
	WHILE @i2 <= @length AND PATINDEX('%[0-9]%', SUBSTRING(@propertynum, (@i1 + @i2), 1)) > 0
	BEGIN
		SET @i2 = @i2 + 1;
	END

	/* Find length of trailing alpha content following the numeric content */
	SET @i3 = @length - (@i1 + @i2) + 1;

	/* Remove punctuation (other than spaces) from trailing alpha content */
	/* e.g. 17A, ABCDEFG... */
	SET @templetter = SUBSTRING(@propertynum, (@length - @i3 + 1) , @i3);
	WHILE PATINDEX('%[^A-Z0-9 ]%', @templetter) > 0
	BEGIN
		SET @templetter = STUFF(@templetter, PATINDEX('%[^A-Z0-9 ]%', @templetter), 1, '');
	END
	/* No! Trailing alpha content might start with a space character
	   which is important in the check for a residual letter below
	SET @templetter = LTRIM(RTRIM(@templetter));
	*/

	SET @number = SUBSTRING(@propertynum, @i1, @i2);

	/* Check for residual letter(s), e.g. 17A */
	IF @number <> '' AND LEN(dbo.cs_utils_getField(@templetter, '\S', 1)) > 0
	BEGIN
		SET @letter2 = dbo.cs_utils_getField(@templetter, '\S', 1);
	END

	/* Format @number if required */
	IF LEN(@number) > 0 AND ISNUMERIC(@number) = 1
	BEGIN
		SET @number = STUFF(@number, 1, 0, REPLICATE('0', 4 - LEN(@number)));
	END

	/* Distinguish between data starting with numeric information, e.g. 17A, SQL TOWERS */
	/* and data which includes numeric information, e.g. FLAT 3A                        */
	IF @i1 = 1
	BEGIN
		SET @letter = '';
	END
	ELSE
	BEGIN
		SET @letter = LTRIM(RTRIM(SUBSTRING(@propertynum, 1, @i1 - 1)));
	END

	SET @result = @letter + '!!' + @letter2 + '!!' + @number;
	RETURN(@result);

END
GO 
