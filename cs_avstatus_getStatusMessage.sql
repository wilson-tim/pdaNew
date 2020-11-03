/*****************************************************************************
** dbo.cs_avstatus_getStatusMessage
** user defined function
**
** Description
** <description>
**
** Parameters
** <parameters>
**
** Returned
** Status message
**
** History
** 19/02/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_avstatus_getStatusMessage', N'FN') IS NOT NULL
    DROP FUNCTION dbo.cs_avstatus_getStatusMessage;
GO
CREATE FUNCTION dbo.cs_avstatus_getStatusMessage
(
	@complaint_no integer,
	@open_yn varchar(1),
	@closed_yn varchar(1),
	@keeper varchar(1)
)
RETURNS varchar(80)
AS
BEGIN

	DECLARE @message varchar(80),
		@date_closed datetime,
		@action_flag varchar(2),
		@comp_record_title varchar(500);

	SET @message = NULL;

	IF @complaint_no IS NOT NULL
	BEGIN
		SELECT @action_flag = action_flag,
			@date_closed = date_closed
			FROM comp
			WHERE complaint_no = @complaint_no;

		IF @@ROWCOUNT = 1
		BEGIN
			SET @comp_record_title = LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'COMP_RECORD_TITLE')));

			IF @closed_yn = 'Y'
			BEGIN
				IF @date_closed IS NOT NULL
				BEGIN
					SET @message = 'The ' + @comp_record_title + ' is already CLOSED';
 				END
				IF @action_flag = 'I'
				BEGIN
					SET @message = 'Please check that the Inspection is completed';
				END
			END
			IF @open_yn = 'Y'
			BEGIN
				IF @date_closed IS NULL
				BEGIN
					SET @message = 'The ' + @comp_record_title + ' is already OPEN';
				END
			END
		END
	END

	RETURN (@message);

END
GO 
