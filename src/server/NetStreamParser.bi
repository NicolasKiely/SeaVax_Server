/'----------------------------------------------------------------------------
 ' Parser for incoming socket stream
 ' Command stream in format of:
 '  <Echo String> | <command> <parameters> | <commands> <parameters> ... ;
 ---------------------------------------------------------------------------'/
 
#Include Once "ZRing.bi"

/' Internal stream separator  | '/
'#Define CMD_STREAM_SEP 9
#Define CMD_STREAM_SEP 124

/' Stream delimiter  ; '/
#Define CMD_STREAM_DEL 59

#Define CMD_STREAM_QUOTE 39


/' List of command/parameter strings from stream'/
Type CmdStream
	/' Text portion '/
	Dim As String text
	
	/' Whether this is a command, parameter, or echo '/
	Dim As Integer strType
	
	/' Next in list '/
	Dim As CmdStream Ptr pNext
	
	Declare Sub DEBUG_PRINT()
	
	Declare Constructor()
	Declare Destructor()
End Type


Enum CommandStreamStrings
	COMMAND_STRING = 1,
	PARAMETER_STRING = 2,
	ECHO_STRING=3
End Enum


Enum NetStreamParserState
	READING_ECHO = 0,
	READING_COMMAND = 1,
	READING_PARAMETER = 2
End Enum


/' Old buffer is any left over data from last run-around,
 '		gets moddified to store what didn't pass this run around
 ' New buffer is what just came from the socket
 ' Returns list of strings
 '/
Declare Function parseNetStream(zOldBuf As ZRing Ptr, zNewBuf As ZString Ptr, _
		datLen As Integer) As CmdStream Ptr

