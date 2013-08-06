#Include Once "Account.bi"
#Include Once "../table/Table.bi"


Constructor Account()
	this.userName = ""
	this.pass = ""
	this.pNext = 0
	this.isLoaded = 0
	this.isLoggedIn = 0
End Constructor


Destructor Account()
	this.userName = ""
	this.pass = ""
	If this.pNext <> 0 Then Delete this.pNext 
End Destructor


Function Account.toRecord() As String
	Dim As String strRec = this.userName + "\t" + this.pass
	
	Return strRec
End Function


Function Account.firstSave() As Integer
	If MkDir(ACCOUNT_ROOT_DIR + this.userName)<>0 Then Return -1
	
	Return this.save()
End Function


Function Account.save() As Integer
	/' Open info file '/
	Dim As Integer fh = FreeFile()
	Open (ACCOUNT_ROOT_DIR + this.userName + "/info.txt") For Output As #fh
	
	If Err=3 OrElse Err=2 Then Return -1
	
	Print #fh, "key" + Chr(9) + "value"
	Print #fh, "password" + Chr(9) + this.pass
	
	Close #fh
	
	Return 0
End Function


Constructor AccountManager()
	this.pAcc = 0
End Constructor


Destructor AccountManager()
	If this.pAcc <> 0 Then Delete this.pAcc
End Destructor


Function AccountManager.loadFromDisk(fileName As String) As Integer
	Dim As Table Ptr pTable = loadTableFromFile(fileName)
	Dim As Integer accountNum = 0
	
	If pTable = 0 Then
		Print "Error! Could not load '" +fileName+ "' for account list info"
		Return 0
	EndIf
	
	Dim As Integer iAccountName = pTable->getColumnID("name")
	Dim As Integer iLoadAccount = pTable->getColumnID("load")
	
	/' Load from table '/
	Dim As Record Ptr pRec = pTable->pRec
	While pRec <> 0
		Dim As Account Ptr pTempAcc = New Account()
		pTempAcc->userName = pRec->getFieldByID(iAccountName)->value
		
		If pRec->getFieldByID(iLoadAccount)->value = "1" Then
			loadSavedAccount(pTempAcc)
			accountNum += 1
		End If
		
		this.addAccount(pTempAcc)
		pRec = pRec->pNext
	Wend
	
	Delete pTable
	
	Return accountNum
End Function


Sub AccountManager.addAccount(pNewAccount As Account Ptr)
	If this.pAcc = 0 Then
		this.pAcc = pNewAccount
		
	Else
		pNewAccount->pNext = this.pAcc
		this.pAcc = pNewAccount
	EndIf
End Sub


Function AccountManager.lookupAccount(accName As String) As Account Ptr
	Dim As Account Ptr pTemp = this.pAcc
	While pTemp <> 0
		If pTemp->userName = accName Then
			Return pTemp
		EndIf
		
		pTemp = pTemp->pNext
	Wend
	
	Return 0
End Function


Sub AccountManager.save()
	Dim As Integer fh = FreeFile()
	Open ACCOUNT_LIST_FILE For Output As #fh
	
	Print #fh, "name" + Chr(9) + "load"
	
	/' Save accounts '/
	Dim As Account Ptr pTemp = this.pAcc
	While pTemp <> 0
		/' Save account info to its directory '/
		pTemp->save()
		
		/' Save account to index '/
		Print #fh, pTemp->userName + Chr(9) + "1"
		
		pTemp = pTemp->pNext
	Wend
	
	Close #fh
End Sub


Function loadSavedAccount(pAcc As Account Ptr) As Integer
	If pAcc = 0 Then Return 1
	If pAcc->userName = "" Then Return 2
	If pAcc->isLoaded <> 0 Then Return 0
	
	Dim As String baseDir = ACCOUNT_ROOT_DIR + pAcc->userName + "/"
	
	/' Load info '/
	Dim As String infoFileName = baseDir + "info.txt"
	Dim As Table Ptr pInfoTab = loadTableFromFile(infoFileName)
	
	pAcc->pass = pInfoTab->findValue("password")
	
	Delete pInfoTab
	pAcc->isLoaded = -1
	Return 0
End Function
