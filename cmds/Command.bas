#Include Once "Command.bi"
#Include Once "table/Table.bi"
#Include Once "../API/FunctionList.bi"


Constructor Flag()
	this.lName = ""
	this.sName = ""
	
	this.minArg = 1
	this.maxArg = 1
	
	this.minUse = 1
	this.maxUse = 1
	
	this.info = "Default flag info"
	
	this.pNext = 0
End Constructor


Destructor Flag()
	this.lName = ""
	this.sName = ""
	this.info = ""
	
	If this.pNext <> 0 Then Delete this.pNext
End Destructor


Constructor Cmd()
	this.pNext = 0
	this.text = ""
	this.pFunc = 0
	this.pFlag = 0
End Constructor


Destructor Cmd()
	If this.pNext <> 0 Then Delete this.pNext
	If this.pFlag <> 0 Then Delete this.pFlag
End Destructor


Constructor Domain()
	this.pNext = 0
	this.pChild = 0
	this.text = ""
	this.pCmd = 0
End Constructor


Destructor Domain()
	If this.pNext <> 0 Then Delete this.pNext
	If this.pChild <> 0 Then Delete this.pChild
	If this.pCmd <> 0 Then Delete this.pCmd
End Destructor


Function cutParentDirectoryName(directory As String) As String
	Dim As String retStr = ""
	Dim As Integer startCounting = 0
	
	/' Loop through characters backwards '/
	For i As Integer = Len(directory)-1 To 0 Step -1
		/' Get working character '/
		Dim As UByte c = directory[i]
		
		If startCounting Then
			/' Copy characters over to string in reverse order '/
			retStr = Chr(c) + retStr
			
			/' Bail if delimiter hit '/
			If c = DOMAIN_DELIMITER Then Exit For
			
		Else
			If c = DOMAIN_DELIMITER Then
				/' Start copying '/
				startCounting = -1
			EndIf
		EndIf
	Next
	

	If retStr = "/" Then
		/' root '/
		Return retStr
		
	ElseIf retStr[0] = DOMAIN_DELIMITER Then
		/' Remove excess slash '/
		Return Right(retStr, Len(retStr)-1)
		
	Else
		/' Return plain result '/
		Return retStr
	EndIf
	
End Function


Function cutBaseDirectoryName(directory As String) As String
	Dim As String retStr = ""
	Dim As Integer startCounting = 0
	
	/' Loop through characters backwards '/
	For i As Integer = Len(directory)-1 To 0 Step -1
		/' Get working character '/
		Dim As UByte c = directory[i]
		
		If startCounting Then
			/' Copy characters over to string in reverse order '/
			retStr = Chr(c) + retStr
			
		Else
			If c = DOMAIN_DELIMITER Then
				/' Start copying '/
				startCounting = -1
			EndIf
		EndIf
	Next
	
	If retStr = "" AndAlso directory[0] = DOMAIN_DELIMITER Then
		retStr = Chr(DOMAIN_DELIMITER)
	EndIf
	
	Return retStr
End Function


Function cutNonBaseDirectoryName(directory As String) As String
	Dim As String retStr = ""
	
	/' Loop through characters backwards '/
	For i As Integer = Len(directory)-1 To 0 Step -1
		/' Get working character '/
		Dim As UByte c = directory[i]
		
		If c = DOMAIN_DELIMITER Then
			Exit For
			
		Else
			/' Copy characters over to string in reverse order '/
			retStr = Chr(c) + retStr
	
		EndIf
	Next
	
	If retStr = "" AndAlso directory[0] = DOMAIN_DELIMITER Then
		retStr = Chr(DOMAIN_DELIMITER)
	EndIf
	
	Return retStr
End Function


Function cutAncestorDirectoryName(directory As String) As String
	Dim As String retStr = ""
	
	If directory[0] = DOMAIN_DELIMITER Then
		/' Return root '/
		Return "/"
	EndIf
	
	/' Loop through characters '/
	For i As Integer = 0 To Len(directory)-1
		Dim As UByte c = directory[i]
		
		If c = DOMAIN_DELIMITER Then
			/' Done copying '/
			Return retStr
		EndIf
		
		/' Add character to string '/
		retStr += Chr(c)
	Next
	
	Return retStr
End Function


