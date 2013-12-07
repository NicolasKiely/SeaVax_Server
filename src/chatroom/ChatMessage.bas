#Include Once "ChatMessage.bi"

Constructor ChatMsg()
	this.msg = ""
	this.author = ""
	
	this.pNext = 0
End Constructor


Destructor ChatMsg()
	this.msg = ""
	this.author = ""
	If this.pNext <> 0 Then Delete this.pNext
End Destructor
