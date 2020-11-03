/*****************************************************************************
** dbo.cs_pdalookup_getNI195FaultCodes
** stored procedure
**
** Description
** [NI195] Selects a list of available fault codes
**
** Parameters (returned by SP cs_sii_getNI195RectificationInfo)
** @pitem_ref  = item reference
** @pitem_type = item type
**
** Returned
** Result set of available fault codes with columns
**   comp_code      = fault code, char(6)
**   comp_code_desc = fault code description, char(40)
**   display_order  = display order, integer
** ordered by display_order, comp_code
**
** Notes
**
** History
** 13/05/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_pdalookup_getNI195FaultCodes', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_pdalookup_getNI195FaultCodes;
GO
CREATE PROCEDURE dbo.cs_pdalookup_getNI195FaultCodes
	@pitem_ref varchar(12),
	@pitem_type varchar(6)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @rowcount integer,
		@errornumber varchar(10),
		@errortext varchar(500),
		@role_name varchar(15),
		@item_ref varchar(12),
		@item_type varchar(6);

	SET @errornumber = '20453';

	SET @item_ref = LTRIM(RTRIM(@pitem_ref));
	SET @item_type = LTRIM(RTRIM(@pitem_type));

	/*
	SET @role_name = LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'PDA_INSPECTOR_ROLE')));
	*/
	SET @role_name = 'pda-in';

	IF (@item_ref = '' OR @item_ref IS NULL)
	BEGIN
		SET @errornumber = '20454';
		SET @errortext = 'item_ref is required';
		GOTO errorexit;
	END

	IF (@item_type = '' OR @item_type IS NULL)
	BEGIN
		SET @errornumber = '20455';
		SET @errortext = 'item_type is required';
		GOTO errorexit;
	END

	SELECT DISTINCT pda_lookup.comp_code,
		pda_lookup.comp_code_desc,
		pda_lookup.display_order,
		flycap_record =
			CASE
				WHEN (
					dbo.cs_modulelic_getInstalled('FC') = 1
					AND
					dbo.cs_utils_getServiceType(pda_lookup.service_c) = 'CORE'
					AND EXISTS
					(SELECT 1 FROM allk a
						WHERE a.lookup_func = 'FCCOMP'
							AND a.lookup_code = pda_lookup.comp_code)
					) THEN 1
				ELSE 0
			END
	FROM it_c, pda_lookup, allk, defa
	WHERE it_c.item_ref = @item_ref
        AND pda_lookup.role_name = @role_name
        AND pda_lookup.comp_code = it_c.comp_code
        AND allk.lookup_func = 'DEFRN'
        AND allk.lookup_code = pda_lookup.comp_code
        AND defa.item_type = @item_type
        AND defa.notice_rep_no = allk.lookup_num
	ORDER BY pda_lookup.display_order, pda_lookup.comp_code;

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO
