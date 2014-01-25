#Include Once "Query.bi"

Function lookupQueryComparison(comp as String) As Function(As String, As String) As Integer
	Select Case comp
	/' String group '/
	Case "$=="
		return @TQS_EQ
		
	Case "$!="
		return @TQS_NQ
		
	Case "$<="
		return @TQS_LE
		
	Case "$>="
		return @TQS_GE
		
	Case "$<_"
		return @TQS_LT
		
	Case "$>_"
		return @TQS_GT
	
	/' Integer group '/
	Case "#=="
		return @TQI_EQ
		
	Case "#!="
		return @TQI_NQ
		
	Case "#<="
		return @TQI_LE
		
	Case "#>="
		return @TQI_GE
		
	Case "#<_"
		return @TQI_LT
		
	Case "#>_"
		return @TQI_GT
	
	/' Floating point group '/
	Case "%=="
		return @TQF_EQ
		
	Case "%!="
		return @TQF_NQ
		
	Case "%<="
		return @TQF_LE
		
	Case "%>="
		return @TQF_GE
		
	Case "%<_"
		return @TQF_LT
		
	Case "%>_"
		return @TQF_GT
	End Select
	
	Return 0
End Function


Function TQS_EQ(lhs As String, rhs As String) As Integer
	Return (lhs = rhs)
End Function


Function TQS_NQ(lhs As String, rhs As String) As Integer
	Return (lhs <> rhs)
End Function


Function TQS_LE(lhs As String, rhs As String) As Integer
	Return (lhs <= rhs)
End Function


Function TQS_GE(lhs As String, rhs As String) As Integer
	Return (lhs >= rhs)
End Function


Function TQS_LT(lhs As String, rhs As String) As Integer
	Return (lhs < rhs)
End Function


Function TQS_GT(lhs As String, rhs As String) As Integer
	Return (lhs > rhs)
End Function


Function TQI_EQ(lhs As String, rhs As String) As Integer
	Return (ValInt(lhs) = ValInt(rhs))
End Function


Function TQI_NQ(lhs As String, rhs As String) As Integer
	Return (ValInt(lhs) <> ValInt(rhs))
End Function


Function TQI_LE(lhs As String, rhs As String) As Integer
	Return (ValInt(lhs) <= ValInt(rhs))
End Function


Function TQI_GE(lhs As String, rhs As String) As Integer
	Return (ValInt(lhs) >= ValInt(rhs))
End Function


Function TQI_LT(lhs As String, rhs As String) As Integer
	Return (ValInt(lhs) < ValInt(rhs))
End Function


Function TQI_GT(lhs As String, rhs As String) As Integer
	Return (ValInt(lhs) > ValInt(rhs))
End Function


Function TQF_EQ(lhs As String, rhs As String) As Integer
	Return (Val(lhs) = Val(rhs))
End Function


Function TQF_NQ(lhs As String, rhs As String) As Integer
	Return (Val(lhs) <> Val(rhs))
End Function


Function TQF_LE(lhs As String, rhs As String) As Integer
	Return (Val(lhs) <= Val(rhs))
End Function


Function TQF_GE(lhs As String, rhs As String) As Integer
	Return (Val(lhs) >= Val(rhs))
End Function


Function TQF_LT(lhs As String, rhs As String) As Integer
	Return (Val(lhs) < Val(rhs))
End Function


Function TQF_GT(lhs As String, rhs As String) As Integer
	Return (Val(lhs) > Val(rhs))
End Function
