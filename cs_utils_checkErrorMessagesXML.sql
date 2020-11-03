/*****************************************************************************
** dbo.cs_utils_checkErrorMessagesXML
** stored procedure
**
** Description
** Check error message IDs in ErrorMessages.xml file
**
** Parameters
** @xmlMessages = contents of ErrorMessages.xml file
**
** Returned
** Result set of error message records
** ordered by descending count by ID
**
** Notes
** execute dbo.cs_utils_checkErrorMessagesXML
**
** History
** 29/04/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_utils_checkErrorMessagesXML', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_utils_checkErrorMessagesXML;
GO
CREATE PROCEDURE dbo.cs_utils_checkErrorMessagesXML
AS

BEGIN

	DECLARE @xmlMessages xml;

	IF OBJECT_ID('tempdb..#tempMessages') IS NOT NULL
	BEGIN
		DROP TABLE #tempMessages;
	END

	GOTO setting

carryon:

	SELECT
		xmldoc.X.value('ID[1]','integer') AS 'ID'
		,xmldoc.X.value('MessageDetails[1]','varchar(500)') AS 'MessageDetails'
		,xmldoc.X.value('Message[1]','varchar(500)') AS 'Message'
		,xmldoc.X.value('Notes[1]','varchar(500)') AS 'Notes'
		INTO #tempMessages
		FROM @xmlMessages.nodes('/Data/ErrorInfo') AS xmldoc(X);

	SELECT COUNT(*) AS recordcount
		,ID
	FROM #tempMessages
	GROUP BY ID
	ORDER BY recordcount DESC, ID

	GOTO finish

setting:

	SET @xmlMessages = 

'<?xml version="1.0" encoding="utf-8" ?>
<Data xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="ErrorMessages.xsd">
  <ErrorInfo>
    <ID>1</ID>
    <MessageDetails>Technical Message 1</MessageDetails>
    <Message>Friendly Message 1</Message>
    <Notes>Optional notes field 1</Notes>
  </ErrorInfo>
  <!-- 													-->
  <!-- Error Range 1000-3999 Mobile App 				-->
  <!-- 													-->
  
  <!-- 													-->
  <!-- Error Range 4000-9999 WebServices API			-->
  <!-- 													-->
  <ErrorInfo>
    <ID>4000</ID>
    <MessageDetails>(none)</MessageDetails>
    <Message>Web Service ModelState Error - Please contact the system administrator.</Message>
    <Notes>HandleModelStateErrorAttribute.cs : The exact error will be recorded on the log.</Notes>
  </ErrorInfo>
  <ErrorInfo>
    <ID>4010</ID>
    <MessageDetails>Attachment filetype not supported - {0}</MessageDetails>
    <Message>Attachment filetype not supported - {0}</Message>
    <Notes>FileUpload.cs : Filename is substituted into the above.</Notes>
  </ErrorInfo>
  <ErrorInfo>
    <ID>4011</ID>
    <MessageDetails>Attachment filesize exceeds maximum allowed ({0} Kb) - {1}</MessageDetails>
    <Message>Attachment filesize exceeds maximum allowed ({0} Kb) - {1}</Message>
    <Notes>FileUpload.cs : Filename and max file size are substituted into the above.</Notes>
  </ErrorInfo>
  <ErrorInfo>
    <ID>4020</ID>
    <MessageDetails>An error occurred while processing attachments : {0}</MessageDetails>
    <Message>An error occurred while processing attachments : {0}</Message>
    <Notes>FileUpload.cs : The exception message is substituted into the above.</Notes>
  </ErrorInfo>
</Data>'

	GOTO carryon

finish:

END

GO
