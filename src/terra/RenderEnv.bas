#Include Once "RenderEnv.bi"

/'
Sub drawBlock(pImg As Integer Ptr, blockSize As Integer, c As Integer, r As Integer, blockC As UInteger)
	'Line pImg, (c*blockSize, r*blockSize) - ((c+1)*blockSize-1, (r+1)*blockSize-1), blockC, BF
End Sub


Sub drawCurrent(pImg As Integer Ptr, bs As Integer, bc As UInteger, c As Integer, r As Integer, cur As Current)	
	Dim As current dirC = getUnit(cur)
	
	/' Get center coordinates '/
	Dim As Integer x1 = c*bs + 1 + Int(bs/2)
	Dim As Integer y1 = r*bs + 1 + Int(bs/2)
	
	/' Get edge coordinates '/
	Dim As Integer x2 = x1 + (dirC.u * bs) / 2
	Dim As Integer y2 = y1 + (-dirC.v * bs) / 2
	
	'Line pImg, (x1, y1) - (x2, y2), bc
	
	'PSet pImg, (x1, y1), RGB(250, 0, 0)
End Sub


sub RenderCompEnv(pTiles As EnvTileSet Ptr, pixelSize As Integer, fileName As string)
	/' Create image '/
	Dim As Integer Ptr pImg = ImageCreate(pixelSize*pTiles->cols, pixelSize*pTiles->rows, RGB(250, 0, 0), 32)
	If pImg = 0 Then Print "Error, unable to allocate memory for rendering image"
	
	/' Loop through each tile '/
	For r As Integer = 0 To pTiles->rows-1
		For c As Integer = 0 To pTiles->cols-1
			/' Get pixel color '/
			Dim As UInteger tileC = pTiles->getTile(r, c)->getColor(pTiles->maxHeight, pTiles->maxPrecip, pTiles->maxTemp)
			
			/' Draw pixel block '/
			drawBlock(pImg, pixelSize, c, r, tileC)
		Next
	Next
	
	BSave fileName+"_compImg.bmp", pImg
	
	ImageDestroy(pImg)
End Sub


Sub renderTempEnv(pTiles As EnvTileSet Ptr, pixelSize As Integer, fileName As String)
	/' Create image '/
	Dim As Integer Ptr pImg = ImageCreate(pixelSize*pTiles->cols, pixelSize*pTiles->rows, RGB(0,0,0),32)
	
	/' Loop though each tile '/
	For r As Integer = 0 To pTiles->rows-1
		For c As Integer = 0 To ptiles->cols-1
			/' Get magnitude of temperature '/
			Dim As Integer mag = pTiles->getTile(r, c)->temp * 250 / pTiles->maxTemp
			Dim As UInteger tileC
			If  pTiles->getTile(r, c)->elev <= 0 Then
				tileC = RGB(0,0,mag)
			Else
				tileC = RGB(mag,0,0)
			EndIf
			
			Line pImg, (c*pixelSize, r*pixelSize) - ((c+1)*pixelSize-1, (r+1)*pixelSize-1), tileC, BF
		Next
	Next
	
	BSave fileName+"_tempImg.bmp", pImg
	
	ImageDestroy(pImg)
End Sub


Sub renderOceanCurrent(pTiles As EnvTileSet Ptr, pixelSize As Integer, fileName As String)
	/' Create image '/
	Dim As Integer Ptr pImg = ImageCreate(pixelSize*pTiles->cols, pixelSize*pTiles->rows, RGB(0,0,0),32)
	
	For r As Integer = 0 To pTiles->rows-1
		For c As Integer = 0 To pTiles->cols-1
			/' Grab tile and current magnitude '/
			Dim As EnvTile Ptr pTile = pTiles->getTile(r, c)
			pTile->ocean.getMag()
			Dim As Single mag = pTile->ocean.mag
			Dim As Integer magC = mag*250/pTiles->maxVel
			
			Dim As UInteger blockC = RGB(magC, magC, magC)
			
			If pTile->elev >= 0 Then
				/' Above sea level, bleh '/
				drawBlock(pImg, pixelSize, c, r, RGB(255, 255, 255))
			
			Else
				drawCurrent(pImg, pixelSize, blockC, c, r, pTile->ocean)
			EndIf
		Next
	Next
	
	BSave fileName+"_OcCurImg.bmp", pImg
	ImageDestroy(pImg)
End Sub


Sub renderPrecipEnv(pTiles As EnvTileSet Ptr, pixelSize As Integer, fileName As String)
	/' Create image '/
	Dim As Integer Ptr pImg = ImageCreate(pixelSize*pTiles->cols, pixelSize*pTiles->rows, RGB(0,0,0),32)
	
	For r As Integer = 0 To pTiles->rows-1
		For c As Integer = 0 To pTiles->cols-1
			Dim As EnvTile Ptr pTile = pTiles->getTile(r, c)
			Dim As Integer mag = pTile->precip *250 / pTiles->maxPrecip
			
			If pTile->elev <= 0 Then
				/' Ocean, dont need '/
				drawBlock(pImg, pixelSize, c, r, RGB(120, 120, 120))
			Else
				/' Draw precip block '/
				drawBlock(pImg, pixelSize, c, r, RGB(0, 0, mag))
			EndIf
		Next
	Next
	
	
	BSave fileName+"_precipImg.bmp", pImg
	ImageDestroy(pImg)
End Sub
'/


Sub drawBlock(pImg As Integer Ptr, blockSize As Integer, c As Integer, r As Integer, blockC As UInteger)
End Sub

Sub drawCurrent(pImg As Integer Ptr, bs As Integer, bc As UInteger, c As Integer, r As Integer, cur As Current)
End Sub

Sub RenderCompEnv(pTiles As EnvTileSet Ptr, pixelSize As Integer, fileName As String)
End Sub

Sub renderTempEnv(pTiles As EnvTileSet Ptr, pixelSize As Integer, fileName As String)
End Sub

Sub renderOceanCurrent(pTiles As EnvTileSet Ptr, pixelSize As Integer, fileName As String)
End Sub

Sub renderPrecipEnv(pTiles As EnvTileSet Ptr, pixelSize As Integer, fileName As String)
End Sub
