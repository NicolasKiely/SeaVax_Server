#Include Once "WorldGen.bi"
#Include Once "EnvTiles.bi"
#Include Once "RenderEnv.bi"
#Include Once "SaveRaw.bi"


Function generateWorld(worldName As String) As String
	Dim As EnvTileSet tiles = EnvTileSet(WORLD_ROWS, WORLD_COLS, MAX_ELEVATION, MAX_PRECIP, MAX_TEMP, MAX_VEL)
	
	Print "Generating world: " + worldName
	
	/' Get random seed '/
	Dim As Integer randSeed = 0
	For i As Integer = 0 To Len(worldName)-1
		randSeed = randSeed + 2^(i Mod 31)*Asc(worldName, i+1)
	Next
	Randomize(randSeed)
	Print "Using random seed "; randSeed
	
	/' Calculate initial height map '/
	Print "Applying initial height map . . ."
	applyHeightMap(@tiles, INIT_HEIGHT_SPOTS)
	
	RenderCompEnv(@tiles, 4, "imgs/" + worldName + "_initHeight")
	'tiles.printStats()
	
	/' Calculate initial temperature map '/
	Print "Applying latitude and alttitude temperatures . . ."
	applyLatElevTemp(@tiles)
	renderCompEnv(@tiles, 4, "imgs/" + worldName + "_initTemp")
	renderTempEnv(@tiles, 4, "imgs/" + worldName + "_initTemp")
	
	
	/' Calculate ocean currents '/
	Print "Calculating initial ocean currents . . ."
	initOceanCurrents(@tiles, COR_FORCE)
	renderOceanCurrent(@tiles, 7, "imgs/" + worldName + "_initOc")
	
	Print "Calculating iterations of ocean currents . . ."
	iterateOceanCurrents(@tiles, COR_FORCE, 100)
	renderOceanCurrent(@tiles, 11, "imgs/" + worldName + "_iterOc")
	
	/' Do precipitation work '/
	Print "Calculating precipitation . . ."
	applyPrecipMap(@tiles, MAX_PRECIP)
	renderPrecipEnv(@tiles, 4, "imgs/" + worldName + "_precip")
	RenderCompEnv(@tiles, 4, "imgs/" + worldName + "_precip")
	
	Print "Saving . . ."
	saveMap("saves/" + worldName, @tiles)
	Print "Done generating"
	
	Return ""
End Function


Sub applyHeightMap(pTileSet As EnvTileSet Ptr, heightSpots As Integer)
	/' Loop through the number of height spots '/
	For i As Integer = 0 To heightSpots-1
		/' Generate height spots '/
		Dim As Single hR
		Dim As Single hC
		Dim As Single hH
		Dim As single hW
		
		/' Get coordinates '/
		hR = Rnd * pTileSet->rows
		hC = Rnd * pTileSet->cols
		
		/' Get width '/
		hW = Rnd * INIT_MAX_WIDTH_SPOT
		
		/' Get height '/
		Dim As Integer temp = Rnd
		If (temp < 0.45) Then
			/' Smooth plateau case, height is roughly the log of the width '/
			hH = Log(hW)
		ElseIf (temp < 0.90) Then
			/' Hilly case, height is roughly proportional to width '/
			hH = hW
		Else
			/' Anything goes case '/
			hH = Rnd * INIT_MAX_HEIGHT_SPOT
		EndIf
		
		/' Add jitter to height '/
		hH = hH + (Rnd-0.5)*0.2*hH
		
		/' Clamp '/
		If hH > INIT_MAX_HEIGHT_SPOT Then hH = INIT_MAX_HEIGHT_SPOT
		
		
		/' Work on each tile '/
		For r As Integer = 0 To pTileSet->rows-1
			For c As Integer = 0 To pTileSet->cols-1
				Dim As EnvTile Ptr pTile
				Dim As Single dist
				
				/' Get tile '/
				pTile = pTileSet->getTile(r, c)
				
				/' Get tile distance from spot '/
				Dim As Single dr2 = (r-hR)^2
				Dim As Single dc2 = (c-hC)^2
				
				dist = sqr(dr2 + dc2)
				
				pTile->elev += hillFunc(hH, hW, dist)
			Next
		Next
	Next
	
	/' Normalize '/
	pTileSet->normalize()
