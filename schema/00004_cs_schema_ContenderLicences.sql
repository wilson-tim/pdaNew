/*****************************************************************************
** dbo.cs_schema_ContenderLicences
** schema change script
**
** Description
** ContenderLicences table
**
** Parameters
**
** Returned
**
** History
** 10/05/2013  TW  New
**
*****************************************************************************/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID('dbo.ContenderLicences', 'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[ContenderLicences](
		[module] [varchar](12) NOT NULL,
		[user_type] [varchar](12) NOT NULL,
		[description] [varchar](200) NOT NULL,
		[expiry_date] [datetime] NULL,
		[max_users] [int] NULL,
		[token] [varchar](32) NOT NULL,
		[licence] [varbinary](1000) NOT NULL,
		CONSTRAINT pk_ContenderLicences PRIMARY KEY ([module], [user_type])
	) ON [PRIMARY]
END
GO

SET ANSI_PADDING OFF
GO
