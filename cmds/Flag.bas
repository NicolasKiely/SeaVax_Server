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
