/'****************************************************************************
 ' Represents a persistent user account for the given server
 ' Stored as a linked list
 ***************************************************************************'/
 
 
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
	
	/' Returns string representation of account '/
	Declare Function toRecord() As String
	
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
	
	
	
	Declare Constructor()
	Declare Destructor()
End Type

/' Loads an account by name from disk '/
Declare Function loadSavedAccount(pAcc As Account Ptr) As Integer
