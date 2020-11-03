/*****************************************************************************
** dbo.cs_compdartdetail_getLookupCodeList
** user defined function
**
** Description
** Get '|' delimited list of lookup codes for a specified complaint_no and lookup_func
**
** Parameters
** @pcomplaint_no = complaint number
** @plookup_func  = lookup function
**
** Returned
** '|' delimited list of lookup codes for a specified complaint_no and lookup_func
**
** History
** 26/04/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_compdartdetail_getLookupCodeList', N'FN') IS NOT NULL
    DROP FUNCTION dbo.cs_compdartdetail_getLookupCodeList;
GO
CREATE FUNCTION dbo.cs_compdartdetail_getLookupCodeList
(
	@pcomplaint_no integer,
	@plookup_func varchar(6)
)
RETURNS varchar(500)
AS
BEGIN

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@complaint_no integer,
		@lookup_func varchar(6),
		@codecount integer,
		@loopvar integer,
		@lookup_code varchar(8),
		@lookup_code_list varchar(500);

	SET @complaint_no = @pcomplaint_no;
	SET @lookup_func  = LTRIM(RTRIM(@plookup_func));

	DECLARE csr_compdartdetail CURSOR FOR
		SELECT lookup_code
			FROM comp_dart_detail
			WHERE complaint_no = @complaint_no
				AND lookup_func = @lookup_func
			ORDER BY lookup_code;

	OPEN csr_compdartdetail;

	FETCH NEXT FROM csr_compdartdetail INTO
		@lookup_code
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @lookup_code <> '' AND @lookup_code IS NOT NULL
		BEGIN
			IF @lookup_code_list = '' OR @lookup_code_list IS NULL
			BEGIN
				SET @lookup_code_list = @lookup_code;
			END
			ELSE
			BEGIN
				SET @lookup_code_list = @lookup_code_list + '|' + @lookup_code;
			END
		END

		FETCH NEXT FROM csr_compdartdetail INTO
			@lookup_code
	END

	CLOSE csr_compdartdetail;
	DEALLOCATE csr_compdartdetail;

	RETURN @lookup_code_list;

END
GO 
