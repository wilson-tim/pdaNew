SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Richard Fisher
-- Create date: 25/02/2013
-- Description:	A user specific view of the 
--              inspections list.
-- =============================================
CREATE PROCEDURE cs_insplist_viewenquiries 
	@UName VARCHAR(15) 
AS
BEGIN
	SET NOCOUNT ON;

	-- TODO: This needs to be changed to be driven from the database
	/*************************************************************************************************/
	DECLARE @InsDef AS BIT 
	DECLARE @InsIsp AS BIT 
	DECLARE @InsSap AS BIT 

	SET @InsDef = 1 
	SET @InsIsp = 1 
	SET @InsSap = 1 

	-- SP functionality
	/*************************************************************************************************/
	DECLARE @Adhoc AS VARCHAR(500) 
	DECLARE @MonSrc AS VARCHAR(500) 
	DECLARE @MonFlt AS VARCHAR(500) 

	SET @Adhoc = (SELECT c_field FROM keys WHERE service_c = 'ALL' AND keyname = 'ADHOC_SAMPLE_FAULT') 
	SET @MonSrc = (SELECT c_field FROM keys WHERE service_c = 'ALL' AND keyname = 'MONITOR_SOURCE') 
	SET @MonFlt = (SELECT c_field FROM keys WHERE service_c = 'ALL' AND keyname = 'MONITOR_FAULT') 

	-- Build complaints list
	SELECT complaint_no, dest_ref, action_flag, item_ref, site_ref, postcode, recvd_by, comp_code, service_c, contract_ref, feature_ref, location_c, date_entered, ent_time_h, ent_time_m, pa_area 
	INTO #CompList
	FROM comp 
	WHERE date_closed IS NULL 
	AND pa_area IS NOT NULL 
	AND pa_area <> '' 
	AND ((action_flag = 'D' AND @InsDef = 1) 
		OR (action_flag = 'I' AND comp_code NOT IN (@MonFlt) AND comp_code <> @Adhoc AND @InsIsp = 1) 
		OR (action_flag = 'P' AND comp_code NOT IN (@MonFlt) AND @InsSap = 1)) 
	ORDER BY complaint_no 
	
	-- Create temporary table 
	CREATE TABLE #InspList (
		complaint_no INT NULL, 
		state VARCHAR(1) NULL, 
		action_flag VARCHAR(2) NULL, 
		action VARCHAR(1) NULL, 
		item_ref VARCHAR(12) NULL, 
		site_ref VARCHAR(16) NULL, 
		postcode VARCHAR(8) NULL, 
		site_name_1 VARCHAR(70) NULL, 
		ward_code VARCHAR(10) NULL, 
		do_date DATETIME NULL, 
		end_time_h VARCHAR(2) NULL, 
		end_time_m VARCHAR(2) NULL, 
		start_time_h VARCHAR(2) NULL, 
		start_time_m VARCHAR(2) NULL, 
		recvd_by VARCHAR(6) NULL, 
		comp_code VARCHAR(6) NULL, 
		user_name VARCHAR(15) NULL, 
		contract_ref VARCHAR(12) NULL, 
		feature_ref VARCHAR(12) NULL, 
		location_c VARCHAR(10) NULL, 
		pa_area VARCHAR(6) NULL, 
		service_c VARCHAR(6) NULL 
	)
	
	-- Declare cursor variables 
	DECLARE @CompNo AS INT 
	DECLARE @DestRef AS INT 
	DECLARE @ActionFlag AS VARCHAR(2) 
	DECLARE @ItemRef AS VARCHAR(12) 
	DECLARE @SiteRef AS VARCHAR(16) 
	DECLARE @PostCode AS VARCHAR(8) 
	DECLARE @RecvdBy AS VARCHAR(6) 
	DECLARE @CompCode AS VARCHAR(6) 
	DECLARE @Srv AS VARCHAR(6) 
	DECLARE @ConRef AS VARCHAR(12) 
	DECLARE @FetRef AS VARCHAR(12) 
	DECLARE @Loc AS VARCHAR(10) 
	DECLARE @DateEnt AS DATETIME 
	DECLARE @EntTimeH AS VARCHAR(2) 
	DECLARE @EntTimeM AS VARCHAR(2) 
	DECLARE @PaArea AS VARCHAR(6) 
	DECLARE @UserName AS VARCHAR(15) 
	DECLARE @LimitListFlag AS VARCHAR(1) 

	-- Declare generic variables
	DECLARE @IgnComp AS BIT 
	DECLARE @InLimitList AS BIT

	-- Loop through users for each area
	DECLARE UserCur INSENSITIVE CURSOR FOR	
		SELECT C.complaint_no, C.dest_ref, C.action_flag, C.item_ref, C.site_ref, C.postcode, C.recvd_by, C.comp_code, C.service_c, C.contract_ref, C.feature_ref, C.location_c, 
			C.date_entered, C.ent_time_h, C.ent_time_m, C.pa_area , U.user_name, U.limit_list_flag 
		FROM #CompList C 
		INNER JOIN patr_area A ON (C.pa_area = A.area_c) 
		INNER JOIN pda_user U ON (A.po_code = U.po_code AND U.user_name = @UName) 
		WHERE A.pa_site_flag = 'P' 
	OPEN UserCur 
	FETCH NEXT FROM UserCur INTO @CompNo, @DestRef, @ActionFlag, @ItemRef, @SiteRef, @PostCode, @RecvdBy, @CompCode, @Srv, @ConRef, @FetRef, @Loc, @DateEnt, @EntTimeH, @EntTimeM, @PaArea, @UserName, @LimitListFlag 
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		-- Process each inspections list line.
		SET @IgnComp = 0 

		IF (@ActionFlag = 'D' OR @ActionFlag = 'I') 
		BEGIN
			IF (@ActionFlag = 'D' AND @DestRef = '') 
				SET @IgnComp = 1 
			ELSE 
			BEGIN 
				SET @InLimitList = 0 
			
				IF (EXISTS(SELECT 1 FROM pda_limit_list WHERE user_name = @UserName AND item_ref = @ItemRef AND comp_code = @CompCode)) 
					SET @InLimitList = 1 

				-- Based on the user limit flag
				IF (@LimitListFlag = 'N') 
				BEGIN 
					IF (@InLimitList = 1) 
						SET @IgnComp = 1 
				END 
				ELSE IF (@LimitListFlag = 'Y') 
				BEGIN 
					IF (@InLimitList = 0) 
						SET @IgnComp = 1 
				END 
			END 
		END 

		IF (@IgnComp = 0) 
		BEGIN
			DECLARE @SiteName AS VARCHAR(70) 
			DECLARE @WardCode AS VARCHAR(10) 

			-- Get site name and ward code
			SELECT @SiteName = site_name_1, @WardCode = ward_code FROM site WHERE site_ref = @SiteRef 

			IF (@ActionFlag = 'D')
			BEGIN
				IF ((SELECT default_status FROM defh WHERE cust_def_no = @DestRef) = 'Y')
				BEGIN
					DECLARE @RecDate AS DATETIME 
					DECLARE @RecTimeH AS VARCHAR(2) 
					DECLARE @RecTimeM AS VARCHAR(2) 

					DECLARE @DAction AS VARCHAR(1) 
					SET @DAction = (SELECT action FROM def_cont_i WHERE cust_def_no = @DestRef) 

					SELECT @RecDate = rectify_date, @RecTimeH = rectify_time_h, @RecTimeM = rectify_time_m 
					FROM defi_rect 
					WHERE default_no = @DestRef 
					AND seq_no = (SELECT MAX(seq_no) FROM defi_rect WHERE default_no = @DestRef) 

					INSERT INTO #InspList (complaint_no, state, action_flag, action, item_ref, site_ref, postcode, site_name_1, ward_code, do_date, end_time_h, end_time_m, 
						start_time_h, start_time_m, recvd_by, comp_code, user_name, service_c, contract_ref, feature_ref, location_c, pa_area) 
					VALUES (@CompNo,'A', @ActionFlag, @DAction, @ItemRef, @SiteRef, @PostCode, @SiteName, @WardCode, @RecDate, @RecTimeH, @RecTimeM, @RecTimeH, @RecTimeM, 
						@RecvdBy, @CompCode, @UserName, @Srv, @ConRef, @FetRef, @Loc, @PaArea) 
				END 
			END
			ELSE IF (@ActionFlag = 'I') 
				INSERT INTO #InspList (complaint_no, state, action_flag, action, item_ref, site_ref, postcode, site_name_1, ward_code, do_date, end_time_h, end_time_m, 
					start_time_h, start_time_m, recvd_by, comp_code, user_name, service_c, contract_ref, feature_ref, location_c, pa_area) 
				VALUES (@CompNo,'A', @ActionFlag, '', @ItemRef, @SiteRef, @PostCode, @SiteName, @WardCode, @DateEnt, @EntTimeH, @EntTimeM, @EntTimeH, @EntTimeM, 
					@RecvdBy, @CompCode, @UserName, @Srv, @ConRef, @FetRef, @Loc, @PaArea) 
			ELSE 
				INSERT INTO #InspList (complaint_no, state, action_flag, action, item_ref, site_ref, postcode, site_name_1, ward_code, do_date, end_time_h, end_time_m, 
					start_time_h, start_time_m, recvd_by, comp_code, user_name, service_c, contract_ref, feature_ref, location_c, pa_area) 
				VALUES (@CompNo,'A', @ActionFlag, '', @ItemRef, @SiteRef, @PostCode, @SiteName, @WardCode, @DateEnt, @EntTimeH, @EntTimeM, @EntTimeH, @EntTimeM, 
					@RecvdBy, @CompCode, @UserName, @Srv, @ConRef, @FetRef, @Loc, @PaArea) 
		END

		FETCH NEXT FROM UserCur INTO @CompNo, @DestRef, @ActionFlag, @ItemRef, @SiteRef, @PostCode, @RecvdBy, @CompCode, @Srv, @ConRef, @FetRef, @Loc, @DateEnt, @EntTimeH, @EntTimeM, @PaArea, @UserName, @LimitListFlag 
	END

	-- Clean up cursor
	CLOSE UserCur 
	DEALLOCATE UserCur 

	-- Return inspection list
	SELECT * 
	FROM #InspList 

	-- Clean up temporary table
	DROP TABLE #InspList 
	DROP TABLE #CompList 
END
GO
