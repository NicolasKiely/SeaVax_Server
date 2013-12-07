/'----------------------------------------------------------------------------
 ' Circular z string buffer
 ---------------------------------------------------------------------------'/

Type ZRing
	/' Size of working buffer '/
	Dim As Integer bufSize
	
	/' Start of buffer marker '/
	Dim As Integer iStart
	
	/' Marker to end of string in buffer, ie one after last character '/
	Dim As Integer iEnd
	
	/' Buffer. Size = working buffer + 1 '/
	Dim As ZString Ptr pBuf
	
	Declare Constructor()
	Declare Destructor()
	
	/' Creates new buffer (deletes old one) '/
	Declare Sub alloc(newSize As Integer)
	
	/' Retuns first available character from start marker in ring
	 ' Start marker incremented, character set back to \0
	 '/
	Declare Function popNext() As UByte
	
	/' Returns 0 if the buffer is not empty, -1 otherwise '/
	Declare Function isEmpty() As Integer
	
	/' Gets size of used bytes in ring '/
	Declare Function getSize() As Integer
	
	/' Gets amount of free bytes in ring '/
	Declare Function getFreeSpace() As Integer
	
	/' Attempts to append zstring to ring. Returns 0 on success '/
	Declare Function addZ(zNewStr As ZString Ptr, strSize As Integer) As Integer
End Type