End Sub


Function hillFunc(hillHeight As single, hillWidth As Single, d As Single) As Single
	/' Function is y(x) ~ f(x) + g(x) '/
	Dim As Single f
	Dim As Single g
	Dim As Single y
	Dim As Single x
	
	/' Important constant to make y(x) differentiable for x > 0. Solution to ln(k)*k^2 = 1/2 '/
	Dim As Single k = 1.327864
	
	/' Get x. k/hillWidth is the inflection point of the hill, ie its "width" '/
	x = Abs(d * k / hillWidth)
	
	/' First function '/
	If x <= k Then f = (k*k) - (x*x) + 1 Else f = 0
	
	/' Second function '/
	If x > k Then g = Log(k) / Log(x) Else g = 0
	
	/' Combine and scale to height '/
	y = (f + g) * hillHeight / (k*k + 1)
	
	Return y
End Function


Sub applyLatElevTemp(pTileSet As EnvTileSet Ptr)
	For r As Integer = 0 To pTileSet->rows-1
		For c As Integer = 0 To pTileSet->cols-1
			Dim As Single elevTemp
			Dim As EnvTile Ptr pTile = pTileSet->getTile(r, c)
			
			/' Calculate latitude temperature '/
			Dim As Single latTemp = (((1+r)/pTileSet->rows)^0.35) * pTileSet->maxTemp
			
			/' Calculate elevation temperature on top of latitude temp '/
			If (pTile->elev) <= 0 Then
				/' Latitude temp is sea level temp '/
				elevTemp = latTemp
				
			Else
				/' Calculate elevation ratio to highest elevation '/
				Dim As Single elevRatio = pTile->elev / pTileSet->maxHeight
				elevTemp = latTemp * (1-0.55*elevRatio)
			EndIf
			
			pTile->temp = elevTemp
		Next
	Next
End Sub


sub initOceanCurrents(pTileSet As EnvTileSet ptr, maxCor As single)
	For r As Integer = 0 To pTileSet->rows-1
		For c As Integer = 0 To pTileSet->cols-1
			Dim As EnvTile ptr pTile = pTileSet->getTile(r, c)
			
			Dim As Single cor = (1-pTileSet->getLat(r))^2 * maxCor
			
			pTile->ocean.u = -Sqr(cor)
			pTile->ocean.v = -Sqr(Sqr(cor))
		Next
	Next
	
	pTileSet->normalizeCurrents()
End Sub


Sub iterateOceanCurrents(pTileSet As EnvTileSet Ptr, maxCor As Single, maxIter As Integer)
	/' Working copy buffer for ocean currents '/
	Dim As Current ocean(pTileSet->rows-1, pTileSet->cols-1)
	
	/' Shallow water threshold '/
	Dim As Single shallow = -pTileSet->maxHeight/10
	
	For i As Integer = 1 To maxIter
		/' Work loops '/
		For r As Integer = 0 To pTileSet->rows-1
			For c As Integer = 0 To pTileSet->cols-1
				Dim As EnvTile Ptr pTile = pTileSet->getTile(r, c)
				
				/' Ignore land terrain '/
				If pTile->elev > 0 Then Continue For
				
				/' Calculate differential '/
				Dim As Current diff = pTileSet->calcOceanDiff(r, c)
				
				Dim As Single cor = (2+pTileSet->getLat(r))/2 * maxCor
				
				/' Shear due to corealis force '/
				diff.u += -cor
				diff.v += -(cor*(pTileSet->getLat(r))^2)
				
				/' Write results to buffer '/
				ocean(r, c) = addCurrent(diff, pTile->ocean)
				
				/' Handle friction in shallow water '/
				If pTile->elev > shallow Then
					Dim coef As Single = (1+(pTile->elev / shallow))/2
					ocean(r, c).u = ocean(r, c).u * coef
					ocean(r, c).v = ocean(r, c).v * coef
				EndIf
			Next
		Next
		
		/' Copy loops '/
		For r As Integer = 0 To pTileSet->rows-1
			For c As Integer = 0 To pTileSet->cols-1
				pTileSet->getTile(r, c)->ocean = ocean(r, c)
			Next
		Next
		
		/' Normalize '/
		pTileSet->normalizeCurrents()
	Next
