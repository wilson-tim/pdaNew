/*****************************************************************************
** dbo.cs_pdauser_getEnfOfficerPoCode
** user defined function
**
** Description
** Get enforcement officer po_code for current user
**
** Parameters
** @user_name = login id
**
** Returned
** Enforcement officer po_code for current user
**
** History
** 21/03/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_pdauser_getEnfOfficerPoCode', N'FN') IS NOT NULL
    DROP FUNCTION dbo.cs_pdauser_getEnfOfficerPoCode;
GO
CREATE FUNCTION dbo.cs_pdauser_getEnfOfficerPoCode
(
	@user_name varchar(15)
)
RETURNS varchar(6)
AS
BEGIN

	DECLARE @result varchar(6);

	SELECT TOP (1) @result = po_code
		FROM pda_user
        WHERE po_code IN
			(
			SELECT lookup_code
				FROM allk
				WHERE lookup_func = 'ENFOFF'
					AND status_yn = 'Y'
			)
			AND po_code IN
			(
			SELECT po_code
				FROM pda_user
				WHERE [user_name] = @user_name
			)
		ORDER BY full_name;

	RETURN (@result);

END
GO 
