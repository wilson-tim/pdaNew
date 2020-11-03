/*****************************************************************************
** dbo.cs_schema_keys
** schema change script
**
** Description
** Adds new records to the keys table
**
** Parameters
**
** Returned
**
** History
** 18/12/2012  TW  New - PDA web.xml parameter def_name_noun
** 04/01/2013  TW  Added IF EXISTS... test
** 05/02/2013  TW  New - local search radius
** 07/03/2013  TW  New - PDA inspection list record insertion parameters (INSPLIST_INS_RECT, INSPLIST_INS_ISNP, INSPLIST_INS_SAMP)
** 10/04/2013  TW  New - PDA inspection list record insertion parameters (INSPLIST_INS_WO, INSPLIST_WO_STATUSES)
** 15/04/2013  TW  New - use_graff_est_cost parameter
** 29/04/2013  TW  Revised - PDA inspection list parameter (INSPLIST_WO_STATUSES)
** 01/05/2013  TW  New - PDA inspection list months parameter default value (INSPLIST_MONTHS)
** 14/05/2013  TW  New - Enable NI195 rectifications (NI195_RECTIFICATION)
** 23/05/2013  TW  New - DEF_NAME_VERB
**
*****************************************************************************/

IF NOT EXISTS
	(SELECT TOP (1) * FROM keys WHERE service_c = 'PDAINI' AND keyname = 'DEF_NAME_NOUN')
BEGIN
	INSERT INTO keys
		(
			service_c,
			keyname,
			keydesc,
			c_field,
			n_field,
			d_field
		)
		VALUES
		(
			'PDAINI',
			'DEF_NAME_NOUN',
			'The name of the noun form for a default.',
			'Rectification',
			NULL,
			NULL
		)
END

GO

IF NOT EXISTS
	(SELECT TOP (1) * FROM keys WHERE service_c = 'PDAINI' AND keyname = 'DEF_NAME_VERB')
BEGIN
	INSERT INTO keys
		(
			service_c,
			keyname,
			keydesc,
			c_field,
			n_field,
			d_field
		)
		VALUES
		(
			'PDAINI',
			'DEF_NAME_VERB',
			'The name of the verb form for a default.',
			'rectify',
			NULL,
			NULL
		)
END

GO

IF NOT EXISTS
	(SELECT TOP (1) * FROM keys WHERE service_c = 'PDAINI' AND keyname = 'LOCAL_SEARCH_RADIUS')
BEGIN
	INSERT INTO keys
		(
			service_c,
			keyname,
			keydesc,
			c_field,
			n_field,
			d_field
		)
		VALUES
		(
			'PDAINI',
			'LOCAL_SEARCH_RADIUS',
			'The radius in metres for a local search.',
			NULL,
			200,
			NULL
		)
END

GO

IF NOT EXISTS
	(SELECT TOP (1) * FROM keys WHERE service_c = 'PDAINI' AND keyname = 'INSPLIST_INS_RECT')
BEGIN
	INSERT INTO keys
		(
			service_c,
			keyname,
			keydesc,
			c_field,
			n_field,
			d_field
		)
		VALUES
		(
			'PDAINI',
			'INSPLIST_INS_RECT',
			'Include rectifications in insplist (Y/N)',
			'Y',
			NULL,
			NULL
		)
END

GO

IF NOT EXISTS
	(SELECT TOP (1) * FROM keys WHERE service_c = 'PDAINI' AND keyname = 'INSPLIST_INS_INSP')
BEGIN
	INSERT INTO keys
		(
			service_c,
			keyname,
			keydesc,
			c_field,
			n_field,
			d_field
		)
		VALUES
		(
			'PDAINI',
			'INSPLIST_INS_INSP',
			'Include inspections in insplist (Y/N)',
			'Y',
			NULL,
			NULL
		)
END

GO

IF NOT EXISTS
	(SELECT TOP (1) * FROM keys WHERE service_c = 'PDAINI' AND keyname = 'INSPLIST_INS_SAMP')
BEGIN
	INSERT INTO keys
		(
			service_c,
			keyname,
			keydesc,
			c_field,
			n_field,
			d_field
		)
		VALUES
		(
			'PDAINI',
			'INSPLIST_INS_SAMP',
			'Include samples in insplist (Y/N)',
			'Y',
			NULL,
			NULL
		)
END

GO

IF NOT EXISTS
	(SELECT TOP (1) * FROM keys WHERE service_c = 'PDAINI' AND keyname = 'INSPLIST_INS_WO')
BEGIN
	INSERT INTO keys
		(
			service_c,
			keyname,
			keydesc,
			c_field,
			n_field,
			d_field
		)
		VALUES
		(
			'PDAINI',
			'INSPLIST_INS_WO',
			'Include works orders in insplist (Y/N)',
			'Y',
			NULL,
			NULL
		)
END

GO

IF NOT EXISTS
	(SELECT TOP (1) * FROM keys WHERE service_c = 'PDAINI' AND keyname = 'INSPLIST_WO_STATUSES')
BEGIN
	INSERT INTO keys
		(
			service_c,
			keyname,
			keydesc,
			c_field,
			n_field,
			d_field
		)
		VALUES
		(
			'PDAINI',
			'INSPLIST_WO_STATUSES',
			'Incl. works order statuses (comma sep)',
			'E,C,A,X,P',
			NULL,
			NULL
		)
END

GO

IF NOT EXISTS
	(SELECT TOP (1) * FROM keys WHERE service_c = 'PDAINI' AND keyname = 'USE_GRAFF_EST_COST')
BEGIN
	INSERT INTO keys
		(
			service_c,
			keyname,
			keydesc,
			c_field,
			n_field,
			d_field
		)
		VALUES
		(
			'PDAINI',
			'USE_GRAFF_EST_COST',
			'Use graffiti est cost section Y, or wo N',
			'N',
			NULL,
			NULL
		)
END

GO

IF EXISTS
	(SELECT TOP (1) * FROM keys WHERE service_c = 'PDAINI' AND keyname = 'INSPLIST_WO_STATUSES')
BEGIN
	UPDATE keys
		SET c_field = 'E,I,C'
		WHERE service_c = 'PDAINI'
			AND keyname = 'INSPLIST_WO_STATUSES'
END

GO

IF NOT EXISTS
	(SELECT TOP (1) * FROM keys WHERE service_c = 'PDAINI' AND keyname = 'INSPLIST_MONTHS')
BEGIN
	INSERT INTO keys
		(
			service_c,
			keyname,
			keydesc,
			c_field,
			n_field,
			d_field
		)
		VALUES
		(
			'PDAINI',
			'INSPLIST_MONTHS',
			'Include if newer than n months old',
			NULL,
			3,
			NULL
		)
END

GO

IF NOT EXISTS
	(SELECT TOP (1) * FROM keys WHERE service_c = 'PDAINI' AND keyname = 'NI195_RECTIFICATION')
BEGIN
	INSERT INTO keys
		(
			service_c,
			keyname,
			keydesc,
			c_field,
			n_field,
			d_field
		)
		VALUES
		(
			'PDAINI',
			'NI195_RECTIFICATION',
			'Enable NI195 rectifications',
			'Y',
			NULL,
			NULL
		)
END

GO
