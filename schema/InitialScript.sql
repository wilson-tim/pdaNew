/*****************************************************************************
** dbo.cs_schema_ContenderUpdates
** schema change script
**
** Description
** ContenderUpdates table
**
** Parameters
**
** Returned
**
** History
** 12/05/2013  TW  New
** 15/07/2013  TW  Renamed as InitialScript.sql
**
*****************************************************************************/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID('dbo.ContenderUpdates', 'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[ContenderUpdates](
		[script_seq_no] [int] NOT NULL,
		[script_filename] [varchar](80) NOT NULL,
		[script_description] [varchar](1024) NULL,
		[process_datestamp] [datetime] NOT NULL,
		[process_comments] [varchar](80) NOT NULL
		CONSTRAINT pk_ContenderUpdates PRIMARY KEY ([script_seq_no])
	) ON [PRIMARY]
END
GO

SET ANSI_PADDING OFF
GO
