/*****************************************************************************
** dbo.csis_woh_updateRecord
** stored procedure
**
** Description
** Acknowledge works order record
**
** Parameters
** @user_name = user login id
** @xmlISWorksOrders = works order data in XML format
**
** Returned
** Return value 0 (success), otherwise -1 (failure)
**
** History
** 06/08/2013  TW  New
** 07/08/2013  TW  Continued development
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.csis_woh_updateRecord', N'P') IS NOT NULL
    DROP PROCEDURE dbo.csis_woh_updateRecord;
GO
CREATE PROCEDURE dbo.csis_woh_updateRecord
	@puser_name varchar(8)
	,@ISWorksOrderResponseXML xml
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500)
		,@errornumber varchar(10)
		,@rowcount integer
		,@user_name varchar(8)
		,@Reference integer
		,@ContractorRef varchar(20)
		,@Rejected varchar(1)
		,@Status varchar(3)
		,@Text varchar(MAX)
		,@wo_ref integer
		,@wo_suffix varchar(6)
		,@prevContractorRef varchar(20)
		,@wo_key integer
		,@wo_h_stat varchar(3)
		,@wo_act_value decimal(13,4)
		;

	SET @user_name = LTRIM(RTRIM(@puser_name));

	/* @user_name validation */
	IF @user_name = '' OR @user_name IS NULL
	BEGIN
		SET @errornumber = '20723';
		SET @errortext = 'user_name is required';
		GOTO errorexit;
	END

	/* Parse xml data string */
	IF OBJECT_ID('tempdb..#tempWohResponse') IS NOT NULL
	BEGIN
		DROP TABLE #tempWohResponse;
	END

	BEGIN TRY
		SELECT
			xmldoc.wohresponse.value('Reference[1]','integer') AS 'Reference'
			,xmldoc.wohresponse.value('ContractorRef[1]','varchar(20)') AS 'ContractorRef'
			,xmldoc.wohresponse.value('Rejected[1]','varchar(1)') AS 'Rejected'
			,xmldoc.wohresponse.value('Status[1]','varchar(3)') AS 'Status'
			,xmldoc.wohresponse.value('Text[1]','varchar(MAX)') AS 'Text'
		INTO #tempWohResponse
		FROM @ISWorksOrderResponseXML.nodes('/ISWorksOrderResponse') AS xmldoc(wohresponse);

		SELECT
			@Reference      = Reference
			,@ContractorRef = LTRIM(RTRIM(ContractorRef))
			,@Rejected      = LTRIM(RTRIM(Rejected))
			,@Status        = LTRIM(RTRIM([Status]))
			,@Text          = LTRIM(RTRIM([Text]))
		FROM #tempWohResponse;

		SET @rowcount = @@ROWCOUNT;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20724';
		SET @errortext = 'Error processing @ISWorksOrderResponseXML';
		GOTO errorexit;
	END CATCH

	IF @rowcount > 1
	BEGIN
		SET @errornumber = '20725';
		SET @errortext = 'Error processing @ISWorksOrderResponseXML - too many rows';
		GOTO errorexit;
	END
	IF @rowcount < 1
	BEGIN
		SET @errornumber = '20726';
		SET @errortext = 'Error processing @ISWorksOrderResponseXML - no rows found';
		GOTO errorexit;
	END

	IF @Reference = 0 or @Reference IS NULL
	BEGIN
		SET @errornumber = '20727';
		SET @errortext = 'Reference is required';
		GOTO errorexit;
	END
	SELECT @rowcount = COUNT(*)
		FROM comp
		WHERE complaint_no = @Reference;
	IF @rowcount <> 1
	BEGIN
		SET @errornumber = '20763';
		SET @errortext = LTRIM(RTRIM(STR(@Reference))) + ' is not a valid complaint reference';
		GOTO errorexit;
	END

	SELECT
		@wo_ref = dest_ref
		,@wo_suffix = dest_suffix
		FROM comp
		WHERE complaint_no = @Reference;

	SELECT @prevContractorRef = contractor_ref
		FROM integration_transfer_log
		WHERE complaint_no = @Reference
			AND contractor_ref IS NOT NULL;

	/* Main processing */
	IF @Rejected = 'Y'
	BEGIN
		/* Rejected */

		/* Update text */
		IF LEN(@Text) > 0
		BEGIN
			SET @Text = '!!Record ' + LTRIM(RTRIM(STR(@Reference))) + ' rejected with the following message!!' + CHAR(13) + CHAR(10) + @Text;
		END
		ELSE
		BEGIN
			SET @Text = '!!Record ' + LTRIM(RTRIM(STR(@Reference))) + ' rejected with no additional message!!';
		END
		BEGIN TRY
			EXECUTE dbo.cs_wohtxt_updateNotes
				@wo_ref
				,@wo_suffix
				,@user_name
				,'Y'
				,@Text
		END TRY
		BEGIN CATCH
			SET @errornumber = '20728';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH

		/* Update transfer log */
		BEGIN TRY
			EXECUTE dbo.csis_itl_updateRecord
				@Reference
				,NULL
				,@Rejected
				,NULL
				,0;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20729';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH
	END
	ELSE
	BEGIN
		/* Accepted */

		/* Must have a ContractorRef */ 
		IF (@ContractorRef = '' OR @ContractorRef IS NULL)
			AND (@prevContractorRef = '' OR @prevContractorRef IS NULL)
		BEGIN
			SET @errornumber = '20730';
			SET @errortext = 'ContractorRef is required';
			GOTO errorexit;
		END

		IF LEN(@ContractorRef) > 0
			AND (@prevContractorRef <> '' AND @prevContractorRef IS NOT NULL)
			AND (@ContractorRef <> @prevContractorRef)
		BEGIN
			SET @errornumber = '20744';
			SET @errortext = 'ContractorRef has changed';
			GOTO errorexit;
		END

		/* If ContractorRef not passed check for ContractorRef in transfer log */
		IF (@ContractorRef = '' OR @ContractorRef IS NULL) AND (@prevContractorRef <> '' AND @prevContractorRef IS NOT NULL)
		BEGIN
			SET @ContractorRef = @prevContractorRef;
		END
		
		/* If ContractorRef passed for the first time create acceptance text */
		IF LEN(@ContractorRef) > 0 AND (@prevContractorRef = '' OR @prevContractorRef IS NULL)
		BEGIN
			IF LEN(@Text) > 0
			BEGIN
				SET @Text = 'Record ' + LTRIM(RTRIM(STR(@Reference))) + ' accepted with contractor ref ' + @ContractorRef + '. ' + @Text;
			END
			ELSE
			BEGIN
				SET @Text = 'Record ' + LTRIM(RTRIM(STR(@Reference))) + ' accepted with contractor ref ' + @ContractorRef + '.';
			END
		END

		/* Update text */
		IF LEN(@Text) > 0
		BEGIN
			BEGIN TRY
				EXECUTE dbo.cs_wohtxt_updateNotes
					@wo_ref
					,@wo_suffix
					,@user_name
					,'Y'
					,@Text
			END TRY
			BEGIN CATCH
				SET @errornumber = '20731';
				SET @errortext = ERROR_MESSAGE();
				GOTO errorexit;
			END CATCH
		END

		/* Update status */
		IF LEN(@Status) > 0
		BEGIN
			BEGIN TRY
				EXECUTE dbo.cs_woh_updateRecordCore
					@Reference
					,@Status
					,@user_name
					,@wo_ref
					,@wo_suffix
					,@wo_key
					,@wo_h_stat
					,@wo_act_value
			END TRY
			BEGIN CATCH
				SET @errornumber = '20732';
				SET @errortext = ERROR_MESSAGE();
				GOTO errorexit;
			END CATCH
		END

		/* Update transfer log */
		BEGIN TRY
			EXECUTE dbo.csis_itl_updateRecord
				@Reference
				,@ContractorRef
				,NULL
				,NULL
				,0;
		END TRY
		BEGIN CATCH
			SET @errornumber = '20743';
			SET @errortext = ERROR_MESSAGE();
			GOTO errorexit;
		END CATCH
	END

normalexit:
	RETURN 0;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END

GO
