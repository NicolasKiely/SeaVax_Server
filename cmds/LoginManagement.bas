#Include Once "FunctionList.bi"
#Include Once "../server/Server.bi"


/' Command name: /acc/log/login
 ' Parameters:
 ' - (a)ccount : account to log in to
 ' - (p)assword: password for account
 ' Login success
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
	
	If pParam->pNext <> 0 Then
		pLineErr = New Record()
		pLineErr->addField("CmdClientLogin")
		pLineErr->addField("Undefined parameter found")
		pLineErr->addField(pParam->pNext->text)
		pPipeErr->addRecord(pLineErr)
	EndIf
	
	/' Lookup account name '/
	Dim As Account Ptr pAcc
	Dim As String accName
	If prmAcc <> 0 Then
		If prmAcc->pVals <> 0 Then
			accName = prmAcc->pVals->text
			pAcc = pServer->accMan.lookupAccount(accName)
			
		Else
			pLineErr = New Record()
			pLineErr->addField("CmdClientLogin")
			pLineErr->addField("Account parameter needs name")
			pLineErr->addField("Use -account 'your account name'")
			pPipeErr->addRecord(pLineErr)
		EndIf
		
	Else
		pLineErr = New Record()
		pLineErr->addField("CmdClientLogin")
		pLineErr->addField("Account not specified")
		pLineErr->addField("Use -account 'your account name'")
		pPipeErr->addRecord(pLineErr)
	EndIf
	
	
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
	If prmPass <> 0 Then
		If prmPass->pVals <> 0 Then
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
			
		Else
			pLineErr = New Record()
			pLineErr->addField("CmdClientLogin")
			pLineErr->addField("Password parameter needs name")
			pLineErr->addField("Use -password 'your password'")
			pPipeErr->addRecord(pLineErr)
		EndIf
		
	Else
		pLineErr = New Record()
		pLineErr->addField("CmdClientLogin")
		pLineErr->addField("Password not specified")
		pLineErr->addField("Use -password 'your password'")
		pPipeErr->addRecord(pLineErr)
	EndIf
	
	
	If prmAcc <> 0 Then Delete prmAcc
	If prmPass <> 0 Then Delete prmPass
End Sub