#Include Once "FunctionList.bi"
#Include Once "../server/Server.bi"
#Include Once "../cmds/Command.bi"


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
	
	/' Open index file '/
	Dim As Integer fh = FreeFile()
	Open (pClient->pAcc->getPath("mazes.txt")) For Input As #fh
	
	If Err = 2 Then
		/' No maps created. Save empty one and return '/
		envVars.pPipeOut->addToHeader("Maps")
		envVars.pPipeOut->addToColumn("ID")
		envVars.pPipeOut->addToColumn("Name")
		envVars.pPipeOut->addToColumn("Size")
		envVars.pPipeOut->addToColumn("Wins")
		envVars.pPipeOut->addToColumn("Plays")
		
		envVars.pPipeOut->save(pClient->pAcc->getPath("mazes.txt"))
		Exit Sub
	EndIf
	
	Close #fh
	
	envVars.pPipeOut = loadTableFromFile(pClient->pAcc->getPath("mazes.txt"), envVars.pPipeOut)
End Sub
