/'----------------------------------------------------------------------------
 ' Internal server data referencing functions
 ---------------------------------------------------------------------------'/

#Include Once "FunctionList.bi"
#Include Once "../server/Server.bi"
#Include Once "../cmds/Command.bi"


/' Description:
 '  Lists subdirectories in a path
 '
 ' Command name:
 '  /dat/ls
 '
 ' Targets:
 '  Clients
 '
 ' Parameters:
 ' -(d)irectory : sub directory to lookup
 '
 ' Returns:
 ' - type:
 '		Whether entry is domain or command
 ' - entry:
 '		Name of command/domain
 '/
Sub CMD_ListDirectory(envVars As CmdEnv)
	CAST_ENV_PARS_MACRO()
	
	'Dim As Server Ptr pServer = CPtr(Server Ptr, envVars.aServer)
	Dim As Record Ptr pLineErr = 0
	Dim As Record Ptr pRec = 0
	Dim As String dirName
	
	
	
	/' Set up header '/
	envVars.pPipeOut->addToHeader("Query")
	envVars.pPipeOut->addToColumn("Type")
	envVars.pPipeOut->addToColumn("Entry")
	
	Print envVars.pParam
	
	/' Pop parameters '/
	Dim As Param Ptr prmDir = envVars.pParam->popParam("directory", "d")
	
	Dim As Domain Ptr pD = 0
	Dim As Domain Ptr pSubD = 0
	Dim As Cmd Ptr pC = 0
	
	If prmDir = 0 Then
		/' List all directories in root '/
		pD = pServer->pRootCmd
		
	Else
		/' List sub directories using parameter '/
		dirName = prmDir->pVals->text
		pD = lookupDomain(dirName, pServer->pRootCmd)
		
		Delete prmDir
	EndIf
	
	If pD = 0 Then
		pLineErr = New Record()
		pLineErr->addField("CMD_ListDirectory")
		pLineErr->addField("Could not find directory")
		pLineErr->addField(dirName)
		envVars.pPipeErr->addRecord(pLineErr)
	
	Else
		/' Its actually the child domain and commands were after '/
		pSubD = pD->pChild
		pC = pD->pCmd
	EndIf
	
	/' Write to output '/
	While pSubD <> 0
		pRec = New Record()
		pRec->addField("d")
		pRec->addField(pSubD->text)
		envVars.pPipeOut->addRecord(pRec)
		pSubD = pSubD->pNext
	Wend
	
	While pC <> 0
		pRec = New Record()
		pRec->addField("c")
		pRec->addField(pC->text)
		envVars.pPipeOut->addRecord(pRec)
		pC = pC->pNext
	Wend
End Sub


/' Description:
 '  Lists info of a directory or command
 '
 ' Command name:
 '  /dat/info
 '
 ' Targets:
 '  Clients
 '
 ' Parameters:
 ' -(d)irectory : sub directory or command to lookup
 '
 ' Returns:
 ' - text (Generic text for user):
 '		Directory info
 '/
Sub CMD_directoryInfo(envVars As CmdEnv)
	
	Dim As Server Ptr pServer = CPtr(Server Ptr, envVars.aServer)
	Dim As Record Ptr pLineErr = 0
	Dim As Domain Ptr pD = 0
	Dim As Domain Ptr pSubD = 0
	Dim As Cmd Ptr pC = 0
	
	/' Set up header '/
	envVars.pPipeOut->addToHeader("Query")
	envVars.pPipeOut->addToColumn("Text")
	
	/' Pop parameters '/
	Dim As Param Ptr prmDir = envVars.pParam->popParam("directory", "d")
	
	
	/' Try looking up domain first '/
	Dim As String dirName = prmDir->pVals->text
	pD = lookupDomain(dirName, pServer->pRootCmd)
	
	If pD <> 0 Then
		envVars.pPipeOut->addRecord(loadRecordFromString(pD->info))
		
	Else
		/' Try looking up command '/
		pC = lookupCmd(dirName, pServer->pRootCmd)
		
		If pC <> 0 Then
			envVars.pPipeOut->addRecord(loadRecordFromString(pC->info))
			
		Else
			pLineErr = New Record()
			pLineErr->addField("CMD_DirectoryInfo")
			pLineErr->addField("Could not find directory")
			pLineErr->addField(dirName)
			envVars.pPipeErr->addRecord(pLineErr)
		EndIf
	EndIf
	
	
	If prmDir <> 0 Then Delete prmDir
End Sub


/' Description:
 '  Lists flag info for a command
 '
 ' Command name:
 '  /dat/lsf
 '
 ' Targets:
 '  Clients
 '
 ' Parameters:
 ' -(d)irectory : sub directory or command to lookup
 '
 ' Returns:
 ' - flag name | letter | min arg | max arg | min use | max use | info
 '/
Sub CMD_flagInfo(envVars As CmdEnv)
	
	Dim As Server Ptr pServer = CPtr(Server Ptr, envVars.aServer)
	Dim As Record Ptr pLineErr = 0
	
	/' Set up header '/
	envVars.pPipeOut->addToHeader("Query")
	envVars.pPipeOut->addToColumn("name")
	envVars.pPipeOut->addToColumn("letter")
	envVars.pPipeOut->addToColumn("minArg")
	envVars.pPipeOut->addToColumn("maxArg")
	envVars.pPipeOut->addToColumn("minUse")
	envVars.pPipeOut->addToColumn("maxUse")
	envVars.pPipeOut->addToColumn("info")
	
	/' Pop parameters '/
	Dim As Param Ptr prmDir = envVars.pParam->popParam("directory", "d")
	
	
	/' Try looking up command '/
	Dim As String dirName = prmDir->pVals->text
	Dim As Cmd Ptr pC = lookupCmd(dirName, pServer->pRootCmd)
	
	If pC <> 0 Then
		/' Run through flags '/
		Dim As Flag Ptr pFlag = pC->pFlag
		While pFlag <> 0
			Dim As Record Ptr pRec = New Record()
			pRec->addField(pFlag->lName)
			pRec->addField(pFlag->sName)
			pRec->addField(Str(pFlag->minArg))
			pRec->addField(Str(pFlag->maxArg))
			pRec->addField(Str(pFlag->minUse))
			pRec->addField(Str(pFlag->maxUse))
			pRec->addField(pFlag->info)
			envVars.pPipeOut->addRecord(pRec)
			
			pFlag = pFlag->pNext
		Wend
		
	Else
		pLineErr = New Record()
		pLineErr->addField("CMD_FlagInfo")
		pLineErr->addField("Could not find Command")
		pLineErr->addField(dirName)
		envVars.pPipeErr->addRecord(pLineErr)
	EndIf
	
	
	If prmDir <> 0 Then Delete prmDir
End Sub
