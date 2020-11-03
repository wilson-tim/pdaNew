/*****************************************************************************
** dbo.cs_compertdetail_getLookupCodeListSP
** stored procedure
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
** Return value of 0 = success or -1 = failure
**
** History
** 22/04/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_compertdetail_getLookupCodeListSP', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_compertdetail_getLookupCodeListSP;
GO
CREATE PROCEDURE dbo.cs_compertdetail_getLookupCodeListSP
	@pcomplaint_no integer,
	@plookup_func varchar(6),
	@lookup_code_list varchar(500) = NULL OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@complaint_no integer,
		@lookup_func varchar(6),
		@codecount integer,
		@loopvar integer,
		@lookup_code varchar(8);

	SET @errornumber = '20232';

	SET @complaint_no = @pcomplaint_no;
	SET @lookup_func  = LTRIM(RTRIM(@plookup_func));

	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @errornumber = '20233';
		SET @errortext   = 'complaint_no is required';
		GOTO errorexit;
	END

	IF @lookup_func = '' OR @lookup_func IS NULL
	BEGIN
		SET @errornumber = '20234';
		SET @errortext   = 'lookup_func is required';
		GOTO errorexit;
	END

	DECLARE csr_compertdetail CURSOR FOR
		SELECT lookup_code
			FROM comp_ert_detail
			WHERE complaint_no = @complaint_no
				AND lookup_func = @lookup_func
			ORDER BY lookup_code;

	OPEN csr_compertdetail;

	FETCH NEXT FROM csr_compertdetail INTO
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

		FETCH NEXT FROM csr_compertdetail INTO
			@lookup_code
	END

	CLOSE csr_compertdetail;
	DEALLOCATE csr_compertdetail;

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
