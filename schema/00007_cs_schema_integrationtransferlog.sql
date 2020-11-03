/*****************************************************************************
** 00007_cs_schema_integrationtransferlog
** schema change script
**
** Description
** integration_transfer_log table
** Records critical information about complaint data transferred in either direction
** between the Contender database and a 3rd party
**
** Parameters
**
** Returned
**
** History
** 02/08/2013  TW  New
**
*****************************************************************************/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID('dbo.integration_transfer_log', 'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[integration_transfer_log]
		(
		complaint_no int NOT NULL,
		contractor_ref varchar(20) NULL,
		rejected varchar(1) NULL,
		transfer_datetime datetime NULL
		)  ON [PRIMARY]
END
GO

IF EXISTS (SELECT name FROM sys.indexes WHERE name = 'idx_integration_transfer_log1' AND object_id = OBJECT_ID('dbo.integration_transfer_log'))
BEGIN
	DROP INDEX dbo.integration_transfer_log.idx_integration_transfer_log1;
END
GO

CREATE UNIQUE CLUSTERED INDEX [idx_integration_transfer_log1] ON [dbo].[integration_transfer_log]
(
	[complaint_no] ASC,
	[contractor_ref] ASC,
	[rejected] ASC,
	[transfer_datetime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING OFF
GO
