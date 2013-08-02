/'----------------------------------------------------------------------------
 ' Manages table structure. Holds relational data, also for structured
 ' I/O to file and to network. Unlike the default, linked list nodes
 ' here are added to the end of the list, not front
 ---------------------------------------------------------------------------'/


/' Field in a record '/
Type Fld
	/' Value of field '/
	Dim As String value
	
	/' Next field '/
	Dim As Fld Ptr pNext
	
	/' Recursively builds a string out of the field linked list '/
	Declare Function rToString() As String
	
	Declare Constructor()
	Declare Destructor()
End Type


/' Record in a table '/
Type Record
	/' List of fields '/
	Dim As Fld Ptr pFld
	Dim As Fld Ptr lFld
	
	/' Next record in table '/
	Dim As Record Ptr pNext
	
	/' Adds field to record. Returns 0 on success '/
	Declare Function addField(text As String) As Integer
	
	/' Returns pointer to field by column id '/
	Declare Function getFieldByID(colID As Integer) As Fld Ptr
	
	/' Dont make recursive to-string function, could overflow stack '/
	
	Declare Constructor()
	Declare Destructor()
End Type


Type Table
	/' Header, list of strings '/
	Dim As Fld Ptr pHeader
	Dim As Fld Ptr lHeader
	
	/' Columns, list of strings '/
	Dim As Fld Ptr pCol
	Dim As Fld Ptr lCol
	
	/' Records, first and last '/
	Dim As Record Ptr pRec
	Dim As Record Ptr lRec
	
	/' Number of columns and records '/
	Dim As Integer headerNum
	Dim As Integer colNum
	Dim As Integer RecNum
	
	
	/' Adds string to header. Returns 0 on success '/
	Declare Function addToHeader(text As String) As Integer
	
	/' Adds a column to table. Returns 0 on success '/
	Declare Function addToColumn(text As String) As Integer
	
	/' Adds a record to the table. Returns 0 on success '/
	Declare Function addRecord(pNewRecord As Record Ptr) As Integer
	
	/' Adds a field to the last record. Returns 0 on success '/
	Declare Function appendField(text As String) As Integer
	
	/' Returns a string representation of the table '/
	Declare Function toString() As String
	
	/' Gets column ID from name. IC = ignore case '/
	Declare Function getColumnID(columnName As String) As Integer
	Declare Function getColumnID_IC(columnName As String) As Integer
	
	/' Returns second value column for a given first-column key '/
	Declare Function findValue(key As String) As String
	
	/' Deletes record, column, and header data '/
	Declare Sub refresh()
	
	Declare Constructor()
	Declare Destructor()
End Type


/'----------------------------------------------------------------------------
 ' Loads a single table file
 ---------------------------------------------------------------------------'/
Declare Function loadTableFromFile(fileName As String) As Table Ptr


/'----------------------------------------------------------------------------
 ' Turns a tab-delimited string to a record structure
 ---------------------------------------------------------------------------'/
Declare Function loadRecordFromString(recStr As String) As Record Ptr