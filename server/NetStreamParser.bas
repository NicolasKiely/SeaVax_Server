#Include Once "NetStreamParser.bi"
#Include Once "../Header.bi"
#Include Once "ZRing.bi"
#Include Once "crt/ctype.bi"


Constructor CmdStream()
	this.text = ""
	this.strType = CommandStreamStrings.ECHO_STRING
	this.pNext = 0
End Constructor


Destructor CmdStream()
	this.text = ""
	If this.pNext <> 0 Then Delete this.pNext
End Destructor


Function parseNetStream(zOldBuf As ZRing Ptr, zNewBuf As ZString Ptr, _
		datLen As Integer) As CmdStream Ptr
	
	Dim As CmdStream Ptr pStream = New CmdStream()
	Dim As CmdStream Ptr pLast = pStream
	
	/' Whether or not reading new buffer '/
	Dim As Integer bufFlag = 0
	Dim As Integer i = 0
	Dim As Integer state = NetStreamParserState.READING_ECHO
	Dim As UByte c
	Dim As String tempStr = ""
	Dim As Integer inQuotes = 0
	
	Do
		/' Handle old buffer being used up '/
		
		If bufFlag = 0 Then
			/' Read old buffer '/
			If zOldBuf->isEmpty() = 0 Then
				c = zOldBuf->popNext()
			Else
				/' End of old buffer '/
				If zNewBuf = 0 Then
					/' Kinda done here '/
					Return pStream
					
				Else
					/' Read new buffer '/
					bufFlag = 1
				EndIf
			End If
			
		Else
			If zNewBuf <> 0 Then
				/' Read new buffer '/
				c = zNewBuf[i]
				i += 1
			End If
		EndIf
		
		
		If c = 0 Then
			/' End of buffer '/
			If bufFlag = 0 Then
				/' This shouldnt happen '/
				Print "Error, unexpected null in zring"
				
			Else
				/' Done with new buffer. At this point, a delimiter hasn't been reached,
				so the new buffer should be appended to the old buffer if possible '/
				
				'Print "Warning: Big client stream inbound!"
				If zOldBuf->addZ(zNewBuf[i], datLen-i) Then
					Print "Big client overflow!"
					Delete pStream
					Return 0
				EndIf
				
				Return pStream
			EndIf
		EndIf
		
		Select Case As Const state
			Case NetStreamParserState.READING_ECHO:
				/' *** Building up echo string *** '/
				
				If c = CMD_STREAM_SEP Then
					/' Done reading echo, move to command '/
					state = NetStreamParserState.READING_COMMAND
					
					/' Add next stream struct '/
					Dim As CmdStream Ptr pTemp = New CmdStream()
					pTemp->strType = CommandStreamStrings.COMMAND_STRING
					pLast->pNext = pTemp
					pLast = pTemp
				
				Else
					/' Just usual char, add to current stream '/
					pLast->text += Chr(c)
				EndIf
				
			Case NetStreamParserState.READING_COMMAND:
				/' *** Building up command string *** '/
				
				If c = CMD_STREAM_SEP Then
					/' Done reading command, skip parameter and move to next command '/
					state = NetStreamParserState.READING_COMMAND
					
					/' Add next stream struct '/
					Dim As CmdStream Ptr pTemp = New CmdStream()
					pTemp->strType = CommandStreamStrings.COMMAND_STRING
					pLast->pNext = pTemp
					pLast = pTemp
					
				ElseIf c = CMD_STREAM_DEL Then
					/' Done reading stream '/
					If bufFlag = 0 Then
						/' In old buffer '/
						If zNewBuf <> 0 Then
							/' Add to zring if possible '/
							If zOldBuf->addZ(zNewBuf, datLen) Then
								Print "Error: Client buffer overflow!"
								Delete pStream
								Return 0
							EndIf
						EndIf
						
						Return pStream
						
					Else
						/' In new buffer '/
						If zOldBuf->addZ(zNewBuf[i], datLen-i) Then
							Print "Client buffer overflow! old buf used up"
							Delete pStream
							Return 0
						EndIf
					EndIf
					
					Return pStream
					
				ElseIf isspace(c) Then
					/' Done reading command, move to parameters '/
					state = NetStreamParserState.READING_PARAMETER
					
					/' Add next stream struct '/
					Dim As CmdStream Ptr pTemp = New CmdStream()
					pTemp->strType = CommandStreamStrings.PARAMETER_STRING
					pLast->pNext = pTemp
					pLast = pTemp
					
				Else
					/' Add char to command string '/
					pLast->text += Chr(c)
				EndIf
				
			Case NetStreamParserState.READING_PARAMETER:
				If c = CMD_STREAM_SEP And Not(inQuotes) Then
					/' Done reading, go to command '/
					state = NetStreamParserState.READING_COMMAND
					
					/' Add next stream struct '/
					Dim As CmdStream Ptr pTemp = New CmdStream()
					pTemp->strType = CommandStreamStrings.COMMAND_STRING
					pLast->pNext = pTemp
					pLast = pTemp
					
				ElseIf c = CMD_STREAM_DEL And Not(inQuotes) Then
					/' Done reading stream '/
					If bufFlag = 0 Then
						/' In old buffer '/
						If zNewBuf <> 0 Then
							/' Add to zring if possible '/
							If zOldBuf->addZ(zNewBuf, datLen) Then
								Print "Error: Client buffer overflow!"
								Delete pStream
								Return 0
							EndIf
						EndIf
						
						Return pStream
						
					Else
						/' In new buffer '/
						If zOldBuf->addZ(zNewBuf[i], datLen-i) Then
							Print "Client buffer overflow! old buf used up"
							Delete pStream
							Return 0
						EndIf
					EndIf
					
					Return pStream
					
				Else
					/' Just add to parameter '/
					pLast->text += Chr(c)
					
					If c = CMD_STREAM_QUOTE Then
						inQuotes = Not(inQuotes)
					EndIf
				EndIf
		End Select
	Loop
	
	
	Return pStream
End Function


Sub CmdStream.DEBUG_PRINT()
	If this.strType = CommandStreamStrings.COMMAND_STRING Then
		Print "-- Command  : '";
		
	ElseIf this.strType = CommandStreamStrings.PARAMETER_STRING Then
		Print "-- Parameter: '";
		
	Else
		Print "-- Echo     : '";
	EndIf
	
	Print this.text + "'"
	
	If this.pNext <> 0 Then this.pNext->DEBUG_PRINT()
End Sub
