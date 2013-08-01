/'****************************************************************************
 ' Represents a persistent user account for the given server
 ' Stored as a linked list
 ***************************************************************************'/
 
Type Account
	/' User login info '/
	Dim userName As String
	Dim pass As String
	
	/' Next account in list '/
	Dim pNext As Account ptr
	
	/' Returns string representation of account '/
	Declare Function toRecord() As String
End Type
