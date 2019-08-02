/****** Script for SelectTopNRows command from SSMS  ******/
SELECT 
       
	   UPPER(CC.[customText1])				[CLIENT_ID],
	   businessSectorList					[BUSINESS_SECTOR],
       UPPER(customText6)					[ABC_MEMBER],
	   LTRIM(RTRIM(UPPER(customText11)))	[DUNS],
	   UPPER(customText15)					[LEAD_SOURCE],
	   notes								[COMPANY_STRUCTURE]

  FROM [BULLHORNDM].[dbo].[ClientCorporation]CC 
       
  where len(CC.customText1) >5

