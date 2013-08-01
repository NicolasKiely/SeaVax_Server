/' Represents ocean and air currents '/
Type Current
	/' Direction '/
	Dim u As Single = 0
	Dim v As Single = 0
	
	/' Magnitude '/
	Dim mag As Single
	
	/' Resets magnitude according to u, v, w '/
	Declare sub getMag()
	
End Type


/' Adds two denormalized vectors. Original vectors are untouched '/
Declare Function addCurrent(lhs As Current, rhs As Current) As Current

/' Returns a unit current pointing in the same direction as a given current '/
Declare Function getUnit(oldCurrent As Current) As Current
