/*****************************************************************************
** dbo.cs_compdartdetail_getLookupCodeDescListSP
** stored procedure
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
** Return value of 0 = success or -1 = failure
**
** History
** 26/04/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_compdartdetail_getLookupCodeDescListSP', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_compdartdetail_getLookupCodeDescListSP;
GO
CREATE PROCEDURE dbo.cs_compdartdetail_getLookupCodeDescListSP
	@pcomplaint_no integer,
	@plookup_func varchar(6),
	@lookup_code_desc_list varchar(500) = NULL OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@complaint_no integer,
		@lookup_func varchar(6),
		@codecount integer,
		@loopvar integer,
		@lookup_code varchar(8),
		@lookup_code_desc varchar(40);

	SET @errornumber = '20276';

	SET @complaint_no = @pcomplaint_no;
	SET @lookup_func  = LTRIM(RTRIM(@plookup_func));

	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @errornumber = '20277';
		SET @errortext   = 'complaint_no is required';
		GOTO errorexit;
	END

	IF @lookup_func = '' OR @lookup_func IS NULL
	BEGIN
		SET @errornumber = '20278';
		SET @errortext   = 'lookup_func is required';
		GOTO errorexit;
	END

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

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
