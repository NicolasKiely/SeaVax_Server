#Include Once "Connector.bi"
#Include Once "Account.bi"
#Include Once "Player.bi"

/'****************************************************************************
 ' Represents a logged in active account
 ' Second to top level in player hierarchy
 ***************************************************************************'/
Type User
	/' Socket connection '/
	Dim con As Connector
	
	/' Pointer to user account, structure is owned by server '/
	Dim pAcc As Account Ptr
	
	/' Game-specific data '/
	Dim dat As GameData
End Type
