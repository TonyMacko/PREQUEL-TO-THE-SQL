USE [DATABASE NAME HERE !!!]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[TimeDimension](
	[DateKey] [int] NOT NULL,
	[DateVal] [datetime] NOT NULL,
	[YearKey] [int] NOT NULL,
	[YearStr] [char](4) NOT NULL,
	[QtrKey] [int] NOT NULL,
	[QtrInt] [int] NOT NULL,
	[QtrStr] [char](2) NOT NULL,
	[YearQtr] [char](7) NOT NULL,
	[QtrYear] [char](7) NOT NULL,
	[MonthKey] [int] NOT NULL,
	[MonthInt] [int] NOT NULL,
	[MonthStrLong] [varchar](9) NOT NULL,
	[MonthStrShort] [char](3) NOT NULL,
	[YearMon] [char](8) NOT NULL,
	[YearMonth] [char](14) NOT NULL,
	[MonYear] [char](8) NOT NULL,
	[MonthYear] [char](14) NOT NULL,
	[DaysInMonth] [int] NOT NULL,
	[DayInt] [int] NOT NULL,
	[WeekDayInt] [int] NOT NULL,
	[WeekDayStr] [varchar](9) NOT NULL,
	[MonthFirst] [datetime] NOT NULL,
	[MonthLast] [datetime] NOT NULL,
 CONSTRAINT [PK_TimeDimension] PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO