/*****************************************************************************
** dbo.cs_utils_wrapText
** stored procedure
**
** Description
** Wrap passed text to specified row length
**
** Parameters
** @inputtext       = string of text to be wrapped
** @maxcharsperline = maximum row length
** @includeblank    = include blank lines: 1 = include, 0 = exclude
**
** Returned
** Table containing rows of wrapped text
**
** History
** 11/03/2013  TW  New
** 21/03/2013  TW  Revised method
**
** Notes
**
	declare @inputtext varchar(MAX)

	SET @inputtext = 'testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123456789 @!@' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + 'hello world hello hello hello @!@' + CHAR(13) + CHAR(10) + 'testing testing 123 testing testing 1234 testing testing 1234 testing testing 1234 testing testing 1234 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123456789 '
	SET @inputtext = @inputtext + 'testingtesting123testingtesting123testingtesting123testingtesting123testingtesting123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123456789 @!@' + CHAR(13) + CHAR(10) + 'hello world hello hello hello @!@' + CHAR(13) + CHAR(10) + 'testing testing 123 testing testing 1234 testing testing 1234 testing testing 1234 testing testing 1234 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123 testing testing 123456789 '

	SET @inputtext = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
	SET @inputtext = @inputtext + ' supercalifragilisticexpialidocioussupercalifragilisticexpialidocioussupercalifragilisticexpialidoc. Lorem ipsum ' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + ' dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
	SET @inputtext = @inputtext + ' Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
	SET @inputtext = @inputtext + ' Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
	SET @inputtext = @inputtext + ' Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
	SET @inputtext = @inputtext + ' Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
	SET @inputtext = @inputtext + ' Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
	SET @inputtext = @inputtext + ' Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
	SET @inputtext = @inputtext + ' Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
	SET @inputtext = @inputtext + ' Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'

	select * from dbo.cs_utils_wrapText(@inputtext, 60, 0) order by linenum

*****************************************************************************/
IF OBJECT_ID(N'dbo.cs_utils_wrapText', N'TF') IS NOT NULL
    DROP FUNCTION dbo.cs_utils_wrapText
GO
CREATE FUNCTION dbo.cs_utils_wrapText
    (
     @inputtext         varchar(MAX)
    ,@maxcharsperline   int
	,@includeblank		int
    )
RETURNS @wordlist2 table (linenum int identity(1,1), linetext varchar(100))
AS
BEGIN
	DECLARE 
		 @doc       xml
		,@word		varchar(100)
		,@temptext	varchar(100)
		,@newword	varchar(100)
		,@spaceleft	int
		,@wordleft	varchar(100);

	DECLARE
		 @wordlist table
			(ID int identity(1,1), word varchar(100));

	SET @inputtext = REPLACE(@inputtext, '&',  '&amp;');
	SET @inputtext = REPLACE(@inputtext, '"',  '&quot;');
	SET @inputtext = REPLACE(@inputtext, '''', '&#39;');
	SET @inputtext = REPLACE(@inputtext, '<',  '&lt;');
	SET @inputtext = REPLACE(@inputtext, '>',  '&gt;');
	SET @inputtext = REPLACE(@inputtext, '£',  '&#163;');
	SET @inputtext = REPLACE(@inputtext, CHAR(13) + CHAR(10), '</v></x><x><v>|||</v></x><x><v>');
	SET @inputtext = '<x><v>' + REPLACE(@inputtext, ' ', '</v></x><x><v>') + '</v></x>';
	SET @doc = CONVERT(xml, @inputtext);

	/* Load wordlist table */
	insert into 
		@wordlist (word)
	select
		 v  = T.c.value('v[1]', 'varchar(100)')
	from
		@doc.nodes('x') T(c);

	SET @spaceleft = @maxcharsperline;
	SET @temptext  = '';

	DECLARE csr_wordlist CURSOR FOR
		SELECT word
			FROM @wordlist
			ORDER BY ID;

	OPEN csr_wordlist;

	FETCH NEXT FROM csr_wordlist
		INTO @word;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		/* Preserve user entered line break */
		IF @word = '|||'
		BEGIN
			INSERT INTO @wordlist2 (linetext) VALUES (LTRIM(@temptext));
			SET @temptext  = '';
			SET @spaceleft = @maxcharsperline;
			/* Get the next word */
			GOTO fetchnext
		END

		/* Process words which are longer than the specified line length */
		/* Fit them in by splitting where necessary                      */
		IF LEN(@word) > @maxcharsperline
		BEGIN
			SET @wordleft = @word;
			WHILE LEN(@wordleft) + 1 > @spaceleft
			BEGIN
				SET @word = LEFT(@wordleft, @spaceleft - 1);
				SET @temptext = @temptext + ' ' + @word;
				INSERT INTO @wordlist2 (linetext) VALUES (LTRIM(@temptext));
				SET @wordleft = STUFF(@wordleft, 1, LEN(@word), '');
				SET @temptext = '';
				SET @spaceleft = @maxcharsperline;
			END
			/* The remaining characters will be processed by the next condition */
			SET @word = @wordleft;
		END

		/* Processing for all other cases */
		IF (LEN(@word) + 1 > @spaceleft)
		BEGIN
			INSERT INTO @wordlist2 (linetext) VALUES (LTRIM(@temptext));
			SET @temptext  = @word;
			SET @spaceleft = @maxcharsperline - LEN(@word);
		END
		ELSE
		BEGIN
			SET @temptext  = @temptext + ' ' + @word;
			SET @spaceleft = @spaceleft - (LEN(@word) + 1)
		END

fetchnext:
		FETCH NEXT FROM csr_wordlist
			INTO @word;
	END

	CLOSE csr_wordlist;
	DEALLOCATE csr_wordlist;

	/* Save any remaining text */
	INSERT INTO @wordlist2 (linetext) VALUES (@temptext);

	RETURN

END
GO
