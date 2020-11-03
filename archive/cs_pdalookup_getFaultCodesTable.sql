/*****************************************************************************
** dbo.cs_pdalookup_getFaultCodesTable
** user defined function
**
** Description
** Creates a table of available fault codes
**
** Parameters
** @service_c = service code
** @item_ref  = item reference
** @task_ref  = task reference [service types TRADE and AGREQ]
**
** Returned
** Table of available fault codes with columns
**   comp_code      = fault code, char(6)
**   comp_code_desc = fault code description, char(40)
**   display_order  = display order, integer
**   flycap_record  = fly capture fault code true / false
**
** Notes
** See document 'Contender - Item Task to Fault Code Linking.pdf' authored by Fiona / Bob during 2012
**
** Selecting COMPLA entries only at this stage
** If later on the rectification action is selected then there must be a check
**   that there is a DEFRN record for the selected fault code with a value in lookup_num
**   and associated defa, etc. records
**
** History
** 03/05/2013  TW  New
** 01/07/2013  TW  Additional column flycap_record
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_pdalookup_getFaultCodesTable', N'TF') IS NOT NULL
    DROP FUNCTION dbo.cs_pdalookup_getFaultCodesTable;
GO
CREATE FUNCTION dbo.cs_pdalookup_getFaultCodesTable
	(
	@service_c varchar(6),
	@item_ref varchar(12),
	@task_ref varchar(12)
	)
RETURNS @faultcodes table 
		(
		comp_code varchar(6) NULL,
		comp_code_desc varchar(40) NULL,
		display_order integer NULL,
		flycap_record bit
		)
AS
BEGIN

	DECLARE @use_itemlink char(1),
		@use_tasklink char(1),
		@role_name varchar(15),
		@service_type varchar(30);

	SET @service_c = RTRIM(LTRIM(@service_c));
	SET @item_ref = RTRIM(LTRIM(@item_ref));
	SET @task_ref = RTRIM(LTRIM(@task_ref));

	SET @use_itemlink = 'N';

	IF UPPER(RTRIM(LTRIM(dbo.cs_keys_getCField('ALL', 'COMP CODE>ITEM LINK')))) = 'Y'
	BEGIN
		SET @use_itemlink = 'Y';
	END

	/*
	SET @role_name = RTRIM(LTRIM(dbo.cs_keys_getCField('ALL', 'PDA_INSPECTOR_ROLE')));
	*/
	SET @role_name = 'pda-in';

	SET @service_type = dbo.cs_utils_getServiceType(@service_c);

	IF (@service_type = 'TRADE')
		OR (@service_type = 'AGREQ')
	BEGIN
		/* TRADE and AGREQ */
		SET @use_tasklink = 'N';

		IF UPPER(RTRIM(LTRIM(dbo.cs_keys_getCField('ALL', 'COMP CODE>TASK LINK')))) = 'Y'
		BEGIN
			SET @use_tasklink = 'Y';
		END

		IF (@task_ref = '' OR @task_ref IS NULL)
			AND @use_tasklink = 'Y'
		BEGIN
			RETURN;
		END

		IF (@item_ref = '' OR @item_ref IS NULL)
			AND @use_tasklink = 'N'
			AND @use_itemlink = 'Y'
		BEGIN
			RETURN;
		END

		IF @use_tasklink = 'Y'
		BEGIN
			/* Using task to fault code link */
			INSERT @faultcodes
			SELECT DISTINCT pda_lookup.comp_code,
				pda_lookup.comp_code_desc,
				pda_lookup.display_order,
				flycap_record =
					CASE
						WHEN (
							dbo.cs_modulelic_getInstalled('FC') = 1
							AND
							@service_type = 'CORE'
							AND
							(SELECT COUNT(*) FROM allk a
								WHERE a.lookup_func = 'FCCOMP'
									AND a.lookup_code = pda_lookup.comp_code) > 0
							) THEN 1
						ELSE 0
					END
			FROM ta_c, pda_lookup, allk
			WHERE RTRIM(LTRIM(ta_c.task_ref)) = @task_ref
				AND pda_lookup.comp_code = ta_c.comp_code
				AND RTRIM(LTRIM(pda_lookup.role_name)) = @role_name
				AND allk.lookup_code = pda_lookup.comp_code
				AND allk.lookup_func = 'COMPLA'
				AND allk.status_yn = 'Y';
		END
		ELSE
		BEGIN
			IF @use_itemlink = 'Y'
			BEGIN
				/* Using item to fault code link */
				INSERT @faultcodes
				SELECT DISTINCT pda_lookup.comp_code,
					pda_lookup.comp_code_desc,
					pda_lookup.display_order,
					flycap_record =
						CASE
							WHEN (
								dbo.cs_modulelic_getInstalled('FC') = 1
								AND
								@service_type = 'CORE'
								AND
								(SELECT COUNT(*) FROM allk a
									WHERE a.lookup_func = 'FCCOMP'
										AND a.lookup_code = pda_lookup.comp_code) > 0
								) THEN 1
							ELSE 0
						END
				FROM it_c, pda_lookup, allk
				WHERE RTRIM(LTRIM(it_c.item_ref)) = @item_ref
					AND pda_lookup.comp_code = it_c.comp_code
					AND RTRIM(LTRIM(pda_lookup.role_name)) = @role_name
					AND allk.lookup_code = pda_lookup.comp_code
					AND allk.lookup_func = 'COMPLA'
					AND allk.status_yn = 'Y';
			END
			ELSE
			BEGIN
				/* Not linked */
				INSERT @faultcodes
				SELECT DISTINCT pda_lookup.comp_code,
					pda_lookup.comp_code_desc,
					pda_lookup.display_order,
					flycap_record =
						CASE
							WHEN (
								dbo.cs_modulelic_getInstalled('FC') = 1
								AND
								@service_type = 'CORE'
								AND
								(SELECT COUNT(*) FROM allk a
									WHERE a.lookup_func = 'FCCOMP'
										AND a.lookup_code = pda_lookup.comp_code) > 0
								) THEN 1
							ELSE 0
						END
				FROM pda_lookup, allk
				WHERE RTRIM(LTRIM(pda_lookup.role_name)) = @role_name
					AND allk.lookup_code = pda_lookup.comp_code
					AND allk.lookup_func = 'COMPLA'
					AND allk.status_yn = 'Y';
			END
		END
	END
	ELSE
	BEGIN
		/* All other service types */
		IF @item_ref = '' OR @item_ref IS NULL
			AND @use_itemlink = 'Y'
		BEGIN
			RETURN;
		END

		IF @use_itemlink = 'Y'
		BEGIN
			/* Using item to fault code link */
			INSERT @faultcodes
			SELECT DISTINCT pda_lookup.comp_code,
				pda_lookup.comp_code_desc,
				pda_lookup.display_order,
				flycap_record =
					CASE
						WHEN (
							dbo.cs_modulelic_getInstalled('FC') = 1
							AND
							@service_type = 'CORE'
							AND
							(SELECT COUNT(*) FROM allk a
								WHERE a.lookup_func = 'FCCOMP'
									AND a.lookup_code = pda_lookup.comp_code) > 0
							) THEN 1
						ELSE 0
					END
			FROM it_c, pda_lookup, allk
			WHERE RTRIM(LTRIM(it_c.item_ref)) = @item_ref
				AND pda_lookup.comp_code = it_c.comp_code
				AND RTRIM(LTRIM(pda_lookup.role_name)) = @role_name
				AND allk.lookup_code = pda_lookup.comp_code
				AND allk.lookup_func = 'COMPLA'
				AND allk.status_yn = 'Y';
		END
		ELSE
		BEGIN
			/* Not linked */
			INSERT @faultcodes
			SELECT DISTINCT pda_lookup.comp_code,
				pda_lookup.comp_code_desc,
				pda_lookup.display_order,
				flycap_record =
					CASE
						WHEN (
							dbo.cs_modulelic_getInstalled('FC') = 1
							AND
							@service_type = 'CORE'
							AND
							(SELECT COUNT(*) FROM allk a
								WHERE a.lookup_func = 'FCCOMP'
									AND a.lookup_code = pda_lookup.comp_code) > 0
							) THEN 1
						ELSE 0
					END
			FROM pda_lookup, allk
			WHERE RTRIM(LTRIM(pda_lookup.role_name)) = @role_name
				AND allk.lookup_code = pda_lookup.comp_code
				AND allk.lookup_func = 'COMPLA'
				AND allk.status_yn = 'Y';
		END
	END

	RETURN;

END

GO
