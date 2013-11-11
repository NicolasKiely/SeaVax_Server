#Include Once "MazeManager.bi"


Function loadMazeStats(pAcc As Account Ptr) As Table Ptr
	If pAcc = 0 Then Return 0
	
	/' Attempt load from disk '/
	Dim As String statsPath = pAcc->getPath("mazes.txt")
	Dim As Table Ptr pTab = loadTableFromFile(statsPath, 0)
	
	If pTab = 0 Then
		pTab = New Table()
		
		/' Handle case of bad load '/
		pTab->addToColumn(MAZE_ID_HEADER)
		pTab->addToColumn(MAZE_NAME_HEADER)
		pTab->addToColumn(MAZE_SIZE_HEADER)
		pTab->addToColumn(MAZE_WINS_HEADER)
		pTab->addToColumn(MAZE_PLAYS_HEADER)
		pTab->addToColumn(MAZE_STAGED_HEADER)
		
		pTab->save(statsPath)
	EndIf
	
	Return pTab
End Function


Function isValidMapSize(size As Integer) As Integer
	If size = FREE_MAX_MAP_SIZE Then Return -1
	If size = ENTRY_MAX_MAP_SIZE Then Return -1
	If size = SILVER_MAX_MAP_SIZE Then Return -1
	If size = GOLD_MAX_MAP_SIZE Then Return -1
	Return 0
End Function


Function getMaxMazeSize(package As String) As Integer
	Dim As String lPackage = LCase(package)
	
	If lpackage = "free" Then
		Return FREE_MAX_MAP_SIZE
	ElseIf lpackage = "entry" Then
		Return ENTRY_MAX_MAP_SIZE
	ElseIf lpackage = "silver" Then
		Return SILVER_MAX_MAP_SIZE
	ElseIf lpackage = "gold" Then
		Return GOLD_MAX_MAP_SIZE
	Else
		Return 0
	EndIf
End Function


Function isAllowedMazeName(mazeName As String) As Integer
	If Len(mazeName) > 16 Then Return 0
	
	For i As Integer = 0 To Len(mazeName)-1
		Dim As UByte c = mazeName[i]
		
		/' Allow numbers'/
		If c >= 48 And c <= 57 Then Continue For
		/' Allow underscore '/
		If c = 95 Then Continue For
		/' Allow upper case letters '/
		If c >= 65 And c <= 90 Then Continue For
		/' Allow lower case letters '/
		If c >= 97 And c <= 122 Then Continue For
		
		Return c
	Next
	
	Return -1
End Function


Function getFreeMazeIndex(pMazeTab As Table Ptr) As Integer
	If pMazeTab = 0 Then Return -1
	Dim As Integer loIndex = 0
	Dim As Integer hiIndex = 0
	
	Dim As Integer colIndex = pMazeTab->getColumnID(MAZE_ID_HEADER)
	
	/' Loop through maze table '/
	Dim As Record Ptr pRec = pMazeTab->pRec
	While pRec <> 0
		Dim As Fld Ptr pFld = pRec->getFieldByID(colIndex)
		If pFld <> 0 Then
			/' Check table index value against current values '/
			Dim As Integer fldVal = ValInt(pFld->value)
			
			/' Update high index first '/
			If fldVal >= hiIndex Then hiIndex = fldVal + 1
			
			/' Update low index '/
			If fldVal = loIndex Then loIndex = hiIndex
		EndIf
		
		pRec = pRec->pNext
	Wend
	
	Return loIndex
End Function


Sub initializeMazeFile(pAcc As Account ptr, id As Integer, size As Integer)
	If (pAcc = 0) Or (id < 0) Or (size < 10) Then Exit Sub
	
	/' Figure out path name for maze '/
	Dim As String path = pAcc->getPath("maze_" + Str(id) + ".txt")
	
	/' Open maze file '/
	Dim As Integer fh = FreeFile()
	Open path For Output As #fh
	
	/' Print empty map '/
	For y As Integer = 0 To size-1
		For x As Integer = 0 To size-1
			If x < size-1 Then
				Print #fh, MAZE_TILE_PASSABLE;
			Else
				Print #fh, MAZE_TILE_PASSABLE
			EndIf
		Next
	Next
	
	Close #fh
End Sub



Sub loadMazeAsTable(fileName As String, pTable As Table Ptr)
	Dim As Integer fh = FreeFile()
	Open fileName For Input As #fh
	If Err = 2 Or Err = 3 Then Exit Sub
	Dim As Integer counter = 0
	
	
	Do Until Eof(fh)
		Dim As String fileLine
		Line Input #fh, fileLine
		
		If fileLine = "" Then Continue Do
		
		/' Load line into record '/
		Dim As Record Ptr pRec = New Record()
		For i As Integer = 0 To Len(fileLine)-1
			pRec->addField(Chr(fileLine[i]))
			
			If counter >= 0 Then
				/' Build column header with first line '/
				pTable->addToColumn(Str(counter))
				counter += 1
			EndIf
		Next
		
		/' Disable adding to columns '/
		counter = -1
		
		/' Add record to table '/
		pTable->addRecord(pRec)
	Loop
	
	Close #fh
End Sub
