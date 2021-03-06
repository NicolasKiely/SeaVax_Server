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
			If this.ppList[i] <> 0 Then
				(this.ppList[i])->pRoom = 0
				this.ppList[i] = 0
			End If
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


Sub GameRoom.removeAccount(pAcc As Account Ptr)
	If pAcc = 0 Then Exit Sub
	If this.ppList = 0 Then Exit Sub
	
	/' Search for account pointer in list '/
	For i As Integer = 0 To this.maxPlyr-1
		If this.ppList[i] = pAcc Then
			/' Remove account from list '/
			this.ppList[i] = 0
			this.numPlyr -= 1
			
			/' Set account to be in no room '/
			pAcc->pRoom = 0
			
			Exit Sub
		End If
	Next
End Sub


Function GameRoom.getHostName() As String
	If this.ppList = 0 Then Return "#Unallocated#"
	If this.ppList[0] = 0 Then Return "#Orphaned#"
	Return this.ppList[0]->userName
End Function


Function GameRoom.getHostAccount() As Account Ptr
	If this.ppList = 0 Then Return 0
	Return this.ppList[0]
End Function


Sub writeRoomToTable(pRoom As GameRoom ptr, pTable As Table Ptr)
	If pTable = 0 Then Exit Sub
	
	/' Set up columns, then add record '/
	writeRoomColumns(pTable)
	writeRoomRecord(pRoom, pTable)
End Sub


Sub writeRoomColumns(pTable As Table Ptr)
	If pTable = 0 Then Exit Sub
	
	/' Set up columns '/
	pTable->addToColumn("Host")
	pTable->addToColumn("Type")
	pTable->addToColumn("Count")
	pTable->addToColumn("Max")
	pTable->addToColumn("Size")
End Sub


Sub writeRoomRecord(pRoom As GameRoom Ptr, pTable As Table Ptr)
	If pTable = 0 Then Exit Sub
	
	/' Add record '/
	Dim As Record Ptr pRec = New Record()
	If pRoom = 0 Then
		/' No Room '/
		pRec->addField("#NULL#")
		pRec->addField("#NULL#")
		pRec->addField("0")
		pRec->addField("0")
		pRec->addField("0")
		
	Else
		/' Add room in record '/
		pRec->addField(pRoom->getHostName())
		pRec->addField(pRoom->gameType)
		pRec->addField(Str(pRoom->numPlyr))
		pRec->addField(Str(pRoom->maxPlyr))
		pRec->addField(Str(pRoom->mapSize))
	End If
	
	pTable->addRecord(pRec)
End Sub
