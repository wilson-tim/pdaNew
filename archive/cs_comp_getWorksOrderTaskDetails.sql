/*****************************************************************************
** dbo.cs_comp_getWorksOrderTaskDetails
** stored procedure
**
** Description
** Selection of customer care works order task data for a specified complaint_no
**   for use with an inspection list works order item
**
** Parameters
** @complaint_no = complaint number
** @xmlWoi = works order item XML structure (output)
**
** Returned
** Result set of customer care works order task data
** Return value of rowcount (should be 1) if successful, otherwise -1
**
** Notes
**
** History
** 30/05/2013  TW  New
** 04/06/2013  TW  Revised to return an XML structure
**
*****************************************************************************/
IF OBJECT_ID (N'dbo.cs_comp_getWorksOrderTaskDetails', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comp_getWorksOrderTaskDetails;
GO
CREATE PROCEDURE dbo.cs_comp_getWorksOrderTaskDetails
	@pcomplaint_no integer
	,@xmlWoi xml OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @rowcount integer
		,@errortext varchar(500)
		,@errornumber varchar(10)
		,@complaint_no integer;

	SET @errornumber = '20498';

	SET @complaint_no = @pcomplaint_no;

	IF @complaint_no = 0 OR @complaint_no IS NULL
	BEGIN
		SET @errornumber = '20499';
		SET @errortext = 'complaint_no is required';
		GOTO errorexit;
	END

	IF OBJECT_ID('tempdb..#tempWoi') IS NOT NULL
	BEGIN
		DROP TABLE #tempWoi;
	END
	SELECT xmldoc.woi.value('woi_serial_no[1]','integer') AS 'woi_serial_no'
		,xmldoc.woi.value('wo_ref[1]','integer') AS 'wo_ref'
		,xmldoc.woi.value('wo_suffix[1]','varchar(6)') AS 'wo_suffix'
		,xmldoc.woi.value('woi_no[1]','integer') AS 'woi_no'
		,xmldoc.woi.value('woi_site_ref[1]','varchar(16)') AS 'woi_site_ref'
		,xmldoc.woi.value('woi_task_ref[1]','varchar(12)') AS 'woi_task_ref'
		,xmldoc.woi.value('woi_feature_ref[1]','varchar(12)') AS 'woi_feature_ref'
		,xmldoc.woi.value('woi_item_ref[1]','varchar(12)') AS 'woi_item_ref'
		,xmldoc.woi.value('woi_volume[1]','decimal(11,3)') AS 'woi_volume'
		,xmldoc.woi.value('woi_item_price[1]','decimal(15,8)') AS 'woi_item_price'
		,xmldoc.woi.value('woi_line_total[1]','decimal(11,2)') AS 'woi_line_total'
		,xmldoc.woi.value('woi_comp_date[1]','datetime') AS 'woi_comp_date'
		,xmldoc.woi.value('woi_act_comp[1]','datetime') AS 'woi_act_comp'
		,xmldoc.woi.value('woi_text_flag[1]','varchar(1)') AS 'woi_text_flag'
		,xmldoc.woi.value('del_build_no[1]','varchar(14)') AS 'del_build_no'
		,xmldoc.woi.value('del_build_name[1]','varchar(60)') AS 'del_build_name'
		,xmldoc.woi.value('del_addr1[1]','varchar(100)') AS 'del_addr1'
		,xmldoc.woi.value('del_addr2[1]','varchar(100)') AS 'del_addr2'
		,xmldoc.woi.value('allocation_ref[1]','varchar(20)') AS 'allocation_ref'
		,xmldoc.woi.value('payment_f[1]','varchar(1)') AS 'payment_f'
		,xmldoc.woi.value('woi_act_vol[1]','decimal(11,3)') AS 'woi_act_vol'
		,xmldoc.woi.value('woi_act_price[1]','decimal(13,4)') AS 'woi_act_price'
		,xmldoc.woi.value('woi_act_line_total[1]','decimal(13,4)') AS 'woi_act_line_total'
		,xmldoc.woi.value('blank1[1]','varchar(6)') AS 'blank1'
		,xmldoc.woi.value('blank2[1]','varchar(6)') AS 'blank2'
		,xmldoc.woi.value('woi_buy_price[1]','decimal(15,8)') AS 'woi_buy_price'
		,xmldoc.woi.value('woi_buy_value[1]','decimal(11,2)') AS 'woi_buy_value'
		,xmldoc.woi.value('task_desc[1]','varchar(40)') AS 'task_desc'
		,xmldoc.woi.value('task_rate[1]','decimal(16,8)') AS 'task_rate'
		,xmldoc.woi.value('unit_of_measure[1]','integer') AS 'unit_of_measure'
	INTO #tempWoi
	FROM @xmlwoi.nodes('/ArrayOfWorksOrderCoreIDTO/WorksOrderCoreIDTO') AS xmldoc(woi);

	BEGIN TRY
		INSERT INTO #tempWoi
			(
			woi_serial_no
			,wo_ref
			,wo_suffix
			,woi_no
			,woi_task_ref
			,task_desc
			,woi_volume
			,task_rate
			,unit_of_measure
			,woi_comp_date
			)
			SELECT
				wo_i.woi_serial_no
				,comp.dest_ref
				,comp.dest_suffix
				,woi_no
				,wo_i.woi_task_ref
				,task.task_desc
				,wo_i.woi_volume
				,(SELECT task_rate
					FROM ta_r
					WHERE task_ref = wo_i.woi_task_ref
						AND contract_ref = wo_h.contract_ref
						AND rate_band_code = 'BUY'
						AND cont_cycle_no = c_da.cont_cycle_no
						AND start_date =
							(
							SELECT MAX(start_date)
								FROM ta_r
								WHERE task_ref = wo_i.woi_task_ref
									AND contract_ref = wo_h.contract_ref
									AND rate_band_code = 'BUY'
									AND cont_cycle_no = c_da.cont_cycle_no
									AND start_date < GETDATE())
							) AS task_rate
				,task.unit_of_meas AS unit_of_measure
				,wo_i.woi_comp_date
				FROM comp
				INNER JOIN wo_h
				ON wo_h.wo_ref = comp.dest_ref
					AND wo_h.wo_suffix = comp.dest_suffix
				INNER JOIN wo_i
				ON wo_i.wo_ref = comp.dest_ref
					AND wo_i.wo_suffix = comp.dest_suffix
				INNER JOIN task
				ON task.task_ref = wo_i.woi_task_ref
				INNER JOIN c_da
				ON c_da.contract_ref = wo_h.contract_ref
					AND period_start <= GETDATE()
					AND period_finish >= GETDATE()
				WHERE complaint_no = @complaint_no;
	END TRY
	BEGIN CATCH
		SET @errornumber = '20574';
		SET @errortext = 'Error inserting #tempWoi record(s)';
		GOTO errorexit;
	END CATCH

	SELECT @rowcount = COUNT(*)
		FROM #tempWoi;

	BEGIN TRY
		SET @xmlWoi = (SELECT * FROM #tempWoi FOR XML PATH('WorksOrderCoreIDTO'), ROOT('ArrayOfWorksOrderCoreIDTO'));
	END TRY
	BEGIN CATCH
		SET @errornumber = '20575';
		SET @errortext = 'Error updating @xmlWoi';
		GOTO errorexit;
	END CATCH

normalexit:
	RETURN @rowcount;

errorexit:
	SET @errortext = '[' + @errornumber + '][' + OBJECT_NAME(@@PROCID) + '] ' + @errortext;
	RAISERROR(@errortext, 16, 9);
	RETURN -1;

END
GO
