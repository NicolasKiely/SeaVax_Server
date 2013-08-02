#Include Once "Table.bi"



Constructor Fld()
	this.value = ""
	this.pNext = 0
End Constructor


Destructor Fld()
	If this.pNext <> 0 Then Delete this.pNext
	this.value = ""
End Destructor


Function Fld.rToString() As String
	If this.pNext <> 0 Then
		Return this.value + Chr(9) + this.pNext->rToString()
	Else
		Return this.value
	EndIf
End Function


Constructor Record()
	this.pFld = 0
	this.lFld = 0

	this.pNext = 0
End Constructor


Destructor Record()
	If this.pFld <> 0 Then Delete pFld
	If this.pNext <> 0 Then Delete pNext
End Destructor


Function Record.addField(text As String) As Integer
	Dim As Fld Ptr pNewFld = New Fld()
	If pNewFld = 0 Then Return -1
	
	pNewFld->value = text
	
	If this.pFld = 0 Then
		/' Add first header value '/
		this.pFld = pNewFld
		this.lFld = pNewFld
	
	Else
		/' Add to last header value '/
		this.lFld->pNext = pNewFld
		this.lFld = pNewFld
	EndIf
	
	Return 0
End Function


Function Record.getFieldByID(colID As Integer) As Fld Ptr
	Dim As fld Ptr pRet
	Dim As Integer i
	
	/' Catch lower-bound error '/
	If colID < 0 Then Return 0
	
	/' Loop through fields '/
	pRet = this.pFld
	While pRet <> 0
		If i = colID Then
			/' Found match, return '/
			Return pRet
		EndIf
		
		i += 1
		pRet = pRet->pNext
	Wend
	
	/' Looped to end of field, return null '/
	Return 0
End Function


Constructor Table()
	pHeader = 0
	pCol = 0
	pRec = 0
	
	lHeader = 0
	lCol = 0
	lRec = 0
	
	headerNum = 0
	colNum = 0
	recNum = 0
End Constructor


Destructor Table()
	If pHeader <> 0 Then Delete pHeader
	If pCol <> 0 Then Delete pCol
	If pRec <> 0 Then Delete pRec
End Destructor


Function Table.addToHeader(text As String) As Integer
	Dim As Fld Ptr pNewFld = New Fld()
	If pNewFld = 0 Then Return -1
	
	pNewFld->value = text
	
	If this.pHeader = 0 Then
		/' Add first header value '/
		this.pHeader = pNewFld
		this.lHeader = pNewFld
	
	Else
		/' Add to last header value '/
		this.lHeader->pNext = pNewFld
		this.lHeader = pNewFld
	EndIf
	
	This.headerNum += 1
	Return 0
End Function


Function Table.addToColumn(text As String) As Integer
	Dim As Fld Ptr pNewFld = New Fld()
	If pNewFld = 0 Then Return -1
	
	pNewFld->value = text
	
	If this.pCol = 0 Then
		/' Add first header value '/
		this.pCol = pNewFld
		this.lCol = pNewFld
	
	Else
		/' Add to last header value '/
		this.lCol->pNext = pNewFld
		this.lCol = pNewFld
	EndIf
	
	This.colNum += 1
	Return 0
End Function


Function Table.addRecord(pNewRecord As Record Ptr) As Integer
	If pNewRecord = 0 Then
		Return -1
	EndIf
	
	If this.pRec = 0 Then
		/' Add first record '/
		this.pRec = pNewRecord
		this.lRec = pNewRecord
	
	Else
		/' Add to end of table '/
		this.lRec->pNext = pNewRecord
		this.lRec = pNewRecord
	EndIf
	
	this.recNum += 1
	Return 0
End Function


Function Table.appendField(text As String) As Integer
	If this.pRec=0 Or this.lRec=0 Then
		/' Cant add to anything '/
		Return -1
		
	Else
		this.lRec->addField(text)
		Return 0
	EndIf
End Function


