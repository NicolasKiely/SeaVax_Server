#Include Once "../player/Account.bi"


/' Manages a game room '/
Type GameRoom
	/' Array of users in list '/
	Dim As Account Ptr Ptr ppList
	Dim As String gameType
	Dim As Integer mapSize
	Dim As Integer maxPlyr
	Dim As Integer numPlyr
	
	/' True if in playing state, false if waiting '/
	Dim As Integer inSession
	
	/' Next game room in list '/
	Dim As GameRoom Ptr pNext
	
	Declare Constructor(pNewHost As Account Ptr, newMax As Integer, _
			newSize As Integer, newType As String)
	Declare Destructor()
	
	/' Attempts to add account to game room '/
	Declare Function addAccount(pAcc As Account Ptr) As Integer
	
	Declare Function getHostName() As String
End Type
