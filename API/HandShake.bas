/'----------------------------------------------------------------------------
 ' Handshake functions
 ---------------------------------------------------------------------------'/

#Include Once "FunctionList.bi"


/' Description:
 '  Gets communication protocol version
 '
 ' Command name:
 '  /hs/v
 '
 ' Targets:
 '  Clients
 '
 ' Parameters:
 '  - None
 '
 ' Returns:
 '  Major version number | minor version number
 '  single line
 '/
Sub CMD_getProtocolVersion(pPipeIn As Table Ptr, pPipeOut As Table Ptr, _
		pPipeErr As Table Ptr, pParam As Param Ptr, _
		aClient As Any Ptr, aServer As Any Ptr)
	
	pPipeOut->addToColumn("major")
	pPipeOut->addToColumn("minor")
	pPipeOut->addRecord(loadRecordFromString(!"0\t1"))
End Sub


/' Description:
 '  Gets server and API version
 '
 ' Command name:
 '  /hs/serv
 '
 ' Targets:
 '  Clients
 '
 ' Parameters:
 '  - None
 '
 ' Returns:
 '  Major version | Minor Version | Release type
 '  Single Line
 '/
Sub CMD_getServerVersion(pPipeIn As Table Ptr, pPipeOut As Table Ptr, _
		pPipeErr As Table Ptr, pParam As Param Ptr, _
		aClient As Any Ptr, aServer As Any Ptr)
	
	pPipeOut->addToColumn("major")
	pPipeOut->addToColumn("minor")
	pPipeOut->addToColumn("type")
	pPipeOut->addRecord(loadRecordFromString(!"0\t1\tpre alpha"))
End Sub


/' Description:
 '  Place to credit author contributions and mods
 '
 ' Command name:
 '  /hs/mod
 '
 ' Targets:
 '  Clients
 '
 ' Parameters:
 '  - None
 '
 ' Returns:
 '  Modification | Major version | Minor version | Author name
 '  Returns as many lines as the sum of the authors contributions
 '  Modification name is vanilla for contributions to core code
 '/
Sub CMD_getModVersion(pPipeIn As Table Ptr, pPipeOut As Table Ptr, _
		pPipeErr As Table Ptr, pParam As Param Ptr, _
		aClient As Any Ptr, aServer As Any Ptr)
	
	pPipeOut->addToColumn("mod")
	pPipeOut->addToColumn("major")
	pPipeOut->addToColumn("minor")
	pPipeOut->addToColumn("author")
	pPipeOut->addRecord(loadRecordFromString(!"vanilla\t0\t1\tNic Kiely"))
End Sub