Function cutNonAncestorDirectoryName(directory As String) As String
	Dim As String retStr = ""
	Dim As Integer startCounting = 0
	
	If directory[0] = DOMAIN_DELIMITER Then
		/' Return non-root '/
		Return Right(directory, Len(directory)-1)
	EndIf
	
	/' Loop through characters '/
	For i As Integer = 0 To Len(directory)-1
		Dim As UByte c = directory[i]
		
		If startCounting Then
			retStr += Chr(c)
			
		Else
			If c = DOMAIN_DELIMITER Then
				/' Start copying '/
				startCounting = -1
			EndIf
		End If
	Next
	
	Return retStr
End Function


Function loadDomains(fileName As String) As Domain Ptr
	Dim As Domain Ptr pDomain
	/' Column ids '/
	Dim As Integer idID, nameID, parentID, infoID
	
	/' Load Table structure of domains '/
	Dim As Table Ptr t = loadTableFromFile(fileName)
	If t = 0 Then Return 0
	
	/' Load ids '/
	idID     = t->getColumnID_IC("id")
	nameID   = t->getColumnID_IC("name")
	parentID = t->getColumnID_IC("parent")
	infoID   = t->getColumnID_IC("info")
	
	If idID = -1 Or nameID = -1 Or parentID = -1 Or infoID = -1 Then
		Print "Error, could not load column names in " + fileName
		Return 0
	EndIf
	
	/' Initialize root domain '/
	pDomain = New Domain()
	pDomain->text = "/"
	
	/' Loop through records '/
	Dim As Record Ptr pRec = t->pRec
	While pRec <> 0
		Dim As Fld Ptr pIDfld
		Dim As Fld Ptr pNameFld
		Dim As Fld Ptr pParentFld
		Dim As Fld Ptr pInfoFld
		Dim As Domain Ptr pSubDom
		
		/' Load up fields '/
		pIDfld     = pRec->getFieldByID(idID)
		pNameFld   = pRec->getFieldByID(nameID)
		pParentFld = pRec->getFieldByID(parentID)
		pInfoFld   = pRec->getFieldByID(infoID)
		
		
		/' Skip incomplete fields '/
		If pIDfld=0 Or pNameFld=0 Or pParentFld=0 Or pInfoFld=0 Then
			pRec = pRec->pNext
			Print "Incomplete field encountered!"
			Continue While
		EndIf
		
		/' Load record fields into new domain '/
		pSubDom = New Domain()
		pSubDom->text = pNameFld->value
		pSubDom->info = pInfoFld->value
		pSubDom->id = ValInt(pIDfld->value)
		
		/' Find parent domain '/
		Dim As Domain Ptr pParentDom = lookupDomain(pParentFld->value, pDomain)
		
		If pParentDom = 0 Then
			/' Failed to find parent domain '/
			Print "Error, could not find parent '"+pParentFld->value+"' for '"+pSubDom->text+"'"
			Delete pSubDom
		
		Else
			/' Add sub domain to parent '/
			pParentDom->addSubDomain(pSubDom)
		EndIf
		
		
		pRec = pRec->pNext
	Wend
	
	/' Free table structure '/
	Delete t
	
	Return pDomain
End Function


Function Domain.findSubDomain(dirStr As String) As Domain Ptr
	/' Handle empty string '/
	If dirStr = "" Then Return 0
	
	/' Intermediate string '/
	Dim As String iStr = dirStr
	
	/' Get ancestory directory name '/
	Dim As String anc = cutAncestorDirectoryName(iStr)
	
	/' Loop through current sub directories '/
	Dim As Domain Ptr pTemp = this.pChild
	While pTemp <> 0
		If pTemp->text = anc Then
			/' Found correct subdirectory '/
			If iStr = pTemp->text Then
				/' End of search '/
				Return pTemp
			
			Else
				/' Search deeper into subdirectory '/
				iStr = cutNonAncestorDirectoryName(iStr)
				Return pTemp->findSubDomain(iStr)
			EndIf
		EndIf
		
		pTemp = pTemp->pNext
	Wend
	
	/' Nothing found, return null '/
	Print "No sub found in " + this.text
	Return 0
End Function


Sub Domain.addSubDomain(pNewDomain As Domain Ptr)	
	If this.pChild = 0 Then
		/' First subdomain '/
		this.pChild = pNewDomain
		
	Else
		/' Loop through child domains '/
		Dim As Domain Ptr pTemp = this.pChild
		Do
			If pTemp->pNext = 0 Then
				/' Found end of list, add '/
				pTemp->pNext = pNewDomain
				Exit Do
			EndIf
			
			pTemp = pTemp->pNext
		loop
	EndIf
