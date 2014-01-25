/' List of query comparison functions '/

Declare Function lookupQueryComparison(comp as String) as Function(As String, As String) As Integer

/' String comparisons '/
Declare Function TQS_EQ(lhs As String, rhs As String) As Integer
Declare Function TQS_NQ(lhs As String, rhs As String) As Integer
Declare Function TQS_LE(lhs As String, rhs As String) As Integer
Declare Function TQS_GE(lhs As String, rhs As String) As Integer
Declare Function TQS_LT(lhs As String, rhs As String) As Integer
Declare Function TQS_GT(lhs As String, rhs As String) As Integer

/' Integer comparisons '/
Declare Function TQI_EQ(lhs As String, rhs As String) As Integer
Declare Function TQI_NQ(lhs As String, rhs As String) As Integer
Declare Function TQI_LE(lhs As String, rhs As String) As Integer
Declare Function TQI_GE(lhs As String, rhs As String) As Integer
Declare Function TQI_LT(lhs As String, rhs As String) As Integer
Declare Function TQI_GT(lhs As String, rhs As String) As Integer

/' Floating point comparisons '/
Declare Function TQF_EQ(lhs As String, rhs As String) As Integer
Declare Function TQF_NQ(lhs As String, rhs As String) As Integer
Declare Function TQF_LE(lhs As String, rhs As String) As Integer
Declare Function TQF_GE(lhs As String, rhs As String) As Integer
Declare Function TQF_LT(lhs As String, rhs As String) As Integer
Declare Function TQF_GT(lhs As String, rhs As String) As Integer
