USE [DATABASE NAME HERE !!!]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_PopulateTimeDimension]
AS
BEGIN
	SET NOCOUNT ON;

	declare @firstdate datetime
	declare @lastdate datetime
	-- Define the First and Last dates you would like to see in your Time Dimension below
	set @firstdate = '1980-01-01'
	set @lastdate = '2020-12-31'

	declare @quarter int
	declare @monthlong varchar(9)
	declare @firstday datetime
	declare @lastday datetime
	declare @weekday int
	declare @dayofweek varchar(9)

	WHILE @firstdate <= @lastdate
	BEGIN
		set @quarter = case month ( @firstdate )
				when 1 then 1
				when 2 then 1
				when 3 then 1
				when 4 then 2
				when 5 then 2
				when 6 then 2
				when 7 then 3
				when 8 then 3
				when 9 then 3
				else 4
			end
		set @monthlong = case month ( @firstdate )
				when 1 then 'January'
				when 2 then 'February'
				when 3 then 'March'
				when 4 then 'April'
				when 5 then 'May'
				when 6 then 'June'
				when 7 then 'July'
				when 8 then 'August'
				when 9 then 'September'
				when 10 then 'October'
				when 11 then 'November'
				else 'December'
			end

		set @firstday = cast( cast ( year ( @firstdate ) as char(4) ) + '/' + cast ( month ( @firstdate ) as char(2) ) + '/01' as datetime)
		set @lastday = dateadd ( d , -1 , dateadd ( m , 1, @firstday ) )
		set @weekday = datepart ( dw , @firstdate )
		set @dayofweek = case @weekday
				when 1 then 'Sunday'
				when 2 then 'Monday'
				when 3 then 'Tuesday'
				when 4 then 'Wednesday'
				when 5 then 'Thursday'
				when 6 then 'Friday'
				else 'Saturday'
			end

		INSERT INTO [TimeDimension]
				( [DateKey], [DateVal], [YearKey], [YearStr], [QtrKey], [QtrInt], [QtrStr], [YearQtr], [QtrYear], [MonthKey], [MonthInt], 
				[MonthStrLong], [MonthStrShort], [YearMon], [YearMonth], [MonYear], [MonthYear], [DaysInMonth], [DayInt], [WeekDayInt], 
				[WeekDayStr], [MonthFirst], [MonthLast] )
			VALUES
				( ( year ( @firstdate ) * 10000 ) + month ( @firstdate ) * 100 + day ( @firstdate )
				, @firstdate
				, year ( @firstdate )
				, cast ( year ( @firstdate ) as char(4) )
				, ( year ( @firstdate ) * 10 ) + @quarter
				, @quarter
				, 'Q' + cast ( @quarter as char(1) )
				, cast ( year ( @firstdate ) as char(4) ) + '-Q' + cast ( @quarter as char(1) )
				, 'Q' + cast ( @quarter as char(1) ) + '-' + cast ( year ( @firstdate ) as char(4) )
				, ( year ( @firstdate ) * 100 ) + month ( @firstdate ) 
				, month ( @firstdate ) 
				, @monthlong
				, left ( @monthlong , 3 )
				, cast ( year ( @firstdate ) as char(4) ) + '/' + left ( @monthlong , 3 )
				, cast ( year ( @firstdate ) as char(4) ) + '/' + @monthlong
				, left ( @monthlong , 3 ) + '/' + cast ( year ( @firstdate ) as char(4) )
				, @monthlong + '/' + cast ( year ( @firstdate ) as char(4) )
				, day ( @lastday )
				, day ( @firstdate )
				, @weekday
				, @dayofweek
				, @firstday
				, @lastday )

		set @firstdate = dateadd ( d , 1 , @firstdate )
	END
END

