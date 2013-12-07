#Include Once "EnvTiles.bi"



Function EnvTile.getColor(maxPrecip As Single, maxTemp As Single, maxElev As single) As UInteger
	/' Get coloring scale from elevation '/
	Dim As integer cElev = this.elev * 250/maxElev
	
	
	If this.elev <= 0 Then
		/' Below sea level '/
		If this.temp >= maxTemp / 2 Then
			/' Warm sea, use light blue '/
			Return RGB(0, 20, 250)
			
		Else
			/' Cold sea, use dark blue '/
			Return RGB(0, 0, 100)
		EndIf
	EndIf
	
	If this.temp >= maxTemp / 2 Then
		/' Warm '/
		If this.precip >= maxPrecip / 8 Then
			/' Wet, use green '/
			Return RGB(0, cElev, cElev/4)
			
		Else
			/' Dry, use yellow '/
			Return RGB(cElev, cElev, 0)
		EndIf
	
	Else
		/' Cold '/
		If this.precip >= maxPrecip /8 Then
			/' Wet, use grayish green '/
			Return RGB(0, cElev*2/3, 0)
			
		Else
			/' Dry, use white '/
			Return RGB(cElev, cElev, cElev)
		EndIf
	EndIf
End Function


Constructor EnvTileSet(newRows As Integer, newCols As Integer, newMaxHeight As Integer, _
								newMaxPrecip As Integer, newMaxTemp As Integer, newMaxVel As Single)
	this.rows = newRows
	this.cols = newCols
	this.maxHeight = newMaxHeight
	this.maxPrecip = newMaxPrecip
	this.maxTemp = newMaxTemp
	this.maxVel  = newMaxVel
	
	pTiles = Callocate(SizeOf(EnvTile) * this.rows * this.cols)
	
	If (this.pTiles = 0) Then
		Print "Error, could not allocate memory for env tile set"
	End If
End Constructor


Destructor EnvTileSet()
	If (pTiles <> 0) Then
		DeAllocate(pTiles)
		pTiles = 0
	End If
End Destructor


Function EnvTileSet.getTile(r As Integer, c As Integer) As EnvTile Ptr
	/' Get tile number '/
	Dim As Integer offset = r + this.rows*c
	
	If (offset < 0 Or offset >= this.rows * this.cols) Then
		Print "Error, bad env tile access (" ;r; ", " ;c; ")"
		Return 0
	EndIf
	
	Return this.pTiles + offset
End Function



Sub EnvTileSet.normalize()
	
	Dim As Single aveElev = 0
	Dim As Single totalElev = 0
	Dim As Single highest = 0
	
	/' Find total elevation as well as heighest '/
	For r As Integer = 0 To this.rows-1
		For c As Integer = 0 To this.cols-1
			Dim As Single elev = this.getTile(r, c)->elev
			totalElev += elev
			
			If (elev > highest) Then highest = elev
		Next
	Next
	
	/' Find average elevation '/
	aveElev = totalElev / (this.rows * this.cols)
	
	/' Normalize heighest '/
	highest = highest - aveElev
	
	/' Set back average to zero and scale to desired elevation '/
	For r As Integer = 0 To this.rows-1
		For c As Integer = 0 To this.cols-1
			Dim As Single elev = this.getTile(r, c)->elev
			elev = elev - aveElev
			elev = elev * maxHeight / highest
			this.getTile(r, c)->elev = elev
		Next
	Next
End Sub


Sub EnvTileSet.printStats()
	Dim As Single totalElev = 0
	Dim As Single aveElev = 0
	Dim As Single maxElev = 0
	Dim As Integer tileCount = this.rows * this.cols
	
	For r As Integer = 0 To this.rows-1
		For c As Integer = 0 To this.cols-1
			Dim As EnvTile Ptr pTile = this.getTile(r, c)
			
			/' Find elevation stats '/
			totalElev += pTile->elev
			If pTile->elev > maxElev Then maxElev = pTile->elev
		Next
	Next
	
	aveElev = totalElev / tileCount
	
	Print "Tile stats:"
	Print "  Average elevation: "; aveElev
	Print "  Highest elevation: "; maxElev
	Print "  Supposed max elevation: "; this.maxHeight
	Print "  Error #: "; err
	Print "End tile stats"
