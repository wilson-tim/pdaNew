/*****************************************************************************
** dbo.cs_utils_splitText
** stored procedure
**
** Description
** Split passed text into specified row length
**
** Parameters
** @inputtext       = string of text to be split
** @maxcharsperline = row length
** @includeblank    = include blank lines: 1 = include, 0 = exclude
**
** Returned
** Table containing rows of split text
**
** History
** 11/03/2013  TW  New
**
** Notes
**
	declare @text varchar(MAX)

	SET @text = 'testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123456789 @!@' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + 'hello world hello hello hello @!@' + CHAR(13) + CHAR(10) + 'testing testing 123 testing testing 1234 testing testing 1234 testing testing 1234 testing testing 1234 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123456789 '
	SET @text = @text + 'testingtesting123testingtesting123testingtesting123testingtesting123testingtesting123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123456789 @!@' + CHAR(13) + CHAR(10) + 'hello world hello hello hello @!@' + CHAR(13) + CHAR(10) + 'testing testing 123 testing testing 1234 testing testing 1234 testing testing 1234 testing testing 1234 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123456789 '

--	SET @text = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'

	select * from dbo.cs_utils_splitText(@text, 60, 0)
--	select * from dbo.cs_utils_splitText(@text, 60, 1)

*****************************************************************************/
IF OBJECT_ID(N'dbo.cs_utils_splitText', N'TF') IS NOT NULL
    DROP FUNCTION dbo.cs_utils_splitText
GO
CREATE FUNCTION dbo.cs_utils_splitText
    (
     @inputtext         varchar(MAX)
    ,@maxcharsperline   int
	,@includeblank		bit
    )
RETURNS @texttable table (linenum int, linetext varchar(1000))
AS
BEGIN
	DECLARE 
		@temptext	varchar(MAX)
		,@textrow   varchar(100)
		,@textlen   int
		,@dellen	int;

	DECLARE @rowlist table (ID int identity(1,1), phrase varchar(1000));

	SET @temptext = @inputtext;

	/* Split text into @maxcharsperline character rows */
	/* LEN() excludes trailing spaces, DATALENGTH() does not */
	WHILE DATALENGTH(@temptext) > @maxcharsperline
	BEGIN
		SET @textrow = SUBSTRING(@temptext, 1, @maxcharsperline);
		IF CHARINDEX(CHAR(13) + CHAR(10), @textrow, 1) > 0
		BEGIN
			SET @textlen = CHARINDEX(CHAR(13) + CHAR(10), @textrow, 1) - 1;
			SET @dellen  = @textlen + 2;
		END
		ELSE
		BEGIN
			SET @textlen = @maxcharsperline;
			SET @dellen  = @textlen;
		END
		SET @textrow = SUBSTRING(@textrow, 1, @textlen);
		INSERT INTO @rowlist (phrase) VALUES (@textrow);
		SET @temptext = STUFF(@temptext, 1, @dellen, '');
	END

	/* Save any remaining text */
	IF DATALENGTH(@temptext) > 0
	BEGIN
		INSERT INTO @rowlist (phrase) VALUES (@temptext);
	END

	/* Output results */
	INSERT INTO @texttable
	SELECT
		 linenum     = ROW_NUMBER() OVER (ORDER BY this.ID)
		,linetext    = LTRIM(this.phrase)
	FROM
		@rowlist this
	WHERE
		/* Check for blank rows */
		(@includeblank = 1 OR (@includeblank = 0 AND (this.phrase <> '' AND this.phrase IS NOT NULL)));

	RETURN
END
GO
