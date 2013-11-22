#Include Once "FunctionList.bi"
#Include Once "../server/Server.bi"
#Include Once "../cmds/Command.bi"
#Include Once "../game/MazeManager.bi"



/' Description:
 '  Starts new game room
 '
 ' Command name:
 '  /maze/room/create
 '
 ' Targets:
 '  Accounts
 '
 ' Parameters:
 '		game type, max players, maze size
 '
 ' Returns:
 '/
Sub CMD_createMazeGame(envVars As CmdEnv)
	Dim As Record Ptr pLineErr = 0
	CAST_ENV_PARS_MACRO()
	ASSERT_NONNULL_CLIENT("CmdCreateMazeGame")
	ASSERT_NONNULL_ACCOUNT("CmdCreateMazeGame")
	
	
	/' Fetch parameters '/
	Dim As Param Ptr prmType    = envVars.pParam->popParam("type", "t")
	Dim As Param Ptr prmPlayers = envVars.pParam->popParam("players", "p")
	Dim As Param Ptr prmSize    = envVars.pParam->popParam("size", "s")
	Dim As String gameType = prmType->pVals->text
	Dim As Integer players = ValInt(prmPlayers->pVals->text)
	Dim As Integer size    = ValInt(prmSize->pVals->text)
	Delete prmType
	Delete prmPlayers
	Delete prmSize
	
	/' First check that the player already isnt in a game '/
	If pClient->pAcc->pRoom <> 0 Then
		pLineErr = New Record()
		pLineErr->addField("CmdCreateMazeGame")
		pLineErr->addField("Player already is in game")
		pLineErr->addField("In game room: #" + Str(pClient->pAcc->pRoom))
		envVars.pPipeErr->addRecord(pLineErr)
		envVars.pPipeErr->addToHeader("DIALOG")
		Exit Sub
	EndIf
	
	/' Two players only allowed for now '/
	If players <> 2 Then
		pLineErr = New Record()
		pLineErr->addField("CmdCreateMazeGame")
		pLineErr->addField("Can only have 2 players in this game")
		pLineErr->addField("players="+Str(players))
		envVars.pPipeErr->addRecord(pLineErr)
		envVars.pPipeErr->addToHeader("DIALOG")
		Exit Sub
	EndIf
	
	/' Check to make sure player has an available map to use '/
	Dim As Table Ptr pMazeTab = loadMazeStats(pClient->pAcc)
	Dim As Record Ptr pRec = pMazeTab->getRecordByField(Str(size), MAZE_SIZE_HEADER)
	If pRec = 0 Then
		pLineErr = New Record()
		pLineErr->addField("CmdCreateMazeGame")
		pLineErr->addField("Player does not have proper maze to play")
		pLineErr->addField("No maze found for size: " + Str(size))
		envVars.pPipeErr->addRecord(pLineErr)
		envVars.pPipeErr->addToHeader("DIALOG")
		Delete pMazeTab
		Exit Sub
	EndIf
	Delete pMazeTab
	
	/' So far so good '/
	Dim As GameRoom Ptr pRoom = New GameRoom(pClient->pAcc, players, size, "1v1race")
	pServer->gameMan.addRoom(pRoom)
End Sub


/' Description:
 '  Fetches list of open game rooms
 '
 ' Command name:
 '  /maze/room/fetch
 '
 ' Targets:
 '  Accounts
 '
 ' Parameters:
 '
 ' Returns:
 '  Room Creator, Current players, max players, Game type, map size
 '/
Sub CMD_fetchMazeRooms(envVars As CmdEnv)
	Dim As Record Ptr pLineErr = 0
	CAST_ENV_PARS_MACRO()
	ASSERT_NONNULL_CLIENT("CmdFetchMazeRooms")
	ASSERT_NONNULL_ACCOUNT("CmdFetchMazeRooms")
	
	If pServer->gameMan.pRoot <> 0 then
		envVars.pPipeOut->addToHeader("MAZELIST")
		envVars.pPipeOut->addToColumn("Host")
		envVars.pPipeOut->addToColumn("Type")
		envVars.pPipeOut->addToColumn("Count")
		envVars.pPipeOut->addToColumn("Max")
		envVars.pPipeOut->addToColumn("Size")
	End If
	
	/' DEBUG '/
	Dim As Fld Ptr pDeb = envVars.pPipeOut->pHeader
	While pDeb <> 0
		Print "'"+pDeb->value+"'";
		
		pDeb = pDeb->pNext
	Wend
	print
	
	
	/' Loop through game rooms '/
	Dim As GameRoom Ptr pRoom = pServer->gameMan.pRoot
	While pRoom <> 0
		If pRoom->inSession = 0 Then
			Dim As Record Ptr pRec = New Record()
			pRec->addField(pRoom->getHostName())
			pRec->addField(pRoom->gameType)
			pRec->addField(Str(pRoom->numPlyr))
			pRec->addField(Str(pRoom->maxPlyr))
			pRec->addField(Str(pRoom->mapSize))
			
			envVars.pPipeOut->addRecord(pRec)
		End If
		
		pRoom = pRoom->pNext
	Wend
End Sub


/' Description:
 '  Attempts for player to join a room
 '
 ' Command name:
 '  /maze/room/joinRoom
 '
 ' Targets:
 '  Accounts
 '
 ' Parameters:
 '  Player host name (p)
 '
 ' Returns:
 '  Room Creator, Current players, max players, Game type, map size
 '/
Sub CMD_joinMazeRoom(envVars As CmdEnv)
	Dim As Record Ptr pLineErr = 0
	CAST_ENV_PARS_MACRO()
	ASSERT_NONNULL_CLIENT("CmdFetchMazeRooms")
	ASSERT_NONNULL_ACCOUNT("CmdFetchMazeRooms")
	
End Sub