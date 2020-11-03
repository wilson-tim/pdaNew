/*****************************************************************************
** dbo.cs_whiteboarddtl_checkExclusionDay
** stored procedure
**
** Description
** Checks whether the passed date is excluded from the rectification date calculation
**
** Parameters
** @calendar_date = date to check (datestamp with time 00:00:00.000)
** @is_exclusion_day = output parameter for return value
**
** Returned
** @is_exclusion_day = 'Y' or 'N'
** Return value of 0 or -1
**
** Notes
** Logic extracted from the current PDA application
**   DefaultAlgBean.java, is_exclusion_day method
**
** History
** 22/01/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_whiteboarddtl_checkExclusionDay', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_whiteboarddtl_checkExclusionDay;
GO
CREATE PROCEDURE dbo.cs_whiteboarddtl_checkExclusionDay
	@calendar_date datetime,
	@is_exclusion_day char(1) OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(100),
		@rowcount integer;

	IF @calendar_date IS NULL
	BEGIN
		SET @errortext = 'calendar_date is required';
		GOTO errorexit;
	END

	SELECT @rowcount = COUNT(DISTINCT exclusion_yn)
		FROM whiteboard_dtl
		WHERE calendar_date = @calendar_date
			AND exclusion_yn = 'Y';

	IF @rowcount > 0
	BEGIN
		SET @is_exclusion_day = 'Y';
	END
	ELSE
	BEGIN
		SET @is_exclusion_day = 'N';
	END

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