End Sub


Sub Domain.addCmd(pNewCmd As Cmd Ptr)
	If this.pCmd = 0 Then
		/' First command '/
		this.pCmd = pNewCmd
	
	Else
		/' Loop through commands '/
		Dim As Cmd Ptr pTemp = this.pCmd
		Do
			If pTemp->pNext = 0 Then
				/' Found end of list, add '/
				pTemp->pNext = pNewCmd
				Exit Do
			EndIf
			
			pTemp = pTemp->pNext
		Loop
	EndIf
End Sub


Function Domain.findCmd(cmdName As String) As Cmd Ptr
	Dim As Cmd Ptr pTemp = this.pCmd
	While pTemp <> 0
		If pTemp->text = cmdName Then Return pTemp
		
		pTemp = pTemp->pNext
	Wend
	
	Return 0
End Function


Sub Domain.DEBUG_PRINT(tabLevel As Integer)
	/' Print self '/
	Print String(tabLevel*2, "-") + Str(this.id) +":"+ this.text
	
	/' Call on children '/
	If this.pChild <> 0 Then this.pChild->DEBUG_PRINT(tabLevel+1)
	
	/' Call on commands '/
	If this.pCmd <> 0 Then this.pCmd->DEBUG_PRINT(tabLevel)
	
	/' Call on syblings '/
	If this.pNext <> 0 Then this.pNext->DEBUG_PRINT(tabLevel)
End Sub


Sub Cmd.DEBUG_PRINT(tabLevel As Integer)
	/' Print self '/
	Print String(tabLevel*2, " ") +"+"+ Str(this.id) +":"+ this.text
	
	/' Call on next command '/
	If this.pNext <> 0 Then this.pNext->DEBUG_PRINT(tabLevel)
End Sub


Function Flag.findFlag(flagName As String) As Flag Ptr
	If flagName = this.lName OrElse flagName = this.sName Then
		/' Match found '/
		Return @This
		
	Else
		If this.pNext <> 0 Then
			/' No match found yet, search further into list '/
			Return this.pNext->findFlag(flagName)
			
		Else
			/' End of list, no match found '/
			Return 0
		EndIf
	EndIf
End Function


Sub Flag.clearTempData()
	this.tempArg = 0
	this.tempUse = 0
	
	If this.pNext <> 0 Then this.pNext->clearTempData()
End Sub


Sub Cmd.callFunc(envVars As CmdEnv)
	
	If this.pFunc <> 0 Then
		Dim As Record Ptr pLineErr = 0
		If this.pFlag <> 0 Then this.pFlag->clearTempData()
		
		/' Check each parameter '/
		Dim As Param Ptr pPar = envVars.pParam->pNext
		Dim As Flag Ptr pTempFlag
		While pPar <> 0
			/' Find flag for this parameter'/
			pTempFlag = 0
			If this.pFlag <> 0 Then pTempFlag = this.pFlag->findFlag(pPar->text)
			
			/' Makes sure parameter matches flag '/
			If pTempFlag = 0 Then
				pLineErr = New Record()
				pLineErr->addField("Cmd "+this.text)
				pLineErr->addField("Undefined parameter found")
				pLineErr->addField(pPar->text)
				envVars.pPipeErr->addRecord(pLineErr)
				Exit Sub
			EndIf
			
			/' Increment use count and find arg count '/
			pTempFlag->tempUse += 1
			pTempFlag->tempArg = pPar->valCount
			
			/' Check val count against specs '/
			If pTempFlag->tempArg < pTempFlag->minArg Then
				pLineErr = New Record()
				pLineErr->addField("Cmd "+this.text)
				pLineErr->addField("Too few values for parameter ("+Str(pTempFlag->minArg)+")")
				pLineErr->addField(pPar->text+" ("+Str(pTempFlag->tempArg)+")")
				envVars.pPipeErr->addRecord(pLineErr)
				Exit Sub
			EndIf
			If pTempFlag->tempArg > pTempFlag->maxArg And pTempFlag->maxArg<>-1 Then
				pLineErr = New Record()
				pLineErr->addField("Cmd "+this.text)
				pLineErr->addField("Too many values for parameter ("+Str(pTempFlag->maxArg)+")")
				pLineErr->addField(pPar->text+" ("+Str(pTempFlag->tempArg)+")")
				envVars.pPipeErr->addRecord(pLineErr)
				Exit Sub
			EndIf
			
			pPar = pPar->pNext
		Wend
		
		/' Check flags for proper use count '/
		pTempFlag = this.pFlag
		While pTempFlag <> 0
			If pTempFlag->tempUse < pTempFlag->minUse Then
				pLineErr = New Record()
				pLineErr->addField("Cmd "+this.text)
				pLineErr->addField("Too few uses of parameter ("+Str(pTempFlag->minUse)+")")
				pLineErr->addField(pTempFlag->lName+" ("+Str(pTempFlag->tempUse)+")")
				envVars.pPipeErr->addRecord(pLineErr)
				Exit Sub
			EndIf
			If pTempFlag->tempUse > pTempFlag->maxUse And pTempFlag->maxUse<>-1 Then
				pLineErr = New Record()
				pLineErr->addField("Cmd "+this.text)
				pLineErr->addField("Too many uses of parameter ("+Str(pTempFlag->maxUse)+")")
				pLineErr->addField(pTempFlag->lName+" ("+Str(pTempFlag->tempUse)+")")
				envVars.pPipeErr->addRecord(pLineErr)
				Exit Sub
			EndIf
			
			pTempFlag = pTempFlag->pNext
		Wend
		
		
		/' Call function if no error raised '/
		
		this.pFunc(envVars)
	EndIf
