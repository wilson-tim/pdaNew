/*****************************************************************************
** dbo.cs_utils_refreshAllObjects
** stored procedure
**
** Description
** Selects objects and refreshes their metadata
**
** Parameters
** none
**
** Returned
** nothing
**
** History
** 24/02/2013  TW  New
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
IF (OBJECT_ID('dbo.cs_utils_refreshAllObjects') IS NOT NULL)
    DROP PROCEDURE dbo.cs_utils_refreshAllObjects
GO
CREATE PROCEDURE dbo.cs_utils_refreshAllObjects
AS
BEGIN
    DECLARE
        @object_id      integer,
        @schema_name    sysname,
        @object_name    sysname,
        @full_name      nvarchar(1024);

    DECLARE csr_objects CURSOR FOR
        SELECT
            object_id,
            OBJECT_SCHEMA_NAME(object_id),
            OBJECT_NAME(object_id)
        FROM
            sys.objects
        WHERE
            type IN ('P', 'TR', 'V', 'FN', 'TF', 'IF');

    OPEN csr_objects;

    FETCH NEXT FROM csr_objects INTO @object_id, @schema_name, @object_name;

    WHILE (@@FETCH_STATUS = 0)
    BEGIN
        SET @full_name = QUOTENAME(@schema_name) + '.' + QUOTENAME(@object_name);

        EXEC sp_refreshsqlmodule @full_name;

        FETCH NEXT FROM csr_objects INTO @object_id, @schema_name, @object_name;
    END

    CLOSE csr_objects;

    DEALLOCATE csr_objects;
END
GO
