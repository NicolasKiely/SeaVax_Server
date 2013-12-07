/'----------------------------------------------------------------------------
 ' Manages a chat room. Buffers messages being sent around
 ---------------------------------------------------------------------------'/

#Include Once "ChatMessage.bi"
#Include Once "../table/Table.bi"

 
/' List of messages and listeners '/
Type ChatRoom
	Dim As ChatMsg Ptr pFirst
	Dim As ChatMsg Ptr pLast
	
	Dim As String roomName
	
	/' Adds message to list '/
	Declare Sub addMsg(newAuthor As String, newMsg As String)
	
	/' Writes message list to table, then clears out message buffer '/
	Declare Function writeToTable() As Table Ptr
	
	Declare Constructor()
	Declare Destructor()
End Type

