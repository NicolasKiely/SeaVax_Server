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
 ' - text (Generic text for user):
 '		Directory/Command name
 '/
Sub CMD_ListDirectory(pPipeIn As Table Ptr, pPipeOut As Table Ptr, _
		pPipeErr As Table Ptr, pParam As Param Ptr, _
		aClient As Any Ptr, aServer As Any Ptr)
	
	Dim As Server Ptr pServer = CPtr(Server Ptr, aServer)
	Dim As Record Ptr pLineErr = 0
	Dim As String dirName
	
	/' Set up header '/
	pPipeOut->addToHeader("Query")
	pPipeOut->addToColumn("Text")
	
	/' Pop parameters '/
	Dim As Param Ptr prmDir = pParam->popParam("directory", "d")
	
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
		pPipeErr->addRecord(pLineErr)
	
	Else
		/' Its actually the child domain and commands were after '/
		pSubD = pD->pChild
		pC = pD->pCmd
	EndIf
	
	/' Write to output '/
	While pSubD <> 0
		pPipeOut->addRecord(loadRecordFromString("d: " + pSubD->text))
		pSubD = pSubD->pNext
	Wend
	
	While pC <> 0
		pPipeOut->addRecord(loadRecordFromString("c: " + pC->text))
		pC = pC->pNext
	Wend
End Sub