End Sub


Function lookupDomain(dirStr As String, pRoot As Domain Ptr) As Domain Ptr
	If dirStr = "" Then Return 0
	
	If dirStr = pRoot->text Then
		/' Just return root '/
		Return pRoot
	EndIf
	
	Dim As String relativeDirStr
	If dirStr[0] = DOMAIN_DELIMITER Then
		/' Ignore leading slash '/
		relativeDirStr = Right(dirStr, Len(dirStr)-1)
		
	Else
		relativeDirStr = dirStr
	EndIf
	
	/' Perform subdomain lookup from root '/
	Return pRoot->findSubDomain(relativeDirStr)
End Function


Function lookupCmd(dirStr As String, pRoot As Domain Ptr) As Cmd Ptr
	/' Get directory of command '/
	Dim As String baseDir = cutBaseDirectoryName(dirStr)
	Dim As String cmdName = cutNonBaseDirectoryName(dirStr)
	
	/' Find directory '/
	Dim As Domain Ptr pDir = lookupDomain(baseDir, pRoot)
	If pDir = 0 Then Return 0
	
	Return pDir->findCmd(cmdName)
End Function


Sub loadCommands(fileName As String, pDomain As Domain Ptr)
	/' Create big array of binding functions for commands '/
	BUILD_CMD_ARRAY_MACRO()
	
	/' Load the commands table from disk '/
	Dim As Table Ptr t = loadTableFromFile(fileName)
	
	/' Get Column ids '/
	Dim As Integer idID, nameID, domainID, infoID
	idID     = t->getColumnID_IC("id")
	nameID   = t->getColumnID_IC("name")
	domainID = t->getColumnID_IC("domain")
	infoID   = t->getColumnID_IC("info")
	
	If idID=-1 Or nameID=-1 Or domainID=-1 Or infoID=-1 Then
		Print "Error, could not load columns from file "+fileName
		Delete t
		Exit sub
	EndIf
	
	/' Loop through records '/
	Dim As Record Ptr pRec = t->pRec
	While pRec <> 0
		/' Load up fields from record '/
		Dim As Fld Ptr pIDfld     = pRec->getFieldByID(idID)
		Dim As Fld Ptr pNameFld   = pRec->getFieldByID(nameID)
		Dim As Fld Ptr pDomainFld = pRec->getFieldByID(domainID)
		Dim As Fld Ptr pInfoFld   = pRec->getFieldByID(infoID)
		
		/' Handle incomplete records '/
		If pIDfld=0 Or pNameFld=0 Or pDomainFld=0 Or pInfoFld=0 Then
			Print "Incomplete command field"
			pRec = pRec->pNext
			Continue While
		EndIf
		
		/' Create new command structure and fill in data '/
		Dim As Cmd Ptr pCmd = New Cmd()
		/' *** TODO: Link id to function table! ***'/
		pCmd->id = ValInt(pIDfld->value)
		pCmd->text = pNameFld->value
		pCmd->info = pInfoFld->value
		If pCmd->id <= UBound(CMD_BINDING_ARRAY) And pCmd->id >= LBound(CMD_BINDING_ARRAY) Then
			pCmd->pFunc = CMD_BINDING_ARRAY(pCmd->id)
		Else
			Print "Error, invalid binding id " +Str(pCmd->id)+ " for command '" +pCmd->text+ "'"
		EndIf
		
		/' Find parent domain '/
		Dim As Domain Ptr pParent = lookupDomain(pDomainFld->value, pDomain)
		If pParent = 0 Then
			Print "Error, could not find parent '" +pDomainFld->value+ "' for " +pCmd->text
			Delete pCmd
			
		Else
			pParent->addCmd(pCmd)
		EndIf
		
		pRec = pRec->pNext
	Wend
	
	
	/' Done with table '/
	Delete t
