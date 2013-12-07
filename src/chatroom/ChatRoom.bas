#Include Once "ChatRoom.bi"


Constructor ChatRoom()
	this.pFirst = 0
	this.pLast = 0
	this.roomName = ""
End Constructor


Destructor ChatRoom()
	If this.pFirst <> 0 Then Delete this.pFirst
End Destructor


Sub ChatRoom.addMsg(newAuthor As String, newMsg As String)
	Dim As ChatMsg Ptr pChat = New ChatMsg()
	pChat->msg = newMsg
	pChat->author = newAuthor
	
	If this.pFirst = 0 Then
		/' Adding first message '/
		this.pFirst = pChat
		this.pLast = pChat
		
	Else
		/' Adding message to nonempty list '/
		this.pLast->pNext = pChat
	EndIf
End Sub


Function ChatRoom.writeToTable() As Table Ptr
	If this.pFirst = 0 Or this.pLast = 0 Then Return 0
	
	Dim As Table Ptr pTable = New Table()
	
	/' Set up header '/
	pTable->addToHeader("chat")
	pTable->addToHeader(this.roomName)
	pTable->addToColumn("author")
	pTable->addToColumn("message")
	
	/' Loop through messages '/
	Dim As ChatMsg Ptr pMsg = this.pFirst
	While pMsg <> 0
		pTable->addRecord(New Record())
		pTable->appendField(pMsg->author)
		pTable->appendField(pMsg->msg)
		
		pMsg = pMsg->pNext
	Wend
	
	/' Clean up messages '/
	If this.pFirst <> 0 Then Delete this.pFirst /' Why is pFirst 0 at this point?! '/
	this.pFirst = 0
	this.pLast = 0
	
	Return pTable
End Function
