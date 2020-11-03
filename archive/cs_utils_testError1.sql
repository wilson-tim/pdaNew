/*****************************************************************************
** dbo.cs_utils_testError1
** stored procedure
**
** Description
** <description>
**
** Parameters
** <parameters>
**
** Returned
** <returned>
**
** History
** 19/12/2012  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_utils_testError1', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_utils_testError1;
GO
CREATE PROCEDURE dbo.cs_utils_testError1
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @testvar varchar(100);

	SELECT *
		FROM keys
		WHERE keyname = 'TEST'
	IF @@ROWCOUNT > 0
	BEGIN
		DELETE FROM keys
			WHERE keyname = 'TEST'
	END
	INSERT INTO keys
		(
		service_c,
		keyname,
		keydesc,
		c_field
		)
		VALUES
		(
		'TEST',
		'TEST',
		'TEST',
		'TEST'
		);
	INSERT INTO keys
		(
		service_c,
		keyname,
		keydesc,
		c_field
		)
		VALUES
		(
		'TEST',
		'TEST',
		'TEST',
		'TEST'
		);
	RETURN -1

END
GO
