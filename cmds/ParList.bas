#Include Once "crt/ctype.bi"
#Include Once "ParList.bi"


Constructor ParamVal()
	this.text = ""
	this.pNext = 0
End Constructor


Destructor ParamVal()
	this.text = ""
	If this.pNext <> 0 Then Delete this.pNext
End Destructor


Sub ParamVal.rAddVal(pNewVal As ParamVal Ptr)
	If this.pNext = 0 Then
		/' End of list '/
		this.pNext = pNewVal
		
	Else
		/' Continue down list '/
		this.rAddVal(pNewVal)
	EndIf
End Sub


Sub ParamVal.DEBUG_PRINT()
	/' Print self '/
	Print "   |"
	Print "   +-: '" +this.text+ "'"
	
	/' Call on rest of list '/
	If this.pNext <> 0 Then this.pNext->DEBUG_PRINT()
End Sub


Constructor Param()
	this.text = ""
	this.pNext = 0
	this.pVals = 0
	this.valCount = 0
End Constructor


Destructor Param()
	this.text = ""
	If this.pVals <> 0 Then Delete this.pVals
	If this.pNext <> 0 Then Delete this.pNext
End Destructor


Sub Param.rAddParam(pNewParam As Param Ptr)
	If this.pNext = 0 Then
		/' End of list '/
		this.pNext = pNewParam
	
	Else
		/' Tell next param to try to add '/
		this.pNext->rAddParam(pNewParam)
	EndIf
End Sub


Sub Param.addVal(pNewVal As ParamVal Ptr)
	If this.pVals = 0 Then
		/' Start of new list '/
		this.pVals = pNewVal
		
	Else
		/' Add to existing list '/
		this.pVals->rAddVal(pNewVal)
	EndIf
	
	this.valCount += 1
End Sub


Sub Param.DEBUG_PRINT()
	/' Print self '/
	Print "---+-> (" +Str(this.valCount)+ ") '" +this.text+ "'"
	
	/' Print values '/
	If this.pVals <> 0 Then this.pVals->DEBUG_PRINT()
	
	/' Print rest of parameters '/
	If this.pNext <> 0 Then 
		Print
		this.pNext->DEBUG_PRINT()
	EndIf
End Sub


