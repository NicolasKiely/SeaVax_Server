#Include Once "GameRoom.bi"


Constructor GameRoom(pNewHost As Account Ptr, newMax As Integer, newSize As Integer, newType As String)
	this.inSession = 0
	this.maxPlyr = newMax
	this.numPlyr = 1
	this.pNext = 0
	this.gameType = newType
	this.mapSize = newSize
	
	/' Create buffer for references to accounts '/
	this.ppList = New Account Ptr[this.maxPlyr]
	
	/' Set host '/
	this.ppList[0] = pNewHost
	pNewHost->pRoom = @this
End Constructor


Destructor GameRoom()
	If this.ppList <> 0 Then
		For i As Integer = 0 To this.maxPlyr-1
			this.ppList[i] = 0
		Next
		
		Delete[] this.ppList
	EndIf
	
	If this.pNext <> 0 Then Delete this.pNext
End Destructor


Function GameRoom.addAccount(pAcc As Account Ptr) As Integer
	If this.numPlyr >= this.maxPlyr Then Return 0
	If pAcc = 0 Then Return 0
	If this.ppList = 0 Then Return 0
	
	For i As Integer = 0 To this.maxPlyr-1
		If this.ppList[i] = 0 Then
			this.ppList[i] = pAcc
			this.numPlyr += 1
			
			pAcc->pRoom = @this
			Return -1
		EndIf
	Next
	
	Return 0
End Function


Function GameRoom.getHostName() As String
	If this.ppList = 0 Then Return "#Unallocated#"
	If this.ppList[0] = 0 Then Return "#Orphaned#"
	Return this.ppList[0]->userName
End Function
