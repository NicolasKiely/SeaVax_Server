/'----------------------------------------------------------------------------
 ' Manages table structure. Holds relational data, also for structured
 ' I/O to file and to network. Unlike the default, linked list nodes
 ' here are added to the end of the list, not front
 ---------------------------------------------------------------------------'/

/' ---------------------------------------------------------------------------
 ' String/Packet format:
 '  Header item  \t Header item  \t . . .  Header item \n
 '  Column name  \t Column name  \t . . .  Column name \n
 '  Record field \t Record field \t . . . Record field \t
 '  Record field \t Record field \t . . . Record field \t
 '  . . .
 '  Record field \t Record field \t . . . Record field \n
 '
 ' 3 packet chunks, all capped with a newline. Next table starts after last newline
 ' First packet chunk: Header
 '   List of tab-separated fields containing metadata for table. N total fields
 ' Second packet chunk: Columns
 '   Column names for records. List of tab-separated fields. M total fields
 ' Third Packet chunk: Records
 '   Row-major list of tab-separated fields of L records. L*M total fields
 ---------------------------------------------------------------------------'/

/' Newline '/
#Define ASC_TABLE_DELIMITER 10
#Define CHR_TABLE_DELIMITER (Chr(ASC_TABLE_DELIMITER))
/' Tab '/
#Define ASC_FIELD_DELIMITER 9
#Define CHR_FIELD_DELIMITER (Chr(ASC_FIELD_DELIMITER))

/' Field in a record '/
Type Fld
	/' Value of field '/
	Dim As String value
	
	/' Next field '/
	Dim As Fld Ptr pNext
	
	/' Recursively builds a string out of the field linked list '/
	Declare Function rToString(fldDel As String = CHR_TABLE_DELIMITER) As String
	
	/' Recursively builds a string out of fields, breaks up across lines '/
	Declare Function rToDivString(div As Integer, counter As Integer = 0) As String
	
	/' Returns number of fields in list '/
	Declare Function getNumberOfFields() As Integer
	
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
	
	/' Returns a formatted string representation of the table '/
	Declare Function toPrettyString() As String
	
	/' Gets column ID from name. IC = ignore case '/
	Declare Function getColumnID(columnName As String) As Integer
	Declare Function getColumnID_IC(columnName As String) As Integer
	
	/' Returns second value column for a given first-column key '/
	Declare Function findValue(key As String) As String
	
	/' Saves table to disk '/
	Declare Sub save(fileName As String)
	
	/' Deletes record, column, and header data '/
	Declare Sub refresh()
	
	Declare Function getNumberOfColumns() As Integer
	
	Declare Constructor()
	Declare Destructor()
End Type


/'----------------------------------------------------------------------------
 ' Loads a single table file
 ---------------------------------------------------------------------------'/
Declare Function loadTableFromFile(fileName As String, pTable As Table Ptr = 0) As Table Ptr


/'----------------------------------------------------------------------------
 ' Turns a tab-delimited string to a record structure
 ---------------------------------------------------------------------------'/
Declare Function loadRecordFromString(recStr As String) As Record Ptr