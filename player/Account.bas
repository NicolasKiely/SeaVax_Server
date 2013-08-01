#Include Once "Account.bi"

Function Account.toRecord() As String
	Dim As String strRec = this.userName + "\t" + this.pass
	
	Return strRec
End Function
