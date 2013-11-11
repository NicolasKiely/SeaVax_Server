#Include Once "FunctionList.bi"
#Include Once "../server/Server.bi"
#Include Once "../cmds/Command.bi"
#Include Once "../game/MazeManager.bi"


/' Description:
 '  Retrieves map names and stats for an account
 '
 ' Command name:
 '  /maze/play/mapStats
 '
 ' Targets:
 '  Accounts
 '
 ' Parameters:
 '
 ' Returns:
 ' - Map ID, map name, map size, map wins, map plays
 '/
Sub CMD_getMapStats(envVars As CmdEnv)
	Dim As Record Ptr pLineErr = 0
	CAST_ENV_PARS_MACRO()
	ASSERT_NONNULL_CLIENT("CmdGetMapStats")
	ASSERT_NONNULL_ACCOUNT("CmdGetMapStats")
	
	/' Open index file '/
	Dim As Integer fh = FreeFile()
	Open (pClient->pAcc->getPath(MAZE_STATS_FILE_NAME)) For Input As #fh
	
	
	envVars.pPipeOut->addToHeader("MapStats")

	
	If Err = 2 Then
		/' No maps created. Save empty one and return '/
		envVars.pPipeOut->addToColumn(MAZE_ID_HEADER)
		envVars.pPipeOut->addToColumn(MAZE_NAME_HEADER)
		envVars.pPipeOut->addToColumn(MAZE_SIZE_HEADER)
		envVars.pPipeOut->addToColumn(MAZE_WINS_HEADER)
		envVars.pPipeOut->addToColumn(MAZE_PLAYS_HEADER)
		envVars.pPipeOut->addToColumn(MAZE_STAGED_HEADER)
		
		envVars.pPipeOut->save(pClient->pAcc->getPath(MAZE_STATS_FILE_NAME))
		Exit Sub
	EndIf
	
	Close #fh
	
	envVars.pPipeOut = loadTableFromFile(pClient->pAcc->getPath(MAZE_STATS_FILE_NAME), envVars.pPipeOut)
End Sub


/' Description:
 '  Attempts to create a new map on behalf of a player
 '
 ' Command name:
 '  /maze/play/newMap
 '
 ' Targets:
 '  Accounts
 '
 ' Parameters:
 '  Map name, Map size
 '
 ' Returns:
 '  Map stats update
 '/
