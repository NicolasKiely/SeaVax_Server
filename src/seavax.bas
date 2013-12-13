/' Boot steps:
 '  - Get working world name from command line, or use default 'world'
 '  - If world doesn't exist, create it
 '  - If -r is used, generate brand new save
 '  - If save doesn't exist, generate brand new save
 '  - Continue on
 '/
 
' Working on: handshaking Commands, account management
/' Command system:
 '		/acc/*  : account management
 '		/acc/mk -name|-n <account name> -password|-p <password hash> [-class|-c <permission class>]
 '			Creates new account
 '		/acc/rm -name|-n <account name>
 '			Deletes account
 '		/acc/lk -name|-n <account name> [-time|-t <time>] [-unlock|-u]
 '			Locks account for given amount of time. If u is specified,
 '			unlocks.
 '		/acc/ls [-team|-t <team name>] [-lock|-l / -unlock|-u]
 '			Lists accounts. -t specifies by team, -l specifies locked/unlocked
 '
 '		/prc/*  : process management
 '		/prc/stop [-time|-t <time>] [-message|-m <message>] [-interval|-i <time>]
 '/

#Include Once "file.bi"
#Include Once "terra/WorldGen.bi"
#Include Once "server/Server.bi"
#Include Once "server/ZRing.bi"
#Include Once "cmds/Command.bi"
#Include Once "cmds/ParList.bi"

/' Included because image generation wont work otherwise '/
'ScreenRes 640, 480, 32

/'
Dim As String param1 = ""   ' Command line arg
Dim As String param2 = ""   ' Command line arg
Dim As String world  = ""   ' World name
Dim As String worldSav = "" ' World save name
Dim As String worldRaw = "" ' World generation name
Dim As Integer forceReload = 0 ' Whether or not to ignore existing save
'/
Dim As Server serv

/' Get the first two command line args '/
'param1 = Command(1)
'param2 = Command(2)

'If param1 = "" Then
	/' Use default world '/
'	world = "world"

'Else
'	If param2 = "" Then
		/' Use first arg as world name '/
'		world = param1
		
'	ElseIf param1 = "-r" Then
		/' Use second arg as world name, and set flag '/
'		world = param2
'		forceReload = -1
		
'	Else
		/' Bad arguments '/
'		Print "Error, bad arguments."
'		Print "Usage: server.exe [-r] world name"
'		Sleep
'		End(1)
		
'	EndIf
'EndIf


/' Get world save and generator names '/
'worldSav = world + ".sav"
'worldRaw = world + ".raw"


'If FileExists("saves/" + worldRaw) = 0 Then
	/' File does not exist. Generate raw world file '/
'	Dim As String errorStr = generateWorld(worldRaw)
/'
	If (errorStr <> "") then 
		Print "Error in world generation:"
		Print "   " + errorStr
	EndIf
	
EndIf 
'/

/' Move back to console '/
'Screen 0

Print "Networking stuff"
serv.initSock()

/' Load command tree '/
Print "Loading domains of commands . . ."
serv.pRootCmd = loadDomains(DOMAIN_LIST_FILE)
If serv.pRootCmd = 0 Then
	Print "Failed to load domains . . ."
	End(1)
	
Else
	Print "Domains loaded!"
	Print "Loading commands ..."
	loadCommands(COMMAND_LIST_FILE, serv.pRootCmd)
	Print "Loading flags ..."
	loadFlags(FLAG_LIST_FILE, serv.pRootCmd)
	serv.pRootCmd->DEBUG_PRINT(1)
EndIf


/' Lookup accounts '/
Print "Loading accounts . . ."
Dim As Integer accNum = serv.accMan.loadFromDisk(ACCOUNT_LIST_FILE)
If accNum = 0 Then
	Print "No accounts loaded"
	
ElseIf accNum = 1 Then
	Print "Loaded one account"
	
Else
	Print "Loaded " +Str(accNum)+ " accounts"
EndIf



Print "Running server's main()"
serv.serverMain()


serv.accMan.save()
serv.cleanSock()


Print "Press any key to exit . . ."
Sleep
End(0)
