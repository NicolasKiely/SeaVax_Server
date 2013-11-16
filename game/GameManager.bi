#Include Once "GameRoom.bi"


/' Managers servers list of game rooms '/
Type GameManager
	/' Root room '/
	Dim As GameRoom Ptr pRoot
	
	/' Number of game rooms active '/
	Dim As Integer numRooms
	
	Declare Constructor()
	Declare Destructor()
	
	/' Adds game room to list '/
	Declare Sub addRoom(pNewRoom As GameRoom Ptr)
	
	/' Removes game room from list '/
	Declare Sub removeRoom(pDelRoom As GameRoom Ptr)
End Type
