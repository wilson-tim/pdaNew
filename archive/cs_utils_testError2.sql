/*****************************************************************************
** dbo.cs_utils_testError2
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
IF OBJECT_ID (N'dbo.cs_utils_testError2', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_utils_testError2;
GO
CREATE PROCEDURE dbo.cs_utils_testError2
AS
BEGIN

	SET NOCOUNT ON;

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
	IF @@ERROR <> 0
	BEGIN
		RAISERROR('Something really bad has happened', 16, 1);
		RETURN -1;
	END

END
GO 
