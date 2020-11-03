/*****************************************************************************
** dbo.cs_defa_getDefaultVolume
** stored procedure
**
** Description
** Calculate the default value for rectification volume
**
** Parameters
** @site_ref      = site reference
** @item_ref      = item reference
** @feature_ref   = feature reference
** @contract_ref  = contract reference
**
** Returned
** @volume
** Return value of 0 (success) or -1 (failure, with exception text)
**
** History
** 28/01/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_defa_getDefaultVolume', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_defa_getDefaultVolume;
GO
CREATE PROCEDURE dbo.cs_defa_getDefaultVolume
	@site_ref varchar(16),
	@item_ref varchar(12),
	@feature_ref varchar(12),
	@contract_ref varchar(12),
	@volume decimal(10,2) = 1 OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE  @errortext varchar(500),
		@errornumber varchar(10);
		
	SET @errornumber = '12100';

	SET @site_ref = LTRIM(RTRIM(@site_ref));
	SET @item_ref = LTRIM(RTRIM(@item_ref));
	SET @contract_ref = LTRIM(RTRIM(@contract_ref));
	SET @feature_ref = LTRIM(RTRIM(@feature_ref));

	IF @site_ref = '' OR @site_ref IS NULL
	BEGIN
		SET @errornumber = '12101';
		SET @errortext = 'site_ref is required';
		GOTO errorexit;
	END

	IF @item_ref = '' OR @item_ref IS NULL
	BEGIN
		SET @errornumber = '12102';
		SET @errortext = 'item_ref is required';
		GOTO errorexit;
	END

	IF @feature_ref = '' OR @feature_ref IS NULL
	BEGIN
		SET @errornumber = '12103';
		SET @errortext = 'feature_ref is required';
		GOTO errorexit;
	END

	IF @contract_ref = '' OR @contract_ref IS NULL
	BEGIN
		SET @errornumber = '12104';
		SET @errortext = 'contract_ref is required';
		GOTO errorexit;
	END

	SET @volume = dbo.cs_keys_getNField('ALL', 'DEFAULT_VOLUME');

	IF @volume = 0 OR @volume IS NULL
	BEGIN
		SELECT @volume = volume
		FROM si_i
			WHERE site_ref = @site_ref
				AND item_ref = @item_ref
				AND feature_ref = @feature_ref
				AND contract_ref = @contract_ref;

		IF @@ROWCOUNT <> 1
		BEGIN
			SET @volume = NULL;
		END

	END

	/* If all else fails... */
	IF @volume = 0 OR @volume IS NULL
	BEGIN
		SET @volume = 1;
	END

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
