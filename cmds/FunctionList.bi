/'----------------------------------------------------------------------------
 ' List of functions to be bound to commands
 ' Note: pPipeOut should be non-null and point to empty table
 ' pPipeErr, aServer, and pParam should also be non-null.
 ' pPipeIn may be null for unprivledged accounts.
 ' To report errors, add to the error table
 ---------------------------------------------------------------------------'/
#Include Once "Command.bi" 


/' For properly defining the subroutines to bind to commands '/
#Macro DECLARE_CMD_SUB(FUNC_TO_BIND)
	Declare Sub CMD_##FUNC_TO_BIND(pPipeIn As Table Ptr, pPipeOut As Table Ptr, _
		pPipeErr As Table Ptr, pParam As Param Ptr, _
		aClient As Any Ptr, aServer As Any Ptr)
#EndMacro



/' Builds the array of commands for binding '/
#Macro BUILD_CMD_ARRAY_MACRO()
	Dim CMD_BINDING_ARRAY(1 To 9) As Sub(pPipeIn As Table Ptr, pPipeOut As Table Ptr, _
		pPipeErr As Table Ptr, pParam As Param Ptr, _
		aClient As Any Ptr, aServer As Any Ptr) _
		= _
		{@CMD_getProtocolVersion, @CMD_getServerVersion, @CMD_getModVersion, @CMD_stopServer, @CMD_listDirectory, _
		@CMD_tableColumns, @CMD_chatMessage, @CMD_clientLogin, @CMD_clientChangePassword}
#EndMacro


/' Declare the subroutines '/
DECLARE_CMD_SUB(getProtocolVersion)			' 1
DECLARE_CMD_SUB(getServerVersion)			' 2
DECLARE_CMD_SUB(getModVersion)				' 3
DECLARE_CMD_SUB(stopServer)					' 4
DECLARE_CMD_SUB(listDirectory)				' 5
DECLARE_CMD_SUB(tableColumns)					' 6
DECLARE_CMD_SUB(chatMessage)					' 7
DECLARE_CMD_SUB(clientLogin)					' 8
DECLARE_CMD_SUB(clientChangePassword)		' 9