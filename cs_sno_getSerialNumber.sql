/*****************************************************************************
** dbo.cs_sno_getSerialNumber
** stored procedure
**
** Description
** Returns next serial number for given key and contract
**
** Parameters
** @sn_func      = key name of serial number required, varchar(18)
** @contract_ref = contract reference, varchar(12)
**
** Returned
** @serial_no    = serial number, integer
** Return value of 0 for success, otherwise -1
**
** Notes
** Example call 
**   DECLARE @complaint_no integer,
**           @result integer;
**   EXECUTE @result = dbo.cs_sno_getSerialNumber 'COMP', '', @serial_no = @complaint_no OUTPUT;
**   IF @result < 0
**     ...
**
** History
** 18/12/2012  TW  New
** 11/02/2013  TW  Revised in line with UTILS\PUTILS.4gl, function get_next_s_no
** 29/05/2013  TW  Bug fix - contract_ref '' should be converted to contract_ref NULL
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_sno_getSerialNumber', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_sno_getSerialNumber;
GO
CREATE PROCEDURE dbo.cs_sno_getSerialNumber
	@sn_func varchar(18),
	@contract_ref varchar(12),
	@serial_no integer OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @rowcount integer,
		@errornumber varchar(10),
		@errortext varchar(500);

	SET @errornumber = '13300';
	DECLARE @tablevar table
		(
		old_serial_no integer
		);

	SET @sn_func      = LTRIM(RTRIM(@sn_func));
	SET @contract_ref = LTRIM(RTRIM(@contract_ref));
  
	/* Check @sn_func parameter */
	IF (@sn_func = '') OR (@sn_func IS NULL)
	BEGIN
		SET @errornumber = '13301';
		SET @errortext = 'sn_func is required';
		GOTO errorexit;
	END

	/* Check @contract_ref parameter */
	IF @contract_ref = '*' OR @contract_ref = ''
	BEGIN
		SET @contract_ref = NULL;
	END
  
	/* Get the next serial number */
	IF (@contract_ref = '') OR (@contract_ref IS NULL)
	BEGIN
		BEGIN TRY
			UPDATE s_no
				SET serial_no = serial_no + 1
				OUTPUT deleted.serial_no
				INTO @tablevar
				WHERE sn_func = @sn_func
					AND contract_ref IS NULL;
		END TRY
		BEGIN CATCH
			SET @errornumber = '13302';
			SET @errortext = 'Error updating s_no record for sn_func ' + @sn_func + ' and contract_ref NULL';
			GOTO errorexit
		END CATCH
	END
	ELSE
	BEGIN
		BEGIN TRY
			UPDATE s_no
				SET serial_no = serial_no + 1
				OUTPUT deleted.serial_no
				INTO @tablevar
				WHERE sn_func = @sn_func
					AND contract_ref = @contract_ref;
		END TRY
		BEGIN CATCH
			SET @errornumber = '13303';
			SET @errortext = 'Error updating s_no record for sn_func ' + @sn_func + ' and contract_ref ' + @contract_ref;
			GOTO errorexit
		END CATCH
	END

	SELECT @serial_no = old_serial_no
		FROM @tablevar;

	SET @rowcount  = @@ROWCOUNT;

	/* Multiple rows found */
	IF @rowcount > 1
	BEGIN
		SET @errornumber = '13304';
		SET @errortext = 'Error selecting s_no record';
		GOTO errorexit;
	END

	/* No row found, create it */
	IF (@rowcount < 1)
	BEGIN
		BEGIN TRY
			INSERT INTO s_no
				(
				sn_func,
				contract_ref,
				serial_no
				)
				VALUES
				(
				@sn_func,
				@contract_ref,
				2
				);

			SET @serial_no = 1;
		END TRY
		BEGIN CATCH
			SET @errornumber = '13305';
			SET @errortext = 'Error inserting s_no record';
			GOTO errorexit
		END CATCH
	END

normalexit:
	RETURN 0

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1
  
END
GO 
