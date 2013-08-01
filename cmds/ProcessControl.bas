/'----------------------------------------------------------------------------
 ' Server process control functions
 ---------------------------------------------------------------------------'/

#Include Once "FunctionList.bi"
#Include Once "../server/Server.bi"


Sub CMD_stopServer(pPipeIn As Table Ptr, pPipeOut As Table Ptr, _
		pPipeErr As Table Ptr, pParam As Param Ptr, _
		aAccount As Any Ptr, aServer As Any Ptr)
		
	Dim As Server Ptr pServer = CPtr(Server Ptr, aServer)
	pServer->shutDown = -1
	/' TODO: Properly Handle parameters '/
End Sub
