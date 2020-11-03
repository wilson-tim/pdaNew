/*****************************************************************************
** dbo.cs_nationalholidays_getDescription
** stored procedure
**
** Description
** Selects national holiday description
**
** Parameters
** @display_date = date (defaults to current date)
**
** Returned
** Result set of national holiday description(s)  [varchar(40)]
** Return value of rowcount
**
** History
** 22/07/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_nationalholidays_getDescription', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_nationalholidays_getDescription;
GO
CREATE PROCEDURE dbo.cs_nationalholidays_getDescription
	@pdisplay_date datetime
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE
		@rowcount integer
		,@display_date datetime
		;

	SET @display_date = @pdisplay_date;
	
	IF @display_date IS NULL
	BEGIN
		SET @display_date = GETDATE();
	END

	SELECT
		[description]
		FROM national_holidays
		WHERE holiday_date >= DATEADD(day, DATEDIFF(day, 0, @display_date), 0)
			AND holiday_date < DATEADD(day, DATEDIFF(day, 0, @display_date) + 1, 0);

	SET @rowcount = @@ROWCOUNT;

	RETURN @rowcount;

END

GO
