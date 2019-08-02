USE [DATABASE NAME HERE !!!]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[RelativeTimeDimension](
	[DateInt] [int] NOT NULL,
	[DateVal] [datetime] NOT NULL,
	[RelativeYear] [varchar](20) NULL,
	[RelativeYr] [varchar](10) NULL,
	[RelativeQuarter] [varchar](20) NULL,
	[RelativeQtr] [varchar](10) NULL,
	[RelativeMonth] [varchar](20) NULL,
	[RelativeMo] [varchar](10) NULL,
	[Rolling6] [bit] NOT NULL,
	[Rolling12] [bit] NOT NULL,
	[Rolling13] [bit] NOT NULL,
	[Rolling18] [bit] NOT NULL,
	[QuarterToDate] [varchar](35) NULL,
	[QtrToDate] [varchar](15) NULL,
	[YearToDate] [varchar](30) NULL,
	[YrToDate] [varchar](10) NULL,
	[RelativeFiscalYear] [varchar](30) NULL,
	[RelativeFiscYr] [varchar](10) NULL,
	[RelativeFiscalQuarter] [varchar](30) NULL,
	[RelativeFiscQtr] [varchar](10) NULL,
	[FiscalYearToDate] [varchar](32) NULL,
	[FiscalYTD] [varchar](10) NULL,
	[AgingBuckets] [varchar](20) NULL,
 CONSTRAINT [PK_RelativeTimeDimension] PRIMARY KEY CLUSTERED 
(
	[DateInt] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[RelativeTimeDimension] ADD CONSTRAINT [DF_RelativeTimeDimension_Rolling6]  DEFAULT ((0)) FOR [Rolling6]
GO
ALTER TABLE [dbo].[RelativeTimeDimension] ADD CONSTRAINT [DF_RelativeTimeDimension_Rolling12]  DEFAULT ((0)) FOR [Rolling12]
GO
ALTER TABLE [dbo].[RelativeTimeDimension] ADD CONSTRAINT [DF_RelativeTimeDimension_Rolling13]  DEFAULT ((0)) FOR [Rolling13]
GO
ALTER TABLE [dbo].[RelativeTimeDimension] ADD CONSTRAINT [DF_RelativeTimeDimension_Rolling18]  DEFAULT ((0)) FOR [Rolling18]
GO

INSERT INTO dbo.RelativeTimeDimension ( DateInt, DateVal ) 
	SELECT TD.DateKey, TD.DateVal FROM dbo.TimeDimension TD

