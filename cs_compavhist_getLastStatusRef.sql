/*****************************************************************************
** dbo.cs_compavhist_getLastStatusRef
** user defined function
**
** Description
** Abandoned Vehicles - get the last status ref for a given complaint_no
**
** Parameters
** @complaint_no = complaint number
**
** Returned
** @last_status_ref = last status ref, varchar(6)
**
** History
** 19/02/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_compavhist_getLastStatusRef', N'FN') IS NOT NULL
    DROP FUNCTION dbo.cs_compavhist_getLastStatusRef;
GO
CREATE FUNCTION dbo.cs_compavhist_getLastStatusRef
(
	@complaint_no integer
)
RETURNS varchar(6)
AS
BEGIN

	DECLARE @last_status_ref varchar(6);

	SELECT @last_status_ref = status_ref
		FROM comp_av_hist, comp_av
		WHERE comp_av.complaint_no = @complaint_no
			AND comp_av.complaint_no = comp_av_hist.complaint_no
			AND comp_av.last_seq = comp_av_hist.seq;

	RETURN (@last_status_ref);

END
GO 
