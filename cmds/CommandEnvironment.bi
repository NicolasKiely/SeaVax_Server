#Include Once "../table/Table.bi"
#Include Once "ParList.bi"

/' For convieniently casting Environment parameters '/
#Macro CAST_ENV_PARS_MACRO()
	Dim As Server Ptr pServer = CPtr(Server Ptr, envVars.aServer)
	Dim As Client Ptr pClient = CPtr(Client Ptr, envVars.aClient)
#EndMacro


/' For convieniently exiting on null client error '/
#Macro ASSERT_NONNULL_CLIENT(SOURCE_PAR)
	If pClient = 0 Then
		pLineErr = New Record()
		pLineErr->addField(SOURCE_PAR)
		pLineErr->addField("No client attached")
		pLineErr->addField("pClient == 0")
		envVars.pPipeErr->addRecord(pLineErr)
		
		Exit Sub
	EndIf
#EndMacro


/' For convieniently exiting on null account error '/
#Macro ASSERT_NONNULL_ACCOUNT(SOURCE_PAR)
	If pClient->pAcc = 0 Then
		pLineErr = New Record()
		pLineErr->addField(SOURCE_PAR)
		pLineErr->addField("Client not logged in")
		pLineErr->addField("pClient->pAccount == 0")
		envVars.pPipeErr->addRecord(pLineErr)
		
		Exit Sub
	EndIf
#EndMacro



/'----------------------------------------------------------------------------
 ' Environmental parameters for a command call
 ---------------------------------------------------------------------------'/
Type CmdEnv
	/' Pointer to the standard input (table structure) '/
	Dim As Table Ptr pPipeIn
	
	/' Pointer to the standard output (table structure) '/
	Dim As Table Ptr pPipeOut
	
	/' Pointer to the error output (table structure) '/
	Dim As Table Ptr pPipeErr
	
	/' List of parameters for the command '/
	Dim As Param Ptr pParam
	
	/' Client to run the function on behalf of '/
	Dim As Any Ptr aClient
	
	/' Pointer to the global server state information '/
	Dim As Any Ptr aServer
End Type