Sub CMD_newMap(envVars As CmdEnv)
	Dim As Record Ptr pLineErr = 0
	CAST_ENV_PARS_MACRO()
	ASSERT_NONNULL_CLIENT("CmdNewMap")
	ASSERT_NONNULL_ACCOUNT("CmdNewMap")
	
	/' Load up accounts existing maze records. TODO: delete maze table '/
	Dim As Table Ptr pMazeTab = loadMazeStats(pClient->pAcc)
	Dim As Integer mazeCount = pMazeTab->recNum
	Dim As Integer freeIndex = getFreeMazeIndex(pMazeTab)
	
	/' Look up the clients package '/
	Dim As String pack = pClient->pAcc->getMazePackage()
	
	Dim As Integer mapsAllowed
	If pack = "Free" Then
		mapsAllowed = FREE_MAPS_ALLOWED
	ElseIf pack = "Entry" Then
		mapsAllowed = ENTRY_MAPS_ALLOWED
	ElseIf pack = "Silver" Then
		mapsAllowed = SILVER_MAPS_ALLOWED
	ElseIf pack = "Gold" Then
		mapsAllowed = GOLD_MAPS_ALLOWED
	EndIf
	
	/' Check players isnt going over map quota '/
	If mazeCount >= mapsAllowed Then
		pLineErr = New Record()
		pLineErr->addField("Error in creating new maze")
		pLineErr->addField("At limit of maze maps for your account package '" +pack+ "'")
		pLineErr->addField("Free accounts are limited to "+Str(mapsAllowed)+ " maps")
		envVars.pPipeErr->addRecord(pLineErr)
		envVars.pPipeErr->addToHeader("DIALOG")
		
		If pMazeTab <> 0 Then Delete pMazeTab
		Exit Sub
	EndIf
	
	/' Pop size parameter '/
	Dim As Param Ptr prmSize = envVars.pParam->popParam("size", "s")
	Dim As Param Ptr prmName = envVars.pParam->popParam("name", "n")
	Dim As Integer size = ValInt(prmSize->pVals->text)
	Dim As String newName = prmName->pVals->text
	Delete prmSize
	Delete prmName
	
	/' Make sure name is not a duplicate '/
	If pMazeTab->getRecordByField(newName, MAZE_NAME_HEADER) <> 0 Then
		pLineErr = New Record()
		pLineErr->addField("Error in creating new maze")
		pLineErr->addField("Maze name '"+newName+"' already exists")
		pLineErr->addField("You cannot create multiple mazes with the same name")
		envVars.pPipeErr->addRecord(pLineErr)
		envVars.pPipeErr->addToHeader("DIALOG")
		
		If pMazeTab <> 0 Then Delete pMazeTab
		Exit Sub
	EndIf
	
	/' Check to make sure size is valid '/
	If isValidMapSize(size)=0 Then
		pLineErr = New Record()
		pLineErr->addField("Error in creating new maze")
		pLineErr->addField("Invalid maze size: " +Str(size)+ " x " +Str(size))
		pLineErr->addField("Valid sizes are: 10, 20, 30, 50")
		envVars.pPipeErr->addRecord(pLineErr)
		envVars.pPipeErr->addToHeader("DIALOG")
		
		If pMazeTab <> 0 Then Delete pMazeTab
		Exit Sub
	EndIf
	
	/' Check to make sure size is allowed for accounts game package '/
	Dim As Integer allowedSize = getMaxMazeSize(pack)
	If size > allowedSize Then
		pLineErr = New Record()
		pLineErr->addField("Error in creating new map")
		pLineErr->addField("Maze size (" +Str(size)+ ") greater than allowed for your package")
		pLineErr->addField("Max maze size for package '" +pack+ "' is " + Str(allowedSize))
		envVars.pPipeErr->addRecord(pLineErr)
		envVars.pPipeErr->addToHeader("DIALOG")
		
		If pMazeTab <> 0 Then Delete pMazeTab
		Exit Sub
	EndIf
	
	/' Make sure name uses valid characters '/
	Dim As Integer badChar = isAllowedMazeName(newName)
	If badChar >= 0 Then
		pLineErr = New Record()
		pLineErr->addField("Error in creating new map")
		pLineErr->addField("Maze name '" +newName+ "' is invalid. Use only letters, numbers, and underscore")
		pLineErr->addField("Invalid character: '" +Chr(badChar)+"' (#" +Str(badChar)+ ")")
		envVars.pPipeErr->addRecord(pLineErr)
		envVars.pPipeErr->addToHeader("DIALOG")
		
		If pMazeTab <> 0 Then Delete pMazeTab
		Exit Sub
	EndIf
	
	/' So far so good . . . so what? '/
	Dim As Record Ptr pNewMazeRecord = New Record()
	pNewMazeRecord->addField(Str(freeIndex)) /' ID '/
	pNewMazeRecord->addField(newName)        /' Name '/
	pNewMazeRecord->addField(Str(size))      /' Size '/
	pNewMazeRecord->addField("0")            /' Wins '/
	pNewMazeRecord->addField("0")            /' Plays '/
	pNewMazeRecord->addField("1")            /' Staged '/
	pMazeTab->addRecord(pNewMazeRecord)
	
	
	initializeMazeFile(pClient->pAcc, freeIndex, size)
	pMazeTab->save(pClient->pAcc->getPath(MAZE_STATS_FILE_NAME))
	Delete pMazeTab
	
	/' Update stats '/
	CMD_getMapStats(envVars)
End Sub


/' Description:
 '  Attempts to swap the public/private state of a maze
 '
 ' Command name:
 '  /maze/play/swapStage
 '
 ' Targets:
 '  Accounts
 '
 ' Parameters:
 '  Map id, Map stage
 '
 ' Returns:
 '  Map stats update
 '/
