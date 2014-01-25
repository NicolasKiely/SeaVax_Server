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
	
	Declare Sub removeAccount(pAcc As Account Ptr)
	
	Declare Function getHostName() As String
	
	Declare Function getHostAccount() As Account Ptr
End Type


/' Writes game room column and record fields to table. Doesn't overwrite data '/
Declare Sub writeRoomToTable(pRoom As GameRoom Ptr, pTable As Table Ptr)

/' Writes columns of room fields to table. Doesn't overwrite data '/
Declare Sub writeRoomColumns(pTable As Table Ptr)

/' Appends room fields as record to table '/
Declare Sub writeRoomRecord(pRoom As GameRoom Ptr, pTable As Table Ptr)
