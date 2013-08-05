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
	
	/' Find target chat room '/
	Dim As ChatRoom Ptr pRoom = 0
	Dim As String roomName = ""
	
	/' Get the value '/
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

	
	/' Bail if unable to find room '/
	If pRoom = 0 Then
		If prmRoom <> 0 Then Delete prmRoom
		If prmMsg <> 0 Then Delete prmMsg
		Exit Sub
	EndIf
	
	/' Send message to chat room '/
	pRoom->addMsg(pClient->getName, prmMsg->pVals->text)
	
	If prmRoom <> 0 Then Delete prmRoom
	If prmMsg <> 0 Then Delete prmMsg
End Sub