/'----------------------------------------------------------------------------
 ' List of parameters passed to a command
 ' Example: -param1 value1 value2 -param2 -param3 "Some stuff" -param4 value3
 ' Note that parameter 0 holds the values preceding any other parameters,
 '		ie as a value to no parameter (or as the command itself)
 ---------------------------------------------------------------------------'/

/' ASCII code for dash '/
#Define PAR_DASH 45

/' ASCII code for quote delimiter '/
#Define PAR_QUOTE 34


/' Values passed to a parameter '/
Type ParamVal
	Dim As String text
	
	/' Next node '/
	Dim As ParamVal Ptr pNext
	
	/' Recursively add a new value to the list '/
	Declare Sub rAddVal(pNewVal As ParamVal Ptr)
	
	/' debug recursive print to screen '/
	Declare Sub DEBUG_PRINT()
	
	Declare Constructor()
	Declare Destructor()
End Type


/' Linked list of parameters '/
Type Param
	/' Text value '/
	Dim As String text
	
	/' List of values for this parameter '/
	Dim As ParamVal Ptr pVals
	
	/' Number of values associated with parameter '/
	Dim As Integer valCount
	
	/' Next node '/
	Dim As Param Ptr pNext
	
	/' Recursively add a new parameter '/
	Declare Sub rAddParam(pNewParam As Param Ptr)
	
	/' Adds a value to the parameter '/
	Declare Sub addVal(pNewVal As ParamVal Ptr)
	
	/' debug recursive print to screen '/
	Declare Sub DEBUG_PRINT()

	/' Recursively looks up parameter, major is long name, minor is short name
	 Does not look up self, only children '/	
	Declare Function getParam(major As String, minor As String) As Param Ptr
	
	/' Pops parameter by name, if it exists '/
	Declare Function popParam(major As String, minor As String) As Param Ptr
	
	Declare Constructor()
	Declare Destructor()
End Type


/'----------------------------------------------------------------------------
 ' Compiles a string of parameters into a linked list
 ---------------------------------------------------------------------------'/
Declare Function compileParameters(parStr As String, pErr As Integer Ptr) As Param Ptr


Enum ParErrors
	NO_ERRORS = 0,
	EXPECTED_DASH = 1,
	EMPTY_PARAMETER_NAME = 2,
	DUPLICATE_DASH = 3,
	BUG_NULL_LAST_PAR = 4,
	UNCLOSED_QUOTE = 5
End Enum


Enum ParserState
	READING_PAR_NAME = 1,
	INTERMEDIATE = 2,
	NONQUOTE_VALUE = 3,
	QUOTE_VALUE = 4
End Enum
