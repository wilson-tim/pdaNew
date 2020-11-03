/*****************************************************************************
** dbo.cs_compdartdetail_getLookupCodeDescList
** user defined function
**
** Description
** Get '|' delimited list of lookup code descriptions for a specified complaint_no and lookup_func
**
** Parameters
** @pcomplaint_no = complaint number
** @plookup_func  = lookup function
**
** Returned
** '|' delimited list of lookup code descriptions for a specified complaint_no and lookup_func
**
** History
** 26/04/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_compdartdetail_getLookupCodeDescList', N'FN') IS NOT NULL
    DROP FUNCTION dbo.cs_compdartdetail_getLookupCodeDescList;
GO
CREATE FUNCTION dbo.cs_compdartdetail_getLookupCodeDescList
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
		@lookup_code_desc varchar(40),
		@lookup_code_desc_list varchar(500);

	SET @complaint_no = @pcomplaint_no;
	SET @lookup_func  = LTRIM(RTRIM(@plookup_func));

	DECLARE csr_compdartdetail CURSOR FOR
		SELECT lookup_code,
			(SELECT TOP(1) lookup_text
				FROM allk
				WHERE lookup_func = @lookup_func
					AND allk.lookup_code = comp_dart_detail.lookup_code
					AND status_yn = 'Y')
				AS lookup_code_desc
			FROM comp_dart_detail
			WHERE complaint_no = @complaint_no
				AND lookup_func = @lookup_func
			ORDER BY lookup_code;

	OPEN csr_compdartdetail;

	FETCH NEXT FROM csr_compdartdetail INTO
		@lookup_code,
		@lookup_code_desc
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @lookup_code <> '' AND @lookup_code IS NOT NULL
		BEGIN
			IF @lookup_code_desc_list = '' OR @lookup_code_desc_list IS NULL
			BEGIN
				SET @lookup_code_desc_list = @lookup_code_desc;
			END
			ELSE
			BEGIN
				SET @lookup_code_desc_list = @lookup_code_desc_list + '|' + @lookup_code_desc;
			END
		END

		FETCH NEXT FROM csr_compdartdetail INTO
			@lookup_code,
			@lookup_code_desc
	END

	CLOSE csr_compdartdetail;
	DEALLOCATE csr_compdartdetail;

	RETURN @lookup_code_desc_list;

END
GO 
