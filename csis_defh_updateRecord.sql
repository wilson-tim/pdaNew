/*****************************************************************************
** dbo.csis_defh_updateRecord
** stored procedure
**
** Description
** Acknowledge / Update rectification record
**
** Parameters
** @user_name = user login id
** @xmlISRectifications = rectification data in XML format
**
** Returned
** Return value 0 (success), otherwise -1 (failure)
**
** History
** 07/08/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.csis_defh_updateRecord', N'P') IS NOT NULL
    DROP PROCEDURE dbo.csis_defh_updateRecord;
GO
CREATE PROCEDURE [dbo].[csis_defh_updateRecord]
                @puser_name varchar(8)
                ,@ISRectificationResponseXML xml
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
                                ,@cust_def_no integer
                                ,@prevContractorRef varchar(20)
                                ,@item_ref varchar(12)
                                ,@feature_ref varchar(12)
                                ,@level integer
                                ,@occ integer
                                ,@points decimal(10,2)
                                ,@value decimal(10,2)
                                ,@rectify_date datetime
                                ,@UnjustifiedReason varchar(6)
                                ,@CompletionDate datetime
                                ,@numberstrth varchar(2)
                                ,@numberstrtm varchar(2)
                                ,@numberstrch varchar(2)
                                ,@numberstrcm varchar(2)
                                ,@datestamp_date datetime
                                ;

                SET @user_name = LTRIM(RTRIM(@puser_name));

                /* @user_name validation */
                IF @user_name = '' OR @user_name IS NULL
                BEGIN
                                SET @errornumber = '20751';
                                SET @errortext = 'user_name is required';
                                GOTO errorexit;
                END

                /* Parse xml data string */
                IF OBJECT_ID('tempdb..#tempDefhResponse') IS NOT NULL
                BEGIN
                                DROP TABLE #tempDefhResponse;
                END

                BEGIN TRY
                                SELECT
                                                xmldoc.defhresponse.value('Reference[1]','integer') AS 'Reference'
                                                ,xmldoc.defhresponse.value('ContractorRef[1]','varchar(20)') AS 'ContractorRef'
                                                ,xmldoc.defhresponse.value('Rejected[1]','varchar(1)') AS 'Rejected'
                                                ,xmldoc.defhresponse.value('Status[1]','varchar(3)') AS 'Status'
                                                ,xmldoc.defhresponse.value('UnjustifiedReason[1]','varchar(6)') AS 'UnjustifiedReason'
                                                ,xmldoc.defhresponse.value('CompletionDate[1]','datetime') AS 'CompletionDate'
                                                ,xmldoc.defhresponse.value('Text[1]','varchar(MAX)') AS 'Text'
                                INTO #tempDefhResponse
                                FROM @ISRectificationResponseXML.nodes('/ISRectificationResponse') AS xmldoc(defhresponse);

                                SELECT
                                                @Reference                                      = Reference
                                                ,@ContractorRef                              = LTRIM(RTRIM(ContractorRef))
                                                ,@Rejected                                        = LTRIM(RTRIM(Rejected))
                                                ,@Status                                              = LTRIM(RTRIM([Status]))
                                                ,@UnjustifiedReason = LTRIM(RTRIM([UnjustifiedReason]))
                                                ,@CompletionDate         = LTRIM(RTRIM([CompletionDate]))
                                                ,@Text                                                 = LTRIM(RTRIM([Text]))
                                FROM #tempDefhResponse;

                                SET @rowcount = @@ROWCOUNT;
                END TRY
                BEGIN CATCH
                                SET @errornumber = '20752';
                                SET @errortext = 'Error processing @ISRectificationResponseXML';
                                GOTO errorexit;
                END CATCH

                IF @rowcount > 1
                BEGIN
                                SET @errornumber = '20753';
                                SET @errortext = 'Error processing @ISRectificationResponseXML - too many rows';
                                GOTO errorexit;
                END
                IF @rowcount < 1
                BEGIN
                                SET @errornumber = '20754';
                                SET @errortext = 'Error processing @ISRectificationResponseXML - no rows found';
                                GOTO errorexit;
                END

                if LEN(@status)>0
                BEGIN
                                IF (@status<>'A' AND @status<>'N' AND @status<>'V' AND @status<>'U')
                                BEGIN
                                SET @errornumber = '20766';
                                SET @errortext = 'Invalid status flag';
                                GOTO errorexit;
                                END
                END

                IF @Reference = 0 or @Reference IS NULL
                BEGIN
                                SET @errornumber = '20755';
                                SET @errortext = 'Reference is required';
                                GOTO errorexit;
                END
                SELECT @rowcount = COUNT(*)
                                FROM comp
                                WHERE complaint_no = @Reference;
                IF @rowcount <> 1
                BEGIN
                                SET @errornumber = '20764';
                                SET @errortext = LTRIM(RTRIM(STR(@Reference))) + ' is not a valid complaint reference';
                                GOTO errorexit;
                END

                SELECT
                                @cust_def_no = dest_ref,
                                @item_ref = item_ref,
                                @feature_ref = feature_ref
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
                                                EXECUTE dbo.cs_definb_updateNotes
                                                                @cust_def_no
                                                                ,@item_ref
                                                                ,@feature_ref
                                                                ,@user_name
                                                                ,'Y'
                                                                ,@Text
                                END TRY
                                BEGIN CATCH
                                                SET @errornumber = '20756';
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
                                                SET @errornumber = '20757';
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
                                                SET @errornumber = '20758';
                                                SET @errortext = 'ContractorRef is required';
                                                GOTO errorexit;
                                END

                                IF LEN(@ContractorRef) > 0
                                                AND (@prevContractorRef <> '' AND @prevContractorRef IS NOT NULL)
                                                AND (@ContractorRef <> @prevContractorRef)
                                BEGIN
                                                SET @errornumber = '20759';
                                                SET @errortext = 'ContractorRef has changed';
                                                GOTO errorexit;
                                END

                                IF LEN(@Status) > 0
                                BEGIN
                                                SELECT
                                                                @level   = default_level
                                                                ,@occ    = default_occ
                                                                ,@points = points
                                                                ,@value  = value
                                                                FROM deft
                                                                WHERE default_no = @cust_def_no;
                                                IF @@ROWCOUNT = 0
                                                BEGIN
                                                                SET @errornumber = '20765';
                                                                SET @errortext = 'deft record not found';
                                                                GOTO errorexit;
                                                END
                                END

                                SELECT
                                                @rectify_date =
                                                                (DATEADD(minute, CAST(ISNULL(rectify_time_m, 0) AS integer),
                                                                                                DATEADD(hour,   CAST(ISNULL(rectify_time_h, 0) AS integer),
                                                                                                DATEADD(day,    DATEPART(day,   rectify_date) - 1, 
                                                                                                DATEADD(month,  DATEPART(month, rectify_date) - 1, 
                                                                                                DATEADD(year,   DATEPART(year,  rectify_date) - 1900, 0))))))
                                                FROM defi_rect
                                                WHERE default_no = @cust_def_no;

                                /* If CompletionDate not passed use now */
                                IF (@CompletionDate IS NULL)
                                BEGIN
                                                SET @CompletionDate = GETDATE();
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
                                                                EXECUTE dbo.cs_definb_updateNotes
                                                                                @cust_def_no
                                                                                ,@item_ref
                                                                                ,@feature_ref
                                                                                ,@user_name
                                                                                ,'Y'
                                                                                ,@Text
                                                END TRY
                                                BEGIN CATCH
                                                                SET @errornumber = '20760';
                                                                SET @errortext = ERROR_MESSAGE();
                                                                GOTO errorexit;
                                                END CATCH
                                END

                                /* Update status */
                                IF LEN(@Status) > 0
                                BEGIN
                                                BEGIN TRY
                                                                SET @datestamp_date = GETDATE();
                                                                SET @numberstrth = DATENAME(hour, @datestamp_date);
                                                                SET @numberstrtm = DATENAME(minute, @datestamp_date);
                                                                SET @numberstrch = DATENAME(hour, @CompletionDate);
                                                                SET @numberstrcm = DATENAME(minute, @CompletionDate);
                                                                UPDATE def_cont_i 
                                                                                SET compl_by = @user_name, 
                                                                                                [Action] = @Status, 
                                                                                                unjust_reason = @UnjustifiedReason,
                                                                                                date_actioned = CONVERT(datetime, CONVERT(date, GETDATE())),
                                                                                                /*
                                                                                                time_actioned_h = FORMAT(GETDATE(),'HH'),
                                                                                                time_actioned_m = FORMAT(GETDATE(),'mm'),
                                                                                                completion_time_h = FORMAT(@CompletionDate,'HH'),
                                                                                                completion_time_m = FORMAT(@CompletionDate,'mm')
                                                                                                */
                                                                                                time_actioned_h = STUFF(@numberstrth, 1, 0, REPLICATE('0', 2 - LEN(@numberstrth))),
                                                                                                time_actioned_m = STUFF(@numberstrtm, 1, 0, REPLICATE('0', 2 - LEN(@numberstrtm))),
                                                                                                completion_date = CONVERT(datetime, CONVERT(date, @CompletionDate)),
                                                                                                completion_time_h = STUFF(@numberstrcm, 1, 0, REPLICATE('0', 2 - LEN(@numberstrcm))),
                                                                                                completion_time_m = STUFF(@numberstrcm, 1, 0, REPLICATE('0', 2 - LEN(@numberstrcm)))
                                                                                WHERE cust_def_no=@cust_def_no

/*                                                           EXECUTE dbo.cs_defh_updateRecordCore
                                                                                @Reference
                                                                                ,@Status
                                                                                ,@level
                                                                                ,@occ
                                                                                ,@points
                                                                                ,@value
                                                                                ,@rectify_date
                                                                                ,@user_name
                                                                                ,NULL
                                                                                ,NULL
                                                                                ,NULL
                                                                                ,NULL
                                                                                ,NULL
*/
                                                END TRY
                                                BEGIN CATCH
                                                                SET @errornumber = '20761';
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
                                                SET @errornumber = '20762';
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
