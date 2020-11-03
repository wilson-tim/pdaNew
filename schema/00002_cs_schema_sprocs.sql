/*****************************************************************************
** dbo.cs_schema_sprocs
** schema change script
**
** Description
** Implements changes to stored procedures
**
** Parameters
**
** Returned
**
** History
** 07/01/2013  TW  New
** 29/01/2013  TW  Revised cs_defi_getDefaultVolume
** 30/01/2013  TW  Revised cs_defp3_getParams, cs_defp4_getParams, cs_defa_checkWorkingDay
** 01/02/2013  TW  Revised cs_defa_getDefaultPointsValueDate, cs_defa_getCorrectByDates
** 17/07/2013  TW  Revised
**
*****************************************************************************/

IF OBJECT_ID (N'dbo.cs_utils_checkServiceType', N'FN') IS NOT NULL
    DROP FUNCTION dbo.cs_utils_checkServiceType;
GO

IF OBJECT_ID (N'dbo.cs_comp_createCustomerCareRecord', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comp_createCustomerCareRecord;
GO

IF OBJECT_ID (N'dbo.cs_comp_getDestSuffix', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comp_getDestSuffix;
GO

IF OBJECT_ID (N'dbo.cs_comp_getWorksOrderTaskDetails', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_comp_getWorksOrderTaskDetails;
GO

IF OBJECT_ID (N'dbo.cs_defi_getDefaultVolume', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_defi_getDefaultVolume;
GO

IF OBJECT_ID (N'dbo.cs_defp3_getParams', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_defp3_getParams;
GO

IF OBJECT_ID (N'dbo.cs_defp4_getParams', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_defp4_getParams;
GO

IF OBJECT_ID (N'dbo.cs_defa_checkWorkingDay', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_defa_checkWorkingDay;
GO

IF OBJECT_ID (N'dbo.cs_defa_getCorrectByDates', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_defa_getCorrectByDates;
GO

IF OBJECT_ID (N'dbo.cs_whiteboarddtl_checkExclusionDay', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_whiteboarddtl_checkExclusionDay;
GO

IF OBJECT_ID (N'dbo.cs_defa_getDefaultPointsValueDate', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_defa_getDefaultPointsValueDate;
GO

IF OBJECT_ID (N'dbo.cs_defa_getCorrectByDates', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_defa_getCorrectByDates;
GO

IF OBJECT_ID (N'dbo.cs_pdalookup_getFaultCodesTable', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_pdalookup_getFaultCodesTable;
GO

IF OBJECT_ID (N'dbo.cs_woh_createRecordCore', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_woh_createRecordCore;
GO

IF OBJECT_ID (N'dbo.cs_utils_getActionsInspList', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_utils_getActionsInspList;
GO

IF OBJECT_ID (N'dbo.cs_utils_testError1', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_utils_testError1;
GO

IF OBJECT_ID (N'dbo.cs_utils_testError2', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_utils_testError2;
GO

IF OBJECT_ID (N'dbo.cs_utils_testError3', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_utils_testError3;
GO

IF OBJECT_ID (N'dbo.cs_utils_testError4', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_utils_testError4;
GO

IF OBJECT_ID (N'dbo.cs_utils_testXmlParam', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_utils_testXmlParam;
GO

IF OBJECT_ID (N'dbo.cs_utils_checkServiceType', N'P') IS NOT NULL
    DROP PROCEDURE dbo.cs_utils_checkServiceType;
GO
