/'----------------------------------------------------------------------------
 ' List of functions to be bound to commands
 ' Note: pPipeOut should be non-null and point to empty table
 ' pPipeErr, aServer, and pParam should also be non-null.
 ' pPipeIn may be null for unprivledged accounts.
 ' To report errors, add to the error table
 ---------------------------------------------------------------------------'/

/' Steps to add a new command: (this system needs to be made better)
 ' In this file:
 '  - Add DECLARE_CMD_SUB(functionName) line 
 '  - Add @CMD_functionName to CMD_BINDING_ARRAY
 '  - Update CMD_BINDING_ARRAY upper limit to include command
 ' In dat folder
 '  - update command, domain, and flag listings
 '  - verify indexs match
 '/


/' All commands should be preceeded by a summary comment block '/ 
/' Description:
 '  <Description of command>
 '
 ' Command name:
 '  <Full default path name of command>
 '
 ' Targets:
 '  <Default lowest priveledge class needed to run command>
 '
 ' Parameters:
 '  - <(p)arameter>: <description of parameter>
 '  - ...
 '
 ' Returns:
 '  <Description and format of return data, if any>
 '/

#Include Once "../cmds/Command.bi" 


/' For properly defining the subroutines to bind to commands '/
#Macro DECLARE_CMD_SUB(FUNC_TO_BIND)
	Declare Sub CMD_##FUNC_TO_BIND(envVars As CmdEnv)
#EndMacro



/' Builds the array of commands for binding '/
#Macro BUILD_CMD_ARRAY_MACRO()
	Dim CMD_BINDING_ARRAY(1 To 20) As Sub(envVars As CmdEnv) _
		= _
		{@CMD_getProtocolVersion, @CMD_getServerVersion, @CMD_getModVersion, @CMD_stopServer, @CMD_listDirectory, _
		@CMD_tableColumns, @CMD_chatMessage, @CMD_clientLogin, @CMD_clientChangePassword, @CMD_manCreateAccount, _
		@CMD_listAccounts, @CMD_clientLogout, @CMD_directoryInfo, @CMD_flagInfo, @CMD_getMapStats, _
		@CMD_newMap, @CMD_mapStageSwap, @CMD_deleteMaze, @CMD_getMaze, @CMD_editMaze}
#EndMacro


/' Declare the subroutines '/
DECLARE_CMD_SUB(getProtocolVersion)			'  1
DECLARE_CMD_SUB(getServerVersion)			'  2
DECLARE_CMD_SUB(getModVersion)				'  3
DECLARE_CMD_SUB(stopServer)					'  4
DECLARE_CMD_SUB(listDirectory)				'  5
DECLARE_CMD_SUB(tableColumns)					'  6
DECLARE_CMD_SUB(chatMessage)					'  7
DECLARE_CMD_SUB(clientLogin)					'  8
DECLARE_CMD_SUB(clientChangePassword)		'  9
DECLARE_CMD_SUB(manCreateAccount)         ' 10
DECLARE_CMD_SUB(listAccounts)             ' 11
DECLARE_CMD_SUB(clientLogout)             ' 12
DECLARE_CMD_SUB(directoryInfo)            ' 13
DECLARE_CMD_SUB(flagInfo)                 ' 14
DECLARE_CMD_SUB(getMapStats)              ' 15
DECLARE_CMD_SUB(newMap)                   ' 16
DECLARE_CMD_SUB(mapStageSwap)             ' 17
DECLARE_CMD_SUB(deleteMaze)               ' 18
DECLARE_CMD_SUB(getMaze)                  ' 19
DECLARE_CMD_SUB(editMaze)                 ' 20