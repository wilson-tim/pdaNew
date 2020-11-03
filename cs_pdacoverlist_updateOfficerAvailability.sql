/*****************************************************************************
** dbo.cs_pdacoverlist_updateOfficerAvailability
** stored procedure
**
** Description
** Update officer availability per specified officer availability data
**
** Parameters
** @xmlOfficerData = XML structure containing officer availability data (multiple records)
** <ArrayOfOfficerMaintDTO>
** 	<OfficerMaintDTO>
** 		<available>true</available>
** 		<cover_full_name/>
** 		<cover_user_name/>
** 		<full_name>FULL NAME</full_name>
** 		<user_name>FULL</user_name>
** 	</OfficerMaintDTO>
** 	<OfficerMaintDTO>
** 		<available>false</available>
** 		<cover_full_name>COVER FULL NAME</cover_full_name>
** 		<cover_user_name>COVER<cover_user_name>
** 		<full_name>USER FULL NAME</full_name>
** 		<user_name>USER</user_name>
** 	</OfficerMaintDTO>
** </ArrayOfOfficerMaintDTO>
**
** Returned
** Return value of 0 (success) or -1 (failure)
**
** History
** 12/07/2013  TW  New
** 15/07/2013  TW  Continued development
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_pdacoverlist_updateOfficerAvailability', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_pdacoverlist_updateOfficerAvailability;
GO
CREATE PROCEDURE dbo.cs_pdacoverlist_updateOfficerAvailability
	@xmlOfficerData xml
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500)
		,@errornumber varchar(10)
		,@rowcount integer
		,@officer_rowcount integer
		,@user_name varchar(15)
		,@available bit
		,@cover_user_name varchar(15)
		;

	IF OBJECT_ID('tempdb..#tempOfficerData') IS NOT NULL
	BEGIN
		DROP TABLE #tempOfficerData;
	END

	BEGIN TRY
		SELECT
			xmldoc.officerdata.value('user_name[1]','varchar(15)') AS 'user_name'
			,xmldoc.officerdata.value('available[1]','bit') AS 'available'
			,xmldoc.officerdata.value('cover_user_name[1]','varchar(15)') AS 'cover_user_name'
		INTO #tempOfficerData
		FROM @xmlOfficerData.nodes('/ArrayOfOfficerMaintDTO/OfficerMaintDTO') AS xmldoc(officerdata);
	END TRY
	BEGIN CATCH
		SET @errornumber = '20691';
		SET @errortext = 'Error processing @xmlOfficerData';
		GOTO errorexit;
	END CATCH

	SELECT * FROM #tempOfficerData;

	DECLARE csr_officers CURSOR FOR
		SELECT [user_name]
			,available
			,cover_user_name
		FROM #tempOfficerData
		ORDER BY [user_name];

	OPEN csr_officers;

	FETCH NEXT FROM csr_officers INTO
		@user_name
		,@available
		,@cover_user_name;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @available = 0
		BEGIN
			BEGIN TRY
				/* Flag officer as unavailable */
				UPDATE pda_cover_list
					SET covered_by = NULL
						,[absent] = 'Y'
					WHERE [user_name] = @user_name;

				/* Make sure that officer is no longer providing cover */
				UPDATE pda_cover_list
					SET covered_by = NULL
					WHERE covered_by = @user_name;
			END TRY
			BEGIN CATCH
				SET @errornumber = '20692';
				SET @errortext = 'Error updating pda_cover_list record (unavailable)';
				GOTO errorexit;
			END CATCH
		END

		IF @available = 0 AND (@cover_user_name <> '' AND @cover_user_name IS NOT NULL)
		BEGIN
			BEGIN TRY
				/* Assign officer cover */
				UPDATE pda_cover_list
					SET covered_by = @cover_user_name
					WHERE [user_name] = @user_name;
			END TRY
			BEGIN CATCH
				SET @errornumber = '20693';
				SET @errortext = 'Error updating pda_cover_list record (assigning cover)';
				GOTO errorexit;
			END CATCH
		END

		IF @available = 1
		BEGIN
			BEGIN TRY
				/* Flag officer as available */
				UPDATE pda_cover_list
					SET covered_by = @user_name
						,[absent] = 'N'
					WHERE [user_name] = @user_name;
			END TRY
			BEGIN CATCH
				SET @errornumber = '20694';
				SET @errortext = 'Error updating pda_cover_list record (available)';
				GOTO errorexit;
			END CATCH
		END

		FETCH NEXT FROM csr_officers INTO
			@user_name
			,@available
			,@cover_user_name;
	END

	CLOSE csr_officers;
	DEALLOCATE csr_officers;

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO
