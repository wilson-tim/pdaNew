/*****************************************************************************
** dbo.cs_compenf_getComplaintNoForSourceRef
** stored procedure
**
** Description
** Get comp_enf, complaint_no (if any) for a customer care record
**
** Parameters
** @source_ref = complaint_no of originating customer care record
**
** Returned
** @complaint_no = complaint_no of enforcement record
** @closed = complaint closed flag, 1=closed, 0=open
** Return value of 1 (success) or 0
**
** History
** 22/03/2013  TW  New
** 26/07/2013  TW  New output parameter closed
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_compenf_getComplaintNoForSourceRef', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_compenf_getComplaintNoForSourceRef;
GO
CREATE PROCEDURE dbo.cs_compenf_getComplaintNoForSourceRef
	@source_ref integer
	,@complaint_no integer = NULL OUTPUT
	,@closed bit OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10);

	SET @errornumber = '20159';

	IF @source_ref = 0 OR @source_ref IS NULL
	BEGIN
		SET @errornumber = '20160';
		SET @errortext   = 'source_ref is required';
		GOTO errorexit;
	END

	SELECT @complaint_no = comp_enf.complaint_no,
		@closed =
			CASE
				WHEN comp.date_closed IS NOT NULL THEN 1
				ELSE 0
			END
		FROM comp_enf
		INNER JOIN comp
		ON comp.complaint_no = comp_enf.complaint_no
		WHERE source_ref = @source_ref;

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
