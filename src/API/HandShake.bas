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
Sub CMD_getProtocolVersion(envVars As CmdEnv)
	
	envVars.pPipeOut->addToColumn("major")
	envVars.pPipeOut->addToColumn("minor")
	envVars.pPipeOut->addRecord(loadRecordFromString(!"0\t1"))
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
Sub CMD_getServerVersion(envVars As CmdEnv)
	
	envVars.pPipeOut->addToColumn("major")
	envVars.pPipeOut->addToColumn("minor")
	envVars.pPipeOut->addToColumn("type")
	envVars.pPipeOut->addRecord(loadRecordFromString(!"0\t1\tpre alpha"))
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
Sub CMD_getModVersion(envVars As CmdEnv)
	
	envVars.pPipeOut->addToColumn("mod")
	envVars.pPipeOut->addToColumn("major")
	envVars.pPipeOut->addToColumn("minor")
	envVars.pPipeOut->addToColumn("author")
	envVars.pPipeOut->addRecord(loadRecordFromString(!"vanilla\t0\t1\tNic Kiely"))
End Sub

