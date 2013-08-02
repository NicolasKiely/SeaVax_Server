#Include Once "Account.bi"
#Include Once "../table/Table.bi"


Constructor Account()
	this.userName = ""
	this.pass = ""
	this.pNext = 0
	this.isLoaded = 0
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


Function loadSavedAccount(pAcc As Account Ptr) As Integer
	If pAcc = 0 Then Return 1
	If pAcc->userName = "" Then Return 2
	
	Dim As String baseDir = ACCOUNT_ROOT_DIR + pAcc->userName + "/"
	
	/' Load info '/
	Dim As String infoFileName = baseDir + "info.txt"
	Dim As Table Ptr pInfoTab = loadTableFromFile(infoFileName)
	
	Delete pInfoTab
End Function
