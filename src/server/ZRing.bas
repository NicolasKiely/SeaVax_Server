#Include Once "ZRing.bi"



Constructor ZRing()
	bufSize = 0
	iStart = 0
	iEnd = 0
	pBuf = 0
End Constructor


Destructor ZRing()
	If pBuf <> 0 Then Delete pBuf
End Destructor


Sub ZRing.alloc(newSize As Integer)
	If pBuf <> 0 Then Delete pBuf
	
	this.bufSize = newSize
	
	/' Allocate memory '/
	this.pBuf = Callocate(this.bufSize+1)
	
	/' Initialize markers '/
	this.iStart = 0
	this.iEnd = 0
	
	/' Set last byte to 0 '/
	this.pBuf[this.bufSize] = 0
End Sub


Function ZRing.popNext() As UByte
	If this.pBuf = 0 Then Return 0
	
	/' Knock off first character '/
	Dim As UByte c = this.pBuf[this.iStart]
	
	/' Zero back the first character '/
	this.pBuf[this.iStart] = 0
	
	
	/' Increment iStart '/
	this.iStart += 1
	If this.iStart >= this.bufSize Then
		this.iStart = 0
	EndIf
	
	/' Check if last character '/
	If this.iStart = this.iEnd Then
		/' Reset entire ring '/
		this.iStart = 0
		this.iEnd = 0
	EndIf
	
	Return c
End Function


Function ZRing.isEmpty() As Integer
	If this.pBuf = 0 Then
		Return -1
	EndIf
	
	If this.iStart = this.iEnd Then
		Return -1
	Else
		Return 0
	EndIf
End Function


Function ZRing.getSize() As Integer
	If this.pBuf = 0 Then Return 0
	
	If this.iStart = this.iEnd Then
		/' Nothing stored '/
		Return 0
	
	ElseIf this.iStart < this.iEnd Then
		/' Straight away cut '/
		Return this.iEnd - this.iStart
		
	Else
		/' Wrap around '/
		Return (this.bufSize - this.iStart) + this.iEnd
	EndIf
End Function


Function ZRing.getFreeSpace() As Integer
	If this.pBuf = 0 Then Return 0
	
	/' Count off one byte because full buffer has same profile as empty one
	 since both cases have iStart = iEnd '/
	Return this.bufSize - (this.getSize() + 1)
End Function


Function ZRing.addZ(zNewStr As ZString Ptr, strSize As Integer) As Integer
	If this.pBuf = 0 Then Return -1
	
	If strSize > this.getFreeSpace() Then
		/' Not enough space '/
		Return -1
	EndIf
	
	/' Get space to end of buffer '/
	Dim As Integer toEnd = This.bufSize - this.iEnd
	
	
	If strSize > toEnd Then
		/' Copy to end, then wrap around '/
		Dim As Integer leftOver = strSize-toEnd
		
		For i As Integer = 0 To toEnd-1
			this.pBuf[i+iEnd] = zNewStr[i]
		Next
		
		For i As Integer = 0 To leftOver-2
			this.pBuf[i] = zNewStr[i+leftOver+1]
		Next
		
	Else
		/' Copy straight after iEnd '/
		For i As Integer = 0 To strSize-1
			this.pBuf[i+iEnd] = zNewStr[i]
		Next
	EndIf
	
	/' Add string size to iEnd '/
	iEnd += strSize
	
	/' Handle wrapping around '/
	If iEnd > this.bufSize Then iEnd = iEnd - this.bufSize
	
	Return 0
End Function
