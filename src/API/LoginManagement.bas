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
Sub CMD_clientLogin(envVars As CmdEnv)
	Dim As Server Ptr pServer = CPtr(Server Ptr, envVars.aServer)
	Dim As Client Ptr pClient = CPtr(Client Ptr, envVars.aClient)
	Dim As Record Ptr pLineErr = 0
	dim as String accName = ""
	Dim As Account Ptr pAcc = 0
	
	If pClient = 0 Then
		pLineErr = New Record()
		pLineErr->addField("CmdClientLogin")
		pLineErr->addField("No client attached")
		pLineErr->addField("pClient == 0")
		envVars.pPipeErr->addRecord(pLineErr)
		
		Exit Sub
	EndIf
	
	
	
	/' Pop parameters '/
	Dim As Param Ptr prmAcc = envVars.pParam->popParam("account", "a")
	Dim As Param Ptr prmPass = envVars.pParam->popParam("password", "p")
	
	/' Lookup account name '/
	accName = prmAcc->pVals->text
	
	pAcc = pServer->accMan.lookupAccount(accName)
	
	
	If pAcc = 0 Then
		/' Checkpoint: Did we load the account right? '/
		pLineErr = New Record()
		pLineErr->addField("CmdClientLogin")
		pLineErr->addField("Could not load account")
		pLineErr->addField("Attempted to load account '"+accName+"'")
		envVars.pPipeErr->addRecord(pLineErr)
		
		If prmAcc <> 0 Then Delete prmAcc
		If prmPass <> 0 Then Delete prmPass
		Exit Sub
	EndIf
	
	/' Lookup password '/
	If pAcc->pass = prmPass->pVals->text Then
		/' Update login state for old account '/
		If pClient->pAcc <> 0 Then pClient->pAcc->isLoggedIn = 0
		
		/' Password match, log in to account '/
		pClient->pAcc = pAcc
		
		/' Load account from disk if not already done '/
		loadSavedAccount(pAcc)
		
		/' Update login state for new account'/
		pAcc->isLoggedIn = -1
		
		
		/' Output account logged in as '/
		envVars.pPipeOut->addToHeader("Login")
		envVars.pPipeOut->addToColumn("Name")
		envVars.pPipeOut->addRecord(loadRecordFromString(accName))
		
	Else
		pLineErr = New Record()
		pLineErr->addField("CmdClientLogin")
		pLineErr->addField("Invalid password")
		pLineErr->addField("Wrong password entered")
		envVars.pPipeErr->addRecord(pLineErr)
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
Sub CMD_clientChangePassword(envVars As CmdEnv)
		
	Dim As Server Ptr pServer = CPtr(Server Ptr, envVars.aServer)
	Dim As Client Ptr pClient = CPtr(Client Ptr, envVars.aClient)
	Dim As Record Ptr pLineErr = 0
	
	/' Make sure theres an account to work with '/
	If pClient=0 OrElse pClient->pAcc=0 Then
		pLineErr = New Record()
		pLineErr->addField("CmdClientChangePassword")
		pLineErr->addField("No client attached")
		pLineErr->addField("pClient or pClient->pAcc == 0")
		envVars.pPipeErr->addRecord(pLineErr)
		
		Exit Sub
	EndIf
	Dim As Account Ptr pAcc = pClient->pAcc
	
	
	/' Pop parameters '/
	Dim As Param Ptr prmOld = envVars.pParam->popParam("old", "o")
	Dim As Param Ptr prmNew = envVars.pParam->popParam("new", "n")
	
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
		envVars.pPipeErr->addRecord(pLineErr)
		
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
Sub CMD_manCreateAccount(envVars As CmdEnv)
	
	Dim As Server Ptr pServer = CPtr(Server Ptr, envVars.aServer)
	Dim As Client Ptr pClient = CPtr(Client Ptr, envVars.aClient)
	Dim As Record Ptr pLineErr = 0
	
	/' Pop parameters '/
	Dim As Param Ptr prmAcc = envVars.pParam->popParam("account", "a")
	Dim As Param Ptr prmPass = envVars.pParam->popParam("password", "p")
	
	/' Check to see if account already exists '/
	Dim As Account Ptr pAcc = pServer->accMan.lookupAccount(prmAcc->pVals->text)
	If pAcc <> 0 Then
		pLineErr = New Record()
		pLineErr->addField("CmdManCreateClient")
		pLineErr->addField("Attempted to create existing account")
		pLineErr->addField(prmAcc->pVals->text)
		envVars.pPipeErr->addRecord(pLineErr)
		
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
		pServer->accMan.saveIndex()
		
	Else
		pLineErr = New Record()
		pLineErr->addField("CmdManCreateClient")
		pLineErr->addField("Could not create new account")
		pLineErr->addField(prmAcc->pVals->text)
		envVars.pPipeErr->addRecord(pLineErr)
	EndIf
	
	
	If prmAcc <> 0 Then Delete prmAcc
	If prmPass <> 0 Then Delete prmPass
End Sub


/' Description:
 '  Lists accounts
 '
 ' Command name:
 '  /acc/log/ls
 '
 ' Targets:
 '  Accounts
 '
 ' Parameters:
 ' - None
 '
 ' Returns:
 '  Account name
 '/
Sub CMD_listAccounts(envVars As CmdEnv)
	
	Dim As Server Ptr pServer = CPtr(Server Ptr, envVars.aServer)
	
	/' Set up table '/
	envVars.pPipeOut->addToColumn("account")
	envVars.pPipeOut->addToColumn("logged")
	
	/' Loop through accounts '/
	Dim As Account Ptr pAcc = pServer->accMan.pAcc
	While pAcc <> 0
		/' Generate record for account '/
		Dim As Record Ptr pRec = New Record()
		pRec->addField(pAcc->userName)
		If pAcc->isLoggedIn = 0 Then
			pRec->addField("0")
		Else
			pRec->addField("1")
		EndIf
		
		/' Add to results '/
		envVars.pPipeOut->addRecord(pRec)
		
		pAcc = pAcc->pNext
	Wend
End Sub


/' Description:
 '  Logs client out of account
 '
 ' Command name:
 '  /acc/log/logout
 '
 ' Targets:
 '  Clients
 '
 ' Parameters:
 ' - None
 '
 ' Returns:
 '  Nothing
 '/
Sub CMD_clientLogout(envVars As CmdEnv)
		
	Dim As Server Ptr pServer = CPtr(Server Ptr, envVars.aServer)
	Dim As Client Ptr pClient = CPtr(Client Ptr, envVars.aClient)
	Dim As Record Ptr pLineErr = 0
	
	If pClient = 0 Then
		pLineErr = New Record()
		pLineErr->addField("CmdClientLogout")
		pLineErr->addField("No client attached")
		pLineErr->addField("pClient == 0")
		envVars.pPipeErr->addRecord(pLineErr)
		
		Exit Sub
	EndIf
	
	If pClient->pAcc <> 0 Then
		/' Log out '/
		pClient->pAcc->isLoggedIn = 0
		pClient->pAcc = 0
		
	Else
		pLineErr = New Record()
		pLineErr->addField("CmdClientLogout")
		pLineErr->addField("Not logged in to any account")
		pLineErr->addField("pClient->pAcc == 0")
		envVars.pPipeErr->addRecord(pLineErr)
	EndIf
End Sub
