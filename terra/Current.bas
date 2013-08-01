#Include Once "Current.bi"

sub Current.getMag()
	this.mag = Sqr(this.u^2 + this.v^2)
End Sub


Function addCurrent(lhs As Current, rhs As Current) As Current
	Dim res As Current
	
	res.u = lhs.u + rhs.u
	res.v = lhs.v + rhs.v
	
	Return res
End Function


Function getUnit(oldCurrent As Current) As Current
	Dim As Current newCurrent
	
	oldCurrent.getMag()
	newCurrent.u = oldCurrent.u / oldCurrent.mag
	newCurrent.v = oldCurrent.v / oldCurrent.mag
	newCurrent.mag = 1
	
	Return newCurrent
End Function
