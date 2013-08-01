/'****************************************************************************
 ' Represents a persistent user account for the given server
 ' Stored as a linked list
 ***************************************************************************'/
 
 
#Define ACCOUNT_LIST_FILE "dat/Accounts/index.txt"

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
End Type


/' Manages servers list of accounts '/
Type AccountManager
	Dim As Account Ptr pAcc
	
	/' Looks up accounts to load '/
	Declare Sub loadFromDisk(fileName As String)
	
	/' Adds new account to list '/
	Declare Sub addAccount(pNewAccount As Account Ptr)
	
	Declare Constructor()
	Declare Destructor()
End Type
