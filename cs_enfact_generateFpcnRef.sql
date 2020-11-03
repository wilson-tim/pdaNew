/*****************************************************************************
** dbo.cs_enfact_generateFpcnRef
** stored procedure
**
** Description
** Generate a FPCN number
**
** Parameters
** @reference_format = the format mask
**
** Returned
** @fpcn = generated FPCN number
** Return value of 0 (if successful), or -1
**
** History
** 20/03/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_enfact_generateFpcnRef', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_enfact_generateFpcnRef;
GO
CREATE PROCEDURE dbo.cs_enfact_generateFpcnRef
	@reference_format varchar(20),
	@reference_max integer,
	@fpcn varchar(20) = NULL OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@fpcn_ref integer,
		@fpcn_str varchar(10),
		@result integer,
		@enf_ref_warn_margin decimal(16,2),
		@checkdigit varchar(1);

	SET @errornumber = '20117';

	IF CHARINDEX('$$1', @reference_format, 1) = 0
	BEGIN
		SET @errornumber = '20118';
		SET @errortext   = 'The FPCN reference format is not configured. A reference has not been generated.';
		GOTO errorexit;
	END

	BEGIN TRY
		EXECUTE @result = dbo.cs_sno_getSerialNumber 'fpcn', '', @serial_no = @fpcn_ref OUTPUT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20119';
		SET @errortext = ERROR_MESSAGE();
		GOTO errorexit;
	END CATCH
	
	/*
	SET @enf_ref_warn_margin = dbo.cs_keys_getNField('ALL', 'ENF_REF_WARN_MARGIN');

	IF @fpcn_ref > (@reference_max - @enf_ref_warn_margin) 
		WARNING 'Document reference range is nearly used up'
	*/

	IF @reference_max > 999999999
	BEGIN
		SET @fpcn_str = RIGHT(LTRIM(RTRIM(STR(@fpcn_ref))), 10);
	END
	ELSE
	BEGIN
		IF @reference_max > 99999999
		BEGIN
			SET @fpcn_str = RIGHT(LTRIM(RTRIM(STR(@fpcn_ref))), 9);
		END
		ELSE
		BEGIN
			IF @reference_max > 9999999
			BEGIN
				SET @fpcn_str = RIGHT(LTRIM(RTRIM(STR(@fpcn_ref))), 8);
			END
			ELSE
			BEGIN
				IF @reference_max > 999999
				BEGIN
					SET @fpcn_str = RIGHT(LTRIM(RTRIM(STR(@fpcn_ref))), 7);
				END
				ELSE
				BEGIN
					IF @reference_max > 99999
					BEGIN
						SET @fpcn_str = RIGHT(LTRIM(RTRIM(STR(@fpcn_ref))), 6);
					END
					ELSE
					BEGIN
						IF @reference_max > 9999
						BEGIN
							SET @fpcn_str = RIGHT(LTRIM(RTRIM(STR(@fpcn_ref))), 5);
						END
						ELSE
						BEGIN
							IF @reference_max > 999
							BEGIN
								SET @fpcn_str = RIGHT(LTRIM(RTRIM(STR(@fpcn_ref))), 4);
							END
							ELSE
							BEGIN
								IF @reference_max > 99
								BEGIN
									SET @fpcn_str = RIGHT(LTRIM(RTRIM(STR(@fpcn_ref))), 3);
								END
								ELSE
								BEGIN
									IF @reference_max > 9
									BEGIN
										SET @fpcn_str = RIGHT(LTRIM(RTRIM(STR(@fpcn_ref))), 2);
									END
									ELSE
									BEGIN
										SET @fpcn_str = RIGHT(LTRIM(RTRIM(STR(@fpcn_ref))), 1);
									END
								END
							END
						END
					END
				END
			END
		END
	END

	SET @fpcn = REPLACE(@reference_format, '$$1', @fpcn_str);

	IF CHARINDEX('$$2', @fpcn, 1) > 0
	BEGIN
		SET @fpcn_str   = REPLACE(@fpcn, '$$2', '');
		SET @checkdigit = dbo.cs_enfact_generateFpcnCheckDigit(@fpcn_str);
		SET @fpcn       = REPLACE(@fpcn, '$$2', @checkdigit);
	END

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