End Sub


Sub applyPrecipMap(pTileSet As EnvTileSet Ptr, maxPrecipLoad As single)
	For r As Integer = 0 To pTileSet->rows-1
		For c As Integer = 0 To pTileSet->cols-1
			Dim As EnvTile Ptr pTile = pTileSet->getTile(r, c)
			
			/' Dont draw precip from dry ground '/
			If (pTile->elev > 0) Then Continue For
			
			/' Dont draw precipitation from cold water '/
			If (pTile->temp < pTileSet->maxTemp/2) Then Continue For
			
			/' Water vapor payload '/
			Dim As Single precipFactor = 2*((pTile->temp / pTileSet->maxTemp)-0.5)
			Dim As Single load = (precipFactor)*maxPrecipLoad
			
			/' Get vectors from current '/
			Dim As Current v = pTile->ocean
			applyPrecipRay(pTileSet, load, r, c, v)
			v.u = -v.u
			v.v = -v.v
			applyPrecipRay(pTileSet, load, r, c, v)
		Next
	Next
	
	pTileSet->normalizePrecip()
End Sub


Sub applyPrecipRay(pTileSet As EnvTileSet Ptr, initLoad As Single, r As Integer, c As Integer, v As Current)
	Dim As Single rs = r
	Dim As Single cs = c
	Dim As Current newV = getUnit(v)
	Dim As Single load = initLoad
	Dim As EnvTile Ptr pTile
	Dim As EnvTile Ptr pOldTile = pTileSet->getTile(r, c)
	Dim As Integer radius = 3
	Dim As Integer area = (radius + 1) ^ 2
	
	For t As Integer = 0 To 100
		/' Finish if off the map '/
		If Int(rs) < 0 Or Int(rs) > pTileSet->rows-1 Then Exit For
		If Int(cs) < 0 Or Int(cs) > pTileSet->cols-1 Then Exit For
		
		/' Finish if dry '/
		If load <= pTileSet->maxPrecip/100 Then Exit For
		
		/' Get current tile '/
		pTile = pTileSet->getTile(Int(rs), Int(cs))
		
		/' Increment to directional vector '/
		rs += -newV.v
		cs +=  newV.u
		
		/' Only work on each tile once '/
		If pTile = pOldTile Then Continue For
		
		/' Get precip load to drop '/
		Dim As Single drop
		If (pTile->elev < 0) Then
			/' Dont drop over ocean, but gain some momentum '/
			drop = 0
			load *= 1.01
			
		Else
			/' Drop as a function of elevation and temperature
			 ' Cold and high = more precip fall
			 '/
			Dim As Single elevFactor = (pTile->elev / pTileSet->maxHeight)/4
			Dim As Single tempFactor = 1-(pTile->temp / pTileSet->maxTemp)
			/'
			If elevFactor > 0.5 Then
				drop = (elevFactor + (tempFactor-0.5)*(1-elevFactor))*load
			Else
				drop = (elevFactor + (tempFactor-0.5)*elevFactor)*load
			End If
			'/
			/' Scale back otherwise it mostly just dumps on the coast '/
			drop = load * (tempFactor^4)
		EndIf
		
		/' Drop load on range '/
		For r2 As Integer = -radius To radius
			For c2 As Integer = -radius To radius
				/' Get new tile '/
				Dim As Integer newR = r2 + Int(rs)
				Dim As Integer newC = c2 + Int(cs)
				
				If newR < 0 Or newR >= pTileSet->rows Then Continue For
				If newC < 0 Or newC >= pTileSet->cols Then Continue For
				
				Dim As EnvTile Ptr pNewTile = pTileSet->getTile(newR, newC)
				
				/' Drop on tile from load '/
				pNewTile->precip += (drop/area) 
				load -= (drop/area)
			Next
		Next
		
		/' Add jitter to directional vector '/
		newV.u += 0.1*(Rnd-0.5)*v.u
		newV.v += 0.1*(Rnd-0.5)*v.v
		newV = getUnit(newV)
		
		/' Update old tile '/
		pOldTile = pTile
		
	Next
End Sub
