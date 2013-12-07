#Include Once "GameManager.bi"

Constructor GameManager()
	this.pRoot = 0
	this.numRooms = 0
End Constructor


Destructor GameManager()
	If this.pRoot <> 0 Then Delete this.pRoot
End Destructor


Sub GameManager.addRoom(pNewRoom As GameRoom Ptr)
	If this.pRoot = 0 Then
		this.pRoot = pNewRoom
		this.numRooms = 1
		
	Else
		pNewRoom->pNext = this.pRoot
		this.pRoot = pNewRoom
		this.numRooms += 1
	EndIf
End Sub


Sub GameManager.removeRoom(pDelRoom As GameRoom Ptr)
	If this.pRoot = 0 Or pDelRoom = 0 Then Exit Sub
	
	If this.pRoot = pDelRoom Then
		this.pRoot = this.pRoot->pNext
		pDelRoom->pNext = 0
		Delete pDelRoom
		this.numRooms -= 1
		
	Else
		Dim As GameRoom Ptr pRoom = this.pRoot
		While pRoom->pNext <> pDelRoom
			If pRoom->pNext = 0 Then
				Print "Error, tried to remove room not in list"
				Exit Sub
			EndIf
			
			pRoom = pRoom->pNext
		Wend
		
		pRoom->pNext = pDelRoom->pNext
		pDelRoom->pNext = 0
		Delete pDelRoom
		this.numRooms -= 1
	EndIf
End Sub


Function GameManager.lookupPlayersGame(playerName As String) As GameRoom Ptr
	Dim As GameRoom Ptr pRoom = this.pRoot
	
	While pRoom <> 0
		If pRoom->getHostName() = playerName Then
			Return pRoom
		EndIf
		
		pRoom = pRoom->pNext
	Wend
	
	Return 0
End Function
