/*****************************************************************************
** SQL_layer_drop_procfuncview
** script
**
** Description
** Drop stored procedures, user defined functions and views
** if filename starts with 'cs_'
**
** Parameters
**
** Returned
**
** Notes
** Comment out or amend the USE command as required
** Comment out the PRINT or EXECUTE commands as required
** Maximum output from PRINT is 8000 characters
**
** History
** 22/02/2013  TW  New
**
*****************************************************************************/
--USE welshdata

DECLARE @sql varchar(MAX);

/* Stored procedures */
SELECT @sql = ISNULL(@sql + 'DROP PROCEDURE ', 'DROP PROCEDURE ')
       + QUOTENAME(s.name) + '.' + QUOTENAME(p.name) +';'
       + CHAR(13) + CHAR(10)
       FROM sys.objects p JOIN sys.schemas s 
       ON p.schema_id = s.schema_id
       WHERE [type] = 'P'
              AND p.name LIKE 'cs@_%' ESCAPE '@'
       ORDER BY p.name

/* User defined functions */
SELECT @sql = ISNULL(@sql + 'DROP FUNCTION ', 'DROP FUNCTION ')
       + QUOTENAME(s.name) + '.' + QUOTENAME(f.name) +';'
       + CHAR(13) + CHAR(10)
       FROM sys.objects f JOIN sys.schemas s 
       ON f.schema_id = s.schema_id
       WHERE [type] = 'FN'
              AND f.name LIKE 'cs@_%' ESCAPE '@'
       ORDER BY f.name

/* Table functions */
SELECT @sql = ISNULL(@sql + 'DROP FUNCTION ', 'DROP FUNCTION ')
       + QUOTENAME(s.name) + '.' + QUOTENAME(f.name) +';'
       + CHAR(13) + CHAR(10)
       FROM sys.objects f JOIN sys.schemas s 
       ON f.schema_id = s.schema_id
       WHERE [type] = 'TF'
              AND f.name LIKE 'cs@_%' ESCAPE '@'
       ORDER BY f.name

/* Views */
SELECT @sql = ISNULL(@sql + 'DROP VIEW ', 'DROP VIEW ')
       + QUOTENAME(s.name) + '.' + QUOTENAME(v.name) +';'
       + CHAR(13) + CHAR(10)
       FROM sys.objects v JOIN sys.schemas s 
       ON v.schema_id = s.schema_id
       WHERE [type] = 'V'
              AND v.name LIKE 'cs@_%' ESCAPE '@'
       ORDER BY v.name

PRINT @sql
--EXECUTE (@sql)

GO