Sub CMD_mapStageSwap(envVars As CmdEnv)
	Dim As Record Ptr pLineErr = 0
	CAST_ENV_PARS_MACRO()
	ASSERT_NONNULL_CLIENT("CmdMapStageSwap")
	ASSERT_NONNULL_ACCOUNT("CmdMapStageSwap")
	
	
	Dim As Param Ptr prmID = envVars.pParam->popParam("id", "i")
	Dim As String id = prmID->pVals->text
	Delete prmID
	
	Dim As Param Ptr prmState = envVars.pParam->popParam("stage", "s")
	Dim As String stage = ""
	If prmState <> 0 Then
		stage = prmState->pVals->text
		Delete prmState
	End If
	
	/' Load up maze table from disk '/
	Dim As Table Ptr pMazeTab = loadMazeStats(pClient->pAcc)
	
	/' Look up specific record '/
	Dim As Record Ptr pRec = pMazeTab->getRecordByField(id, MAZE_ID_HEADER)
	If pRec = 0 Then
		pLineErr = New Record()
		pLineErr->addField("CmdMapStageSwap")
		pLineErr->addField("Maze ID not found")
		pLineErr->addField("pRec = 0 for id=" + Str(id))
		envVars.pPipeErr->addRecord(pLineErr)
		
		Delete pMazeTab
		Exit Sub
	EndIf
	
	/' Look up field in table '/
	Dim As Integer colIndex = pMazeTab->getColumnID(MAZE_STAGED_HEADER)
	Dim As Fld Ptr pFld = pRec->getFieldByID(colIndex)
	
	If stage <> "1" And stage <> "0" Then
		/' Load stage value '/
		Dim As Integer flippedStage = ValInt(pFld->value)
		If flippedStage = 0 Then stage = "0" Else stage = "1"
	EndIf
	
	/' Flip stage value '/
	If stage = "0" Then stage = "1" Else stage = "0"
	
	/' Set field and save '/
	pFld->value = stage
	pMazeTab->save(pClient->pAcc->getPath(MAZE_STATS_FILE_NAME))
	Delete pMazeTab
	
	/' Update stats '/
	CMD_getMapStats(envVars)
End Sub


/' Description:
 '  Attempts to delete a player's map
 '
 ' Command name:
 '  /maze/play/deleteMap
 '
 ' Targets:
 '  Accounts
 '
 ' Parameters:
 '  Map id
 '
 ' Returns:
 '  Map stats update
 '/
Sub CMD_deleteMaze(envVars As CmdEnv)
	Dim As Record Ptr pLineErr = 0
	CAST_ENV_PARS_MACRO()
	ASSERT_NONNULL_CLIENT("CmdDeleteMaze")
	ASSERT_NONNULL_ACCOUNT("CmdDeleteMaze")
	
	Dim As Param Ptr prmID = envVars.pParam->popParam("id", "i")
	Dim As String id = prmID->pVals->text
	Delete prmID
	
	/' Load up maze table from disk '/
	Dim As Table Ptr pMazeTab = loadMazeStats(pClient->pAcc)
	
	/' Remove specific record '/
	pMazeTab->removeRecordByField(id, MAZE_ID_HEADER)
	
	/' Save modified table and update client '/
	pMazeTab->save(pClient->pAcc->getPath(MAZE_STATS_FILE_NAME))
	Delete pMazeTab
	
	/' Update stats '/
	CMD_getMapStats(envVars)
End Sub


/' Description:
 '  Retrieves maze data
 '
 ' Command name:
 '  /maze/play/getMaze
 '
 ' Targets:
 '  Accounts
 '
 ' Parameters:
 '		id
 '
 ' Returns:
 ' - Maze data
 '/
Sub CMD_getMaze(envVars As CmdEnv)
	CAST_ENV_PARS_MACRO()
	Dim As Record Ptr pLineErr = 0
	
	If pClient = 0 Then
		pLineErr = New Record()
		pLineErr->addField("CmdGetMapStats")
		pLineErr->addField("No client attached")
		pLineErr->addField("pClient == 0")
		envVars.pPipeErr->addRecord(pLineErr)
		
		Exit Sub
	EndIf
	
	If pClient->pAcc = 0 Then
		pLineErr = New Record()
		pLineErr->addField("CmdGetMapStats")
		pLineErr->addField("Client not logged in")
		pLineErr->addField("pClient->pAccount == 0")
		envVars.pPipeErr->addRecord(pLineErr)
		
		Exit Sub
	EndIf
	
	/' Get stats '/
	Dim As Table Ptr pStatsTab = loadMazeStats(pClient->pAcc)
End Sub 