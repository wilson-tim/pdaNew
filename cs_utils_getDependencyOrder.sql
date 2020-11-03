/*****************************************************************************
** dbo.cs_utils_getDependencyOrder
** stored procedure
**
** Description
** Lists objects in dependency order
**
** Parameters
** none
**
** Returned
** Result set of objects in dependency order
**
** History
** 24/02/2013  TW  New
** 15/05/2013  TW  Soft code ...\schema folder contents listing
** 27/06/2013  TW  Exclude ...\schema folder, now being processed by database version control
** 07/08/2013  TW  Also check for csis_ prefix
**
** Notes
** Object type. Can be one of these values:
**
** C = CHECK constraint
** D = Default or DEFAULT constraint
** F = FOREIGN KEY constraint
** FN = Scalar function
** IF = Inlined table-function
** K = PRIMARY KEY or UNIQUE constraint
** L = Log
** P = Stored procedure
** R = Rule
** RF = Replication filter stored procedure
** S = System table
** TF = Table function
** TR = Trigger
** U = User table
** V = View
** X = Extended stored procedure
**
*****************************************************************************/
IF (OBJECT_ID('dbo.cs_utils_getDependencyOrder') IS NOT NULL)
    DROP PROCEDURE dbo.cs_utils_getDependencyOrder
GO
CREATE PROCEDURE dbo.cs_utils_getDependencyOrder
AS
BEGIN
    DECLARE
        @i  integer,
        @count  integer,
		@SubDirectory nvarchar(512);

    DECLARE
        @run_order table (object_name sysname, object_id integer, run_level smallint, object_type char(2));

    SET @i = 0;
    SET @count = 1;

    WHILE (@count > 0)
    BEGIN
        INSERT INTO @run_order (object_name, object_id, run_level, object_type)
        SELECT
            OBJECT_NAME(o.object_id),
			o.object_id,
            @i,
			o.type
        FROM
            sys.objects o
        WHERE
            NOT EXISTS (SELECT * FROM sys.sql_dependencies d WHERE d.object_id = o.object_id AND d.referenced_major_id NOT IN (SELECT object_id FROM @run_order)) AND
            NOT EXISTS (SELECT * FROM @run_order ro WHERE ro.object_id = o.object_id)
            AND o.type IN ('U', 'P', 'V', 'TR', 'TF', 'IF', 'FN');

        SELECT @count = @@ROWCOUNT;

        SELECT @i = @i + 1;
    END

    INSERT INTO @run_order (object_name, object_id, run_level, object_type)
    SELECT
        OBJECT_NAME(o.object_id),
		o.object_id,
        -999,
		o.type
    FROM
        sys.objects o
    WHERE
        NOT EXISTS (SELECT * FROM @run_order ro WHERE ro.object_id = o.object_id)
		AND o.type IN ('U', 'P', 'V', 'TR', 'TF', 'IF', 'FN');
/*
	INSERT INTO @run_order (object_name, object_id, run_level, object_type)
		VALUES ('schema\00001_cs_schema_sitedetail', 0, 0, 'CS');

	INSERT INTO @run_order (object_name, object_id, run_level, object_type)
		VALUES ('schema\00002_cs_schema_sprocs', 0, 0, 'CS');

	INSERT INTO @run_order (object_name, object_id, run_level, object_type)
		VALUES ('schema\00003_cs_schema_keys', 0, 0, 'CS');
		
	INSERT INTO @run_order (object_name, object_id, run_level, object_type)
		VALUES ('schema\00004_cs_schema_ContenderLicences', 0, 0, 'CS');

	INSERT INTO @run_order (object_name, object_id, run_level, object_type)
		VALUES ('schema\00005_cs_schema_ContenderUsers', 0, 0, 'CS');
*/
/*
	IF OBJECT_ID('tempdb..#DirTree') IS NOT NULL
	BEGIN
		DROP TABLE #DirTree;
	END

	CREATE TABLE #DirTree
		(
		Id int identity(1,1),
		SubDirectory nvarchar(512),
		Depth smallint,
		FileFlag bit,
		ParentDirectoryID int
		);

	INSERT INTO #DirTree (SubDirectory, Depth, FileFlag)
		EXEC master..xp_dirtree 'C:\csl\trunk\SQL_layer\schema', 10, 1;

	DECLARE csr_dirtree CURSOR FOR
		SELECT SubDirectory
			FROM #DirTree
			WHERE SubDirectory LIKE '%@_cs@_%' ESCAPE '@'
				AND SubDirectory LIKE '%@.sql' ESCAPE '@'
				AND FileFlag = 1
			ORDER BY SubDirectory;

	OPEN csr_dirtree;

	FETCH NEXT FROM csr_dirtree INTO
		@SubDirectory;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @SubDirectory = REPLACE(@SubDirectory, '.sql', '');

		INSERT INTO @run_order (object_name, object_id, run_level, object_type)
			VALUES ('schema\' + @SubDirectory, 0, 0, 'CS');

		FETCH NEXT FROM csr_dirtree INTO
			@SubDirectory;
	END

	CLOSE csr_dirtree;
	DEALLOCATE csr_dirtree;
*/
    SELECT object_name + '.sql' AS proc_name,
		run_level,
		object_type
		FROM @run_order 
		WHERE (object_name LIKE 'cs@_%' ESCAPE '@'
			OR object_name LIKE 'csis@_%' ESCAPE '@'
			OR object_name LIKE 'schema@\%' ESCAPE '@')
			AND object_type IN ('P', 'V', 'FN', 'CS', 'TF')
		ORDER BY ABS(run_level), proc_name;

END
GO