End Sub


Sub EnvTileSet.normalizeCurrents()
	Dim As Single maxOcean = 0
	
	/' Get maximum magnitudes '/
	For r As Integer = 0 To this.rows-1
		For c As Integer = 0 To this.cols-1
			Dim As EnvTile Ptr pTile = this.getTile(r, c)
			
			/' Calculate magnitude '/
			pTile->ocean.getMag()
			If (pTile->ocean.mag > maxOcean) Then maxOcean = pTile->ocean.mag
		Next
	Next
	
	/' Scale to proper max '/
	For r As Integer = 0 To this.rows-1
		For c As Integer = 0 To this.cols-1
			Dim As EnvTile Ptr pTile = this.getTile(r, c)
			
			pTile->ocean.u *= this.maxVel / maxOcean
			pTile->ocean.v *= this.maxVel / maxOcean
			pTile->ocean.mag *= this.maxVel / maxOcean
		Next
	Next
End Sub


Function EnvTileSet.calcOceanDiff(r As Integer, c As Integer) As Current
	/' To calculate the current differential D between two adjacent tiles
	 ' A and B wrt A is
	 '   D = M(k) * (B - A)
	 ' where M(k) is dependent on some tweaking coefficients and how
	 ' B and A are situated near each other
	 '/
	Dim As Current diff
	Dim As EnvTile Ptr pTile = this.getTile(r, c)
	
	/' Ignore if above sea level '/
	If pTile->elev >= 0 Then Return diff
	
	/' Evaluate surrounding tiles '/
	For dr As Integer = -1 To 1
		For dc As Integer = -1 To 1
			Dim As Current d
			
			/' Ignore center tile '/
			If dr = 0 And dc = 0 Then Continue For
			
			/' Ignore out-of-bounds tiles '/
			If r + dr >= this.rows Or r + dr < 0 Then Continue For
			If c + dc >= this.cols Or c + dc < 0 Then Continue For
			
			/' Ignore corner cases (for now?) '/
			If dr * dc <> 0 Then Continue For
			
			/' Get current '/
			Dim As Current cOff = this.getTile(r + dr, c + dc)->ocean
			
			/' Get current direction to this tile from center '/
			Dim As Integer du = dc
			Dim As Integer dv = -dr
			
			Dim As Single k1 = 1.0*Abs(du) + 0.6*Abs(dv)
			Dim As Single k2 = -du*0.6
			Dim As Single k3 = -dv*0.6
			Dim As Single k4 = 0.6*Abs(du) + 1.0*Abs(dv)
			
			'If this.getTile(r+dr, c+dc)->elev > 0 Then
				/' Handle coastal effects '/
				
			'EndIf
			
			/' Calculate differential '/
			d.u = k1*   (cOff.u - pTile->ocean.u) + k2*Abs(cOff.v - pTile->ocean.v)
			d.v = k3*Abs(cOff.u - pTile->ocean.u) + k4*   (cOff.v - pTile->ocean.v)
			
			/' Take fraction since summing across four different currents '/
			d.u /= 4
			d.v /= 4
			
			/' Sum up with other neighboring differentials '/
			diff = addCurrent(diff, d)
		Next
	Next
	
	Return diff
End Function


Function EnvTileSet.getLat(r As Integer) As Single
	Return 1 - (CSng(r) / (this.rows-1))
End Function


Sub EnvTileSet.normalizePrecip()
	Dim max As Single = 0
	
	/' Get max '/
	For r As Integer = 0 To this.rows-1
		For c As Integer = 0 To this.cols-1
			Dim As Single precip = this.getTile(r, c)->precip
			If precip > max Then max = precip
		Next
	Next
	
	/' Normalize '/
	For r As Integer = 0 To this.rows-1
		For c As Integer = 0 To this.cols-1
			this.getTile(r, c)->precip *= this.maxPrecip / max
		Next
	Next
End Sub
