#Include Once "Table.bi"
#Include Once "Query.bi"



Constructor Fld()
	this.value = ""
	this.pNext = 0
End Constructor


Destructor Fld()
	If this.pNext <> 0 Then Delete this.pNext
	this.value = ""
End Destructor


Function Fld.rToString(fldDel As String = CHR_FIELD_DELIMITER) As String
	If this.pNext <> 0 Then
		Return this.value + fldDel + this.pNext->rToString(fldDel)
	Else
		Return this.value
	EndIf
End Function


Function Fld.rToDivString(div As Integer, counter As Integer = 0) As String
	If this.pNext <> 0 Then
		If div = 0 Then
			/' Ignore division '/
			Return this.value + CHR_FIELD_DELIMITER + this.pNext->rToDivString(div, counter)
			
		Else
			/' Factor in dividing string '/
			If div <= counter Then
				Return this.value + CHR_TABLE_DELIMITER + this.pNext->rToDivString(div, 0)
				
			Else
				return this.value + CHR_FIELD_DELIMITER + this.pNext->rToDivString(div, counter+1)
			EndIf
		EndIf
	Else
		Return this.value
	EndIf
End Function


Function Fld.getNumberOfFields() As Integer
	If this.pNext <> 0 Then
		Return this.pNext->getNumberOfFields() + 1
	Else
		Return 1
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
	Dim As Integer i = 0
	
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


Function Record.clone() As Record Ptr
	Dim As Record Ptr pNew = New Record()
	Dim As Fld Ptr pTmp = this.pFld
	
	While pTmp <> 0
		/' Copy field value '/
		pNew->addField(pTmp->value)
		
		pTmp = pTmp->pNext
	Wend
	
	Return pNew
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


Function Table.hasRecords() As Integer
	If this.pRec = 0 Then Return 0
	If this.pRec->pFld = 0 Then Return 0
	Return -1
End Function


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


Function loadTableFromFile(fileName As String, pTable As Table Ptr = 0) As Table Ptr
	/' Create table '/
	If pTable = 0 Then pTable = New Table()
	If pTable = 0 Then Return 0
	
	
	/' Attempt to open up file '/
	Dim As Integer fh = FreeFile()
	Open fileName For Input As #fh
	Dim As Integer e = Err
	If e = 2 Or e = 3 Then
		Return 0
	EndIf
	
	/' Set title '/
	'pTable->addToHeader(fileName)
	
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
		
		If c = ASC_FIELD_DELIMITER Then
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
		
		If c = ASC_FIELD_DELIMITER Then
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
	
	/' Header '/
	If this.pHeader <> 0 Then
		tabStr = pHeader->rToString(CHR_FIELD_DELIMITER)
	EndIf
	tabStr += CHR_TABLE_DELIMITER
	
	/' Columns '/
	If this.pCol <> 0 Then
		tabStr += pCol->rToString(CHR_FIELD_DELIMITER)
	EndIf
	tabStr += CHR_TABLE_DELIMITER
	
	/' Records '/
	pTemp = this.pRec
	While pTemp <> 0
		tabStr += pTemp->pFld->rToString(CHR_FIELD_DELIMITER)
		
		If pTemp->pNext <> 0 Then
			/' Append extra field delimiter between records '/
			tabStr += CHR_FIELD_DELIMITER
		EndIf
		
		pTemp = pTemp->pNext
	Wend
	tabStr += CHR_TABLE_DELIMITER

	Return tabStr
End Function


Function Table.toPrettyString() As String
	Dim As String tabStr = "[H: "
	Dim As Record Ptr pTemp
	
	/' Header '/
	If this.pHeader <> 0 Then tabStr += pHeader->rToString(CHR_FIELD_DELIMITER)
	tabStr += "]" + CHR_TABLE_DELIMITER + "[C: "
	
	/' Columns '/
	If this.pCol <> 0 Then
		tabStr += pCol->rToString(CHR_FIELD_DELIMITER)
	EndIf
	tabStr += "]" + CHR_TABLE_DELIMITER + "[R: "
	
	/' Records '/
	pTemp = this.pRec
	While pTemp <> 0
		tabStr += pTemp->pFld->rToString(CHR_FIELD_DELIMITER)
		
		If pTemp->pNext <> 0 Then
			/' Append extra field delimiter between records '/
			tabStr += " ..." + CHR_TABLE_DELIMITER
		EndIf
		
		pTemp = pTemp->pNext
	Wend
	tabStr += "]" + CHR_TABLE_DELIMITER

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


