SELECT 
      [userID]						[LEAD_ID]
      ,CU.customText1				[EMPLOYEE_ID]
	  ,UPPER(CC.[customText1])		[CLIENT_ID]
	  ,upper([businessSectorList])	[CLIENT_SECTOR]	
      ,UPPER([action]) as			[ACTION]
      ,CONVERT(varchar,(note.[dateAdded]),101) as				[ACTION_DATE]
	  ,UPPER([trackTitle])			[TYPE]
      ,CONVERT(varchar,(cc.[dateLastModified]),101) as				[DATE_UPDATED]
      ,cc.[notes]					    [COMPANY_TYPE]
	  ,cc.[status]                      [STATUS]
	 ,count(distinct note.noteid)							[COUNT]
	 --,1 [COUNT]

  FROM [BULLHORNDM].[dbo].[Note] Note
  Left JOIN [BULLHORNDM].[dbo].[NoteEntity] NE on Note.noteID = NE.noteID
  Left JOIN [BULLHORNDM].[dbo].[CorporateUser] CU on Note.[commentingPersonID] = CU.[userID]
  Left JOIN [BULLHORNDM].[dbo].[ClientCorporation]CC on note.personReferenceID = cc.clientCorporationID
       
  where len(CU.customText1) >1
        AND cc.customText10 = 'Bx Priority Leads'
		AND cast(note.[dateAdded] as date) >= '7/1/2019'

  group by

        CU.customText1				
	  ,UPPER(CC.[customText1])	
	  ,upper([businessSectorList])
      ,UPPER([action]) 
      ,CONVERT(varchar,(note.[dateAdded]),101) 
	  ,UPPER([trackTitle])
	  ,cc.[dateAdded]					
      ,cc.[dateLastModified]			
      ,cc.[notes]					   
	  ,cc.[status]
	  ,[userID]