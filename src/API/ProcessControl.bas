/'----------------------------------------------------------------------------
 ' Server process control functions
 ---------------------------------------------------------------------------'/

#Include Once "FunctionList.bi"
#Include Once "../server/Server.bi"


/' Description:
 '  Shuts down server
 '
 ' Command name:
 '  /prc/stop
 '
 ' Targets:
 '  Admin
 '
 ' Parameters:
 '  - (t)ime: time to shut down [NOT IMPLEMENTED]
 '	 - (m)essage: message to broadcast to rest of server [NOT IMPLEMENTED]
 '
 ' Returns:
 '  Nothing
 '/
Sub CMD_stopServer(envVars As CmdEnv)
		
	Dim As Server Ptr pServer = CPtr(Server Ptr, envVars.aServer)
	pServer->shutDown = -1
	/' TODO: Properly Handle parameters '/
End Sub
