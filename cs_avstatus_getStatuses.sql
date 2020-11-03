/*****************************************************************************
** dbo.cs_avstatus_getStatuses
** stored procedure
**
** Description
** Return a list of permitted AV statuses and associated information
**   for a given complaint number
**
** Parameters
** @complaint_no = complaint number (required if known)
**
** Returned
** Result set of status codes with the following information:
**   code
**   description
**   message         = confirmation message to be displayed if this code is selected
**   next_code_count = count of next statuses if this code is selected
**                     [if 0 and this code is selected can then display a message
**                     e.g. 'There are no further status codes configured']
**   av_docs         = count of documents associated with this code if it is selected
**                     [if > 0 then need to call print, etc. routines]
**   keeper_required = 1 if keeper details required if this code is selected, else 0
**                     [if 1 and this code is selected can then display a message
**                     e.g 'Keeper details are required, no further status codes can be selected']
**   will_close      = 1 if this status will close the enquiry
**   lookup_num      = for internal use
**
** Return value of rowcount (if successful), or -1
**
** Notes
** Following the logic of enhanced AV with controlled status flow
** No patrol officer check (av_status.officer) - assumed to be the logged in mobile user
**
** History
** 18/02/2013  TW  New
** 19/02/2013  TW  Continued
** 27/02/2013  TW  Added will_close column
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_avstatus_getStatuses', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_avstatus_getStatuses;
GO
CREATE PROCEDURE dbo.cs_avstatus_getStatuses
	@complaint_no integer = NULL
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@errornumber varchar(10),
		@rowcount integer,
		@last_status_ref varchar(6),
		@car_id varchar(12),
		@date_closed datetime,
		@action_flag varchar(1),
		@dest_ref integer,
		@dest_suffix varchar(1);

	SET @errornumber = '10500';
	/* Get the last status ref for this customer care record */
	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @last_status_ref = NULL;
	END
	ELSE
	BEGIN
		SET @last_status_ref = LTRIM(RTRIM(dbo.cs_compavhist_getLastStatusRef(@complaint_no)));
	END

	/* Get the car_id for this enquiry */
	SELECT @car_id = car_id
		FROM comp_av
		WHERE complaint_no = @complaint_no;

	/* Get comp details */
	SELECT @date_closed = date_closed,
		@action_flag = action_flag,
		@dest_ref = dest_ref,
		@dest_suffix = dest_suffix
		FROM comp
		WHERE complaint_no = @complaint_no;

	/* First status */
	IF @last_status_ref = '' OR @last_status_ref IS NULL
	BEGIN
		IF UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'AV_TYPE_PROMPT')))) = 'Y'
		BEGIN
			/* Select first statuses from the allk table */
			SELECT
				b.lookup_text AS code,
				a.lookup_text AS [description],
				(dbo.cs_avstatus_getStatusMessage(@complaint_no, av_status.open_yn, av_status.closed_yn, av_status.keeper)) AS message,
				next_code_count =
					/* Keeper details required for this status?  */
					CASE 
						WHEN
							(
							av_status.keeper = 'Y'
							AND @complaint_no IS NOT NULL
							)
						THEN 0
						ELSE
							(SELECT COUNT(*) FROM allk_avstat_link WHERE lookup_code = b.lookup_text)
					END,
				(SELECT COUNT(*) FROM av_docs WHERE av_docs.status_ref = b.lookup_text) AS av_docs,
				status_days_remaining = 
					/* Notice period? */
					CASE
						WHEN av_status.[delay] > 0
						THEN av_status.[delay]
						ELSE 0
					END,
				keeper_required =
					/* Keeper details required for this status?  */
					CASE 
						WHEN
							(
							av_status.keeper = 'Y'
							AND @complaint_no IS NOT NULL
							)
						THEN 1
						ELSE 0
					END,
				will_close = 
					/* Will this status close the enquiry? */
					CASE
						WHEN (av_status.closed_yn = 'Y')
						THEN 1
						ELSE 0
					END,
				a.lookup_num
				FROM allk a
				INNER JOIN allk b
				ON b.lookup_num = a.lookup_num
					AND b.lookup_func = 'AVTP'
					AND b.lookup_code = 'STATUS'
				INNER JOIN av_status
				ON av_status.status_ref = b.lookup_text
				WHERE a.lookup_func = 'AVTP'
					AND	a.lookup_code = 'BTN'
				ORDER BY lookup_num;

				SET @rowcount = @@ROWCOUNT;

				GOTO normalexit;
		END
		ELSE
		BEGIN
			/* Select first statuses that are permitted from 'NONE' */
			SET @last_status_ref = 'NONE';
		END
	END

	/* Select statuses using the allk_avstat_link table */
	SELECT a.next_lookup_code AS code,
		av_status.[description],
		(dbo.cs_avstatus_getStatusMessage(@complaint_no, av_status.open_yn, av_status.closed_yn, av_status.keeper)) AS message,
		next_code_count =
			/* Keeper details required for this status?  */
			CASE 
				WHEN
					(
					av_status.keeper = 'Y'
					AND @complaint_no IS NOT NULL
					)
				THEN 0
				ELSE (SELECT COUNT(*) FROM allk_avstat_link WHERE lookup_code = a.next_lookup_code)
			END,
		(SELECT COUNT(*) FROM av_docs WHERE av_docs.status_ref = av_status.status_ref) AS av_docs,
		status_days_remaining = 
			/* Notice period? */
			CASE
				WHEN av_status.[delay] > 0
				THEN av_status.[delay]
				ELSE 0
			END,
		keeper_required =
			/* Keeper details required for this status?  */
			CASE 
				WHEN
					(
					av_status.keeper = 'Y'
					AND @complaint_no IS NOT NULL
					)
				THEN 1
				ELSE 0
			END,
		will_close = 
			/* Will this status close the enquiry? */
			CASE
				WHEN (av_status.closed_yn = 'Y')
				THEN 1
				ELSE 0
			END,
		NULL AS lookup_num
		FROM allk_avstat_link a
		INNER JOIN av_status
		ON av_status.status_ref = a.next_lookup_code
		WHERE 
			a.lookup_code = @last_status_ref
			AND NOT
				/* Enquiry is closed and not an opening status */
				(
				@date_closed IS NOT NULL
				AND av_status.open_yn <> 'Y'
				)
			AND NOT
				/* Closing status and there is an open works order */
				(
				av_status.closed_yn = 'Y'
				AND @action_flag = 'W' 
				AND EXISTS (SELECT 1 FROM wo_h WHERE wo_ref = @dest_ref AND wo_h.wo_suffix = @dest_suffix AND wo_h.wo_paycl_dte IS NULL)
				)
			AND NOT
				/* Opening status and there is a closed works order */
				(
				av_status.open_yn = 'Y'
				AND @action_flag = 'W' 
				AND EXISTS (SELECT 1 FROM wo_h WHERE wo_ref = @dest_ref AND wo_h.wo_suffix = @dest_suffix AND wo_h.wo_paycl_dte IS NOT NULL)
				)
			AND NOT
				/* There is already an enquiry open for this vehicle */
				(
				av_status.open_yn = 'Y'
				AND
				@car_id IS NOT NULL
				AND
				(@car_id NOT IN ('UNKNOWN','NOPLATES','NO PLATES'))
				AND EXISTS
				(SELECT 1
					FROM comp_av, comp innercomp
					WHERE car_id = @car_id
						AND comp_av.complaint_no = innercomp.complaint_no
						AND comp_av.complaint_no <> @complaint_no)
				)
		ORDER BY a.next_lookup_code;

	SET @rowcount = @@ROWCOUNT;

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO 
