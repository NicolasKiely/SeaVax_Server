'#Include Once "../player/Organization.bi"
#Include Once "../player/Account.bi"
#Include Once "win/winsock.bi"
#Include Once "../player/Client.bi"
#Include Once "../cmds/Command.bi"
#Include Once "../Header.bi"
#Include Once "../chatroom/ChatRoom.bi"


/'****************************************************************************
 ' Servers primary data structure
 ***************************************************************************'/
Type Server
	/' Needed for sockets '/
	Dim As WSAData wdat
	
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
	
	/' Handles chat room broadcasting '/
	Declare Sub handleChatRooms()
End Type
