#Include Once "FunctionList.bi"
#Include Once "../server/Server.bi"


/' Description:
 '  Sends chat message to a chat room
 '
 ' Command name:
 '  /msg/chat
 '
 ' Target:
 '  Clients, Players, and Accounts. Dependent on room
 '
 ' Parameters:
 ' - (r)oom : specific chat room to say
 ' - (m)essage: Message to say
 '
 ' Output:
 '  None. Chat message broadcasting is done by the chatroom/ChatRoom module
 '/
Sub CMD_chatMessage(pPipeIn As Table Ptr, pPipeOut As Table Ptr, _
		pPipeErr As Table Ptr, pParam As Param Ptr, _
		aClient As Any Ptr, aServer As Any Ptr)
	
	Dim As Server Ptr pServer = CPtr(Server Ptr, aServer)
	Dim As Client Ptr pClient = CPtr(Client Ptr, aClient)
	Dim As Record Ptr pLineErr = 0
	
	/' Pop parameters '/
	Dim As Param Ptr prmRoom = pParam->popParam("room", "r")
	Dim As Param Ptr prmMsg = pParam->popParam("message", "m")
	
	If pParam->pNext <> 0 Then
		pLineErr = New Record()
		pLineErr->addField("CmdChatMessage")
		pLineErr->addField("Undefined parameter found")
		pLineErr->addField(pParam->pNext->text)
		pPipeErr->addRecord(pLineErr)
	EndIf
	
	/' Find target chat room '/
	Dim As ChatRoom Ptr pRoom = 0
	Dim As String roomName = ""
	If prmRoom <> 0 Then
		/' Get the value '/
		If prmRoom->pVals <> 0 Then
			roomName = prmRoom->pVals->text
			
			/' Lookup rooms '/
			If roomName = "lobby" Then
				pRoom = @(pServer->lobby)
				
			Else
				pLineErr = New Record()
				pLineErr->addField("CmdChatMessage")
				pLineErr->addField("Room not found")
				pLineErr->addField(roomName)
				pPipeErr->addRecord(pLineErr)
			EndIf
			
		Else			
			pLineErr = New Record()
			pLineErr->addField("CmdChatMessage")
			pLineErr->addField("-room parameter needs value")
			pLineErr->addField("Use: -room lobby or -room game")
			pPipeErr->addRecord(pLineErr)
		EndIf
		
	Else
		
		/' Chat room needs to be specified '/
		pLineErr = New Record()
		pLineErr->addField("CmdChatMessage")
		pLineErr->addField("Chat room not specified")
		pLineErr->addField("Use: -room lobby or -room game")
		pPipeErr->addRecord(pLineErr)
	EndIf
	
	/' Bail if unable to find room '/
	If pRoom = 0 Then
		If prmRoom <> 0 Then Delete prmRoom
		If prmMsg <> 0 Then Delete prmMsg
		Exit Sub
	EndIf
	
	/' Get message '/
	If prmMsg <> 0 Then
		If prmMsg->pVals <> 0 Then
			 /' Send message to chat room '/
			 pRoom->addMsg(pClient->getName, prmMsg->pVals->text)
		
		Else
			pLineErr = New Record()
			pLineErr->addField("CmdChatMessage")
			pLineErr->addField("Message has no text")
			pLineErr->addField("Use: -message 'your message'")
			pPipeErr->addRecord(pLineErr)
		End If
		
	Else
		pLineErr = New Record()
		pLineErr->addField("CmdChatMessage")
		pLineErr->addField("Message not specified")
		pLineErr->addField("Use: -message 'your message'")
		pPipeErr->addRecord(pLineErr)
	EndIf
	
	If prmRoom <> 0 Then Delete prmRoom
	If prmMsg <> 0 Then Delete prmMsg
End Sub