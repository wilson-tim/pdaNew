/*****************************************************************************
** dbo.cs_avstatus_validateNextStatus
** stored procedure
**
** Description
** Validate new Abandoned Vehicle status
**
** Parameters
** @complaint_no    = complaint number
** @next_status_ref = next (new) status
**
** Returned
** Return value of 1 (if successful), or 0
**
** Notes
**
** History
** 26/02/2013  TW  New
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_avstatus_validateNextStatus', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_avstatus_validateNextStatus;
GO
CREATE PROCEDURE dbo.cs_avstatus_validateNextStatus
	@complaint_no integer,
	@next_status_ref varchar(6)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @errortext varchar(500),
		@rowcount integer,
		@prev_status_ref varchar(6),
		@car_id varchar(12),
		@date_closed datetime,
		@action_flag varchar(1),
		@dest_ref integer,
		@dest_suffix varchar(1);

	/* Get the last status ref for this customer care record */
	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @prev_status_ref = NULL;
	END
	ELSE
	BEGIN
		SET @prev_status_ref = LTRIM(RTRIM(dbo.cs_compavhist_getLastStatusRef(@complaint_no)));
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
	IF @prev_status_ref = '' OR @prev_status_ref IS NULL
	BEGIN
		IF UPPER(LTRIM(RTRIM(dbo.cs_keys_getCField('ALL', 'AV_TYPE_PROMPT')))) = 'Y'
		BEGIN
			/* Select first statuses from the allk table */
			SELECT b.lookup_text
				FROM allk a
				INNER JOIN allk b
				ON b.lookup_num = a.lookup_num
					AND b.lookup_func = 'AVTP'
					AND b.lookup_code = 'STATUS'
				WHERE a.lookup_func = 'AVTP'
					AND	a.lookup_code = 'BTN'
					AND b.lookup_text = @next_status_ref;

				SET @rowcount = @@ROWCOUNT;

				GOTO finish;
		END
		ELSE
		BEGIN
			/* Select first statuses that are permitted from 'NONE' */
			SET @prev_status_ref = 'NONE';
		END
	END

	/* Select statuses using the allk_avstat_link table */
	SELECT a.next_lookup_code
		FROM allk_avstat_link a
		INNER JOIN av_status
		ON av_status.status_ref = a.next_lookup_code
		WHERE 
			a.lookup_code = @prev_status_ref
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
			AND a.next_lookup_code = @next_status_ref;

	SET @rowcount = @@ROWCOUNT;

finish:

	IF @rowcount = 1
	BEGIN
		RETURN 1;
	END
	ELSE
	BEGIN
		RETURN 0;
	END

END
GO 
