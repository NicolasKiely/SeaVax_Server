#Include Once "Organization.bi"
#Include Once "User.bi"

Constructor Organization(pPrev As Organization ptr)
	/' Initialize own data '/
	this.orgName = "Default"
	this.pUser = 0
	this.pNext = 0
	
	If pPrev <> 0 Then
		/' Add as child to previous organization '/
		If pPrev->pNext <> 0 Then Print "Warning, overwriting org over previous ptr"
		pPrev->pNext = @this
	EndIf
End Constructor


Function Organization.hasUser(pUse As User Ptr) As Integer
	Return 0
End Function


Sub Organization.addNew()
	this.rFree()
	
	this.pNext = New Organization(@this)
	If this.pNext = 0 Then Print "Error in creating org"
End Sub


Sub Organization.rFree()
	If this.pNext <> 0 Then
		/' Call rFree on child first '/
		this.pNext->rFree()
		
		/' Free child and reset '/
		Delete this.pNext
		
		this.pNext = 0
	EndIf
End Sub