Function loadTableFromFile(fileName As String) As Table Ptr
	/' Create table '/
	Dim As Table Ptr pTable = New Table()
	If pTable = 0 Then Return 0
	
	
	/' Attempt to open up file '/
	Dim As Integer fh = FreeFile()
	Open fileName For Input As #fh
	Dim As Integer e = Err
	If e = 2 Or e = 3 Then
		Return 0
	EndIf
	
	/' Set title '/
	pTable->addToHeader(fileName)
	
	/' Load up columns '/
	Dim As String colLine
	Line Input #fh, colLine
	
	/' Error, no columns '/
	If Len(colLine) = 0 Then 
		Close #fh
		Delete pTable
		Return 0
	EndIf
	
	Dim As String tempBuf = ""
	For i As Integer = 0 To Len(colLine) - 1
		Dim As UByte c = colLine[i]
		
		If c = 9 Then
			/' Tab '/
			If pTable->addToColumn(tempBuf) Then
				Close #fh
				Delete pTable
				Return 0
			EndIf
			tempBuf = ""
		
		Else
			tempBuf += Chr(c)

		EndIf
	Next
	/' Add last column '/
	If pTable->addToColumn(tempBuf) Then
		Close #fh
		Delete pTable
		Return 0
	EndIf

	
	/' Load records '/
	While Eof(fh) = 0
		'Print "Loading record field"
		
		Dim As String recBuf
		Line Input #fh, recBuf
		
		If pTable->addRecord(loadRecordFromString(recBuf)) Then
			Close #fh
			Delete pTable
			Return 0
		EndIf
		
	Wend
	
	
	Close #fh
	Return pTable
End Function


Function loadRecordFromString(recStr As String) As Record Ptr
	Dim As Record Ptr pRec = New Record()
	If pRec = 0 Then Return 0
	
	Dim As String tempBuf = ""
	For i As Integer = 0 To Len(recStr) - 1
		Dim As UByte c = recStr[i]
		
		If c = 9 Then
			If pRec->addField(tempBuf) Then
				Delete pRec
				Return 0
			EndIf
			
			tempBuf = ""
		
		Else
			tempBuf += Chr(c)
		EndIf
	Next
	
	If pRec->addField(tempBuf) Then
		Delete pRec
		Return 0
	EndIf
	
	Return pRec
End Function


Function Table.toString() As String
	Dim As String tabStr = ""
	Dim As Record Ptr pTemp
	Dim As String d = Chr(10)' + Chr(13)
	
	/' Header '/
	If this.pHeader <> 0 Then
		tabStr = pHeader->rToString()
	EndIf
	tabStr += d
	
	/' Columns '/
	If this.pCol <> 0 Then
		tabStr += pCol->rToString()
	EndIf
	tabStr += d
	
	/' Records '/
	pTemp = this.pRec
	
	While pTemp <> 0
		tabStr += pTemp->pFld->rToString()
		
		If pTemp->pNext <> 0 Then
			tabStr += d
		EndIf
		
		pTemp = pTemp->pNext
	Wend

	Return tabStr
End Function


Function Table.getColumnID(columnName As String) As Integer
	Dim As Integer id
	Dim As Fld Ptr pTemp = this.pCol
	While pTemp <> 0
		If pTemp->value = columnName Then
			/' Found match, return '/
			Return id
		EndIf
		
		/' Loop to next column '/
		pTemp = pTemp->pNext
		id += 1
	Wend
	
	/' Failed to find match '/
	Return -1
End Function


Function Table.getColumnID_IC(columnName As String) As Integer
	Dim As Integer id
	Dim As Fld Ptr pTemp = this.pCol
	While pTemp <> 0
		If LCase(pTemp->value) = LCase(columnName) Then
			/' Found match, return '/
			Return id
		EndIf
		
		/' Loop to next column '/
		pTemp = pTemp->pNext
		id += 1
	Wend
	
	/' Failed to find match '/
	Return -1
End Function


Sub Table.refresh()
	/' Free memory '/
	If pHeader <> 0 Then Delete pHeader
	If pCol <> 0 Then Delete pCol
	If pRec <> 0 Then Delete pRec
	
	/' Zero everything out '/
	pHeader = 0
	pCol = 0
	pRec = 0
	
	lHeader = 0
	lCol = 0
	lRec = 0
	
	headerNum = 0
	colNum = 0
	recNum = 0
End Sub


Function Table.findValue(key As String) As String
	Dim As String results = ""
	
	/' Loop through records '/
	Dim As Record Ptr pTemp = this.pRec
	While pTemp <> 0
		/' Make sure fields exist '/
		Dim As Fld Ptr pKeyFld = pTemp->pFld
		Dim As Fld Ptr pValFld
		If pKeyFld = 0 Then Continue While
		pValFld = pKeyFld->pNext
		If pValFld = 0 Then Continue While
		
		If pKeyFld->value = key Then
			/' Found match '/
			results = pValFld->value
			Exit While
		EndIf
		
		pTemp = pTemp->pNext
	Wend
	
	Return results
End Function
