USE [DATABASE NAME HERE !!!]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_UpdateRelativeTimeDimension] (
    @fy_start_month char(3) = 'JAN'
)
AS
BEGIN
	SET NOCOUNT ON;

	declare @cdate datetime
	declare @cyear int
	declare @cqtr int
	declare @lqtr int
	declare @nqtr int
	declare @cmnth int
	declare @lmnth int
	declare @nmnth int
	declare @cday int

	-- The following are used to populate the 'AgingBuckets' field. If the date is <= @bcktdays# days old it's in that bucket
	-- The values for these buckets can be altered or commented out to suit your needs
	declare @bcktdays1 int
	declare @bcktdays2 int
	declare @bcktdays3 int
	declare @bcktdays4 int
	declare @bcktdays5 int
	declare @bcktdays6 int
	declare @bcktdays7 int

	declare @bckt1str varchar(20)
	declare @bckt2str varchar(20)
	declare @bckt3str varchar(20)
	declare @bckt4str varchar(20)
	declare @bckt5str varchar(20)
	declare @bckt6str varchar(20)
	declare @bckt7str varchar(20)

	set @bcktdays1 = 7
	set @bckt1str = '1 to 7 Days Old'
	set @bcktdays2 = 14
	set @bckt2str = '8 to 14 Days Old'
	set @bcktdays3 = 21
	set @bckt3str = '15 to 21 Days Old'
	set @bcktdays4 = 28
	set @bckt4str = '22 to 28 Days Old'
	set @bcktdays5 = 35
	set @bckt5str = '29 to 35 Days Old'
	set @bcktdays6 = 42
	set @bckt6str = '36 to 42 Days Old'
	set @bcktdays7 = 49
	set @bckt7str = '43 to 49 Days Old'

	set @cdate = GETDATE()								-- Current Date/Time
	set @cyear = YEAR(@cdate)							-- Current Year
	set @cqtr = DATEPART(qq, @cdate)					-- Current Quarter
	set @lqtr = DATEPART(qq, DATEADD(qq, -1, @cdate))	-- Last Quarter
	set @nqtr = DATEPART(qq, DATEADD(qq, 1, @cdate))	-- Next Quarter
	set @cmnth = MONTH(@cdate)							-- Current Month
	set @lmnth = MONTH(DATEADD(month, -1, @cdate))		-- Last Month
	set @nmnth = MONTH(DATEADD(month, 1, @cdate))		-- Next Month
	set @cday = DAY(@cdate)								-- Current Day

	-- The following is used to 'offset' by a number of months for the fiscal year calculations (This assumes the fiscal year starts on the first of a month)
	declare @da_fy_number int
	set @da_fy_number =
		CASE @fy_start_month
			WHEN 'FEB' THEN 11
			WHEN 'MAR' THEN 10
			WHEN 'APR' THEN 9
			WHEN 'MAY' THEN 8
			WHEN 'JUN' THEN 7
			WHEN 'JUL' THEN 6
			WHEN 'AUG' THEN 5
			WHEN 'SEP' THEN 4
			WHEN 'OCT' THEN 3
			WHEN 'NOV' THEN 2
			WHEN 'DEC' THEN 1
			ELSE 0
		END
	-- The following is used to 'offset' by a number of months for the fiscal quarter calculations (This assumes fiscal quarters start on the first of a month)
	declare @da_fq_number int
	set @da_fq_number =
		CASE @fy_start_month
			WHEN 'FEB' THEN -1
			WHEN 'MAR' THEN -2
			WHEN 'MAY' THEN -1
			WHEN 'JUN' THEN -2
			WHEN 'AUG' THEN -1
			WHEN 'SEP' THEN -2
			WHEN 'NOV' THEN -1
			WHEN 'DEC' THEN -2
			ELSE 0
		END

	declare @today_fy_offset datetime
	declare @today_fq_offset datetime
	declare @cfqtr int
	declare @lfqtr int
	declare @nfqtr int

	set @today_fy_offset = DATEADD(mm, @da_fy_number, @cdate)
	set @today_fq_offset = DATEADD(mm, @da_fq_number, @cdate)
	set @cfqtr = DATEPART(qq, @today_fq_offset)
	set @lfqtr = DATEPART(qq, DATEADD(qq, -1, @today_fq_offset))
	set @nfqtr = DATEPART(qq, DATEADD(qq, 1, @today_fq_offset))

