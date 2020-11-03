/*****************************************************************************
** dbo.cs_schema_sno
** schema change script
**
** Description
** Adjustment for s_no table relating to defh default_no and cust_def_no
**
** Parameters
**
** Returned
**
** History
** 17/05/2013  TW  Adjustment for s_no table relating to defh default_no and cust_def_no
**                 (See cs_defh_createRecordCore revision on 17/05/2013)
**
*****************************************************************************/

/* defh,default_no */
UPDATE s_no
	SET serial_no = ((SELECT MAX(default_no) FROM defh) + 1)
	WHERE sn_func = 'defh'
		AND contract_ref IS NULL;
GO
	
/* defh,cust_def_no */
UPDATE s_no
	SET serial_no = (SELECT MAX(cust_def_no) FROM defh)
	WHERE sn_func = 'DEFREF'
		AND contract_ref IS NULL;
GO
