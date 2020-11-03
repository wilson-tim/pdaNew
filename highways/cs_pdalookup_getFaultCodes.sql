/*****************************************************************************
** dbo.cs_pdalookup_getFaultCodes
** stored procedure
**
** Description
** Selects a list of available fault codes
**
** Parameters
** @service_c = service code
** @item_ref  = item reference
** @task_ref  = task reference [service types TRADE and AGREQ]
**
** Returned
** Result set of available fault codes with columns
**   comp_code      = fault code, char(6)
**   comp_code_desc = fault code description, char(40)
**   display_order  = display order, integer
**   flycap_record  = fly capture fault code true / false
** ordered by display_order, comp_code
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
** 12/12/2012  TW  New
** 21/01/2013  TW  Revised
** 01/07/2013  TW  Additional column flycap_record
** 03/10/2013  TW  Additional columm defect_record
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_pdalookup_getFaultCodes', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_pdalookup_getFaultCodes;
GO
CREATE PROCEDURE dbo.cs_pdalookup_getFaultCodes
	@service_c varchar(6),
	@item_ref varchar(12),
	@task_ref varchar(12)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @use_itemlink char(1),
		@use_tasklink char(1),
		@role_name varchar(15),
		@rowcount integer,
		@errornumber varchar(10),
		@errortext varchar(500),
		@service_type varchar(30);

	SET @errornumber = '10800';
	SET @service_c = LTRIM(RTRIM(@service_c));
	SET @item_ref = LTRIM(RTRIM(@item_ref));
	SET @task_ref = LTRIM(RTRIM(@task_ref));

	IF @service_c = '' OR @service_c IS NULL
	BEGIN
		SET @errornumber = '10801';
		SET @errortext = 'service_c is required';
		GOTO errorexit;
	END

	SET @use_itemlink = 'N';

	IF UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'COMP CODE>ITEM LINK')))) = 'Y'
	BEGIN
		SET @use_itemlink = 'Y';
	END

	/*
	SET @role_name = LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'PDA_INSPECTOR_ROLE')));
	*/
	SET @role_name = 'pda-in';

	SET @service_type = dbo.cs_utils_getServiceType(@service_c);

	IF (@service_type = 'TRADE')
		OR (@service_type = 'AGREQ')
	BEGIN
		/* TRADE and AGREQ */
		SET @use_tasklink = 'N';

		IF UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'COMP CODE>TASK LINK')))) = 'Y'
		BEGIN
			SET @use_tasklink = 'Y';
		END

		IF (@task_ref = '' OR @task_ref IS NULL)
			AND @use_tasklink = 'Y'
		BEGIN
			SET @errornumber = '10802';
			SET @errortext = 'task_ref is required';
			GOTO errorexit;
		END

		IF (@item_ref = '' OR @item_ref IS NULL)
			AND @use_tasklink = 'N'
			AND @use_itemlink = 'Y'
		BEGIN
			SET @errornumber = '10803';
			SET @errortext = 'item_ref is required';
			GOTO errorexit;
		END

		IF @use_tasklink = 'Y'
		BEGIN
			/* Using task to fault code link */
			SELECT DISTINCT pda_lookup.comp_code,
				pda_lookup.comp_code_desc,
				pda_lookup.display_order,
				flycap_record =
					CASE
						WHEN (
							dbo.cs_modulelic_getInstalled('FC') = 1
							AND
							@service_type = 'CORE'
							AND EXISTS
							(SELECT 1 FROM allk a
								WHERE a.lookup_func = 'FCCOMP'
									AND a.lookup_code = pda_lookup.comp_code)
							) THEN 1
						ELSE 0
					END,
				(dbo.cs_keys_checkDefectFaultCode(pda_lookup.comp_code)) AS defect_record
			FROM ta_c, pda_lookup, allk
			WHERE ta_c.task_ref = @task_ref
				AND pda_lookup.comp_code = ta_c.comp_code
				AND pda_lookup.role_name = @role_name
				AND allk.lookup_code = pda_lookup.comp_code
				AND allk.lookup_func = 'COMPLA'
				AND allk.status_yn = 'Y'
			ORDER BY pda_lookup.display_order, pda_lookup.comp_code;

			SET @rowcount = @@ROWCOUNT;
		END
		ELSE
		BEGIN
			IF @use_itemlink = 'Y'
			BEGIN
				/* Using item to fault code link */
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
						END,
					(dbo.cs_keys_checkDefectFaultCode(pda_lookup.comp_code)) AS defect_record
				FROM it_c, pda_lookup, allk
				WHERE it_c.item_ref = @item_ref
					AND pda_lookup.comp_code = it_c.comp_code
					AND pda_lookup.role_name = @role_name
					AND allk.lookup_code = pda_lookup.comp_code
					AND allk.lookup_func = 'COMPLA'
					AND allk.status_yn = 'Y'
				ORDER BY pda_lookup.display_order, pda_lookup.comp_code;

				SET @rowcount = @@ROWCOUNT;
			END
			ELSE
			BEGIN
				/* Not linked */
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
						END,
					(dbo.cs_keys_checkDefectFaultCode(pda_lookup.comp_code)) AS defect_record
				FROM pda_lookup, allk
				WHERE pda_lookup.role_name = @role_name
					AND allk.lookup_code = pda_lookup.comp_code
					AND allk.lookup_func = 'COMPLA'
					AND allk.status_yn = 'Y'
				ORDER BY pda_lookup.display_order, pda_lookup.comp_code;

				SET @rowcount = @@ROWCOUNT;
			END
		END
	END
	ELSE
		/* All other service types */
		IF @item_ref = '' OR @item_ref IS NULL
			AND @use_itemlink = 'Y'
		BEGIN
			SET @errornumber = '10804';
			SET @errortext = 'item_ref is required';
			GOTO errorexit;
		END

		IF @use_itemlink = 'Y'
		BEGIN
			/* Using item to fault code link */
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
					END,
				(dbo.cs_keys_checkDefectFaultCode(pda_lookup.comp_code)) AS defect_record
			FROM it_c, pda_lookup, allk
			WHERE it_c.item_ref = @item_ref
				AND pda_lookup.comp_code = it_c.comp_code
				AND pda_lookup.role_name = @role_name
				AND allk.lookup_code = pda_lookup.comp_code
				AND allk.lookup_func = 'COMPLA'
				AND allk.status_yn = 'Y'
			ORDER BY pda_lookup.display_order, pda_lookup.comp_code;

			SET @rowcount = @@ROWCOUNT;
		END
		ELSE
		BEGIN
			/* Not linked */
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
					END,
				(dbo.cs_keys_checkDefectFaultCode(pda_lookup.comp_code)) AS defect_record
			FROM pda_lookup, allk
			WHERE pda_lookup.role_name = @role_name
				AND allk.lookup_code = pda_lookup.comp_code
				AND allk.lookup_func = 'COMPLA'
				AND allk.status_yn = 'Y'
			ORDER BY pda_lookup.display_order, pda_lookup.comp_code;

			SET @rowcount = @@ROWCOUNT;
		END

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO
