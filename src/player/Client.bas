#Include Once "Client.bi"
#Include Once "../Header.bi"
#Include Once "../server/Server.bi"


Constructor Client()
	Print "Creating client: "; @this
	this.sock = -1
	this.pNext = 0
	this.markForDeletion = 0
	this.pAcc = 0
	
	This.pNetBuf = New ZRing()
	this.pNetBuf->alloc(LARGE_NET_BUFFER)
End Constructor


Destructor Client()
	this.freeSelf()
End Destructor


Sub client.freeSelf()
	Print "Deleting client: "; @This
	
	If this.sock <> -1 Then
		#IFDEF __FB_WIN32__
		closeSocket(this.sock)
		#ELSE
		close(this.sock)
		#ENDIF
		this.sock = -1
	EndIf
	
	If this.pNext <> 0 Then 
		this.pNext->freeSelf()
		Delete this.pNext
		this.pNext = 0
	EndIf
	
	If this.pNetBuf <> 0 Then
		Delete this.pNetBuf
		this.pNetBuf = 0
	EndIf
	
	If this.pAcc <> 0 Then
		this.pAcc->isLoggedIn = 0
	EndIf
End Sub


Sub Client.sendTable(pTable As Table Ptr)
	If pTable = 0 Then Exit Sub
	If this.sock = -1 Then Exit Sub
	
	Dim As String tabStr = pTable->toString()
	
	Dim As Integer sendLen = send(this.sock, StrPtr(tabStr), Len(tabStr), 0)
End Sub


Function Client.getName() As String
	If this.pAcc = 0 Then
		Return "Client#" + Str(Hex(@This,4))
	else
		return this.pAcc->userName
	end If
End Function