End Sub


Sub loadFlags(fileName As String, pDomain As domain Ptr)
	/' Load the flag table from disk '/
	Dim As Table Ptr t = loadTableFromFile(fileName)
	
	/' Load column header ids '/
	Dim As Integer iName    = t->getColumnID_IC("name")
	Dim As Integer iLetter  = t->getColumnID_IC("letter")
	Dim As Integer iCommand = t->getColumnID_IC("command")
	Dim As Integer iMinArg  = t->getColumnID_IC("minarg")
	Dim As Integer iMaxArg  = t->getColumnID_IC("maxarg")
	Dim As Integer iMinUse  = t->getColumnID_IC("minuse")
	Dim As Integer iMaxUse  = t->getColumnID_IC("maxuse")
	Dim As Integer iInfo    = t->getColumnID_IC("info")
	
	If iName=-1 Or iLetter=-1 Or iCommand=-1 Or iMinArg=-1 Or iMaxArg=-1 Or iMinUse=-1 Or iMaxUse=-1 Or iInfo=-1 Then
		Print "Error, could not load columns from file "+fileName
		Delete t
		Exit Sub
	EndIf
	
	
	/' Loop through records '/
	Dim As Record Ptr pRec = t->pRec
	While pRec <> 0
		/' Get record fields '/
		Dim As Fld Ptr pName    = pRec->getFieldByID(iName)
		Dim As Fld Ptr pLetter  = pRec->getFieldByID(iLetter)
		Dim As Fld Ptr pCommand = pRec->getFieldByID(iCommand)
		Dim As Fld Ptr pMinArg  = pRec->getFieldByID(iMinArg)
		Dim As Fld Ptr pMaxArg  = pRec->getFieldByID(iMaxArg)
		Dim As Fld Ptr pMinUse  = pRec->getFieldByID(iMinUse)
		Dim As Fld Ptr pMaxUse  = pRec->getFieldByID(iMaxUse)
		Dim As Fld Ptr pInfo    = pRec->getFieldByID(iInfo)
		
		If pName=-1 Or pLetter=-1 Or pCommand=-1 Or pMinArg=-1 Or pMaxArg=-1 Or pMinUse=-1 Or pMaxUse=-1 Or pInfo=-1 Then
			Print "Incomplete flag field"
			pRec = pRec->pNext
			Continue While
		EndIf
		
		/' Lookup command to bind flags '/
		Dim As Cmd Ptr pCmd = lookupCmd(pCommand->value, pDomain)
		
		If pCmd = 0 Then
			Print "Could not look up command '" +pCommand->value+ "' for flag '" +pName->value+ "'"
			pRec = pRec->pNext
			Continue While
		EndIf
		
		
		/' Create new flag structure '/
		Dim As Flag Ptr pFlag = New Flag()
		pFlag->lName = pName->value
		pFlag->sName = pLetter->value
		pFlag->minArg = ValInt(pMinArg->value)
		pFlag->maxArg = ValInt(pMaxArg->value)
		pFlag->minUse = ValInt(pMinUse->value)
		pFlag->maxUse = ValInt(pMaxUse->value)
		pFlag->info = pInfo->value
		
		/' Bind flag to command '/
		If pCmd->pFlag = 0 Then
			pCmd->pFlag = pFlag
			
		Else
			pFlag->pNext = pCmd->pFlag
			pCmd->pFlag = pFlag
		EndIf
		
		
		pRec = pRec->pNext
	Wend
	
	Delete t
End Sub
