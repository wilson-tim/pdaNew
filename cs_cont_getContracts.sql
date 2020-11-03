/*****************************************************************************
** dbo.cs_cont_getContracts
** stored procedure
**
** Description
** Selects a set of cont records for a given service and optionally a given date,
**   defaults to current date
**
** Parameters
** @service_c = service code (NOT service type)
** @contdate  = date (optional)
**
** Returned
** Result set of contract data
** Return value of @@ROWCOUNT or -1
**
** History
** 02/01/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_cont_getContracts', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_cont_getContracts;
GO
CREATE PROCEDURE dbo.cs_cont_getContracts
	@service_c varchar(6),
	@contdate datetime = NULL
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @rowcount integer,
		@errortext varchar(500),
		@errornumber varchar(10);
		
	SET @errornumber = '11600';

	SET @service_c = LTRIM(RTRIM(@service_c));

	IF @service_c = '' OR @service_c IS NULL
	BEGIN
		SET @errornumber = '11601';
		SET @errortext = 'service_c is required';
		GOTO errorexit;
	END

	IF @contdate IS NULL
	BEGIN
		SET @contdate = GETDATE();
	END

	SELECT cont.contract_ref,
		cont.contractor_ref,
		cont.contract_name,
		cont.max_points,
		cont.period_points,
		cont.start_date,
		cont.finish_date,
		c_da.cont_cycle_no,
		c_da.period_func,
		c_da.period_no,
		c_da.period_desc,
		c_da.period_start,
		c_da.period_finish,
		c_da.duration
		FROM cont, c_da
		WHERE cont.service_c = @service_c
			AND cont.contract_ref = c_da.contract_ref
			AND c_da.period_start <= @contdate
			AND c_da.period_finish >= @contdate
		ORDER BY contract_name;

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
