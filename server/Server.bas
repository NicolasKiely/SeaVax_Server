#Include Once "Server.bi"
#Include Once "../player/Organization.bi"
#Include Once "../player/User.bi"
#Include Once "../player/Connector.bi"
#Include Once "../cmds/ParList.bi"
#Include Once "../table/Table.bi"
#Include Once "win/winsock.bi"
#Include Once "NetStreamParser.bi"


Constructor Server()
	this.pClient = 0
	this.lobby.roomName = "lobby"
End Constructor


Destructor Server()
	If this.pClient <> 0 Then Delete this.pClient
End Destructor


Sub Server.initSock()
	/' Needed for initializing '/
	
	If WSAStartup(MAKEWORD(2,2), @this.wdat) <> 0 Then
		Print "Error in calling WSAstartup(1,1,@)"
	EndIf
	
	/' IPv4 TCP listening socket '/
	this.sock_l = OpenSocket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
	
	If this.sock_l = INVALID_SOCKET Then
		Print "Error in opening listening socket"
	EndIf
	
	Dim sockAd As sockaddr_in
	
	/' Using IPv4 on port 6282. Dont care about address '/
	sockAd.sin_family = AF_INET
	sockAd.sin_port   = htons(6282)
	sockAd.sin_addr.s_addr = inaddr_any
	
	/' Ignore "address in use" error '/
	Dim yes As ZString * 2 => "1"
	setsockopt(this.sock_l, SOL_SOCKET, SO_REUSEADDR, yes, 1)
	
	/' Bind socket descriptor to address '/
	If bind(this.sock_l, @sockAd, SizeOf(sockAd))<0 Then
		Print "Error in binding listening socket"
		Return
	EndIf
	
	/' Listen to socket '/
	If listen(this.sock_l, 10) < 0 Then
		Print "Error in listening to socket"
		Return
	EndIf
End Sub


Sub Server.cleanSock()
	WSACleanup()
	
	CloseSocket(this.sock_l)
End Sub


Sub Server.serverMain()
	Dim As Double startTime = Timer
	Dim As Integer tick = 0
	Dim As fd_set readSet
	
	While this.shutDown = 0
		Dim As Double loopTime = Timer
		
		tick += 1
		If tick >= 200 Then
			Print "Tick"
			Print "Client count: " + Str(this.getClientCount())
			tick = 0
		EndIf
		
		/' Work '/
		
		/' Check for client input '/
		FD_ZERO(@readSet)
		getReadSocks(@readSet)
		handleReadSocks(@readSet)
		this.cleanUpClients()
		
		
		/' Handle chat rooms '/
		If tick Mod CHAT_SLICE = 0 Then this.handleChatRooms()
		
		
		
		
		/' Cap loop rate '/
		Dim As Double loop_d = Timer - loopTime
		If loop_d < LOOP_SLICE Then
			Dim As Integer pausePeriod = (LOOP_SLICE - loop_d)*1000
			
			/' Make sure to not accidently sleep 0 or -1 '/
			If pausePeriod < 1 Then pausePeriod = 1
			
			/' Make sure to not sleep too long in case timer() decides to fritz out '/
			If LOOP_SLICE*1000 Then pausePeriod = LOOP_SLICE*1000
			
			Sleep pausePeriod
		EndIf
	Wend
End Sub


Sub Server.getReadSocks(pReadSet As fd_set Ptr)
	/' Start tracking max sockets '/
	Dim As UInteger max = this.sock_l
	
	/' Add the listner socket '/
	FD_SET_(this.sock_l, pReadSet)
	
	Dim As Client Ptr pCurrent = this.pClient
	Dim As Integer DEBUG_I = 0
	While pCurrent <> 0
		/' Set descriptor in list '/
		
		If this.pClient->sock <> -1 And this.pClient->markForDeletion=0 Then 
			FD_SET_(pCurrent->sock, pReadSet)
			If max < pCurrent->sock Then max = pCurrent->sock
		EndIf
		
		pCurrent = pCurrent->pNext
		
		DEBUG_I += 1
		If DEBUG_I = 100 Then
			Print "Infinite loop detected"
			Exit while
		EndIf
	Wend
	
	/' Indicate no waiting'/
	Dim As timeVal tv
	tv.tv_sec = 0
	tv.tv_usec = 0
	
	/' Poll read sockets '/
	selectSocket(max, pReadSet, 0, 0, @tv)
	
	If FD_ISSET(this.sock_l, pReadSet) Then Print "Connection attempt detected!"
End Sub


