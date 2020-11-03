/*****************************************************************************
** dbo.cs_utils_getActions
** stored procedure
**
** Description
** Selects a list of available action codes for a given service code
** and a given fault code
**
** Parameters
** @service_c    = service code (required for create route)
** @comp_code    = fault code (required for create route)
** @complaint_no = complaint number (required for update route)
** @user_name    = login id (required for either route)
**
** Returned
** Result set of available action codes with columns
**   action_code  = action code, char(1)
**   action_desc  = action code description, char(40)
**   default_flag = default action code flag, bit (assigned for create route only)
**   display_order
** ordered by display_order
** Return value of @@ROWCOUNT or -1
**
** Notes
** @user_name required in all cases as future proofing for Enforcements requirements
**
** History
** 17/12/2012  TW  New
** 28/01/2013  TW  Added 'A - Auto Rectification' option
** 12/02/2013  TW  Added condition for AV rectification and works order options
** 14/02/2013  TW  Additional parameter @complaint_no
** 18/02/2013  TW  AV - no action selection possible if currently works order
**                 or rectification
** 21/03/2013  TW  Additional parameter @user_name
** 01/07/2013  TW  Complete rethink - now with processing for both
**                 the create and update routes
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_utils_getActions', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_utils_getActions;
GO
CREATE PROCEDURE dbo.cs_utils_getActions
	@pservice_c varchar(6)
	,@pcomp_code varchar(6)
	,@pcomplaint_no integer = NULL
	,@puser_name varchar(8)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @default_code varchar(6)
		,@action_flag varchar(1)
		,@xmldoc varchar(1000)
		,@idoc integer
		,@flag char(1)
		,@display_order integer
		,@def_name_noun varchar(40)
		,@errortext varchar(500)
		,@errornumber varchar(10)
		,@rowcount integer
		,@dest_suffix varchar(6)
		,@comp_action_flag varchar(1)
		,@last_seq integer
		,@av_expiry_date datetime
		,@service_c varchar(6)
		,@comp_code varchar(6)
		,@complaint_no integer
		,@user_name varchar(8)
		;

	SET @service_c = LTRIM(RTRIM(@pservice_c));
	SET @comp_code = LTRIM(RTRIM(@pcomp_code));
	SET @complaint_no = @pcomplaint_no;
	SET @user_name = LTRIM(RTRIM(@puser_name));

	IF @complaint_no IS NULL
	BEGIN
		/* Create */
		BEGIN TRY
			EXECUTE @rowcount = dbo.cs_utils_getActionsCreate
				@service_c
				,@comp_code
				,@user_name
		END TRY
		BEGIN CATCH
			SET @errornumber = '20668';
			SET @errortext   = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH
	END
	ELSE
	BEGIN
		/* Update */
		BEGIN TRY
			EXECUTE @rowcount = dbo.cs_utils_getActionsUpdate
				@complaint_no
				,@user_name
		END TRY
		BEGIN CATCH
			SET @errornumber = '20669';
			SET @errortext   = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH
	END

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO
