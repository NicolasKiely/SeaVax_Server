/'----------------------------------------------------------------------------
 ' Linked list of client connections
 '	Has an id, ip address
 ---------------------------------------------------------------------------'/
#Include Once "win/winsock.bi"
#Include Once "../server/ZRing.bi"
#Include Once "../table/Table.bi"
#Include Once "Account.bi"


Type Client
	/' Socket '/
	Dim As Socket sock
	
	/' Address '/
	Dim As SockAddr addr
	
	/' Next client in list '/
	Dim As Client Ptr pNext
	
	/' Any logged in account '/
	Dim As Account Ptr pAcc
	
	/' Client To be deleted '/
	Dim As Integer markForDeletion
	
	/' Own net buffer '/
	Dim As ZRing Ptr pNetBuf
	
	/' Cause destructor wont always be called on time '/
	Declare Sub freeSelf()
	
	/' Sends a table packet over the socket '/
	Declare Sub sendTable(pTable As Table Ptr)
	
	/' Gets account name if exist, or own name '/
	Declare Function getName() As String
	
	Declare Constructor()
	Declare Destructor()
End Type