Sub Table.save(fileName As String)
	/' Open info file '/
	Dim As Integer fh = FreeFile()
	Open fileName For Output As #fh
	
	If Err=3 OrElse Err=2 Then Exit Sub
	
	/' Print columns '/
	If this.pCol <> 0 Then Print #fh, this.pCol->rToString(Chr(9))
	
	Dim As Record Ptr pRs = this.pRec
	While pRs <> 0
		Print #fh, pRs->pFld->rToString(Chr(9))
		pRs = pRs->pNext
	Wend
	
	Close #fh
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


Function Table.findValue_IC(key As String) As String
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
		
		If LCase(pKeyFld->value) = LCase(key) Then
			/' Found match '/
			results = pValFld->value
			Exit While
		EndIf
		
		pTemp = pTemp->pNext
	Wend
	
	Return results
End Function


Function Table.getNumberOfColumns() As Integer
	If this.pCol = 0 Then
		Return 0
	Else
		Return this.pCol->getNumberOfFields()
	EndIf
End Function


Function Table.getRecordByField(value As String, colName As String) As Record Ptr
	Dim As Integer colIndex = this.getColumnID(colName)
	If colIndex < 0 Then Return 0
	
	/' Loop though records '/
	Dim As Record Ptr pRecTemp = this.pRec
	While pRecTemp <> 0
		/' Loop through fields of record '/
		Dim As Integer i = 0
		Dim As Fld Ptr pTempFld = pRecTemp->pFld
		While pTempFld<>0
			If i = colIndex Then
				/' Check field value '/
				If pTempFld->value = value Then
					Return pRecTemp
				Else
					/' Done checking field '/
					Exit While
				EndIf
			EndIf
			
			i += 1
			pTempFld = pTempFld->pNext
		Wend
		
		pRecTemp = pRecTemp->pNext
	Wend
	
	Return 0
End Function


Sub Table.removeRecordByField(value As String, colName As String)
	Dim As Integer colIndex = this.getColumnID(colName)
	If colIndex < 0 Then Exit Sub
	
	/' Loop though records '/
	Dim As Record Ptr pCurRec = this.pRec
	Dim As Record Ptr pPrevRec = 0
	
	While pCurRec <> 0
		/' Lookup field '/
		Dim As Fld Ptr pFld = pCurRec->getFieldByID(colIndex)
		If pFld->value = value Then
			/' Delete this record '/
			If pPrevRec = 0 Then
				/' First record in table, push table pointer forward '/
				this.pRec = pCurRec->pNext
				
				/' Delete old record '/
				pCurRec->pNext = 0
				Delete pCurRec
				
				/' Push current record tracker to first table pointer '/
				pCurRec = this.pRec
				Continue While
			
			Else
				/' Deleting middle record. Redirect previous node '/
				pPrevRec->pNext = pCurRec->pNext
				
				/' Delete old record '/
				pCurRec->pNext = 0
				Delete pCurRec
				
				/' Push current record tracker to next record '/
				pCurRec = pPrevRec->pNext
				Continue While
			EndIf
			
		EndIf
		
		
		/' Loop to next record '/
		pPrevRec = pCurRec
		pCurRec = pCurRec->pNext
	Wend
End Sub


Sub copyTableColumns(pSrc As Table Ptr, pDst As Table Ptr)
	If pSrc = 0 Or pDst = 0 Then Exit Sub
	
	Dim As Fld Ptr pCol = pSrc->pCol
	While pCol <> 0
		pDst->addToColumn(pCol->value)
		pCol = pCol->pNext
	Wend
End Sub


Function queryTable(pTable As Table Ptr, col As String, comp as String) As Table Ptr
	If Len(comp) < 4 Then Return 0
	If pTable = 0 Then Return 0
	
	Dim fComp As Function(As String, As String) As Integer
	Dim As String value = Mid(comp, 4)
	Dim As Table Ptr pQry
	Dim As Record Ptr pRec
	Dim As Integer index
	Dim As Fld Ptr pFld
	
	/' Lookup Query comparison func '/
	fComp = lookupQueryComparison(Left(comp, 3))
	If fComp = 0 Then Return 0
	
	/' Create subquery table with same columns as original '/
	pQry = New Table()
	copyTableColumns(pTable, pQry)
	
	/' Lookup index for column '/
	index = pTable->getColumnID(col)
	
	/' Run through records '/
	pRec = pTable->pRec
	While pRec <> 0
		/' Look up relavent field '/
		pFld = pRec->getFieldByID(index)
		If (pFld = 0) Then Continue While
	
		If fComp(pFld->value, value) Then
			/' Found match, add record to new table '/
			pQry->addRecord(pRec->clone())
		End If
		
		pRec = pRec->pNext
	Wend
	
	Return pQry
End Function
