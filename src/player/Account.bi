/'****************************************************************************
 ' Represents a persistent user account for the given server
 ' Stored as a linked list
 ***************************************************************************'/

#Include Once "../table/Table.bi"
 
#Define ACCOUNT_LIST_FILE "dat/Accounts/index.txt"
#Define ACCOUNT_ROOT_DIR "dat/Accounts/"

Type Account
	/' User login info '/
	Dim userName As String
	Dim pass As String
	
	/' Next account in list '/
	Dim pNext As Account Ptr
	
	/' Whether or not account is pre-loaded '/
	Dim As Integer isLoaded
	
	/' Whether or not a client has logged in to account '/
	Dim As Integer isLoggedIn
	
	/' Rank in maze game '/
	Dim As Integer mazeRank
	
	/' Maze package '/
	Dim As String mazePack
	
	/' Accounts game room '/
	Dim As Any Ptr pRoom
	
	/' First time account is saved. 0 returned on success '/
	Declare Function firstSave() As Integer
	
	/' Saves account to disk. 0 returned on success '/
	Declare Function save() As Integer
	
	/' Returns string representation of account '/
	Declare Function toRecord() As String
	
	/' Returns path to account directory '/
	Declare Function getPath(appendPath As String = "") As String
	
	/' Returns maze pack. Normalizes to capital casing to avoid
	 ' internal server inconsistencies
	 '/
	Declare Function getMazePackage() As String
	
	Declare Constructor()
	Declare Destructor()
End Type


/' Manages servers list of accounts '/
Type AccountManager
	Dim As Account Ptr pAcc
	
	/' Looks up accounts to load '/
	Declare Function loadFromDisk(fileName As String) As Integer
	
	/' Adds new account to list '/
	Declare Sub addAccount(pNewAccount As Account Ptr)
	
	/' Looks up an account by name '/
	Declare Function lookupAccount(accName As String) As Account Ptr
	
	/' Saves all accounts and index '/
	Declare Sub save()
	
	/' Saves index of accounts '/
	Declare Sub saveIndex()
	
	Declare Constructor()
	Declare Destructor()
End Type

/' Loads an account by name from disk '/
Declare Function loadSavedAccount(pAcc As Account Ptr) As Integer