Sub Server.handleReadSocks(pReadSet As fd_set Ptr)
	Dim As ZString Ptr pBuf = Callocate(250)
		
	If FD_ISSET(this.sock_l, pReadSet) Then
		/' New client trying to connect '/
		Dim As Client Ptr pNewClient
		Dim As Integer size = SizeOf(pNewClient->addr)
		pNewClient = New Client()
		Dim As Integer safeToAdd = -1
		
		/' Accept new connections '/
		pNewClient->sock = accept(this.sock_l, @(pNewClient->addr), @size)
		If pNewClient->sock = -1 Or pNewClient->sock = 0 Then
			Print "Error: accept"
			Print WSAGetLastError - WSABASEERR
			safeToAdd = 0
		EndIf
		
		If WSAGetLastError <> 0 Then safeToAdd = 0
		
		/' Dont accept if getting ready to kick, theres a bug where dropped
		   clients have a ghost structure that reconnects and blocks the recv
		   call.'/
		Dim As Client Ptr pTemp = pClient
		While pTemp <> 0
			If pTemp->markForDeletion <> 0 Then
				safeToAdd = 0
				Print "Can't add, kicking!"
			EndIf
			
			pTemp = pTemp->pNext
		Wend
		
		/' Add client struct to list '/
		If safeToAdd Then this.addClient(pNewClient) Else Print "Bad client"
	EndIf
	
	/' Read back messages from client '/
	Dim As Client Ptr pCurrent = this.pClient
	While pCurrent <> 0
		If FD_ISSET(pCurrent->sock, pReadSet) Then
			/' input!!!!! '/
			Dim As Integer datLen = recv(pCurrent->sock, pBuf, 249, 0)
			If datLen >= 248 Then Print "Weirdness going on in packets"
			pBuf[249] = 0
			
			If datLen = 0 Or datLen = -1 Then
				/' Closed connection, remove '/
				If datLen = 0 Then Print "Connection closed!" Else Print "Connection Error!"
				pCurrent->markForDeletion = 1
			
			Else
				pBuf[datLen] = 0
				'Print "Message from client: '" + *pBuf + "'"
				handleClientInput(pCurrent, pBuf, datLen)
			EndIf
			
		Else
			/' Try to read backlog '/
			If pCurrent->pNetBuf->isEmpty() = 0 Then
				Print "Backlog detected! FreeSpace: "; pCurrent->pNetBuf->getFreeSpace()
				handleClientInput(pCurrent, 0, 0)
			EndIf
		EndIf
		
		pCurrent = pCurrent->pNext
	Wend
End Sub


Sub Server.addClient(pNewClient As Client Ptr)
	If this.pClient = 0 Then
		this.pClient = pNewClient
		
	Else
		pNewClient->pNext = this.pClient
		this.pClient = pNewClient
	EndIf
End Sub


Function Server.getClientCount() As Integer
	Dim As Client Ptr pTemp = this.pClient
	Dim As Integer count = 0
	While pTemp <> 0
		pTemp = pTemp->pNext
		count = count + 1
	Wend
	
	Return count
End Function


Sub Server.cleanUpClients()
	Dim As Client Ptr pCurrent = this.pClient
	Dim As client Ptr pPrev = 0
	
	While pCurrent <> 0
		If pCurrent->markForDeletion = 0 Then
			/' Iterate '/
			pPrev = pCurrent
			pCurrent = pCurrent->pNext
			
		ElseIf pCurrent->markForDeletion >= 3 Then
			/' Delete '/
			If pPrev = 0 Then
				Print "Deleting first client"
				/' Delete first client '/
				pCurrent = pCurrent->pNext
				this.pClient->pNext = 0
				this.pClient->freeSelf()
				Delete this.pClient
				this.pClient = pCurrent
			
			Else
				/' Delete imbedded client '/
				Print "Deleting mid client"
			
				pPrev->pNext = pCurrent->pNext
				pCurrent->pNext = 0
				This.pClient->freeSelf()
				Delete pCurrent
				pCurrent = pPrev->pNext
			EndIf
			
		Else
			/' Increment the counter '/
			pCurrent->markForDeletion += 1
			
			pPrev = pCurrent
			pCurrent = pCurrent->pNext
		EndIf
	Wend
End Sub


