#Include Once "FunctionList.bi"
#Include Once "../server/Server.bi"


/' Description:
 '  Binds client to account, ie account "login"
 '
 ' Command name:
 '  /acc/log/login
 '
 ' Targets:
 '  Clients
 '
 ' Parameters:
 ' - (a)ccount : account to log in to
 ' - (p)assword: password for account
 '
 ' Returns:
 '  Account name logged in
 '/
Sub CMD_clientLogin(pPipeIn As Table Ptr, pPipeOut As Table Ptr, _
		pPipeErr As Table Ptr, pParam As Param Ptr, _
		aClient As Any Ptr, aServer As Any Ptr)
		
	Dim As Server Ptr pServer = CPtr(Server Ptr, aServer)
	Dim As Client Ptr pClient = CPtr(Client Ptr, aClient)
	Dim As Record Ptr pLineErr = 0
	
	If pClient = 0 Then
		pLineErr = New Record()
		pLineErr->addField("CmdClientLogin")
		pLineErr->addField("No client attached")
		pLineErr->addField("pClient == 0")
		pPipeErr->addRecord(pLineErr)
		
		Exit Sub
	EndIf
	
	/' Pop parameters '/
	Dim As Param Ptr prmAcc = pParam->popParam("account", "a")
	Dim As Param Ptr prmPass = pParam->popParam("password", "p")
	
	/' Lookup account name '/
	Dim As Account Ptr pAcc
	Dim As String accName
	
	accName = prmAcc->pVals->text
	pAcc = pServer->accMan.lookupAccount(accName)
	
	
	If pAcc = 0 Then
		/' Checkpoint: Did we load the account right? '/
		pLineErr = New Record()
		pLineErr->addField("CmdClientLogin")
		pLineErr->addField("Could not load account")
		pLineErr->addField("Attempted to load account '"+accName+"'")
		pPipeErr->addRecord(pLineErr)
		
		If prmAcc <> 0 Then Delete prmAcc
		If prmPass <> 0 Then Delete prmPass
		Exit Sub
	EndIf
	
	/' Lookup password '/
	If pAcc->pass = prmPass->pVals->text Then
		/' Password match, log in to account '/
		pClient->pAcc = pAcc
		
		/' Load account from disk if not already done '/
		loadSavedAccount(pAcc)
		
		/' Output account logged in as '/
		pPipeOut->addToHeader("Login")
		pPipeOut->addToColumn("Name")
		pPipeOut->addRecord(loadRecordFromString(accName))
		
	Else
		pLineErr = New Record()
		pLineErr->addField("CmdClientLogin")
		pLineErr->addField("Invalid password")
		pLineErr->addField("Wrong password entered")
		pPipeErr->addRecord(pLineErr)
	EndIf

	
	
	If prmAcc <> 0 Then Delete prmAcc
	If prmPass <> 0 Then Delete prmPass
End Sub


/' Description:
 '  Changes password of a clients account
 '
 ' Command name:
 '  /acc/log/setpass
 '
 ' Targets:
 '  Accounts
 '
 ' Parameters:
 ' - (o)ld: Old password of account
 ' - (n)ew: New password for account
 '
 ' Returns:
 '  Nothing
 '/
Sub CMD_clientChangePassword(pPipeIn As Table Ptr, pPipeOut As Table Ptr, _
		pPipeErr As Table Ptr, pParam As Param Ptr, _
		aClient As Any Ptr, aServer As Any Ptr)
		
	Dim As Server Ptr pServer = CPtr(Server Ptr, aServer)
	Dim As Client Ptr pClient = CPtr(Client Ptr, aClient)
	Dim As Record Ptr pLineErr = 0
	
	/' Make sure theres an account to work with '/
	If pClient=0 OrElse pClient->pAcc=0 Then
		pLineErr = New Record()
		pLineErr->addField("CmdClientChangePassword")
		pLineErr->addField("No client attached")
		pLineErr->addField("pClient or pClient->pAcc == 0")
		pPipeErr->addRecord(pLineErr)
		
		Exit Sub
	EndIf
	Dim As Account Ptr pAcc = pClient->pAcc
	
	
	/' Pop parameters '/
	Dim As Param Ptr prmOld = pParam->popParam("old", "o")
	Dim As Param Ptr prmNew = pParam->popParam("new", "n")
	
	/' Lookup old password '/
	Dim As String oldPass
	
	/' Invalidate password if no match found '/
	oldPass = prmOld->pVals->text
	If oldPass <> pAcc->pass Then oldPass = ""

	/' Checkpoint: validate that old password was gathered '/
	If oldPass = "" Then
		pLineErr = New Record()
		pLineErr->addField("CmdClientChangePassword")
		pLineErr->addField("Could not validate password")
		pLineErr->addField("Attempted to load account '"+pAcc->userName+"'")
		pPipeErr->addRecord(pLineErr)
		
		If prmOld <> 0 Then Delete prmOld
		If prmNew <> 0 Then Delete prmNew
		Exit Sub
	EndIf
	
	/' Set password '/
	pAcc->pass = prmOld->pVals->text
	
	If prmOld <> 0 Then Delete prmOld
	If prmNew <> 0 Then Delete prmNew
End Sub


/' Description:
 '  Creates new account
 '
 ' Command name:
 '  /acc/man/create
 '
 ' Targets:
 '  Admin
 '
 ' Parameters:
 ' - (a)ccount : account name
 ' - (p)assword: password for account
 '
 ' Returns:
 '  Account name
 '/
Sub CMD_manCreateAccount(pPipeIn As Table Ptr, pPipeOut As Table Ptr, _
		pPipeErr As Table Ptr, pParam As Param Ptr, _
		aClient As Any Ptr, aServer As Any Ptr)
	
	Dim As Server Ptr pServer = CPtr(Server Ptr, aServer)
	Dim As Client Ptr pClient = CPtr(Client Ptr, aClient)
	Dim As Record Ptr pLineErr = 0
	
	/' Pop parameters '/
	Dim As Param Ptr prmAcc = pParam->popParam("account", "a")
	Dim As Param Ptr prmPass = pParam->popParam("password", "p")
	
	/' Check to see if account already exists '/
	Dim As Account Ptr pAcc = pServer->accMan.lookupAccount(prmAcc->pVals->text)
	If pAcc <> 0 Then
		pLineErr = New Record()
		pLineErr->addField("CmdManCreateClient")
		pLineErr->addField("Attempted to create existing account")
		pLineErr->addField(prmAcc->pVals->text)
		pPipeErr->addRecord(pLineErr)
		
		If prmAcc <> 0 Then Delete prmAcc
		If prmPass <> 0 Then Delete prmPass
		Exit Sub
	EndIf
	
	/' Create new account '/
	pAcc = New Account()
	pAcc->userName = prmAcc->pVals->text
	pAcc->pass = prmPass->pVals->text
	
	If pAcc->firstSave() = 0 Then
		pServer->accMan.addAccount(pAcc)
		
	Else
		pLineErr = New Record()
		pLineErr->addField("CmdManCreateClient")
		pLineErr->addField("Could not create new account")
		pLineErr->addField(prmAcc->pVals->text)
		pPipeErr->addRecord(pLineErr)
	EndIf
	
	
	If prmAcc <> 0 Then Delete prmAcc
	If prmPass <> 0 Then Delete prmPass
End Sub
