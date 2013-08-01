#Include Once "Account.bi"
#Include Once "../table/Table.bi"


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


Sub AccountManager.loadFromDisk(fileName As String)
	Dim As Table Ptr pTable = loadTableFromFile(fileName)
	
	If pTable = 0 Then
		Print "Error! Could not load '" +fileName+ "' for account list info"
		Exit Sub
	EndIf
	
	Dim As Integer iAccountName = pTable->getColumnID("name")
	Dim As Integer iLoadAccount = pTable->getColumnID("load")
	
	/' Load from table '/
	Dim As Record Ptr pRec = pTable->pRec
	While pRec <> 0
		Dim As Account Ptr pTempAcc = New Account()
		pTempAcc->userName = pRec->getFieldByID(iAccountName)->value
		
		If pRec->getFieldByID(iLoadAccount)->value = "1" Then
			/' TODO: Load account from disk '/
			pTempAcc->isLoaded = -1
			
		Else
			pTempAcc->isLoaded = 0
		EndIf
		
		this.addAccount(pTempAcc)
		pRec = pRec->pNext
	Wend
	
	Delete pTable
End Sub


Sub AccountManager.addAccount(pNewAccount As Account Ptr)
	If this.pAcc = 0 Then
		this.pAcc = pNewAccount
		
	Else
		pNewAccount->pNext = this.pAcc
		this.pAcc = pNewAccount
	EndIf
End Sub
