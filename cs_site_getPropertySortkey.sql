/*****************************************************************************
** dbo.cs_site_getPropertySortkey
** user defined function
**
** Description
** Create sortkey for a given set of property details
**
** Parameters
** @location_name     = location (street) name
** @building_no       = building number
** @building_name     = building name
** @building_sub_name = building sub name
** @building_sub_no   = building sub number
**
** Returned
** @result = property sortkey, varchar(400)
**
** Notes
** Addresses are of the form:
**   organisation details
**   building sub number
**   building sub name
**   building name
**   building number
**   location name (street name)
**   etc.
**
** History
** 08/01/2013  TW  New
** 02/05/2013  TW  Revised
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_site_getPropertySortkey', N'FN') IS NOT NULL
    DROP FUNCTION dbo.cs_site_getPropertySortkey;
GO
CREATE FUNCTION dbo.cs_site_getPropertySortkey
(
	@plocation_name varchar(100),
	@pbuilding_no varchar(14),
	@pbuilding_name varchar(100),
	@pbuilding_sub_name varchar(100),
	@pbuilding_sub_no varchar(14)
)
RETURNS varchar(400)
AS
BEGIN

	DECLARE @result varchar(400)
		,@location_name varchar(100)
		,@building_no varchar(14)
		,@building_name varchar(100)
		,@building_sub_name varchar(100)
		,@building_sub_no varchar(14)
		,@building_no_letter1 varchar(14)
		,@building_no_letter2 varchar(14)
		,@building_no_number varchar(14)
		,@building_name_letter1 varchar(100)
		,@building_name_letter2 varchar(100)
		,@building_name_number varchar(100)
		,@building_sub_no_letter1 varchar(14)
		,@building_sub_no_letter2 varchar(14)
		,@building_sub_no_number varchar(14)
		,@building_sub_name_letter1 varchar(100)
		,@building_sub_name_letter2 varchar(100)
		,@building_sub_name_number varchar(100)
		,@temp varchar(300)
		,@split_building_no varchar(56)
		,@split_building_sub_no varchar(56);

	SET @location_name = LTRIM(RTRIM(@plocation_name));
	SET @building_no = LTRIM(RTRIM(@pbuilding_no));
	SET @building_name = LTRIM(RTRIM(@pbuilding_name));
	SET @building_sub_name = LTRIM(RTRIM(@pbuilding_sub_name));
	SET @building_sub_no = LTRIM(RTRIM(@pbuilding_sub_no));

	SET @result = '';
	SET @building_no_letter1 = '';
	SET @building_no_letter2 = '';
	SET @building_no_number = '';
	SET @building_name_letter1 = '';
	SET @building_name_letter2 = '';
	SET @building_name_number = '';
	SET @building_sub_no_letter1 = '';
	SET @building_sub_no_letter2 = '';
	SET @building_sub_no_number = '';
	SET @building_sub_name_letter1 = '';
	SET @building_sub_name_letter2 = '';
	SET @building_sub_name_number = '';
	SET @temp = '';

	IF @location_name = '' OR @location_name IS NULL
	BEGIN
		SET @result = '!';
	END
	ELSE
	BEGIN
		SET @result = @location_name + '!';
	END

	IF @building_no = '' OR @building_no IS NULL
	BEGIN
		SET @result = @result + '!';
	END
	ELSE
	BEGIN
		SET @split_building_no = dbo.cs_utils_splitBuildNo(@building_no);
		SET @building_no = dbo.cs_utils_getField(@split_building_no, '|', 1) + dbo.cs_utils_getField(@split_building_no, '|', 2);
		SET @temp = dbo.cs_utils_analysePropertyNumber(@building_no)
		SET @building_no_letter1 = dbo.cs_utils_getField(@temp, '!!', 1);
		SET @building_no_letter2 = dbo.cs_utils_getField(@temp, '!!', 2);
		SET @building_no_number = dbo.cs_utils_getField(@temp, '!!', 3);
		SET @result = @result + @building_no_letter1 + '!';
		SET @result = @result + @building_no_number + '!';
		SET @result = @result + @building_no_letter2 + '!';
	END

	IF @building_name = '' OR @building_name IS NULL
	BEGIN
		SET @result = @result + '!';
	END
	ELSE
	BEGIN
		SET @temp = dbo.cs_utils_analysePropertyNumber(@building_name)
		SET @building_name_letter1 = dbo.cs_utils_getField(@temp, '!!', 1);
		SET @building_name_letter2 = dbo.cs_utils_getField(@temp, '!!', 2);
		SET @building_name_number = dbo.cs_utils_getField(@temp, '!!', 3);
		SET @result = @result + @building_name_letter1 + '!';
		SET @result = @result + @building_name_number + '!';
		SET @result = @result + @building_name_letter2 + '!';
	END

	IF @building_sub_name = '' OR @building_sub_name IS NULL
	BEGIN
		SET @result = @result + '!';
	END
	ELSE
	BEGIN
		SET @temp = dbo.cs_utils_analysePropertyNumber(@building_sub_name)
		SET @building_sub_name_letter1 = dbo.cs_utils_getField(@temp, '!!', 1);
		SET @building_sub_name_letter2 = dbo.cs_utils_getField(@temp, '!!', 2);
		SET @building_sub_name_number = dbo.cs_utils_getField(@temp, '!!', 3);
		SET @result = @result + @building_sub_name_letter1 + '!';
		SET @result = @result + @building_sub_name_number + '!';
		SET @result = @result + @building_sub_name_letter2 + '!';
	END

	IF @building_sub_no = '' OR @building_sub_no IS NULL
	BEGIN
		SET @result = @result + '!';
	END
	ELSE
	BEGIN
		SET @split_building_sub_no = dbo.cs_utils_splitBuildNo(@building_sub_no);
		SET @building_sub_no = dbo.cs_utils_getField(@split_building_sub_no, '|', 1) + dbo.cs_utils_getField(@split_building_sub_no, '|', 2);
		SET @temp = dbo.cs_utils_analysePropertyNumber(@building_sub_no)
		SET @building_sub_no_letter1 = dbo.cs_utils_getField(@temp, '!!', 1);
		SET @building_sub_no_letter2 = dbo.cs_utils_getField(@temp, '!!', 2);
		SET @building_sub_no_number = dbo.cs_utils_getField(@temp, '!!', 3);
		SET @result = @result + @building_sub_no_letter1 + '!';
		SET @result = @result + @building_sub_no_number + '!';
		SET @result = @result + @building_sub_no_letter2 + '!';
	END

	RETURN (@result);

END
GO 
