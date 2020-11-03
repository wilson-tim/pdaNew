/*****************************************************************************
** dbo.cs_whiteboarddtl_getDetails
** stored procedure
**
** Description
** Selects whiteboard information
**
** Parameters
** @display_date = date (defaults to current date)
**
** Returned
** @xmlWhiteboardDetails = XML result set of whiteboard information
**
** History
** 17/07/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_whiteboarddtl_getDetails', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_whiteboarddtl_getDetails;
GO
CREATE PROCEDURE dbo.cs_whiteboarddtl_getDetails
	@pdisplay_date datetime
	,@xmlWhiteboardDetails xml OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500)
		,@errornumber varchar(10)
		,@display_date datetime
		;

	SET @display_date = @pdisplay_date;

	IF @display_date IS NULL
	BEGIN
		SET @display_date = GETDATE();
	END

	SET @xmlWhiteboardDetails = 
		(
		SELECT
			whiteboard_ref
			,seq
			,calendar_date
			,calendar_weekday
			,calendar_day
			,calendar_month
			,calendar_year
			,username
			,DATEADD(minute, CAST(ISNULL(time_entered_m, 0) AS integer),
				DATEADD(hour,   CAST(ISNULL(time_entered_h, 0) AS integer),
				DATEADD(day,    DATEPART(day,   date_entered) - 1, 
				DATEADD(month,  DATEPART(month, date_entered) - 1, 
				DATEADD(year,   DATEPART(year,  date_entered) - 1900, 0))))) AS date_entered_datetime
			,DATEADD(minute, CAST(ISNULL(start_time_m, 0) AS integer),
				DATEADD(hour,   CAST(ISNULL(start_time_h, 0) AS integer),
				DATEADD(day,    DATEPART(day,   [start_date]) - 1, 
				DATEADD(month,  DATEPART(month, [start_date]) - 1, 
				DATEADD(year,   DATEPART(year,  [start_date]) - 1900, 0))))) AS start_datetime
			,DATEADD(minute, CAST(ISNULL(end_time_m, 0) AS integer),
				DATEADD(hour,   CAST(ISNULL(end_time_h, 0) AS integer),
				DATEADD(day,    DATEPART(day,   [end_date]) - 1, 
				DATEADD(month,  DATEPART(month, [end_date]) - 1, 
				DATEADD(year,   DATEPART(year,  [end_date]) - 1900, 0))))) AS end_datetime
			,site_ref
			,RTRIM(LTRIM(RTRIM(ISNULL(site_name_1, ''))) + ' ' + LTRIM(RTRIM(ISNULL(site_name_2, '')))) AS site_name_1
			,item_ref
			,item_desc
			,round_c
			,round_desc
			,service_c
			,service_desc
			,pa_area
			,pa_area_desc
			,status_flag
			,exclusion_yn
			,(SELECT
				whiteboard_ref
				,seq
				,username
				,DATEADD(minute, CAST(ISNULL(time_entered_m, 0) AS integer),
					DATEADD(hour,   CAST(ISNULL(time_entered_h, 0) AS integer),
					DATEADD(day,    DATEPART(day,   doa) - 1, 
					DATEADD(month,  DATEPART(month, doa) - 1, 
					DATEADD(year,   DATEPART(year,  doa) - 1900, 0))))) AS doa_datetime
				,txt
				FROM whiteboard_txt AS WhiteboardTxtDTO
				WHERE WhiteboardTxtDTO.whiteboard_ref = WhiteboardDtlDTO.whiteboard_ref
				ORDER BY WhiteboardTxtDTO.whiteboard_ref, WhiteboardTxtDTO.seq
				FOR XML AUTO, ELEMENTS, TYPE, ROOT('Texts'))
		FROM whiteboard_dtl AS WhiteboardDtlDTO
		WHERE [start_date] <= @display_date
			AND [end_date] >= @display_date
		ORDER BY start_date, start_time_h, start_time_m, seq
		FOR XML AUTO, ELEMENTS, TYPE, ROOT('ArrayOfWhiteboardDtlDTO')
		);

END

GO