Sub Server.handleClientInput(pTalker As Client Ptr, zDatIn As ZString Ptr, datLen As Integer)
	/' TODO: Lookup permissions '/
	Dim As CmdStream Ptr pStream = parseNetStream(pTalker->pNetBuf, zDatIn, datLen)
	If pStream = 0 Then
		Print "Parsing failed!"
		Exit Sub
	EndIf
	
	
	/' Execute commands '/
	Dim As CmdStream Ptr pTemp = pStream
	
	Dim As String echo = ""
	Dim As Table Ptr pPipeIn
	Dim As Table Ptr pPipeOut = New Table()
	Dim As Table Ptr pPipeErr = New Table()
	pPipeErr->addToColumn("Location")
	pPipeErr->addToColumn("Message")
	pPipeErr->addToColumn("Cause")
	Dim As Record Ptr pErrLine
	
	If pStream = 0 Then
		pErrLine = loadRecordFromString(!"Server.handleClientInput\tParsing failed")
		pPipeErr->addRecord(pErrLine)
	EndIf
	
	
	While pTemp <> 0
		Dim As Cmd Ptr pCmd
		
		Select Case As Const pTemp->strType
			Case CommandStreamStrings.COMMAND_STRING:
				Dim As String pars = ""
				Dim As String cmdName = pTemp->text
				
				/' Execute command '/
				pCmd = lookupCmd(cmdName, this.pRootCmd)
				
				/' Check for parameters '/
				If pTemp->pNext <> 0 Then
					If pTemp->pNext->strType = CommandStreamStrings.PARAMETER_STRING Then
						/' Found parameters for this command '/
						pars = pTemp->pNext->text
						pTemp = pTemp->pNext
					EndIf
				EndIf
				
				/' Compile parameters if possible '/
				Dim As Integer parErr = 0
				Dim As Param Ptr pCompPar = compileParameters(pars, @parErr)
				
				If pCmd <> 0 And pCompPar <> 0 Then
					Dim As CmdEnv envVars
					/' Call command function '/
					
					/' Set up pipe in from old pipe out, then make new pipe out '/
					Delete pPipeIn
					pPipeIn = pPipeOut
					pPipeOut = New Table()
					pPipeOut->addToHeader(echo)
					
					/' Run '/
					envVars.pPipeIn  = pPipeIn
					envVars.pPipeOut = pPipeOut
					envVars.pPipeErr = pPipeErr
					envVars.pParam   = pCompPar
					envVars.aClient  = pTalker
					envVars.aServer  = @This
					pCmd->callFunc(envVars)
					
					Delete pCompPar
					
					If pPipeErr->pHeader <> 0 Then
						/' Error found '/
						pErrLine = loadRecordFromString(!"Server.handleClientInput\tError in command")
						pPipeErr->addRecord(pErrLine)
						Exit While
						
					ElseIf pPipeOut->pCol=0 And pPipeOut->pRec=0 Then
						/' No error found and empty table returned, send ACK back '/
						pPipeOut->addToColumn("ACK")
						pPipeOut->addRecord(loadRecordFromString(cmdName))
						
					EndIf
					
				Else
					If pCmd = 0 Then
						pErrLine = loadRecordFromString(!"Server.handleClientInput\tCould not lookup command")
						pPipeErr->addRecord(pErrLine)
					EndIf
					
					If pCompPar = 0 Then
						pErrLine = loadRecordFromString(!"Server.handleClientInput\tError in command")
						pPipeErr->addRecord(pErrLine)
					EndIf
					Exit While
				EndIf
				
			Case CommandStreamStrings.PARAMETER_STRING:
				pErrLine = loadRecordFromString(!"Server.handleClientInput\tBug: split parameter string")
				pPipeErr->addRecord(pErrLine)
				Exit While
				
			Case CommandStreamStrings.ECHO_STRING:
				/' Set echo string '/
				echo = pTemp->text
		End Select
		
		pTemp = pTemp->pNext
	Wend
	
	/' Either send out message or send out error '/
	Dim As Table Ptr pOut
	If pPipeErr->pHeader = 0 And pPipeErr->pRec = 0 Then
		/' All fine '/
		pOut = pPipeOut
	Else
		pPipeErr->addToHeader("error")
		pOut = pPipeErr
	EndIf
	
	/' Send to client '/
	If pOut->pHeader <> 0 Or pOut->pRec <> 0 Then
		Print "|--- " + pOut->toPrettyString() + " ---|"
		pTalker->sendTable(pOut)
	End If
	
	If pStream <> 0 Then Delete pStream
	If pPipeIn <> 0 Then Delete pPipeIn
	If pPipeOut <> 0 Then Delete pPipeOut
	If pPipeErr <> 0 Then Delete pPipeErr
End Sub


Sub Server.handleChatRooms()
	/' Broadcast lobby messages '/
	Dim As Table Ptr pLobbyTab = this.lobby.writeToTable()
			
	/' Assuming theres something to say, broadcast it '/
	If pLobbyTab <> 0 Then
		/' Loop through clients and send them the message '/
		Dim As Client Ptr pTemp = this.pClient
		While pTemp <> 0
			pTemp->sendTable(pLobbyTab)
			
			pTemp = pTemp->pNext
		Wend
		
		Delete pLobbyTab
	EndIf
End Sub