UPDATE RelativeTimeDimension
	SET RelativeYear = 
		CASE
			WHEN YEAR(DateVal) = @cyear THEN 'Current Year'
			WHEN YEAR(DateVal) = (@cyear -1) THEN 'Last Year'
			WHEN YEAR(DateVal) = (@cyear +1) THEN 'Next Year'
			WHEN YEAR(DateVal) < (@cyear -1) THEN 'Current Year -' + CAST((@cyear - YEAR(DateVal)) AS VARCHAR(3))
			ELSE 'Current Year +' + CAST((YEAR(DateVal) - @cyear) AS VARCHAR(3))
		END,
	RelativeYr = 
		CASE
			WHEN YEAR(DateVal) = @cyear THEN 'CY'
			WHEN YEAR(DateVal) = (@cyear -1) THEN 'LY'
			WHEN YEAR(DateVal) = (@cyear +1) THEN 'NY'
			WHEN YEAR(DateVal) < (@cyear -1) THEN 'CY -' + CAST((@cyear - YEAR(DateVal)) AS VARCHAR(3))
			ELSE 'CY +' + CAST((YEAR(DateVal) - @cyear) AS VARCHAR(3))
		END,
	RelativeQuarter = 
		CASE
			WHEN YEAR(DateVal) = @cyear AND DATEPART(qq, DateVal) = @cqtr THEN 'Current Quarter'
			WHEN YEAR(DateVal) = YEAR(DATEADD(qq, -1, @cdate)) AND DATEPART(qq, DateVal) = @lqtr THEN 'Last Quarter'
			WHEN YEAR(DateVal) = YEAR(DATEADD(qq, +1, @cdate)) AND DATEPART(qq, DateVal) = @nqtr THEN 'Next Quarter'
			WHEN DateVal < @cdate THEN 'Current Quarter ' + CAST((((@cyear - YEAR(DateVal))*4) + (@cqtr - DATEPART(qq, DateVal)))*-1 AS VARCHAR(4))
			ELSE 'Current Quarter +' + CAST((((@cyear - YEAR(DateVal))*4) + (@cqtr - DATEPART(qq, DateVal)))*-1 AS VARCHAR(3))
		END,
	RelativeQtr = 
		CASE
			WHEN YEAR(DateVal) = @cyear AND DATEPART(qq, DateVal) = @cqtr THEN 'CQ'
			WHEN YEAR(DateVal) = YEAR(DATEADD(qq, -1, @cdate)) AND DATEPART(qq, DateVal) = @lqtr THEN 'LQ'
			WHEN YEAR(DateVal) = YEAR(DATEADD(qq, +1, @cdate)) AND DATEPART(qq, DateVal) = @nqtr THEN 'NQ'
			WHEN DateVal < @cdate THEN 'CQ ' + CAST((((@cyear - YEAR(DateVal))*4) + (@cqtr - DATEPART(qq, DateVal)))*-1 AS VARCHAR(4))
			ELSE 'CQ +' + CAST((((@cyear - YEAR(DateVal))*4) + (@cqtr - DATEPART(qq, DateVal)))*-1 AS VARCHAR(3))
		END,
	QuarterToDate = 
		CASE
			WHEN YEAR(DateVal) = @cyear AND DATEPART(qq, DateVal) = @cqtr AND DateVal <= @cdate THEN 'Current Quarter to Date'
			WHEN YEAR(DateVal) = YEAR(DATEADD(qq, -1, @cdate)) AND DATEPART(qq, DateVal) = @lqtr AND DateVal <= DATEADD(qq, -1, @cdate) THEN 'Last Quarter to Date'
			WHEN YEAR(DateVal) = YEAR(DATEADD(qq, +1, @cdate)) AND DATEPART(qq, DateVal) = @nqtr AND DateVal <= DATEADD(qq, 1, @cdate) THEN 'Next Quarter to Date'
			WHEN DateVal < @cdate AND DATEPART(qq, DateVal) = @cqtr AND (MONTH(DateVal) < @cmnth OR (MONTH(DateVal) = @cmnth AND DAY(DateVal) <= @cday))
				THEN 'Current Quarter to Date -' + CAST((@cyear - YEAR(DateVal)) AS VARCHAR(3)) + ' yrs'
			WHEN DateVal > @cdate AND DATEPART(qq, DateVal) = @cqtr AND (MONTH(DateVal) < @cmnth OR (MONTH(DateVal) = @cmnth AND DAY(DateVal) <= @cday))
				THEN 'Current Quarter to Date +' + CAST((YEAR(DateVal) - @cyear) AS VARCHAR(3)) + ' yrs'
			ELSE null
		END,
	QtrToDate = 
		CASE
			WHEN YEAR(DateVal) = @cyear AND DATEPART(qq, DateVal) = @cqtr AND DateVal <= @cdate THEN 'CQTD'
			WHEN YEAR(DateVal) = YEAR(DATEADD(qq, -1, @cdate)) AND DATEPART(qq, DateVal) = @lqtr AND DateVal <= DATEADD(qq, -1, @cdate) THEN 'LQTD'
			WHEN YEAR(DateVal) = YEAR(DATEADD(qq, +1, @cdate)) AND DATEPART(qq, DateVal) = @nqtr AND DateVal <= DATEADD(qq, 1, @cdate) THEN 'NQTD'
			WHEN DateVal < @cdate AND DATEPART(qq, DateVal) = @cqtr AND (MONTH(DateVal) < @cmnth OR (MONTH(DateVal) = @cmnth AND DAY(DateVal) <= @cday))
				THEN 'CQTD -' + CAST((@cyear - YEAR(DateVal)) AS VARCHAR(3)) + ' yrs'
			WHEN DateVal > @cdate AND DATEPART(qq, DateVal) = @cqtr AND (MONTH(DateVal) < @cmnth OR (MONTH(DateVal) = @cmnth AND DAY(DateVal) <= @cday))
				THEN 'CQTD +' + CAST((YEAR(DateVal) - @cyear) AS VARCHAR(3)) + ' yrs'
			ELSE null
		END,
	RelativeMonth = 
		CASE
			WHEN YEAR(DateVal) = @cyear AND MONTH(DateVal) = @cmnth THEN 'Current Month'
			WHEN YEAR(DateVal) = YEAR(DATEADD(month, -1, @cdate)) AND MONTH(DateVal) = @lmnth THEN 'Last Month'
			WHEN YEAR(DateVal) = YEAR(DATEADD(month, +1, @cdate)) AND MONTH(DateVal) = @nmnth THEN 'Next Month'
			WHEN DateVal < @cdate THEN 'Current Month ' + CAST((((@cyear - YEAR(DateVal))*12) + (@cmnth - MONTH(DateVal)))*-1 AS VARCHAR(5))
			ELSE 'Current Month +' + CAST((((@cyear - YEAR(DateVal))*12) + (@cmnth - MONTH(DateVal)))*-1 AS VARCHAR(4))
		END,
	RelativeMo = 
		CASE
			WHEN YEAR(DateVal) = @cyear AND MONTH(DateVal) = @cmnth THEN 'CM'
			WHEN YEAR(DateVal) = YEAR(DATEADD(month, -1, @cdate)) AND MONTH(DateVal) = @lmnth THEN 'LM'
			WHEN YEAR(DateVal) = YEAR(DATEADD(month, +1, @cdate)) AND MONTH(DateVal) = @nmnth THEN 'NM'
			WHEN DateVal < @cdate THEN 'CM ' + CAST((((@cyear - YEAR(DateVal))*12) + (@cmnth - MONTH(DateVal)))*-1 AS VARCHAR(5))
			ELSE 'CM +' + CAST((((@cyear - YEAR(DateVal))*12) + (@cmnth - MONTH(DateVal)))*-1 AS VARCHAR(4))
		END,
	Rolling6 = 
		CASE
			WHEN (((@cyear - YEAR(DateVal))*12) + (@cmnth - MONTH(DateVal)))*-1 BETWEEN -5 and 0 THEN 1
			ELSE 0
		END,
	Rolling12 = 
		CASE
			WHEN (((@cyear - YEAR(DateVal))*12) + (@cmnth - MONTH(DateVal)))*-1 BETWEEN -11 and 0 THEN 1
			ELSE 0
		END,
	Rolling13 = 
		CASE
			WHEN (((@cyear - YEAR(DateVal))*12) + (@cmnth - MONTH(DateVal)))*-1 BETWEEN -12 and 0 THEN 1
			ELSE 0
		END,
	Rolling18 = 
		CASE
			WHEN (((@cyear - YEAR(DateVal))*12) + (@cmnth - MONTH(DateVal)))*-1 BETWEEN -17 and 0 THEN 1
			ELSE 0
		END,
	YearToDate = 
		CASE
			WHEN YEAR(DateVal) = @cyear AND DateVal <= @cdate THEN 'Current Year to Date'
			WHEN YEAR(DateVal) = (@cyear - 1) AND DateVal <= DATEADD(year, -1, @cdate) THEN 'Last Year to Date'
			WHEN YEAR(DateVal) = (@cyear+1) AND DateVal <= DATEADD(year, 1, @cdate) THEN 'Next Year to Date'
			WHEN DateVal < @cdate and (MONTH(DateVal) < @cmnth OR (MONTH(DateVal) = @cmnth AND DAY(DateVal) <= @cday))
				THEN 'Current Year to Date -' + CAST((@cyear - YEAR(DateVal)) AS VARCHAR(3))
			WHEN DateVal > @cdate and (MONTH(DateVal) < @cmnth OR (MONTH(DateVal) = @cmnth AND DAY(DateVal) <= @cday))
				THEN 'Current Year to Date +' + CAST((YEAR(DateVal) - @cyear) AS VARCHAR(3))
			ELSE null
		END,
	YrToDate = 
		CASE
			WHEN YEAR(DateVal) = @cyear AND DateVal <= @cdate THEN 'CYTD'
			WHEN YEAR(DateVal) = (@cyear - 1) AND DateVal <= DATEADD(year, -1, @cdate) THEN 'LYTD'
			WHEN YEAR(DateVal) = (@cyear+1) AND DateVal <= DATEADD(year, 1, @cdate) THEN 'NYTD'
			WHEN DateVal < @cdate and (MONTH(DateVal) < @cmnth OR (MONTH(DateVal) = @cmnth AND DAY(DateVal) <= @cday))
				THEN 'CYTD -' + CAST((@cyear - YEAR(DateVal)) AS VARCHAR(3))
			WHEN DateVal > @cdate and (MONTH(DateVal) < @cmnth OR (MONTH(DateVal) = @cmnth AND DAY(DateVal) <= @cday))
				THEN 'CYTD +' + CAST((YEAR(DateVal) - @cyear) AS VARCHAR(3))
			ELSE null
		END,
	RelativeFiscalYear = 
		CASE
			WHEN YEAR(DATEADD(mm, @da_fy_number, DateVal)) = YEAR(@today_fy_offset) THEN 'Current Fiscal Year'
			WHEN YEAR(DATEADD(mm, @da_fy_number, DateVal)) = (YEAR(@today_fy_offset) -1) THEN 'Last Fiscal Year'
			WHEN YEAR(DATEADD(mm, @da_fy_number, DateVal)) = (YEAR(@today_fy_offset) +1) THEN 'Next Fiscal Year'
			WHEN YEAR(DATEADD(mm, @da_fy_number, DateVal)) < (YEAR(@today_fy_offset) -1) THEN 'Current Fiscal Year -' + CAST(YEAR(@today_fy_offset) - YEAR(DATEADD(mm, @da_fy_number, DateVal)) AS VARCHAR(3))
			ELSE 'Current Fiscal Year +' + CAST(YEAR(DATEADD(mm, @da_fy_number, DateVal)) - YEAR(@today_fy_offset) AS VARCHAR(3))
		END,
	RelativeFiscYr = 
		CASE
			WHEN YEAR(DATEADD(mm, @da_fy_number, DateVal)) = YEAR(@today_fy_offset) THEN 'CFY'
			WHEN YEAR(DATEADD(mm, @da_fy_number, DateVal)) = (YEAR(@today_fy_offset) -1) THEN 'LFY'
			WHEN YEAR(DATEADD(mm, @da_fy_number, DateVal)) = (YEAR(@today_fy_offset) +1) THEN 'NFY'
			WHEN YEAR(DATEADD(mm, @da_fy_number, DateVal)) < (YEAR(@today_fy_offset) -1) THEN 'CFY -' + CAST(YEAR(@today_fy_offset) - YEAR(DATEADD(mm, @da_fy_number, DateVal)) AS VARCHAR(3))
			ELSE 'CFY +' + CAST(YEAR(DATEADD(mm, @da_fy_number, DateVal)) - YEAR(@today_fy_offset) AS VARCHAR(3))
		END,
	RelativeFiscalQuarter = 
		CASE
			WHEN YEAR(DATEADD(mm, @da_fq_number, DateVal)) = YEAR(@today_fq_offset) AND DATEPART(qq, DATEADD(mm, @da_fq_number, DateVal)) = @cfqtr THEN 'Current Fiscal Quarter'
			WHEN YEAR(DATEADD(mm, @da_fq_number, DateVal)) = YEAR(DATEADD(qq, -1, @today_fq_offset)) AND DATEPART(qq, DATEADD(mm, @da_fq_number, DateVal)) = @lfqtr THEN 'Last Fiscal Quarter'
			WHEN YEAR(DATEADD(mm, @da_fq_number, DateVal)) = YEAR(DATEADD(qq, +1, @today_fq_offset)) AND DATEPART(qq, DATEADD(mm, @da_fq_number, DateVal)) = @nfqtr THEN 'Next Fiscal Quarter'
			WHEN DateVal < @cdate THEN 'Current Fiscal Quarter ' + CAST((((YEAR(@today_fq_offset) - YEAR(DATEADD(mm, @da_fq_number, DateVal)))*4) + (DATEPART(qq, @today_fq_offset) - DATEPART(qq, DATEADD(mm, @da_fq_number, DateVal))))*-1 AS VARCHAR(4))
			ELSE 'Current Fiscal Quarter +' + CAST((((YEAR(@today_fq_offset) - YEAR(DATEADD(mm, @da_fq_number, DateVal)))*4) + (DATEPART(qq, @today_fq_offset) - DATEPART(qq, DATEADD(mm, @da_fq_number, DateVal))))*-1 AS VARCHAR(3))
		END,
	RelativeFiscQtr = 
		CASE
			WHEN YEAR(DATEADD(mm, @da_fq_number, DateVal)) = YEAR(@today_fq_offset) AND DATEPART(qq, DATEADD(mm, @da_fq_number, DateVal)) = @cfqtr THEN 'CFQ'
			WHEN YEAR(DATEADD(mm, @da_fq_number, DateVal)) = YEAR(DATEADD(qq, -1, @today_fq_offset)) AND DATEPART(qq, DATEADD(mm, @da_fq_number, DateVal)) = @lfqtr THEN 'LFQ'
			WHEN YEAR(DATEADD(mm, @da_fq_number, DateVal)) = YEAR(DATEADD(qq, +1, @today_fq_offset)) AND DATEPART(qq, DATEADD(mm, @da_fq_number, DateVal)) = @nfqtr THEN 'NFQ'
			WHEN DateVal < @cdate THEN 'CFQ ' + CAST((((YEAR(@today_fq_offset) - YEAR(DATEADD(mm, @da_fq_number, DateVal)))*4) + (DATEPART(qq, @today_fq_offset) - DATEPART(qq, DATEADD(mm, @da_fq_number, DateVal))))*-1 AS VARCHAR(4))
			ELSE 'CFQ +' + CAST((((YEAR(@today_fq_offset) - YEAR(DATEADD(mm, @da_fq_number, DateVal)))*4) + (DATEPART(qq, @today_fq_offset) - DATEPART(qq, DATEADD(mm, @da_fq_number, DateVal))))*-1 AS VARCHAR(3))
		END,
	FiscalYearToDate = 
		CASE
			WHEN YEAR(DATEADD(mm, @da_fy_number, DateVal)) = YEAR(@today_fy_offset) AND DATEADD(mm, @da_fy_number, DateVal) <= @today_fy_offset THEN 'Current Fiscal Year to Date'
			WHEN YEAR(DATEADD(mm, @da_fy_number, DateVal)) = YEAR(@today_fy_offset)-1 AND DATEADD(mm, @da_fy_number, DateVal) <= DATEADD(year, -1, @today_fy_offset) THEN 'Last Fiscal Year to Date'
			WHEN YEAR(DATEADD(mm, @da_fy_number, DateVal)) = YEAR(@today_fy_offset)+1 AND DATEADD(mm, @da_fy_number, DateVal) <= DATEADD(year, 1, @today_fy_offset) THEN 'Next Fiscal Year to Date'
			WHEN DateVal < @cdate AND (MONTH(DATEADD(mm, @da_fy_number, DateVal)) < MONTH(@today_fy_offset) OR 
					(MONTH(DATEADD(mm, @da_fy_number, DateVal)) = MONTH(@today_fy_offset) AND DAY(DateVal) <= @cday))
				THEN 'Current Fiscal Year to Date -' + CAST(YEAR(@today_fy_offset) - YEAR(DATEADD(mm, @da_fy_number, DateVal)) AS VARCHAR(3))
			WHEN DateVal > @cdate and (MONTH(DATEADD(mm, @da_fy_number, DateVal)) < MONTH(@today_fy_offset) OR 
					(MONTH(DATEADD(mm, @da_fy_number, DateVal)) = MONTH(@today_fy_offset) AND DAY(DateVal) <= @cday))
				THEN 'Current Fiscal Year to Date +' + CAST(YEAR(DATEADD(mm, @da_fy_number, DateVal)) - YEAR(@today_fy_offset) AS VARCHAR(3))
			ELSE null
		END,
	FiscalYTD = 
		CASE
			WHEN YEAR(DATEADD(mm, @da_fy_number, DateVal)) = YEAR(@today_fy_offset) AND DATEADD(mm, @da_fy_number, DateVal) <= @today_fy_offset THEN 'CFYTD'
			WHEN YEAR(DATEADD(mm, @da_fy_number, DateVal)) = YEAR(@today_fy_offset)-1 AND DATEADD(mm, @da_fy_number, DateVal) <= DATEADD(year, -1, @today_fy_offset) THEN 'LFYTD'
			WHEN YEAR(DATEADD(mm, @da_fy_number, DateVal)) = YEAR(@today_fy_offset)+1 AND DATEADD(mm, @da_fy_number, DateVal) <= DATEADD(year, 1, @today_fy_offset) THEN 'NFYTD'
			WHEN DateVal < @cdate AND (MONTH(DATEADD(mm, @da_fy_number, DateVal)) < MONTH(@today_fy_offset) OR 
					(MONTH(DATEADD(mm, @da_fy_number, DateVal)) = MONTH(@today_fy_offset) AND DAY(DateVal) <= @cday))
				THEN 'CFYTD -' + CAST(YEAR(@today_fy_offset) - YEAR(DATEADD(mm, @da_fy_number, DateVal)) AS VARCHAR(3))
			WHEN DateVal > @cdate and (MONTH(DATEADD(mm, @da_fy_number, DateVal)) < MONTH(@today_fy_offset) OR 
					(MONTH(DATEADD(mm, @da_fy_number, DateVal)) = MONTH(@today_fy_offset) AND DAY(DateVal) <= @cday))
				THEN 'CFYTD +' + CAST(YEAR(DATEADD(mm, @da_fy_number, DateVal)) - YEAR(@today_fy_offset) AS VARCHAR(3))
			ELSE null
		END,
	AgingBuckets = 
		CASE
			WHEN DATEDIFF(dd, DateVal, @cdate) BETWEEN 1 AND @bcktdays1 THEN @bckt1str
			WHEN DATEDIFF(dd, DateVal, @cdate) BETWEEN @bcktdays1  AND @bcktdays2 THEN @bckt2str
			WHEN DATEDIFF(dd, DateVal, @cdate) BETWEEN @bcktdays2  AND @bcktdays3 THEN @bckt3str
			WHEN DATEDIFF(dd, DateVal, @cdate) BETWEEN @bcktdays3  AND @bcktdays4 THEN @bckt4str
			WHEN DATEDIFF(dd, DateVal, @cdate) BETWEEN @bcktdays4  AND @bcktdays5 THEN @bckt5str
			WHEN DATEDIFF(dd, DateVal, @cdate) BETWEEN @bcktdays5  AND @bcktdays6 THEN @bckt6str
			WHEN DATEDIFF(dd, DateVal, @cdate) BETWEEN @bcktdays6  AND @bcktdays7 THEN @bckt7str
			ELSE null
		END
END

