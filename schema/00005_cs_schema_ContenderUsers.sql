/*****************************************************************************
** dbo.cs_schema_ContenderUsers
** schema change script
**
** Description
** ContenderUsers table
**
** Parameters
**
** Returned
**
** History
** 10/05/2013  TW  New
** 11/06/2013  TW  Additional column user_type; drop then create
**
*****************************************************************************/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID('dbo.ContenderUsers', 'U') IS NOT NULL
BEGIN
	DROP TABLE [dbo].[ContenderUsers]
END

CREATE TABLE [dbo].[ContenderUsers](
	[user_id] [int] NOT NULL,
	[user_type] [varchar](12) NOT NULL,
	[user_name] [varchar](8) NOT NULL,
	[login_time] [datetime] NOT NULL,
	CONSTRAINT pk_ContenderUsers PRIMARY KEY ([user_type], [user_id])
) ON [PRIMARY]
GO

SET ANSI_PADDING OFF
GO
