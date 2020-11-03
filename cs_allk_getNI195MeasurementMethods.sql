/*****************************************************************************
** dbo.cs_allk_getNI195MeasurementMethods
** stored procedure
**
** Description
** [NI195] Selects a list of NI195 measurement methods
**
** Parameters
** None
**
** Returned
** Result set of NI195 measurement methods data
** Return value of @@ROWCOUNT
**
** History
** 09/05/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_allk_getNI195MeasurementMethods', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_allk_getNI195MeasurementMethods;
GO
CREATE PROCEDURE dbo.cs_allk_getNI195MeasurementMethods
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer;

	SELECT lookup_code AS code,
		lookup_text AS [description]
		FROM allk
		WHERE lookup_func = 'BVMEAS'
			AND status_yn = 'Y'
		ORDER BY lookup_code;

	SET @rowcount = @@ROWCOUNT;

	RETURN @rowcount;

END
GO 
