#Include Once "../player/Account.bi"
#Include Once "../player/Client.bi"
#Include Once "../cmds/Command.bi"
#Include Once "../Header.bi"
#Include Once "../chatroom/ChatRoom.bi"
#Include Once "../game/GameManager.bi"


#Define SERVER_READ_BUFFER_SIZE 250


/'****************************************************************************
 ' Servers primary data structure
 ***************************************************************************'/
Type Server
	#IFDEF __FB_WIN32__
		/' Needed for sockets '/
		Dim As WSAData wdat
	#ENDIF
	
	/' Listening socket '/
	Dim As SOCKET sock_l
	
	/' List of accounts '/
	Dim accMan As AccountManager
	
	/' List of clients '/
	Dim pClient As Client Ptr
	
	Dim As Integer shutDown
	
	/' Tree struct of commands '/
	Dim As Domain Ptr pRootCmd
	
	/' Main lobby '/
	Dim As ChatRoom lobby
	
	/' Buffer for reading socket '/
	Dim As ZString Ptr sockBuf
	
	/' Managers game rooms '/
	Dim As GameManager gameMan
	
	Declare Constructor()
	Declare Destructor()
	
	/' Initialize socket stuff '/
	Declare Sub initSock()
	
	/' Clean up socket stuff '/
	Declare Sub cleanSock()
	
	/' Main server loop '/
	Declare Sub serverMain()
	
	/' Gets list of read-ready sockets and stores results in read socks '/
	Declare Sub getReadSocks(pReadSet As fd_set Ptr)
	
	/' Handles input from read-ready-sockets '/
	Declare Sub handleReadSocks(pReadSet As fd_set Ptr)
	
	/' Adds a new client to the list '/
	Declare Sub addClient(pNewClient As Client Ptr)
	
	/' Returns number of clients '/
	Declare Function getClientCount() As Integer
	
	/' Interprets client input '/
	Declare Sub handleClientInput(pTalker As Client Ptr, zDatIn As ZString Ptr, datLen As Integer)
	
	/' Cleans up clients '/
	Declare Sub cleanUpClients()
	
	/' Cleans up clients account on logout '/
	Declare Sub cleanUpAccount(pAccount As Account Ptr)
	
	/' Handles chat room broadcasting '/
	Declare Sub handleChatRooms()
End Type
