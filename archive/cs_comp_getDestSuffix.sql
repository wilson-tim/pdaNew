/*****************************************************************************
** dbo.cs_comp_getDestSuffix
** user defined function
**
** Description
** Get dest_suffix for a given complaint_no
**
** Parameters
** @complaint_no = complaint_no
**
** Returned
** @dest_suffix
**
** History
** 14/02/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_comp_getDestSuffix', N'FN') IS NOT NULL
    DROP FUNCTION dbo.cs_comp_getDestSuffix;
GO
CREATE FUNCTION dbo.cs_comp_getDestSuffix
(
	@complaint_no integer
)
RETURNS varchar(6)
AS
BEGIN

	DECLARE @result varchar(6);

	IF @complaint_no IS NULL
	BEGIN
		SET @result = NULL;
		GOTO functionexit;
	END

	SELECT @result = dest_suffix
		FROM comp
		WHERE complaint_no = @complaint_no;

functionexit:

	RETURN (@result);

END
GO 