Function compileParameters(parStr As String, pErr As Integer Ptr) As Param Ptr
	Dim As Param Ptr pPars = New Param
	Dim As Integer state = ParserState.INTERMEDIATE
	Dim As String tempStr = ""
	Dim As Param Ptr pLastPar = pPars
	
	
	/' Run through each character in the string '/
	For i As Integer = 0 To Len(parStr) - 1
		Dim As UByte c = parStr[i]
		
		Select Case As Const state			
			Case ParserState.READING_PAR_NAME:
				/'--- Reading for parameter name ---'/
				If isspace(c) Or c=PAR_QUOTE Then
					/' Done reading '/
					If tempStr = "" Then
						/' Empty string '/
						*pErr = ParErrors.EMPTY_PARAMETER_NAME
						Delete pPars
						Return 0
						
					Else
						/' Done reading parameter name '/
						Dim As Param Ptr pNewParam = New Param()
						pNewParam->text = tempStr
						pLastPar->rAddParam(pNewParam)
						
						/' Set to intermediate state, track this parameter '/
						pLastPar = pNewParam
						If c=PAR_QUOTE Then
							state = ParserState.QUOTE_VALUE
							
						Else
							state = ParserState.INTERMEDIATE
						EndIf
						
						tempStr = ""
						Continue For
					EndIf
					
				ElseIf c = PAR_DASH Then
					/' Duplicate dash '/
					*pErr = ParErrors.DUPLICATE_DASH
					Delete pPars
					Return 0
					
				Else
					/' Add character to buffer for name '/
					tempStr += Chr(c)
					Continue For
				EndIf
				
			Case ParserState.INTERMEDIATE:
				/'--- Intermediate state ---'/
				If isspace(c) Then
					/' Ignore extra spacing '/
					Continue For
					
				ElseIf c = PAR_DASH Then
					/' Start of new parameter '/
					tempStr = ""
					state = ParserState.READING_PAR_NAME
					Continue For
					
				ElseIf c = PAR_QUOTE Then
					/' Start of quoted parameter value'/
					tempStr = ""
					state = ParserState.QUOTE_VALUE
					Continue For
					
				Else
					/' Part of single parameter value, start reading '/
					tempStr = Chr(c)
					state = ParserState.NONQUOTE_VALUE
					Continue For
				EndIf
				
			Case ParserState.NONQUOTE_VALUE:
				/'--- Reading non-quote parameter value ---'/
				If isspace(c) Or c=PAR_DASH Or c=PAR_QUOTE Then
					/' Done reading parameter '/
					Dim As ParamVal Ptr pNewVal = New ParamVal()
					pNewVal->text = tempStr
					
					/' Add to last parameter '/
					pLastPar->addVal(pNewVal)
					tempStr = ""
					
					If isspace(c) Then
						/' Go back to intermediate state '/
						state = ParserState.INTERMEDIATE
						
					ElseIf c = PAR_DASH Then
						/' Rather abrupt jump to next parameter, but ok '/
						state = ParserState.READING_PAR_NAME
						
					Else
						/' Is using white space really that hard? Start quotes '/
						state = ParserState.QUOTE_VALUE
					End If
					
					Continue For
					
				Else
					/' Add to buffer '/
					tempStr += Chr(c)
					Continue For
				EndIf
				
			Case ParserState.QUOTE_VALUE:
				/'--- Reading quoted parameter ---'/
				If c = PAR_QUOTE Then
					/' Done reading quoted stuff '/
					Dim As ParamVal Ptr pNewVal = New ParamVal()
					pNewVal->text = tempStr
					
					/' Add to last parameter '/
					pLastPar->addVal(pNewVal)
					tempStr = ""
					
					/' Go to intermediate state '/
					state = ParserState.INTERMEDIATE
					Continue For
					
				Else
					
					/' Just add it '/
					tempStr += Chr(c)
					Continue For
				EndIf
		End Select
	Next i
	

	If tempStr = "" Then
		/' Nothing left to do '/
		Return pPars
	EndIf
	
	/' One last buffer of text remaining '/
	Select Case As Const state
		Case ParserState.READING_PAR_NAME:
			/' Add parameter name '/
			Dim As Param Ptr pNewParam = New Param()
			pNewParam->text = tempStr
			pLastPar->rAddParam(pNewParam)
			
		Case ParserState.NONQUOTE_VALUE:
			/' Add value '/
			Dim As ParamVal Ptr pNewVal = New ParamVal()
			pNewVal->text = tempStr
			pLastPar->addVal(pNewVal)
			
		Case ParserState.QUOTE_VALUE:
			/' Something prolly went broke '/
			*pErr = ParErrors.UNCLOSED_QUOTE
			Delete pPars
			Return 0
			
			/'Dim As ParamVal Ptr pNewVal = New ParamVal()
			pNewVal->text = tempStr
			pLastPar->addVal(pNewVal) '/
	End Select
	
	Return pPars
End Function


Function Param.getParam(major As String, minor As String) As Param Ptr
	If this.pNext = 0 Then Return 0
	
	If this.pNext->text=major OrElse this.pNext->text=minor Then
		Return this.pNext
		
	Else
		Return this.pNext->getParam(major, minor)
	EndIf
End Function


Function Param.popParam(major As String, minor As String) As Param Ptr
	Dim As Param Ptr pOld
	Dim As Param Ptr pTemp = this.pNext
	
	While pTemp <> 0
		If pTemp->text=major OrElse pTemp->text=minor Then
			/' Cut this one out '/
			If pOld = 0 Then
				/' First parameter '/
				this.pNext = this.pNext->pNext
				Return pTemp
			
			Else
				/' Internal parameter '/
				pOld->pNext = pTemp->pNext
				Return pTemp
			EndIf
		EndIf
		
		pOld = pTemp
		pTemp = pTemp->pNext
	Wend
	
	Return 0
End Function
