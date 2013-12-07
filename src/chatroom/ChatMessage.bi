/'----------------------------------------------------------------------------
 ' Manages a chat list. Message order is from oldest to newest
 ---------------------------------------------------------------------------'/

/' Linked list of chat messages '/
Type ChatMsg
	/' Message '/
	Dim As String msg
	
	/' Author '/
	Dim As String author
	
	/' Next message in list '/
	Dim As ChatMsg Ptr pNext
	
	Declare Constructor()
	Declare Destructor()
End Type
