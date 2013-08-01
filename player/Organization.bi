#Include Once "User.bi"

/'****************************************************************************
 ' Group of users. Top level in player data structure hierarchy
 ' Stored as a linked list
 ***************************************************************************'/
Type Organization
	/' Name of organization '/
	Dim orgName As String
	
	/' List of users '/
	Dim pUser As User ptr
	
	/' Next org '/
	Dim pNext As Organization Ptr
	
	/' Initialize organization. pPrev is the pointer to a parent organization. '/
	Declare Constructor(pPrev As Organization Ptr)
	
	/' Returns 0 if user not found, non-zero otherwise '/
	Declare Function hasUser(pUse As User Ptr) As Integer
	
	/' Adds new child node '/
	Declare Sub addNew()
	
	/' Recursively free child node '/
	Declare Sub rFree()
End Type
