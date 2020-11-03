/*****************************************************************************
** dbo.cs_pdalookup_getFaultCodeDesc
** user defined function
**
** Description
** Lookup a fault code description
**
** Parameters
** @comp_code = fault code
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
** 09/07/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_pdalookup_getFaultCodeDesc', N'FN') IS NOT NULL
    DROP FUNCTION dbo.cs_pdalookup_getFaultCodeDesc;
GO
CREATE FUNCTION dbo.cs_pdalookup_getFaultCodeDesc
	(
	@pcomp_code varchar(6),
	@pservice_c varchar(6),
	@pitem_ref varchar(12),
	@ptask_ref varchar(12)
	)
RETURNS varchar(40)
AS
BEGIN

	DECLARE 
		@comp_code_desc varchar(40),
		@use_itemlink char(1),
		@use_tasklink char(1),
		@role_name varchar(15),
		@service_type varchar(30),
		@comp_code varchar(6),
		@service_c varchar(6),
		@item_ref varchar(12),
		@task_ref varchar(12)
		;

	SET @comp_code = LTRIM(RTRIM(@pcomp_code));
	SET @service_c = LTRIM(RTRIM(@pservice_c));
	SET @item_ref  = LTRIM(RTRIM(@pitem_ref));
	SET @task_ref  = LTRIM(RTRIM(@ptask_ref));

	SET @comp_code_desc = NULL;

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
			RETURN @comp_code_desc;
		END

		IF (@item_ref = '' OR @item_ref IS NULL)
			AND @use_tasklink = 'N'
			AND @use_itemlink = 'Y'
		BEGIN
			RETURN @comp_code_desc;
		END

		IF @use_tasklink = 'Y'
		BEGIN
			/* Using task to fault code link */
			SELECT TOP(1) @comp_code_desc = comp_code_desc
			FROM
			(
			SELECT DISTINCT
				pda_lookup.comp_code,
				pda_lookup.comp_code_desc
			FROM ta_c, pda_lookup, allk
			WHERE 
				pda_lookup.comp_code = @comp_code
				AND ta_c.task_ref = @task_ref
				AND pda_lookup.comp_code = ta_c.comp_code
				AND pda_lookup.role_name = @role_name
				AND allk.lookup_code = pda_lookup.comp_code
				AND allk.lookup_func = 'COMPLA'
				AND allk.status_yn = 'Y'
			) X;
		END
		ELSE
		BEGIN
			IF @use_itemlink = 'Y'
			BEGIN
				/* Using item to fault code link */
				SELECT TOP(1) @comp_code_desc = comp_code_desc
				FROM
				(
				SELECT DISTINCT
					pda_lookup.comp_code,
					pda_lookup.comp_code_desc
				FROM it_c, pda_lookup, allk
				WHERE 
					pda_lookup.comp_code = @comp_code
					AND it_c.item_ref = @item_ref
					AND pda_lookup.comp_code = it_c.comp_code
					AND pda_lookup.role_name = @role_name
					AND allk.lookup_code = pda_lookup.comp_code
					AND allk.lookup_func = 'COMPLA'
					AND allk.status_yn = 'Y'
				) X;
			END
			ELSE
			BEGIN
				/* Not linked */
				SELECT TOP(1) @comp_code_desc = comp_code_desc
				FROM
				(
				SELECT DISTINCT
					pda_lookup.comp_code,
					pda_lookup.comp_code_desc
				FROM pda_lookup, allk
				WHERE 
					pda_lookup.comp_code = @comp_code
					AND pda_lookup.role_name = @role_name
					AND allk.lookup_code = pda_lookup.comp_code
					AND allk.lookup_func = 'COMPLA'
					AND allk.status_yn = 'Y'
				) X;
			END
		END
	END
	ELSE
	BEGIN
		/* All other service types */
		IF @item_ref = '' OR @item_ref IS NULL
			AND @use_itemlink = 'Y'
		BEGIN
			RETURN @comp_code_desc;
		END

		IF @use_itemlink = 'Y'
		BEGIN
			/* Using item to fault code link */
			SELECT TOP(1) @comp_code_desc = comp_code_desc
			FROM
			(
			SELECT DISTINCT
				pda_lookup.comp_code,
				pda_lookup.comp_code_desc
			FROM it_c, pda_lookup, allk
			WHERE pda_lookup.comp_code = @comp_code
				AND it_c.item_ref = @item_ref
				AND pda_lookup.comp_code = it_c.comp_code
				AND pda_lookup.role_name = @role_name
				AND allk.lookup_code = pda_lookup.comp_code
				AND allk.lookup_func = 'COMPLA'
				AND allk.status_yn = 'Y'
			) X;
		END
		ELSE
		BEGIN
			/* Not linked */
			SELECT TOP(1) @comp_code_desc = comp_code_desc
			FROM
			(
			SELECT DISTINCT
				pda_lookup.comp_code,
				pda_lookup.comp_code_desc
			FROM pda_lookup, allk
			WHERE pda_lookup.comp_code = @comp_code
				AND pda_lookup.role_name = @role_name
				AND allk.lookup_code = pda_lookup.comp_code
				AND allk.lookup_func = 'COMPLA'
				AND allk.status_yn = 'Y'
			) X;
		END
	END

	RETURN @comp_code_desc;

END

GO
