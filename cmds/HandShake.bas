/'----------------------------------------------------------------------------
 ' Handshake functions
 ---------------------------------------------------------------------------'/

#Include Once "FunctionList.bi"


Sub CMD_getProtocolVersion(pPipeIn As Table Ptr, pPipeOut As Table Ptr, _
		pPipeErr As Table Ptr, pParam As Param Ptr, _
		aAccount As Any Ptr, aServer As Any Ptr)
	
	pPipeOut->addToColumn("major")
	pPipeOut->addToColumn("minor")
	pPipeOut->addRecord(loadRecordFromString(!"0\t1"))
End Sub


Sub CMD_getServerVersion(pPipeIn As Table Ptr, pPipeOut As Table Ptr, _
		pPipeErr As Table Ptr, pParam As Param Ptr, _
		aAccount As Any Ptr, aServer As Any Ptr)
	
	pPipeOut->addToColumn("major")
	pPipeOut->addToColumn("minor")
	pPipeOut->addToColumn("type")
	pPipeOut->addRecord(loadRecordFromString(!"0\t1\tpre alpha"))
End Sub


Sub CMD_getModVersion(pPipeIn As Table Ptr, pPipeOut As Table Ptr, _
		pPipeErr As Table Ptr, pParam As Param Ptr, _
		aAccount As Any Ptr, aServer As Any Ptr)
	
	pPipeOut->addToColumn("mod")
	pPipeOut->addToColumn("major")
	pPipeOut->addToColumn("minor")
	pPipeOut->addToColumn("author")
	pPipeOut->addRecord(loadRecordFromString(!"vanilla\t0\t1\tNic Kiely"))
End Sub

