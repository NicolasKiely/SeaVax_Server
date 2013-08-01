#Include Once "SaveRaw.bi"

Sub saveMap(fileName As String, pTileSet As EnvTileSet Ptr)
	Dim As Integer fh = FreeFile()
	
	/' Open file '/
	Open fileName For Output As #fh
	
	/' Version number '/
	Print #fh, 0.1
	/' Rest of header '/
	Print #fh, pTileSet->rows
	Print #fh, pTileSet->cols
	Print #fh, pTileSet->maxHeight
	Print #fh, pTileSet->maxPrecip
	Print #fh, pTileSet->maxTemp
	Print #fh, pTileSet->maxVel
	
	/' Tile records '/
	For i As Integer = 0 To pTileSet->rows*pTileSet->cols-1
		/' Get working tile '/
		Dim As EnvTile Ptr pTile = pTileSet->pTiles + i
		Print #fh, pTile->precip, pTile->temp, pTile->elev, pTile->ocean.u, pTile->ocean.v
	Next
	
	
	Close #fh
End Sub
