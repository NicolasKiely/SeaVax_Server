/'----------------------------------------------------------------------------
 ' Manages the flag listing and checking for commands
 ---------------------------------------------------------------------------'/
 

/' List of flags associated with a command '/
Type Flag
	/' Long name '/
	Dim As String lName
	
	/' Short name '/
	Dim As String sName
	
	/' Minimum and maximum number of arguments per flag. -1 means no limit '/
	Dim As Integer minArg
	Dim As Integer maxArg
	
	/' Minimum and maximum number of times used per command. -1 means no limit '/
	Dim As Integer minUse
	Dim As Integer maxUse
	
	/' Associated info text '/
	Dim As String info
	
	Dim As Flag Ptr pNext
	
	Declare Constructor()
	Declare Destructor()
End Type
