/*****************************************************************************
** dbo.cs_wostat_getDetails
** stored procedure
**
** Description
** Get wo_stat details for specified works order status code
**
** Parameters
** @wo_h_stat = works order status code
**
** Returned
** wo_stat details for specified works order status code
**
** History
** 22/03/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_wostat_getDetails', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_wostat_getDetails;
GO
CREATE PROCEDURE dbo.cs_wostat_getDetails
	@wo_h_stat varchar(3)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10);

	SET @errornumber = '20137';

	SET @wo_h_stat = LTRIM(RTRIM(@wo_h_stat));

	IF @wo_h_stat = '' OR @wo_h_stat IS NULL
	BEGIN
		SET @errornumber = '20138';
		SET @errortext   = 'wo_h_stat is required';
		GOTO errorexit;
	END

	SELECT wo_h_stat
		,wo_stat_desc
		,wo_next_stat
		,estimate
		,pending
		,issue
		,[clear]
		,cancel
		,authorise
		,assessment
		,prov_sched
		,conf_sched
		,close_comp
		,close_wo
		,remote_status
		,complete
		FROM wo_stat
		WHERE wo_h_stat = @wo_h_stat;

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
