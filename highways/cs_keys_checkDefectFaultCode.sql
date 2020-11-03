/*****************************************************************************
** dbo.cs_keys_checkDefectFaultCode
** user defined function
**
** Description
** Is the passed fault code included in the list of defect (pothole) fault codes?
**
** Parameters
** @comp_code = fault code
**
** Returned
** integer
**
** History
** 03/10/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_keys_checkDefectFaultCode', N'FN') IS NOT NULL
    DROP FUNCTION dbo.cs_keys_checkDefectFaultCode;
GO
CREATE FUNCTION dbo.cs_keys_checkDefectFaultCode
(
	@comp_code varchar(6)
)
RETURNS integer
AS
BEGIN

	DECLARE @result integer,
		@code_list varchar(500),
		@errornumber varchar(10),
		@grade varchar(3),
		@category varchar(10),
		@keyscategory varchar(10),
		@grades varchar(500),
		@grade_desc varchar(10);

	SET @result = 0;

	IF @comp_code <> '' AND @comp_code IS NOT NULL
	BEGIN
		IF dbo.cs_modulelic_getInstalled('HWAY') = 1
			AND UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'MS_INSTALLATION')))) = 'Y'
		BEGIN
			SET @code_list = UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'MS_FAULT_CODES'))));

			IF CHARINDEX(',' + @comp_code + ',', ',' + @code_list + ',', 1) > 0
			BEGIN
				SET @result = 1;
			END
		END
	END

	RETURN(@result)

END
GO 
