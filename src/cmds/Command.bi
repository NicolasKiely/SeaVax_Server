/'----------------------------------------------------------------------------
 ' Manages the server commands in a directory tree
 ---------------------------------------------------------------------------'/

#Include Once "../table/Table.bi"
#Include Once "ParList.bi"
#Include Once "CommandEnvironment.bi"


#Define DOMAIN_LIST_FILE "dat/DomainListing.txt"
#Define COMMAND_LIST_FILE "dat/CommandListing.txt"
#Define FLAG_LIST_FILE "dat/FlagListing.txt"
#Define DOMAIN_DELIMITER 47


/'----------------------------------------------------------------------------
 ' List of flags associated with a command
 ---------------------------------------------------------------------------'/
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
	
	/' Temporary variables for counting '/
	Dim As Integer tempArg
	Dim As Integer tempUse
	
	Dim As Flag Ptr pNext
	
	Declare Constructor()
	Declare Destructor()
	
	/' Looks up flag by name '/
	Declare Function findFlag(flagName As String) As Flag Ptr
	
	/' Resets temporary variables of list '/
	Declare Sub clearTempData()
End Type


/'----------------------------------------------------------------------------
 ' The command leaf nodes of the domain tree
 ---------------------------------------------------------------------------'/
Type Cmd
	/' Sybling command in list '/
	Dim As Cmd Ptr pNext
	
	/' Text value of the command '/
	Dim As String text
	
	/' Info about command '/
	Dim As String info
	
	/' ID of command '/
	Dim As Integer id
	
	/' Flag list '/
	Dim As Flag Ptr pFlag
	
	/' Recursive Debug print statement '/
	Declare Sub DEBUG_PRINT(tabLevel As Integer)
	
	
	/' Bound function to command. For simplicitys sake of dependency
	 ' resolution, accounts and servers are void pointers.
	 ' pPipeIn is the pointer to the standard input (table structure)
	 ' pPipeOut is the pointer to the standard output (table structure)
	 ' pPipeErr is the pointer to the error output (table structure)
	 ' pParam is the list of parameters for the command
	 ' aAccount is the account to run the function on behalf of
	 ' aServer is the pointer to the global server state information
	 '/
	Dim pFunc as Sub(envVars As CmdEnv)
	
	/' Calls pFunc if not-null and parameters fit flag specs '/
	Declare Sub callFunc(envVars As CmdEnv)
	
	Declare Constructor()
	Declare Destructor()
End Type


/'----------------------------------------------------------------------------
 ' Internal tree node
 ---------------------------------------------------------------------------'/
Type Domain
	/' Sybling domain list '/
	Dim As Domain Ptr pNext
	
	/' Child domain sub-tree '/
	Dim As Domain Ptr pChild
	
	/' Text value of domain '/
	Dim As String text
	
	/' Help string '/
	Dim As String info
	
	/' Start of command list '/
	Dim As Cmd Ptr pCmd
	
	/' id '/
	Dim As Integer id
	
	/' Recursively lookup subdirectory by name '/
	Declare Function findSubDomain(dirStr As String) As Domain Ptr
	
	/' Adds a new subdomain '/
	Declare Sub addSubDomain(pNewDomain As Domain Ptr)
	
	/' Adds a new command '/
	Declare Sub addCmd(pNewCmd As Cmd Ptr)
	
	/' Looks up local command in directory '/
	Declare Function findCmd(cmdStr As String) As Cmd ptr
	
	/' Debug sub to print entire structure to screen '/
	Declare Sub DEBUG_PRINT(tabLevel As Integer)
	
	Declare Constructor()
	Declare Destructor()
End Type


/'----------------------------------------------------------------------------
 ' Looks up directory in tree. Different from findSubDomain() in that
 ' this method may take absolute paths
 ---------------------------------------------------------------------------'/
Declare Function lookupDomain(dirStr As String, pRoot As Domain Ptr) As Domain Ptr

/'----------------------------------------------------------------------------
 ' Looks up command in tree
 ---------------------------------------------------------------------------'/
Declare Function lookupCmd(dirStr As String, pRoot As Domain Ptr) As Cmd Ptr


/'----------------------------------------------------------------------------
 ' Returns the parent directory string from a directory string
 ---------------------------------------------------------------------------'/
Declare Function cutParentDirectoryName(directory As String) As String


/'----------------------------------------------------------------------------
 ' Returns everything but the most nested directory name
 ---------------------------------------------------------------------------'/
Declare Function cutBaseDirectoryName(directory As String) As String


/'----------------------------------------------------------------------------
 ' Returns the most nested directory name
 ---------------------------------------------------------------------------'/
Declare Function cutNonBaseDirectoryName(directory As String) As String


/'----------------------------------------------------------------------------
 ' Returns the lowest level directory string from a directory string
 ---------------------------------------------------------------------------'/
Declare Function cutAncestorDirectoryName(directory As String) As String


/'----------------------------------------------------------------------------
 ' Returns everything but the lowest level directory string from a
 ' directory string
 ---------------------------------------------------------------------------'/
Declare Function cutNonAncestorDirectoryName(directory As String) As String


/'----------------------------------------------------------------------------
 ' Loads domains from file. Returns Domain tree with "/" root node
 ---------------------------------------------------------------------------'/
Declare Function loadDomains(fileName As String) As Domain Ptr


/'----------------------------------------------------------------------------
 ' Loads commands from file into domain tree structure
 ---------------------------------------------------------------------------'/
Declare Sub loadCommands(fileName As String, pDomain As Domain Ptr)


/'----------------------------------------------------------------------------
 ' Links flags to commands on file
 ---------------------------------------------------------------------------'/
Declare Sub loadFlags(fileName As String, pDomain As domain Ptr)