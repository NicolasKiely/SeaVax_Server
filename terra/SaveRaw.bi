/' Saves generated raw map data to disk '/

/' File format:
 '  Version number
 '  Rows
 '  Columns
 '  Max height
 '  Max precip
 '  Max temp
 '  Max current velocity
 '  Tile records (row major order?)
 '/
 
/' Tile record format:
 ' precip, temp, elev, current.u, current.v
 '/


#Include Once "EnvTiles.bi"


Declare Sub saveMap(fileName As String, pTileSet As EnvTileSet Ptr)