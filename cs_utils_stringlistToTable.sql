/*****************************************************************************
** dbo.cs_utils_stringlistToTable
** user defined function
**
** Description
** Convert a delimited string into a table of values
**
** Parameters
** @list  = delimited varchar string
** @delim = the delimiter cahracter(s)
**
** Returned
** Table with columns position and value
**
** Notes
**
** declare @test varchar(100);
** SET @test = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('PDAINI', 'INSPLIST_WO_STATUSES'))));
** select * from (select position, value from dbo.cs_utils_stringlistToTable(@test, ',')) AS T;
**
** History
** 24/04/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_utils_stringlistToTable', N'TF') IS NOT NULL
  DROP FUNCTION dbo.cs_utils_stringlistToTable;
GO
CREATE FUNCTION dbo.cs_utils_stringlistToTable
(
	@list AS varchar(8000),
	@delim AS varchar(10)
)
RETURNS @listTable table
	(
	position integer,
	value varchar(8000)
	)
AS
BEGIN

	DECLARE @myPos AS int;

	SET @myPos = 1;

	WHILE CHARINDEX(@delim, @list) > 0
	BEGIN
		INSERT INTO @listTable
			(
			position
			,value
			)
			VALUES
			(
			@myPos
			,LEFT(@list, CHARINDEX(@delim, @list) - 1)
			);

		SET @myPos = @myPos + 1;
		IF CHARINDEX(@delim, @list) = LEN(@list)
		BEGIN
			INSERT INTO @listTable
				(
				position
				,value
				)
				VALUES
				(
				@myPos
				,''
				);
		END
		SET @list = RIGHT(@list, LEN(@list) - CHARINDEX(@delim, @list));
	END

	IF LEN(@list) > 0
	BEGIN
		INSERT INTO @listTable
			(
			position
			,value
			)
			VALUES
			(
			@myPos
			,@list
			);
	END

	RETURN

END
GO 
